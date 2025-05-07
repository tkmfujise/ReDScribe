class_name GDScriptInteractiveSession
## Dynamically alters an anonymous script to run arbitrary code on demand.

var _script: GDScript
var _script_instance: RefCounted
var _class_name := &''
var _base_class := &''
var _decls := {}

# I realize, in the general case, you can't actually parse code with regex;
# you need at least a pushdown automaton.
# However, I don't need to parse code completely, only in a limited capacity,
# mostly to determine whether or not any given statement is an expression.
# I think regex should suffice for this purpose.
const RX_COMMENT := "^\\s*#"
const RX_IF := "^\\s*if\\b"
const RX_ELIF := "^\\s*elif\\b"
const RX_ELSE := "^\\s*else\\b"
const RX_FOR := "^\\s*for\\b"
const RX_WHILE := "^\\s*while\\b"
const RX_MATCH := "^\\s*match\\b"
const RX_BREAK := "^\\s*break\\b"
const RX_CONTINUE := "^\\s*continue\\b"
const RX_PASS := "^\\s*pass\\b"
const RX_RETURN := "^\\s*return\\b"
const RX_CLASS := "^\\s*class\\s+(\\w+)"
const RX_CLASS_NAME := "^\\s*class_name\\s+(\\w+)"
const RX_EXTENDS := "^\\s*extends\\s+(\\w+)"
const RX_CLASS_EXTENDS := "^\\s*class\\s+(\\w+)\\s+extends\\b"
const RX_CLASS_NAME_EXTENDS := \
	"^\\s*class_name\\s+(\\w+)\\s+extends\\s+(\\w+)"
const RX_SIGNAL := "^\\s*signal\\s+(\\w+)"
const RX_FUNC := "^\\s*func\\s+(\\w+)"
const RX_CONST := "^\\s*const\\s+(\\w+)"
const RX_ENUM := "^\\s*enum\\s+(\\w+)"
const RX_VAR := "^\\s*var\\s+(\\w+)"
const RX_BREAKPOINT := "^\\s*breakpoint\\b"
const RX_ASSERT := "^\\s*assert\\b"
const RX_STATIC_FUNC := "^\\s*static\\s+func\\s+(\\w+)"
const RX_STATIC_VAR := "^\\s*static\\s+var\\s+(\\w+)"
const RX_ALL_WS := "^\\s*$"
const RX_LEADING_WS := "^\\s*"
const RX_AFTER_EQUALS := "=(.*)$"

static var _static_init_done := false
static var rx_comment: RegEx
static var rx_if: RegEx
static var rx_elif: RegEx
static var rx_else: RegEx
static var rx_for: RegEx
static var rx_while: RegEx
static var rx_match: RegEx
static var rx_break: RegEx
static var rx_continue: RegEx
static var rx_pass: RegEx
static var rx_return: RegEx
static var rx_class: RegEx
static var rx_class_name: RegEx
static var rx_extends: RegEx
static var rx_class_extends: RegEx
static var rx_class_name_extends: RegEx
static var rx_signal: RegEx
static var rx_func: RegEx
static var rx_const: RegEx
static var rx_enum: RegEx
static var rx_var: RegEx
static var rx_breakpoint: RegEx
static var rx_assert: RegEx
static var rx_static_func: RegEx
static var rx_static_var: RegEx
static var rx_all_ws: RegEx
static var rx_leading_ws: RegEx
static var rx_after_equals: RegEx


