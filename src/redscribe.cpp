#include "redscribe.h"
#include <godot_cpp/core/class_db.hpp>

#include <mruby.h>
#include <mruby/compile.h>
#include <mruby/data.h>
#include <mruby/string.h>


using namespace godot;


void ReDScribe::_bind_methods() {
  ClassDB::bind_method(D_METHOD("execute_dsl"), &ReDScribe::execute_dsl);

  ClassDB::bind_method(D_METHOD("set_dsl", "dsl"), &ReDScribe::set_dsl);
  ClassDB::bind_method(D_METHOD("get_dsl"), &ReDScribe::get_dsl);
  ADD_PROPERTY(PropertyInfo(Variant::STRING, "dsl"), "set_dsl", "get_dsl");

  ClassDB::bind_method(D_METHOD("set_dsl_error", "dsl_error"), &ReDScribe::set_dsl_error);
  ClassDB::bind_method(D_METHOD("get_dsl_error"), &ReDScribe::get_dsl_error);
  ADD_PROPERTY(PropertyInfo(Variant::STRING, "dsl_error"), "set_dsl_error", "get_dsl_error");
}

ReDScribe::ReDScribe() {
  // initialize
}

ReDScribe::~ReDScribe() {
  // cleanup
}


void ReDScribe::set_dsl(const String &p_dsl) {
  dsl = p_dsl;
}

String ReDScribe::get_dsl() const {
  return dsl;
}

void ReDScribe::set_dsl_error(const String &p_dsl_error) {
  dsl_error = p_dsl_error;
}

String ReDScribe::get_dsl_error() const {
  return dsl_error;
}


static mrb_value
method_missing(mrb_state *mrb, mrb_value self)
{
  mrb_sym method_name;
  mrb_value *args;
  mrb_int arg_count;

  mrb_get_args(mrb, "n*", &method_name, &args, &arg_count);

  const char *method_name_str = mrb_sym2name(mrb, method_name);

  return mrb_str_new_cstr(mrb, "method not found: ");
}


void ReDScribe::execute_dsl() {
  mrb_state* mrb = mrb_open();
  if (!mrb) {
    // handle error
    return;
  }

  struct RClass* base_class = mrb->object_class;

  mrb_define_method(mrb, base_class, "method_missing", method_missing, MRB_ARGS_ANY());

  mrb_load_string(mrb, dsl.utf8().get_data());
  if (mrb->exc) {
    dsl_error = "error";
  } else {
    dsl_error = "";
  }
  mrb_close(mrb);
}


