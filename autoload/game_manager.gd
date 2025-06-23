extends Node

var evidence_popup_scene = preload("res://scenes/ui/evidence_popup.tscn")
var current_evidence_popup: Control
var current_room: String
var room_history: Array[String] = []
var is_transitioning: bool = false
var fade_overlay: ColorRect
var fade_duration: float = 0.333
var preloaded_rooms: Dictionary = {}
var room_names: Array[String] = [
	"garage",
	"grace_room",
	"house_exterior",
	"kitchen",
	"living_room",
	"parent_room"
]

func _ready():
	EventBus.evidence_popup_requested.connect(_on_evidence_popup_requested)
	_preload_all_rooms()
	_setup_fade_overlay()

func _preload_all_rooms():
	for room_name in room_names:
		var room_path = "res://scenes/rooms/%s.tscn" % room_name
		preloaded_rooms[room_name] = load(room_path)

func _setup_fade_overlay():
	fade_overlay = ColorRect.new()
	fade_overlay.color = Color.BLACK
	fade_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_overlay.modulate.a = 0.0
	fade_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fade_overlay.z_index = 1000
	get_tree().current_scene.add_child(fade_overlay)

func change_room(new_room: String) -> void:
	if is_transitioning or new_room == current_room:
		return
	is_transitioning = true
	await _transition_to_room(new_room)
	is_transitioning = false

func _transition_to_room(new_room: String) -> void:
	await _fade_to_black()
	var world = get_tree().current_scene.get_node("World")
	if world.get_child_count() > 0:
		world.get_child(0).queue_free()
		await get_tree().process_frame
	var room_instance = preloaded_rooms[new_room].instantiate()
	world.add_child(room_instance)
	await get_tree().process_frame
	if current_room != new_room:
		room_history.append(current_room)
		current_room = new_room
	await _fade_from_black()

func _fade_to_black() -> void:
	var tween = create_tween()
	tween.tween_property(fade_overlay, "modulate:a", 1.0, fade_duration)
	await tween.finished

func _fade_from_black() -> void:
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
