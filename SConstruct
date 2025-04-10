#!/usr/bin/env python
import os
import sys

from methods import print_error


libname = "redscribe"
projectdir = "demo"

mruby_include_path = "mruby/build/host/include"
mruby_library_path = "mruby/build/host/lib"

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

# リンカフラグの追加
# env.Append(LINKFLAGS=["/NODEFAULTLIB:MSVCRT"])
# env.Append(LINKFLAGS=["/VERBOSE:LIB"])
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

if env["platform"] == "macos" or env["platform"] == "ios":
    filepath = "{}.framework/".format(env["platform"])
    file = "{}{}".format(libname, env["suffix"])

libraryfile = "bin/{}/{}{}".format(env["platform"], filepath, file)
library = env.SharedLibrary(
    libraryfile,
    source=sources,
)

copy = env.InstallAs("{}/bin/{}/{}lib{}".format(projectdir, env["platform"], filepath, file), library)

default_args = [library, copy]
Default(*default_args)
