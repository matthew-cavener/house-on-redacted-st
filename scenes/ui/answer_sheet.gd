@tool
class_name AnswerSheet
extends TextureButton

@export var puzzle_resource: PuzzleResource
@export var answer_sheet_texture: Texture2D : set = set_answer_sheet_texture

signal puzzle_completed(result: Dictionary)
signal puzzle_failed(result: Dictionary)
signal feedback_shown(feedback: String)

func _ready():
	if not Engine.is_editor_hint():
		_setup_puzzle()
		_connect_dropdowns()
		EventBus.puzzle_evaluated.connect(_on_puzzle_evaluated)

func _connect_dropdowns():
	_connect_dropdowns_recursive(self)

func _connect_dropdowns_recursive(node: Node):
	for child in node.get_children():
		if child.has_method("setup_dropdown"):
			child.selection_changed.connect(_on_dropdown_changed)
		_connect_dropdowns_recursive(child)

func _on_dropdown_changed(field_name: String, selected_value: String):
	if not Engine.is_editor_hint() and puzzle_resource and not puzzle_resource.puzzle_id.is_empty():
		EventBus.dropdown_selection_changed.emit(puzzle_resource.puzzle_id, field_name, selected_value)

func _setup_puzzle():
	if not Engine.is_editor_hint() and puzzle_resource:
		GameManager.register_puzzle(puzzle_resource)

func _on_puzzle_evaluated(puzzle_id: String, result: Dictionary):
	if puzzle_resource and puzzle_resource.puzzle_id == puzzle_id:
		_show_feedback(result.feedback)
		if result.is_correct:
			puzzle_completed.emit(result)
		else:
			puzzle_failed.emit(result)

func _show_feedback(_feedback_text: String):
	feedback_shown.emit(_feedback_text)
	pass

func set_puzzle_resource(resource: PuzzleResource):
	puzzle_resource = resource
	if not Engine.is_editor_hint() and puzzle_resource:
		GameManager.register_puzzle(puzzle_resource)

func get_user_selections() -> Dictionary:
	if not Engine.is_editor_hint() and puzzle_resource and not puzzle_resource.puzzle_id.is_empty():
		return GameManager.get_puzzle_selections(puzzle_resource.puzzle_id)
	return {}

func set_answer_sheet_texture(value: Texture2D):
	answer_sheet_texture = value
	if answer_sheet_texture:
		texture_normal = answer_sheet_texture