static func _static_init() -> void:
	rx_comment = RegEx.new(); rx_comment.compile(RX_COMMENT)
	rx_if = RegEx.new(); rx_if.compile(RX_IF)
	rx_elif = RegEx.new(); rx_elif.compile(RX_ELIF)
	rx_else = RegEx.new(); rx_else.compile(RX_ELSE)
	rx_for = RegEx.new(); rx_for.compile(RX_FOR)
	rx_while = RegEx.new(); rx_while.compile(RX_WHILE)
	rx_match = RegEx.new(); rx_match.compile(RX_MATCH)
	rx_break = RegEx.new(); rx_break.compile(RX_BREAK)
	rx_continue = RegEx.new(); rx_continue.compile(RX_CONTINUE)
	rx_pass = RegEx.new(); rx_pass.compile(RX_PASS)
	rx_return = RegEx.new(); rx_return.compile(RX_RETURN)
	rx_class = RegEx.new(); rx_class.compile(RX_CLASS)
	rx_class_name = RegEx.new(); rx_class_name.compile(RX_CLASS_NAME)
	rx_extends = RegEx.new(); rx_extends.compile(RX_EXTENDS)
	rx_class_extends = RegEx.new(); rx_class_extends.compile(RX_CLASS_EXTENDS)
	rx_class_name_extends = RegEx.new(); \
		rx_class_name_extends.compile(RX_CLASS_NAME_EXTENDS)
	rx_signal = RegEx.new(); rx_signal.compile(RX_SIGNAL)
	rx_func = RegEx.new(); rx_func.compile(RX_FUNC)
	rx_const = RegEx.new(); rx_const.compile(RX_CONST)
	rx_enum = RegEx.new(); rx_enum.compile(RX_ENUM)
	rx_var = RegEx.new(); rx_var.compile(RX_VAR)
	rx_breakpoint = RegEx.new(); rx_breakpoint.compile(RX_BREAKPOINT)
	rx_assert = RegEx.new(); rx_assert.compile(RX_ASSERT)
	rx_static_func = RegEx.new(); rx_static_func.compile(RX_STATIC_FUNC)
	rx_static_var = RegEx.new(); rx_static_var.compile(RX_STATIC_VAR)
	rx_all_ws = RegEx.new(); rx_all_ws.compile(RX_ALL_WS)
	rx_leading_ws = RegEx.new(); rx_leading_ws.compile(RX_LEADING_WS)
	rx_after_equals = RegEx.new(); rx_after_equals.compile(RX_AFTER_EQUALS)
	_static_init_done = true


# Helper for divide_code_into_statements.
static func _get_statement(code: String, mark: int, i: int = -1) -> String:
	if i > 0:
		return code.substr(mark, i - mark + 1)
	else:
		return code.substr(mark)


## Given GDScript code, returns its statements.
static func _divide_code_into_statements(code: String) -> PackedStringArray:
	var statements := PackedStringArray([])
	var mark: int = 0
	var brackets: Array[int] = []
	var escape := false
	var comment := false
	code = code.replace("\r\n", "\n").replace("\r", "\n")
	# iterate the string
	for i in code.length():
		var c := code.unicode_at(i)
		# if we are in a comment:
		if comment:
			match c:
				0xa: # \n
					# only break the comment at the end of the line
					comment = false
					statements.append(_get_statement(code, mark, i))
					mark = i + 1
					escape = true # newline after newline redundant
					continue # don't unset escape
				_:
					continue # don't unset escape
		# if we are not in brackets nor a string:
		elif brackets.is_empty():
			match c:
				0x9, 0x20: # tab, space
					continue # don't unset escape
				0xa: # \n
					# unless newline is escaped, end statement
					if not escape:
						statements.append(_get_statement(code, mark, i))
						mark = i + 1
						escape = true # newline after newline redundant
						continue # don't unset escape
				0x22, 0x27, 0x28, 0x5b, 0x7b: # "'([{
					# enter brackets or a string
					brackets.append(c)
				0x23: # #
					# start a comment
					comment = true
					continue # don't unset escape
				0x3a: # :
					# check if we are building a var decl
					var thus_far := code.substr(mark, i - mark)
					if not (
						rx_var.search(thus_far) or
						rx_static_var.search(thus_far) or
						rx_const.search(thus_far)
					):
						# if not, end statement
						statements.append(_get_statement(code, mark, i))
						mark = i + 1
						escape = true # newline after : redundant
						continue # don't unset escape
				0x3b: # ;
					# end statement
					statements.append(_get_statement(code, mark, i))
					mark = i + 1
					escape = true # newline after ; redundant
					continue # don't unset escape
				0x5c: # \
					# set escape
					escape = true
					continue # don't unset escape
		# if we are in brackets or a string
		else:
			# check what we're in
			var b := brackets[-1]
			match b:
				0x22, 0x27: # "'
					# if in string:
					match c:
						b:
							# unescaped matching quote => ascend from string
							if not escape:
								brackets.pop_back()
						0x5c: # \
							# set escape
							escape = not escape
							continue # don't unset escape
				0x28: # (
					# if in parens:
					match c:
						0x22, 0x27, 0x28, 0x5b, 0x7b: # "'([{
							# descend
							brackets.append(c)
						0x29: # )
							# ascend
							brackets.pop_back()
				0x5b: # [
					# if in bracks:
					match c:
						0x22, 0x27, 0x28, 0x5b, 0x7b: # "'([{
							# descend
							brackets.append(c)
						0x5d: # ]
							# ascend
							brackets.pop_back()
				0x7b: # {
					# if in braces:
					match c:
						0x22, 0x27, 0x28, 0x5b, 0x7b: # "'([{
							# descend
							brackets.append(c)
						0x7d: # }
							# ascend
							brackets.pop_back()
		# if we didn't explicitly continue, unset escape
		escape = false
	# end statement
	statements.append(_get_statement(code, mark))
	# done
	return statements


