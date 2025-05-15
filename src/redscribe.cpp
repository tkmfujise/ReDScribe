#include "redscribe.h"
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/classes/engine.hpp>
#include <godot_cpp/classes/file_access.hpp>
#include <godot_cpp/variant/utility_functions.hpp>

#include <mruby.h>
#include <mruby/compile.h>
#include <mruby/data.h>
#include <mruby/variable.h>
#include <mruby/string.h>
#include <mruby/hash.h>
#include <mruby/array.h>


using namespace godot;

#define PRINT(s) UtilityFunctions::print(s)

ReDScribe *gd_context = nullptr;

void set_gdcontext(ReDScribe *r);
static ReDScribe* get_gdcontext(void);
static void mrb_define_godot_module(mrb_state *mrb);
static bool mrb_execute_file(mrb_state *mrb, String path);
static mrb_value require(mrb_state *mrb, mrb_value self);
static mrb_value method_missing(mrb_state *mrb, mrb_value self);
static void mrb_define_utility_methods(mrb_state *mrb);
Variant mrb_variant(mrb_state *mrb, mrb_value value);


void ReDScribe::_bind_methods() {
  ClassDB::bind_method(D_METHOD("perform", "dsl"), &ReDScribe::perform);

  ClassDB::bind_method(D_METHOD("set_boot_file", "boot_file"), &ReDScribe::set_boot_file);
  ClassDB::bind_method(D_METHOD("get_boot_file"), &ReDScribe::get_boot_file);
  ADD_PROPERTY(PropertyInfo(Variant::STRING, "boot_file", PROPERTY_HINT_FILE, "*.rb"), "set_boot_file", "get_boot_file");

  ClassDB::bind_method(D_METHOD("set_exception", "exception"), &ReDScribe::set_exception);
  ClassDB::bind_method(D_METHOD("get_exception"), &ReDScribe::get_exception);
  ADD_PROPERTY(PropertyInfo(Variant::STRING, "exception"), "set_exception", "get_exception");

  ADD_SIGNAL(MethodInfo("method_missing",
    PropertyInfo(Variant::STRING, "method_name"),
    PropertyInfo(Variant::ARRAY,  "args"))
  );
  ADD_SIGNAL(MethodInfo("channel",
    PropertyInfo(Variant::STRING_NAME, "key"),
    PropertyInfo(Variant::NIL,         "payload"))
  );
}

ReDScribe::ReDScribe() {
  mrb = mrb_open();
  if (!mrb) {
    // handle error
    return;
  }
  set_gdcontext(this);
  struct RClass* base_class = mrb->object_class;

  mrb_define_godot_module(mrb);
  mrb_define_utility_methods(mrb);
  mrb_define_method(mrb, base_class, "method_missing", method_missing, MRB_ARGS_ANY());
}

ReDScribe::~ReDScribe() {
  if (mrb) {
    mrb_close(mrb);
  }
}


void ReDScribe::set_boot_file(const String &p_boot_file) {
  boot_file = p_boot_file;
  if (!boot_file.is_empty()) {
    mrb_execute_file(mrb, boot_file);
  }
}

String ReDScribe::get_boot_file() const {
  return boot_file;
}

void ReDScribe::set_exception(const String &p_exception) {
  exception = p_exception;
}

String ReDScribe::get_exception() const {
  return exception;
}

static int
mrb_hash_variant_set(mrb_state *mrb, mrb_value key, mrb_value value, void *data)
{
  Dictionary *dict = static_cast<Dictionary *>(data);

  Variant gd_key   = mrb_variant(mrb, key);
  Variant gd_value = mrb_variant(mrb, value);

  dict->operator[](gd_key) = gd_value;

  return 0; // 継続
}


Dictionary
mrb_hash_variant(mrb_state *mrb, mrb_value hash)
{
  Dictionary dict;

  if (mrb_hash_p(hash)) {
    struct RHash *hash_ptr = mrb_hash_ptr(hash);
    mrb_hash_foreach(mrb, hash_ptr, mrb_hash_variant_set, &dict);
  }

  return dict;
}


Dictionary
mrb_time_variant(mrb_state *mrb, mrb_value value)
{
  Dictionary dict;
  dict["year"]   = mrb_integer(mrb_funcall(mrb, value, "year", 0));
  dict["month"]  = mrb_integer(mrb_funcall(mrb, value, "month", 0));
  dict["day"]    = mrb_integer(mrb_funcall(mrb, value, "day", 0));
  dict["hour"]   = mrb_integer(mrb_funcall(mrb, value, "hour", 0));
  dict["minute"] = mrb_integer(mrb_funcall(mrb, value, "min", 0));
  dict["second"] = mrb_integer(mrb_funcall(mrb, value, "sec", 0));
  return dict;
}


Variant
mrb_inspect_variant(mrb_state *mrb, mrb_value value)
{
  mrb_value ipt = mrb_funcall(mrb, value, "inspect", 0);
  return String::utf8(mrb_string_value_ptr(mrb, ipt));
}


