extends Node

var evidence_popup_scene = preload("res://scenes/ui/evidence_popup.tscn")
var current_evidence_popup: Control

var current_room: String = "house_exterior"
var room_history: Array[String] = []
var is_transitioning: bool = false

func _ready():
	EventBus.evidence_popup_requested.connect(_on_evidence_popup_requested)

func change_room(new_room: String) -> void:
	if is_transitioning or new_room == current_room:
		return
	var world = get_tree().current_scene.get_node("World")
	if not world:
		push_error("World node not found in the current scene.")
		return
	is_transitioning = true
	var old_scene = null
	if world.get_child_count() > 0:
		old_scene = world.get_child(0)
	var room_path = "res://scenes/rooms/%s.tscn" % new_room
	if old_scene:
		# var transition_manager = get_node("/root/TransitionManager")
		# if transition_manager:
		# 	transition_manager.paper_crumple_transition(old_scene, room_path, world)
		# 	await transition_manager.transition_completed
		# else:
		# 	# Fallback to immediate transition if TransitionManager not found
		old_scene.queue_free()
		var room_scene = load(room_path)
		if room_scene:
			var room_instance = room_scene.instantiate()
			world.add_child(room_instance)
	else:
		var room_scene = load(room_path)
		if not room_scene:
			push_error("Failed to load room scene: " + room_path)
			is_transitioning = false
			return
		var room_instance = room_scene.instantiate()
		world.add_child(room_instance)
	if current_room != new_room:
		room_history.append(current_room)
		current_room = new_room
	is_transitioning = false

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
