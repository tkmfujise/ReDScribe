#include "redscribe.h"
#include <godot_cpp/core/class_db.hpp>

#include <mruby.h>
#include <mruby/compile.h>

using namespace godot;

void ReDScribe::_bind_methods() {
  ClassDB::bind_method(D_METHOD("test_ruby"), &ReDScribe::test_ruby);
}

ReDScribe::ReDScribe() {
  // initialize
}

ReDScribe::~ReDScribe() {
  // cleanup
}


static mrb_value
mrb_foo_bar(mrb_state *mrb, mrb_value recv)
{
  return mrb_fixnum_value(1);
}

void ReDScribe::test_ruby() {
  mrb_state* mrb = mrb_open();
  if (!mrb) {
    // handle error
    return;
  }

  struct RClass *r = mrb_define_module(mrb, "Foo");
  mrb_define_module_function(mrb, r, "bar", mrb_foo_bar, MRB_ARGS_NONE());
  
  mrb_load_string(mrb, "Foo.bar");
  mrb_close(mrb);
}
