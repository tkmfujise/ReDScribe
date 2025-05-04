extends Resource
class_name ReDScribeEditorSyntax

@export var indent_size = 4
@export var regions = {
	"key": [["begin", "end"]]
}
@export var keywords = {
	"key": ["keyword"]
}
@export var completions = [
	["display_text", "insert_text"]
]
