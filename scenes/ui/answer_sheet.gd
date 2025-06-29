@tool
class_name AnswerSheet
extends TextureButton

@export var puzzle_resource: PuzzleResource
@export var answer_sheet_texture: Texture2D : set = set_answer_sheet_texture
@export var next_answer_sheet_scene: PackedScene : set = set_next_answer_sheet_scene
@export var slide_distance: float = 840
@export var slide_duration: float = 0.5

var is_slid_up: bool = true
var is_animating: bool = false
var current_tween: Tween
var initial_position: Vector2
var up_position: Vector2
var down_position: Vector2

signal puzzle_completed(result: Dictionary)
signal puzzle_failed(result: Dictionary)
signal feedback_shown(feedback: String)

func _ready():
	if not Engine.is_editor_hint():
		if up_position == Vector2.ZERO and down_position == Vector2.ZERO:
			initial_position = position
			up_position = position
			down_position = position + Vector2(0, slide_distance)
		elif initial_position == Vector2.ZERO:
			initial_position = up_position
		_setup_puzzle()
		_connect_dropdowns()
		EventBus.puzzle_evaluated.connect(_on_puzzle_evaluated)
		EventBus.puzzle_solved.connect(_on_puzzle_solved)
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
		else:
			puzzle_failed.emit(result)
			_shake_incorrect()

func _on_puzzle_solved(puzzle_id: String):
	if puzzle_resource and puzzle_resource.puzzle_id == puzzle_id:
		if next_answer_sheet_scene:
			_replace_with_next_answer_sheet()

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
	var target_position = position
	var off_screen_position = target_position + Vector2(0, 1000)
	next_answer_sheet.position = off_screen_position
	next_answer_sheet.is_slid_up = is_slid_up
	next_answer_sheet.setup_positions(target_position)

	parent_node.add_child(next_answer_sheet)
	var my_index = get_index()
	parent_node.move_child(next_answer_sheet, my_index)
	_stop_current_tween()
	is_animating = true
	current_tween = create_tween()
	current_tween.set_ease(Tween.EASE_IN)
	current_tween.set_trans(Tween.TRANS_QUART)
	current_tween.tween_property(self, "position", off_screen_position, slide_duration)
	await current_tween.finished
	var new_tween = next_answer_sheet.create_tween()
	new_tween.set_ease(Tween.EASE_OUT)
	new_tween.set_trans(Tween.TRANS_QUART)
	new_tween.tween_property(next_answer_sheet, "position", target_position, slide_duration)
	queue_free()

func set_next_answer_sheet_scene(scene: PackedScene):
	next_answer_sheet_scene = scene

func _on_answer_sheet_clicked():
	if is_animating:
		return
	toggle_slide()

func slide_up():
	if is_slid_up or is_animating:
		return
	_stop_current_tween()
	is_animating = true
	is_slid_up = true
	var target_position = up_position
	current_tween = create_tween()
	current_tween.set_parallel(true)
	current_tween.set_ease(Tween.EASE_OUT)
	current_tween.set_trans(Tween.TRANS_QUART)
	current_tween.tween_property(self, "position", target_position, slide_duration)
	current_tween.tween_property(self, "scale", Vector2(1.02, 1.02), slide_duration * 0.4)
	current_tween.tween_property(self, "scale", Vector2(1.0, 1.0), slide_duration * 0.6).set_delay(slide_duration * 0.4)
	current_tween.finished.connect(_on_animation_finished)

func slide_down():
	if not is_slid_up or is_animating:
		return
	_stop_current_tween()
	is_animating = true
	is_slid_up = false
	var target_position = down_position
	current_tween = create_tween()
	current_tween.set_parallel(true)
	current_tween.set_ease(Tween.EASE_IN_OUT)
	current_tween.set_trans(Tween.TRANS_BACK)
	current_tween.tween_property(self, "position", target_position, slide_duration)
	current_tween.tween_property(self, "scale", Vector2(1.0, 1.0), slide_duration * 0.5)
	current_tween.finished.connect(_on_animation_finished)

func toggle_slide():
	if is_animating:
		return
	if is_slid_up:
		slide_down()
	else:
		slide_up()

func _shake_incorrect():
	if is_animating:
		return
	_stop_current_tween()
	is_animating = true
	var original_position = position
	var shake_amount = 6.0
	var shake_duration = 0.03
	var shake_count = 3
	current_tween = create_tween()
	current_tween.set_ease(Tween.EASE_OUT)
	current_tween.set_trans(Tween.TRANS_BACK)
	for i in shake_count:
		var shake_offset = Vector2(shake_amount * (1 if i % 2 == 0 else -1), 0)
		current_tween.tween_property(self, "position", original_position + shake_offset, shake_duration)
		current_tween.tween_property(self, "position", original_position, shake_duration)
	current_tween.tween_property(self, "position", original_position, shake_duration * 0.5)
	current_tween.finished.connect(_on_animation_finished)

func _stop_current_tween():
	if current_tween and current_tween.is_valid():
		current_tween.kill()
		current_tween = null

func _on_animation_finished():
	is_animating = false
	if current_tween:
		current_tween = null

func setup_positions(base_position: Vector2):
	initial_position = base_position
	up_position = base_position
	down_position = base_position + Vector2(0, slide_distance)
