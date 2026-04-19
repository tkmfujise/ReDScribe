#!/usr/bin/env python
import os
import sys

from methods import print_error


libname = "redscribe"
projectdir = "demo"
mruby_build_name = ARGUMENTS.get("mruby_config", os.environ.get("MRUBY_CONFIG_NAME", "host"))

mruby_include_path = f"mruby/build/{mruby_build_name}/include"
mruby_library_path = f"mruby/build/{mruby_build_name}/lib"

localEnv = Environment(tools=["default"], PLATFORM="")

customs = ["custom.py"]
customs = [os.path.abspath(path) for path in customs]

opts = Variables(customs, ARGUMENTS)
opts.Update(localEnv)

Help(opts.GenerateHelpText(localEnv))

env = localEnv.Clone()

# mruby
env.Append(CPPPATH=[mruby_include_path])
env.Append(LIBPATH=[mruby_library_path])
env.Append(LIBS=["libmruby"])

# for Windows
if (os.name != 'posix'):
    env.Append(LIBS=["Ws2_32"])


submodule_initialized = False
dir_name = 'godot-cpp'
if os.path.isdir(dir_name):
    if os.listdir(dir_name):
        submodule_initialized = True

if not submodule_initialized:
    print_error("""godot-cpp is not available within this folder, as Git submodules haven't been initialized.
Run the following command to download godot-cpp:

    git submodule update --init --recursive""")
    sys.exit(1)

env = SConscript("godot-cpp/SConstruct", {"env": env, "customs": customs})

env.Append(CPPPATH=["src/"])
sources = Glob("src/*.cpp")

if env["target"] in ["editor", "template_debug"]:
    try:
        doc_data = env.GodotCPPDocData("src/gen/doc_data.gen.cpp", source=Glob("doc_classes/*.xml"))
        sources.append(doc_data)
    except AttributeError:
        print("Not including class reference as we're targeting a pre-4.3 baseline.")

file = "{}{}{}".format(libname, env["suffix"], env["SHLIBSUFFIX"])
filepath = ""
library_builder = env.SharedLibrary
install_name = "lib{}".format(file)
library_output = None

if env["platform"] == "macos":
    filepath = "{}.framework/".format(env["platform"])
    file = "{}{}".format(libname, env["suffix"])
    install_name = "lib{}".format(file)
elif env["platform"] == "ios":
    file = "{}{}".format(libname, env["suffix"])
    library_builder = env.StaticLibrary
    install_name = "lib{}.a".format(file)

libraryfile = "bin/{}/{}{}".format(env["platform"], filepath, file)
library_target = libraryfile
if env["platform"] == "ios":
    library_target = "bin/{}/intermediate/{}".format(env["platform"], install_name)

library = library_builder(
    library_target,
    source=sources,
)

if env["platform"] == "ios":
    godot_cpp_lib = "godot-cpp/bin/libgodot-cpp{}{}".format(env["suffix"], env["LIBSUFFIX"])
    mruby_lib = "{}/libmruby.a".format(mruby_library_path)
    library_output = env.Command(
        "bin/{}/{}".format(env["platform"], install_name),
        [library, godot_cpp_lib, mruby_lib],
        [
            Delete("$TARGET"),
            "libtool -static -o $TARGET $SOURCES",
        ],
    )
else:
    library_output = library

copy = env.InstallAs("{}/addons/redscribe/bin/{}/{}{}".format(projectdir, env["platform"], filepath, install_name), library_output)

default_args = [library_output, copy]
Default(*default_args)