## Checks if the statement is an assignment statement.
static func _statement_is_assignment(statement: String) -> bool:
	var brackets: Array[int] = []
	var escape := false
	var comment := false
	var expect := &'equals-or-op'
	# iterate the string
	for i in statement.length():
		var c := statement.unicode_at(i)
		# if we are in a comment:
		if comment:
			match c:
				0xa: # \n
					# only break the comment at the end of the line
					comment = false
		# if we are not in brackets nor a string:
		elif brackets.is_empty():
			match c:
				0x22, 0x27, 0x28, 0x5b, 0x7b: # "'([{
					# reset expectation
					expect = &'equals-or-op'
					# enter brackets or a string
					brackets.append(c)
				0x23: # #
					# reset expectation
					expect = &'equals-or-op'
					# start a comment
					comment = true
				_:
					# check against expectation
					match expect:
						&'equals-or-op':
							match c:
								0x25, 0x26, 0x2b, 0x2d, 0x2f, 0x5e, 0x7c:
									# %&+-/^|
									expect = &'equals'
								0x2a: # *
									expect = &'equals-or-star'
								0x3c: # <
									expect = &'lt'
								0x3d: # =
									expect = &'not-equals'
								0x3e: # >
									expect = &'gt'
						&'equals':
							match c:
								0x3d: # =
									return true
								_:
									# reset expectation
									expect = &'equals-or-op'
						&'equals-or-star':
							match c:
								0x2a: # *
									expect = &'equals'
								0x3d: # =
									return true
								_:
									# reset expectation
									expect = &'equals-or-op'
						&'not-equals':
							match c:
								0x3d: # =
									# reset expectation
									expect = &'equals-or-op'
								_:
									return true
						&'lt':
							match c:
								0x3c: # <
									expect = &'equals'
								_:
									expect = &'equals-or-op' # reset
						&'gt':
							match c:
								0x3e: # >
									expect = &'equals'
								_:
									expect = &'equals-or-op' # reset
		# if we are in brackets or a string
		else:
			# check what we're in
			var b := brackets[-1]
			match b:
				0x22, 0x27: # "'
					# if in string:
					match c:
						b:
							# unescaped matching quote => ascend from string
							if not escape:
								brackets.pop_back()
						0x5c: # \
							# set escape
							escape = not escape
							continue # don't unset escape
				0x28: # (
					# if in parens:
					match c:
						0x22, 0x27, 0x28, 0x5b, 0x7b: # "'([{
							# descend
							brackets.append(c)
						0x29: # )
							# ascend
							brackets.pop_back()
				0x5b: # [
					# if in bracks:
					match c:
						0x22, 0x27, 0x28, 0x5b, 0x7b: # "'([{
							# descend
							brackets.append(c)
						0x5d: # ]
							# ascend
							brackets.pop_back()
				0x7b: # {
					# if in braces:
					match c:
						0x22, 0x27, 0x28, 0x5b, 0x7b: # "'([{
							# descend
							brackets.append(c)
						0x7d: # }
							# ascend
							brackets.pop_back()
		# if we didn't explicitly continue, unset escape
		escape = false
	# fallthrough = fail
	return false


## Returns the regex which the statement matches, plus the match.
##
## Returns empty on fallthrough. Our choice of regex is such
## that if this function falls through, the statement is probably
## an expression. If the statement is an assignment, the array [&'assignment']
## is returned, because regex is not sufficient to identify all assignments.
static func _categorize_statement(statement: String) -> Array:
	statement = statement.replace("\n", ' ').replace("\\", '').strip_edges()
	for rx in [
		rx_comment,
		rx_if,
		rx_elif,
		rx_else,
		rx_for,
		rx_while,
		rx_match,
		rx_break,
		rx_continue,
		rx_pass,
		rx_return,
		rx_class,
		rx_class_name,
		rx_extends,
		rx_class_extends,
		rx_class_name_extends,
		rx_signal,
		rx_func,
		rx_const,
		rx_enum,
		rx_var,
		rx_breakpoint,
		rx_assert,
		rx_static_func,
		rx_static_var,
		rx_all_ws
	]:
		var rxmatch: RegExMatch = rx.search(statement)
		if rxmatch:
			return [rx, rxmatch]
	if _statement_is_assignment(statement):
		return [&'assignment']
	return []


