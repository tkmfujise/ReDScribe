#ifndef REDSCRIBE_ENTRY_H
#define REDSCRIBE_ENTRY_H

#include <godot_cpp/classes/resource.hpp>

namespace godot {

class ReDScribeEntry : public Resource {
  GDCLASS(ReDScribeEntry, Resource)

protected:
  static void _bind_methods();

public:
  ReDScribeEntry();
  ~ReDScribeEntry();
};

}

#endif

