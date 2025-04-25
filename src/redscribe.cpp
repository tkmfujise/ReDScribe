#include "redscribe.h"
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/classes/engine.hpp>
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
static mrb_value method_missing(mrb_state *mrb, mrb_value self);
static void mrb_define_utility_methods(mrb_state *mrb);
Variant mrb_variant(mrb_state *mrb, mrb_value value);


void ReDScribe::_bind_methods() {
  ClassDB::bind_method(D_METHOD("perform", "dsl"), &ReDScribe::perform);

  ClassDB::bind_method(D_METHOD("set_exception", "exception"), &ReDScribe::set_exception);
  ClassDB::bind_method(D_METHOD("get_exception"), &ReDScribe::get_exception);
  ADD_PROPERTY(PropertyInfo(Variant::STRING, "exception"), "set_exception", "get_exception");

  ADD_SIGNAL(MethodInfo("method_missing", 
    PropertyInfo(Variant::STRING, "method_name"),
    PropertyInfo(Variant::ARRAY,  "args"))
  );
  ADD_SIGNAL(MethodInfo("channel", 
    PropertyInfo(Variant::STRING, "name"),
    PropertyInfo(Variant::NIL,    "payload"))
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

  Variant godot_key   = mrb_variant(mrb, key);
  Variant godot_value = mrb_variant(mrb, value);

  dict->operator[](godot_key) = godot_value;

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
    return String(mrb_sym2name(mrb, mrb_symbol(value)));
  case MRB_TT_STRING:
    return String(mrb_str_to_cstr(mrb, value));
  case MRB_TT_HASH:
    return mrb_hash_variant(mrb, value);
  case MRB_TT_ARRAY: {
    Array godot_array;
    mrb_int len = RARRAY_LEN(value);
    for (mrb_int i = 0; i < len; i++) {
      mrb_value element = mrb_ary_entry(value, i);
      godot_array.append(mrb_variant(mrb, element));
    }
    return godot_array;
  }
  default:
    return Variant();
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
                          String(mrb_sym2name(mrb, key)),
                          mrb_variant(mrb, payload));
  }
  return mrb_true_value();
}


String get_godot_version() {
  Dictionary version_info = Engine::get_singleton()->get_version_info();
  int major     = version_info["major"];
  int minor     = version_info["minor"];
  String status = version_info["status"];
  return String("v{0}.{1}.{2}").format(Array::make(major, minor, status));
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
}


static mrb_value
method_missing(mrb_state *mrb, mrb_value self)
{
  mrb_sym method_name;
  mrb_value *args;
  mrb_int arg_count;

  mrb_get_args(mrb, "n*", &method_name, &args, &arg_count);

  String method_name_str = String(mrb_sym2name(mrb, method_name));

  ReDScribe *instance = get_gdcontext();

  if (instance) {
    Array godot_args;
    for (mrb_int i = 0; i < arg_count; i++) {
      godot_args.append(mrb_variant(mrb, args[i]));
    }
    
    instance->emit_signal("method_missing", method_name_str, godot_args);
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
    exception = "error";
  } else {
    exception = "";
  }
}


