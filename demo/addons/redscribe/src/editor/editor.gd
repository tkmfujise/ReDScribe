@tool
extends CodeEdit
class_name ReDScribeEditor

@export var current_syntax : ReDScribeEditorSyntax : set = set_syntax
@export var current_theme : ReDScribeEditorTheme : set = set_code_theme

const DEFAULT_THEME = preload("res://addons/redscribe/data/editor_themes/gessetti_theme.tres")
const RUBY_SYNTAX = preload("res://addons/redscribe/data/editor_syntaxes/ruby_syntax.tres")


func _ready() -> void:
	syntax_highlighter = CodeHighlighter.new()
	if current_theme && current_syntax: apply_syntax_theme()
	if not current_theme:  set_code_theme(DEFAULT_THEME)
	if not current_syntax: set_syntax(RUBY_SYNTAX)


func set_code_theme(_theme: ReDScribeEditorTheme) -> void:
	current_theme = _theme
	add_theme_color_override("background_color", _theme.background_color)
	add_theme_color_override("font_color", _theme.foreground_color)
	if current_syntax: apply_syntax_theme()


func set_syntax(syntax: ReDScribeEditorSyntax) -> void:
	current_syntax = syntax
	set_indent(syntax.indent_size)
	apply_syntax_theme()



func apply_syntax_theme() -> void:
	if not (current_theme and current_syntax): return
	clear_syntax_highlighter()
	apply_syntax_highlighter()
	for key in current_syntax.regions:
		for arr in current_syntax.regions[key]:
			if current_theme.syntax_colors.has(key):
				syntax_highlighter.add_color_region(
					arr[0], arr[1], current_theme.syntax_colors[key]
				)
	for key in current_syntax.keywords:
		for value in current_syntax.keywords[key]:
			if current_theme.syntax_colors.has(key):
				syntax_highlighter.add_keyword_color(value, current_theme.syntax_colors[key])


func apply_syntax_highlighter() -> void:
	var _theme = current_theme
	if not _theme: return
	syntax_highlighter.set_symbol_color(_theme.symbol_color)
	syntax_highlighter.set_number_color(_theme.number_color)
	syntax_highlighter.set_function_color(_theme.function_color)
	syntax_highlighter.set_member_variable_color(_theme.member_variable_color)


func clear_syntax_highlighter():
	syntax_highlighter.clear_highlighting_cache()
	syntax_highlighter.clear_color_regions()
	syntax_highlighter.clear_keyword_colors()
	syntax_highlighter.clear_member_keyword_colors()


func set_indent(_indent_size: int) -> void:
	indent_size = _indent_size


func _on_code_completion_requested() -> void:
	if !current_syntax: return
	for arr in current_syntax.completions:
		add_code_completion_option(CodeEdit.KIND_PLAIN_TEXT, arr[0], arr[1])

	update_code_completion_options(true)


func _on_text_changed() -> void:
	if get_word_at_pos(get_caret_draw_pos()).length() > 1:
		request_code_completion(true)
