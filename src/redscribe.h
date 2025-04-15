#ifndef REDSCRIBE_H
#define REDSCRIBE_H

#include <godot_cpp/classes/resource.hpp>

#include <mruby.h>

namespace godot {

class ReDScribe : public Resource {
  GDCLASS(ReDScribe, Resource)
  
private:
  void set_dsl_error(const String &p_dsl_error);
  String get_dsl_error() const;

protected:
  static void _bind_methods();

public:
  ReDScribe();
  ~ReDScribe();

  String dsl = "";
  String dsl_error = "";

  void set_dsl(const String &p_dsl);
  String get_dsl() const;

  void execute_dsl();
};

}

#endif
