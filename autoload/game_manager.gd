extends Node

signal room_changed(new_room: String)

const FADE_DURATION: float = 0.333
const MAX_ROOM_HISTORY: int = 30
const NOTEPAD_TEXTURE_COUNT: int = 6
const FADE_OVERLAY_Z_INDEX: int = 1000
var starting_room: String = "house_exterior"
var current_room: String
var current_room_instance: Node
var room_history: Array[String] = []
var preloaded_rooms: Dictionary = {}
var room_names: Array[String] = [
	"garage",
	"grace_room",
	"house_exterior",
	"kitchen",
	"living_room",
	"parent_room"
]
var is_transitioning: bool = false
var fade_overlay: ColorRect
var current_evidence_popup: Control
var evidence_popup_scene = preload("res://scenes/ui/evidence_popup.tscn")
var notepad_textures: Array[Texture2D] = []
var position_weights: PackedFloat32Array = PackedFloat32Array([5.0, 4.0, 3.0, 2.0, 1.0, 0.0])
var textures_loaded: bool = false

func _ready():
	EventBus.evidence_popup_requested.connect(_on_evidence_popup_requested)
	_setup_fade_overlay()
	_load_notepad_textures()
	_load_and_show_starting_room()

func _load_and_show_starting_room():
	var room_path = "res://scenes/rooms/%s.tscn" % starting_room
	preloaded_rooms[starting_room] = load(room_path)
	var world = get_tree().current_scene.get_node_or_null("World")
	if world:
		_setup_room_in_world(world)
	else:
		_setup_room_as_scene()
	_load_remaining_rooms_async.call_deferred()

func _setup_room_in_world(world: Node):
	current_room_instance = preloaded_rooms[starting_room].instantiate()
	world.add_child(current_room_instance)
	current_room = starting_room
	room_history.append(current_room)
	room_changed.emit.call_deferred()

func _setup_room_as_scene():
	current_room_instance = get_tree().current_scene
	current_room = get_tree().current_scene.scene_file_path.get_file().get_basename()
	room_history.append(current_room)
	room_changed.emit.call_deferred()

func _load_remaining_rooms_async():
	await get_tree().process_frame
	for room_name in room_names:
		if room_name != starting_room:
			var room_path = "res://scenes/rooms/%s.tscn" % room_name
			preloaded_rooms[room_name] = load(room_path)
			await get_tree().process_frame

func change_room(new_room: String) -> void:
	if is_transitioning or new_room == current_room:
		return
	if not preloaded_rooms.has(new_room):
		print("Room '%s' not loaded yet, skipping transition" % new_room)
		return
	is_transitioning = true
	await _transition_to_room(new_room)
	is_transitioning = false

func _transition_to_room(new_room: String) -> void:
	await _fade_out()
	if current_room_instance:
		current_room_instance.queue_free()
		current_room_instance = null
		await get_tree().process_frame
	var world = get_tree().current_scene.get_node("World")
	current_room_instance = preloaded_rooms[new_room].instantiate()
	world.add_child(current_room_instance)
	await get_tree().process_frame
	current_room = new_room
	room_history.append(current_room)
	if room_history.size() > MAX_ROOM_HISTORY:
		room_history.pop_front()
	room_changed.emit()
	await _fade_in()

func _setup_fade_overlay():
	fade_overlay = ColorRect.new()
	fade_overlay.color = Color.BLACK
	fade_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_overlay.modulate.a = 0.0
	fade_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fade_overlay.z_index = FADE_OVERLAY_Z_INDEX
	get_tree().current_scene.add_child(fade_overlay)

func _fade_out() -> void:
	var tween = create_tween()
	tween.tween_property(fade_overlay, "modulate:a", 1.0, FADE_DURATION)
	await tween.finished

func _fade_in() -> void:
	var tween = create_tween()
	tween.tween_property(fade_overlay, "modulate:a", 0.0, FADE_DURATION)
	await tween.finished

func _load_notepad_textures():
	if textures_loaded:
		return
	for i in range(1, NOTEPAD_TEXTURE_COUNT + 1):
		var texture_path = "res://assets/sprites/ui/notepad%d.png" % i
		var texture = load(texture_path) as Texture2D
		if texture:
			notepad_textures.append(texture)
			texture.set_meta("original_name", "notepad%d" % i)
	textures_loaded = true

func get_next_notepad_texture() -> Texture2D:
	if notepad_textures.is_empty():
		return null
	if notepad_textures.size() == 1:
		return notepad_textures[0]
	var selected_index = _get_weighted_random_index()
	var selected_texture = notepad_textures[selected_index]
	_move_texture_to_back(selected_index)
	return selected_texture

func _get_weighted_random_index() -> int:
	var rng = RandomNumberGenerator.new()
	return rng.rand_weighted(position_weights)

func _move_texture_to_back(index: int):
	var texture = notepad_textures[index]
	notepad_textures.remove_at(index)
	notepad_textures.append(texture)

func _on_evidence_popup_requested(evidence: EvidenceResource):
	show_evidence_popup(evidence)

func show_evidence_popup(evidence: EvidenceResource):
	if current_evidence_popup:
		current_evidence_popup.queue_free()
		current_evidence_popup = null
	current_evidence_popup = evidence_popup_scene.instantiate()
	get_tree().current_scene.add_child(current_evidence_popup)
	current_evidence_popup.show_evidence(evidence)
	current_evidence_popup.tree_exiting.connect(_on_popup_closed)

func _on_popup_closed():
	current_evidence_popup = null