Variant
mrb_variant(mrb_state *mrb, mrb_value value)
{
  switch (mrb_type(value)) {
  case MRB_TT_TRUE:
    return true;
  case MRB_TT_FALSE:
    if (mrb_nil_p(value)) {
      return Variant();
    }
    return false;
  case MRB_TT_INTEGER:
    return mrb_integer(value);
  case MRB_TT_FLOAT:
    return mrb_float(value);
  case MRB_TT_SYMBOL:
    return StringName(mrb_sym2name(mrb, mrb_symbol(value)));
  case MRB_TT_STRING:
    return String::utf8(mrb_string_value_ptr(mrb, value));
  case MRB_TT_HASH:
    return mrb_hash_variant(mrb, value);
  case MRB_TT_ARRAY: {
    Array gd_array;
    mrb_int len = RARRAY_LEN(value);
    for (mrb_int i = 0; i < len; i++) {
      mrb_value item = mrb_ary_entry(value, i);
      gd_array.append(mrb_variant(mrb, item));
    }
    return gd_array;
  }
  case MRB_TT_RANGE: {
    mrb_value arr = mrb_funcall(mrb, value, "to_a", 0);
    return mrb_variant(mrb, arr);
  }
  case MRB_TT_DATA: {
    // Time
    if (mrb_obj_is_kind_of(mrb, value, mrb_class_get(mrb, "Time"))) {
      return mrb_time_variant(mrb, value);
    }
    return mrb_inspect_variant(mrb, value);
  }
  default:
    return mrb_inspect_variant(mrb, value);
  }
}


static mrb_value
emit_signal(mrb_state *mrb, mrb_value self)
{
  mrb_sym key;
  mrb_value payload;
  mrb_get_args(mrb, "no", &key, &payload);

  ReDScribe *instance = get_gdcontext();
  if (instance) {
    instance->emit_signal("channel",
                          String::utf8(mrb_sym2name(mrb, key)),
                          mrb_variant(mrb, payload));
  }
  return mrb_true_value();
}


String get_godot_version() {
  Dictionary version_info = Engine::get_singleton()->get_version_info();
  int major     = version_info["major"];
  int minor     = version_info["minor"];
  int patch     = version_info["patch"];
  String status = version_info["status"];
  return String::utf8("v{0}.{1}.{2}.{3}").format(Array::make(major, minor, patch, status));
}


static void
mrb_define_godot_module(mrb_state *mrb)
{
  struct RClass *godot_module;
  godot_module = mrb_define_module(mrb, "Godot");
  mrb_define_const(mrb, godot_module, "VERSION",
                   mrb_str_new_cstr(mrb, get_godot_version().utf8().get_data()));
  mrb_define_class_method(mrb, godot_module, "emit_signal", emit_signal, MRB_ARGS_REQ(2));
}


static mrb_value
puts(mrb_state *mrb, mrb_value self)
{
  mrb_value *args;
  mrb_int arg_count;

  mrb_get_args(mrb, "*", &args, &arg_count);
  for (mrb_int i = 0; i < arg_count; i++) {
    PRINT(mrb_variant(mrb, args[i]));
  }

  return mrb_nil_value();
}


static void
mrb_define_utility_methods(mrb_state *mrb)
{
  struct RClass* base_class = mrb->object_class;
  mrb_define_method(mrb, base_class, "puts", puts, MRB_ARGS_ANY());
  mrb_define_method(mrb, base_class, "require", require, MRB_ARGS_REQ(1));
}


static bool
mrb_execute_file(mrb_state *mrb, String path)
{
  Ref<FileAccess> file = FileAccess::open(path, FileAccess::ModeFlags::READ);
  if (file.is_valid()) {
    String content = file->get_as_text();
    mrb_load_string(mrb, content.utf8().get_data());
    return true;
  } else {
    PRINT("cannot load such file -- " + path);
    return false;
  }
}


static mrb_value
require(mrb_state *mrb, mrb_value self)
{
  mrb_value path;

  mrb_get_args(mrb, "S", &path);
  String gd_path = "res://" + String(mrb_variant(mrb, path));
  if (gd_path.get_extension().is_empty()) {
    gd_path += ".rb";
  }
  if (mrb_execute_file(mrb, gd_path)) {
    return mrb_true_value();
  }
  return mrb_false_value();
}

static mrb_value
method_missing(mrb_state *mrb, mrb_value self)
{
  mrb_sym method_name;
  mrb_value *args;
  mrb_int arg_count;

  mrb_get_args(mrb, "n*", &method_name, &args, &arg_count);

  String method_name_str = String::utf8(mrb_sym2name(mrb, method_name));

  ReDScribe *instance = get_gdcontext();

  if (instance) {
    Array gd_args;
    for (mrb_int i = 0; i < arg_count; i++) {
      gd_args.append(mrb_variant(mrb, args[i]));
    }

    instance->emit_signal("method_missing", method_name_str, gd_args);
  }

  return mrb_nil_value();
}


void set_gdcontext(ReDScribe *r) {
  gd_context = r;
}

static ReDScribe* get_gdcontext(void) {
  return gd_context;
}

void clear_gdcontext(void) {
  gd_context = nullptr;
}


void ReDScribe::perform(const String &dsl) {
  mrb_load_string(mrb, dsl.utf8().get_data());
  if (mrb->exc) {
    mrb_value exc = mrb_obj_value(mrb->exc);
    mrb_value inspect = mrb_inspect(mrb, exc);
    exception = mrb_variant(mrb, inspect);
  } else {
    exception = "";
  }
}

