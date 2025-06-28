@tool
class_name AnswerSheet
extends TextureButton

@export var puzzle_resource: PuzzleResource
@export var answer_sheet_texture: Texture2D : set = set_answer_sheet_texture
@export var next_answer_sheet_scene: PackedScene : set = set_next_answer_sheet_scene
@export var slide_distance: float = 840
@export var slide_duration: float = 0.5

signal puzzle_completed(result: Dictionary)
signal puzzle_failed(result: Dictionary)
signal feedback_shown(feedback: String)

var original_position: Vector2
var is_slid_up: bool = false

func _ready():
	original_position = position
	if not Engine.is_editor_hint():
		_setup_puzzle()
		_connect_dropdowns()
		EventBus.puzzle_evaluated.connect(_on_puzzle_evaluated)
		pressed.connect(_on_answer_sheet_clicked)

func _connect_dropdowns():
	_connect_dropdowns_recursive(self)

func _connect_dropdowns_recursive(node: Node):
	for child in node.get_children():
		if child.has_method("set_dropdown_field"):
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
			if next_answer_sheet_scene:
				_replace_with_next_answer_sheet()
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

func _replace_with_next_answer_sheet():
	if not next_answer_sheet_scene or Engine.is_editor_hint():
		return
	var next_answer_sheet: AnswerSheet = next_answer_sheet_scene.instantiate()
	if not next_answer_sheet:
		push_error("Failed to instantiate next answer sheet from scene")
		return
	var parent_node = get_parent()
	if not parent_node:
		push_error("AnswerSheet has no parent, cannot replace")
		return
	next_answer_sheet.original_position = original_position
	if is_slid_up:
		next_answer_sheet.position = original_position
		next_answer_sheet.is_slid_up = false
	else:
		next_answer_sheet.position = position
		next_answer_sheet.is_slid_up = false
	parent_node.add_child(next_answer_sheet)
	var my_index = get_index()
	parent_node.move_child(next_answer_sheet, my_index)
	if is_slid_up:
		next_answer_sheet.slide_up()
	queue_free()

func set_next_answer_sheet_scene(scene: PackedScene):
	next_answer_sheet_scene = scene

func _on_answer_sheet_clicked():
	toggle_slide()

func slide_up():
	if is_slid_up:
		return
	is_slid_up = true
	var target_position = original_position - Vector2(0, slide_distance)
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUART)
	tween.tween_property(self, "position", target_position, slide_duration)
	tween.tween_property(self, "scale", Vector2(1.02, 1.02), slide_duration * 0.4)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), slide_duration * 0.6).set_delay(slide_duration * 0.4)

func slide_down():
	if not is_slid_up:
		return
	is_slid_up = false
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "position", original_position, slide_duration)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), slide_duration * 0.5)

func _notification(what):
	if what == NOTIFICATION_READY:
		original_position = position

func toggle_slide():
	if is_slid_up:
		slide_down()
	else:
		slide_up()

func reset_position():
	position = original_position
	is_slid_up = false
