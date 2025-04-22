#include "redscribe.h"
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/utility_functions.hpp>

#include <mruby.h>
#include <mruby/compile.h>
#include <mruby/data.h>
#include <mruby/variable.h>
#include <mruby/string.h>


using namespace godot;

#define PRINT(s) UtilityFunctions::print(s)

ReDScribe *gd_context = nullptr;

void set_gdcontext(ReDScribe *r);
static ReDScribe* get_gdcontext(void);
static mrb_value method_missing(mrb_state *mrb, mrb_value self);


void ReDScribe::_bind_methods() {
  ClassDB::bind_method(D_METHOD("perform", "dsl"), &ReDScribe::perform);

  ClassDB::bind_method(D_METHOD("set_exception", "exception"), &ReDScribe::set_exception);
  ClassDB::bind_method(D_METHOD("get_exception"), &ReDScribe::get_exception);
  ADD_PROPERTY(PropertyInfo(Variant::STRING, "exception"), "set_exception", "get_exception");

  ADD_SIGNAL(MethodInfo("method_missing", 
    PropertyInfo(Variant::STRING, "method_name"))
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


static mrb_value
method_missing(mrb_state *mrb, mrb_value self)
{
  mrb_sym method_name;
  mrb_value *args;
  mrb_int arg_count;

  mrb_get_args(mrb, "n*", &method_name, &args, &arg_count);

  const char *method_name_str = mrb_sym2name(mrb, method_name);

  ReDScribe *instance = get_gdcontext();

  if (instance) {
    instance->emit_signal("method_missing", String(method_name_str));
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


