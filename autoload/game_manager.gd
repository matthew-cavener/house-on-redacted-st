extends Node

signal room_changed(new_room: String)

var evidence_popup_scene = preload("res://scenes/ui/evidence_popup.tscn")
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
var fade_duration: float = 0.333
var current_evidence_popup: Control

func _ready():
	EventBus.evidence_popup_requested.connect(_on_evidence_popup_requested)
	_setup_fade_overlay()
	_load_and_show_starting_room()

func _load_and_show_starting_room():
	var room_path = "res://scenes/rooms/%s.tscn" % starting_room
	preloaded_rooms[starting_room] = load(room_path)
	var world = get_tree().current_scene.get_node("World")
	current_room_instance = preloaded_rooms[starting_room].instantiate()
	world.add_child(current_room_instance)
	current_room = starting_room
	room_history.append(current_room)
	room_changed.emit.call_deferred()
	_load_remaining_rooms_async.call_deferred()

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
		print("Room %s not loaded yet, skipping transition" % new_room)
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
	if room_history.size() > 30:
		room_history.pop_front()
	room_changed.emit()
	await _fade_in()

func _setup_fade_overlay():
	fade_overlay = ColorRect.new()
	fade_overlay.color = Color.BLACK
	fade_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_overlay.modulate.a = 0.0
	fade_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fade_overlay.z_index = 1000
	get_tree().current_scene.add_child(fade_overlay)

func _fade_out() -> void:
	var tween = create_tween()
	tween.tween_property(fade_overlay, "modulate:a", 1.0, fade_duration)
	await tween.finished

func _fade_in() -> void:
	var tween = create_tween()
	tween.tween_property(fade_overlay, "modulate:a", 0.0, fade_duration)
	await tween.finished

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
