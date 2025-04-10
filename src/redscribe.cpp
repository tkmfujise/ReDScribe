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

void ReDScribe::test_ruby() {
  mrb_state* mrb = mrb_open();
  if (!mrb) {
    // handle error
    return;
  }

  mrb_load_string(mrb, "1+1");
  mrb_close(mrb);
}
