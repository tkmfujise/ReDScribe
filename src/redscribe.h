#ifndef REDSCRIBE_H
#define REDSCRIBE_H

#include <godot_cpp/classes/resource.hpp>

#include <mruby.h>

namespace godot {

class ReDScribe : public Resource {
  GDCLASS(ReDScribe, Resource)
  
private:
  mrb_state* mrb;
  void set_exception(const String &p_exception);
  String get_exception() const;

protected:
  static void _bind_methods();

public:
  ReDScribe();
  ~ReDScribe();

  String boot_file = "";
  void set_boot_file(const String &p_boot_file);
  String get_boot_file() const;

  String exception = "";

  void perform(const String &dsl);
};

}

#endif
