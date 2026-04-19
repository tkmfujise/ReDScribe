# ReDScribe agent instructions

## Build and test commands

- `rake` builds the embedded mruby static library first, then runs `scons` for the host debug GDExtension build.
- `rake release` builds mruby, then runs `scons target=template_release`.
- `rake mruby_build` rebuilds only mruby from `mruby/` using `build_config/*.rb`. On macOS this produces separate arm64/x86_64 builds and merges them with `lipo`.
- `rake test` runs the Godot GUT suite from `demo/` via `godot -s addons/gut/gut_cmdln.gd -d -gexit`.
- Run a single test file with `cd demo && godot -s addons/gut/gut_cmdln.gd -d -gexit -gtest=res://test/gdextension/test_variant.gd`.
- Run a single test case with `cd demo && godot -s addons/gut/gut_cmdln.gd -d -gexit -gtest=res://test/test_main.gd -gunit_test_name=test_ready`.
- `rake doc` regenerates `doc_classes/*.xml` from the demo project with Godot doctool.
- No dedicated lint task is wired into the repo today.

## High-level architecture

- The native extension lives in `src/`. `ReDScribe` is a `Resource` that owns a single `mrb_state`, exposes `perform`/`boot_file`, converts mruby values into Godot `Variant`s, and bridges Ruby back into Godot through the `method_missing` and `channel` signals.
- The Ruby-side bridge is defined in `src/redscribe.cpp`: it installs `Godot.emit_signal`, `puts`, and `require` into mruby. `require` always resolves through `res://...` and tracks loaded paths in `required_paths` to avoid duplicate loads.
- `register_types.cpp` registers both `ReDScribe` and `ReDScribeEntry` with Godot. `ReDScribeEntry` is the editor-facing resource type used to make `.rb` files editable in the plugin UI.
- `SConstruct` links the GDExtension against `godot-cpp` and the mruby static library, then installs the built library into `demo/addons/redscribe/bin/<platform>/...`. The `demo/` project is the canonical integration environment, not just an example app.
- The editor plugin lives under `demo/addons/redscribe/`. `redscribe.gd` mounts the main screen, `src/main/main.gd` switches between the editor and REPL tabs, `src/editor/editor_area.gd` handles file IO for `.rb` sources, and `src/repl/repl.gd` runs interactive Ruby by wrapping input in `Godot.emit_signal :repl, (...)`.
- `.rb` files are treated as Godot resources by `demo/addons/redscribe/ext/redscribe_entry_loader.gd`, which reports them as `ReDScribeEntry` so Quick Open and `EditorInterface.edit_resource(load(path))` route Ruby files into the addon editor flow.

## Key conventions

- For addon/editor changes, start from `demo/addons/redscribe/`; for engine/runtime changes, start from `src/`. Most user-visible behavior crosses both layers.
- Treat `demo/` as the source of truth for manual testing, packaging, and automated tests. The packaged addon is copied into `demo/addons/redscribe`, and `rake package` archives from there.
- Ruby scripts should be referenced with project-relative paths like `require 'addons/redscribe/mrblib/actor'`; the native `require` implementation prepends `res://` and appends `.rb` when missing.
- Runtime failures are surfaced through the `ReDScribe.exception` property after `perform(...)`. GDScript callers usually inspect that property instead of expecting Godot exceptions to be raised.
- After creating or saving files from plugin code, rescan the Godot resource filesystem (`EditorInterface.get_resource_filesystem().scan()`). The editor code relies on this to make new or updated resources visible immediately.
- The GUT suite is configured by `demo/.gutconfig.json`: tests live under `res://test/`, use the `test_` prefix, and include subdirectories by default.
