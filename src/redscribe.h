#ifndef REDSCRIBE_H
#define REDSCRIBE_H

#include <godot_cpp/classes/resource.hpp>

namespace godot {

class ReDScribe : public Resource {
  GDCLASS(ReDScribe, Resource)
  
private:
  char *code;

protected:
  static void _bind_methods();

public:
  ReDScribe();
  ~ReDScribe();

  void test_ruby();
};

}

#endif
