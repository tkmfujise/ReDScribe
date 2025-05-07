# GDScript Input Field Plugin

This is a plugin for Godot 4 that adds a GDScript input field
to the bottom of the editor output panel.

## Installation

Copy the directory `addons/gdscript_input_field`
into the directory `[your project]/addons`,
such that you wind up with `[your project]/addons/gdscript_input_field`.

You can then enable or disable the plugin in Godot under
`Project -> Project Settings... -> Plugins`.

Enabling it should place a new input field in the `Output` panel,
underneath `Filter Messages`, with the placeholder text
`Evaluate GDScript`.

## Usage

The field functions like a REPL: you may type a GDScript expression
or statement there and then Enter, and the expression or statement
will be consumed and evaluated, and its result printed to the log above.

### Multiline input

To break the line without submitting, hold Shift while pressing Enter.
In this way, you can submit multiline expressions or block statements.
These should be properly indented.

### History

Past inputs are memorized. To navigate them, press Up
to go backward in history, or Down to go forward in history.
**You will lose the current input buffer when doing this.**
If your input buffer is currently multiline, Up and Down unmodified
are reserved for navigating the input buffer, as is more intuitive,
and so to navigate history in this case, you will need to hold Ctrl.

### Declaring variables

You can declare a variable with `var`, e.g. `var my_var`.
You may specify an initial value, e.g. `var my_var = 'foo'`,
but you don't have to. Your variable can be `static`,
but this is probably not useful.

For a variable to persist between inputs,
the `var` declaration must be the only statement in its input snippet.
If any other statements accompany it,
then the declaration will run in function context,
and so it will be interpreted as local.

### Declaring classes

You can declare inner classes. For example:

```
class Foo:
	var bar
```

An inner class declaration should be isolated in its input snippet.
If the input snippet contains code preceding the inner class declaration,
then the declaration will run in function context, and so it will be invalid,
as you cannot declare a class inside a function.

### Declaring functions

You can declare functions. For example:

```
func foo(x):
	return x**2
```

A function declaration should be isolated in its input snippet.
If the input snippet contains code preceding the function declaration,
then your code will be run in function context, and so it will be invalid,
as you cannot declare a function inside another function.

### Redeclaring symbols

Unlike in non-interactive GDScript, you can redeclare symbols
and change what kind of declaration they are. For example,
even if you've previously said `var foo = 'bar'`, you can then say
`func foo(): return 'bar'`. A symbol will behave exclusively
in whatever manner it was most recently declared, and if you've declared
functions that referenced the symbol in its original role,
they may stop working -- but that's fine, because you can just
redeclare them as well, if you need to.

### Signals, extends, and class_name

You can also declare `signal`s, change the base class
of the session script instance with `extends`, and give it a public name
with `class_name`, though the utility of doing any of these things
is questionable.

### Accessible variables and functions

`self` has the variable `_editor_interface`.
You can use `_editor_interface.get_edited_scene_root()`
to get the root node of the scene currently open in the editor.
`self` also has the method `_recur`, which contains your input snippet,
such that calling `_recur()` from within your input snippet
will constitute a recursive call (for what limited use that may be,
considering `_recur` accepts no arguments).

### Interactive GDScript in-game

The instance `self` in the context of an input snippet is an instance
of a dynamically generated and regenerated anonymous backend script
maintained by a frontend instance of a helper class
called `GDScriptInteractiveSession`.

`GDScriptInteractiveSession` is separate from the plugin entry point class.
Only the plugin entry point class, not `GDScriptInteractiveSession`,
relies on the editor, so it is possible to instantiate
`GDScriptInteractiveSession` in-game. You can use this to easily create
a cheat console or debug console.

`GDScriptInteractiveSession` is instantiated
with `GDScriptInteractiveSession.new()`. The resulting frontend instance
has two public methods: `eval` and `inject`.

`eval` takes a string and evaluates it as GDScript code. If the code
is an expression or contains a `return` statement, `eval` returns
what the code returns; otherwise, `eval` returns null.
`eval` is responsible for evaluating your input snippets
in the in-editor GDScript input field,
and therefore has exactly the same semantics.

`inject` takes a `StringName` and any other value, creates a variable
by the given name in the session backend, and sets it to the given value.
This allows you to provide a session with references it can't obtain
with `eval` alone.

Note that the backend of a fresh instance of `GDScriptInteractiveSession`
does not have `_editor_interface`; that is `inject`ed
by the plugin entry point class.

### Known issues

Occasionally, trying to call a function or method which returns `void`
will result in an error informing you you cannot get the result
of such a function, as there is none:

```
Parse Error: Cannot get return value of call to "foo()"
because it returns "void".
```

When evaluating a statement, `GDScriptInteractiveSession.eval`
will first iterate through several regular expressions
to try to determine what kind of statement it is.
The main reason this matters is because if it is not any
of the known types of statements, it's probably an expression,
which -- if the expression evaluates to non-`void` --
means `return` should be prefixed to save you the trouble.
So that, for example, you can just type `2*2` instead of `return 2*2`.

It would be bad if this rule of implicitly prefixing `return`
caused us to try to `return` the result of an expression that *is* `void`,
so before falling back to actually evaluating the expression as GDScript,
we first try evaluating it as an `Expression`.
The language of Godot's `Expression` class is not as capable
as GDScript proper, but there is one thing it can do which GDScript code
in an expression context cannot: an `Expression` is allowed to be `void`,
in which case it returns `null`.

The problem occurs when a `void` expression is too complex for `Expression`,
and so falls through to the prefix-`return` strategy,
which is unable to handle it because it is `void`.
Unfortunately, as far as I know, there is no way to actually check beforehand
whether an expression will evaluate to `void`,
short of writing my own GDScript parser,
so I have no ideas as to any solution to this issue.

In the meantime, you can work around the issue by following the expression up
with `; pass`. `GDScriptInteractiveSession.eval` will never treat a snippet
as an expression if it contains multiple statements.