## Executes code.
func eval(code: String) -> Variant:
	var script_source := ""
	var statements := _divide_code_into_statements(code)
	var categorized_statements: Array[Array] = []
	var meaningful_statement_count: int = 0
	var first_meaningful_statement: int = -1
	var body := "return null\n"
	# Categorize statements and find first meaningful statement.
	for i in statements.size():
		var statement := statements[i]
		var categorized = _categorize_statement(statement.strip_edges())
		if categorized.is_empty() or (
			categorized.size() > 0 and (
				categorized[0] is StringName or (
					categorized[0] != rx_comment and
					categorized[0] != rx_all_ws
				)
			)
		):
			meaningful_statement_count += 1
			if first_meaningful_statement < 0:
				first_meaningful_statement = i
		categorized.append(statement)
		categorized_statements.append(categorized)
	# If only one meaningful statement, special semantics may apply:
	if meaningful_statement_count == 1:
		var statement := statements[first_meaningful_statement].strip_edges()
		var category := categorized_statements[first_meaningful_statement]
		if category.size() == 1:
			# If only meaningful statement is expression,
			# first try evaluating with Expression class.
			# This way, we can handle cases
			# where the expression evaluates to void,
			# and not try to build an invalid statement
			# such as `return print("Hello world!")`.
			# I can think of no way to do this
			# except to leverage the Expression class.
			var exprobj := Expression.new()
			if exprobj.parse(statement) == OK:
				var result = exprobj.execute([], _script_instance, false)
				if not exprobj.has_execute_failed():
					return result
			# If evaluation via Expression class fails,
			# evaluate with full GDScript, and prefix `return`.
			# Expressions which evaluate to void might still get through,
			# because Expression can't handle all valid expressions --
			# hence the need for this line in the first place.
			# It will have to be good enough, however,
			# because I'm pretty sure we have no other good way
			# of checking for void.
			body = "return " + statement + "\n"
		else:
			match category[0]:
				# On class_name ...: change _class_name.
				rx_class_name:
					_class_name = category[1].get_string(1)
				# On extends ...: change _base_class.
				rx_extends:
					_base_class = category[1].get_string(1)
				# On class_name ... extends ...: change both.
				rx_class_name_extends:
					_class_name = category[1].get_string(1)
					_base_class = category[1].get_string(2)
				# On signal ...: declare signal.
				rx_signal:
					_decls[category[1].get_string(1)] = code
				# On [static] func ...: declare func.
				rx_func, rx_static_func:
					_decls[category[1].get_string(1)] = code
				# On const ...: declare const.
				rx_const:
					_decls[category[1].get_string(1)] = code
				# On enum ...: declare enum.
				rx_enum:
					_decls[category[1].get_string(1)] = code
				# On [static] var ...: declare instance var.
				rx_var, rx_static_var:
					_decls[category[1].get_string(1)] = code
					# Check if default value.
					var rxmatch = \
						rx_after_equals.search(
							category[2].replace("\n", ' ').replace("\\", '')
						)
					if rxmatch:
						# Apply if so.
						eval(
							category[1].get_string(1) + " = " +
							rxmatch.get_string(1)
						)
						# Value is for some reason not applied persistently
						# unless we return early. Very weird.
						return null
				# Any other case: no special semantics.
				_:
					body = code
	else:
		body = code
		# Depending on first meaningful statement,
		# special semantics may still apply,
		# even though there's more than one statement
		# (but said semantics are different in this case):
		var head := categorized_statements[first_meaningful_statement]
		if head.size() > 1:
			body = "return null\n"
			match head[0]:
				# On class ... [extends ...]: declare class.
				rx_class, rx_class_extends:
					_decls[head[1].get_string(1)] = code
				# On [static] func ...: declare func.
				rx_func, rx_static_func:
					_decls[head[1].get_string(1)] = code
				# Any other case: no special semantics.
				_:
					body = code
	# Build script.
	if not _class_name.is_empty():
		script_source += "class_name " + _class_name + "\n"
	if not _base_class.is_empty():
		script_source += "extends " + _base_class + "\n"
	for declname in _decls:
		script_source += _decls[declname] + "\n"
	script_source += "func _recur():\n" + body.indent("\t") + "\n"
	# Reload script and call _recur.
	_script.source_code = script_source
	_script.reload(true)
	return _script_instance._recur()


## Sets a variable within the script instance.
func inject(varname: StringName, varval: Variant) -> void:
	eval("var " + varname)
	_script_instance.set(varname, varval)


func _init() -> void:
	if not _static_init_done:
		_static_init()
	_script = GDScript.new()
	_script.source_code = ""
	_script.reload()
	_script_instance = _script.new()
