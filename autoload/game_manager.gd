extends Node
<<<<<<< Updated upstream
=======

var evidence_popup_scene = preload("res://scenes/ui/evidence_popup.tscn")
var current_evidence_popup: Control

var current_room: String = "house_exterior"
var room_history: Array[String] = []

func _ready():
	EventBus.evidence_popup_requested.connect(_on_evidence_popup_requested)

func change_room(new_room: String) -> void:
	var world = get_tree().current_scene.get_node("World")
	if not world:
		push_error("World node not found in the current scene.")
		return

	for child in world.get_children():
		child.queue_free()

	var room_path = "res://scenes/rooms/%s.tscn" % new_room
	var room_scene = load(room_path)
	if not room_scene:
		push_error("Failed to load room scene: " + room_path)
		return

	var room_instance = room_scene.instantiate()
	world.add_child(room_instance)

	if current_room != new_room:
		room_history.append(current_room)
		current_room = new_room

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
>>>>>>> Stashed changes
