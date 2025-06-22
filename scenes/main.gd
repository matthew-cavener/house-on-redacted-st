extends Node

@onready var room_history_label: RichTextLabel = $GUI/RichTextLabel

func _ready():
	GameManager.change_room("house_exterior")
	$GUI/Button.pressed.connect(_on_room_button_pressed.bind("garage"))
	$GUI/Button2.pressed.connect(_on_room_button_pressed.bind("grace_room"))
	$GUI/Button3.pressed.connect(_on_room_button_pressed.bind("house_exterior"))
	$GUI/Button4.pressed.connect(_on_room_button_pressed.bind("kitchen"))
	$GUI/Button5.pressed.connect(_on_room_button_pressed.bind("living_room"))
	$GUI/Button6.pressed.connect(_on_room_button_pressed.bind("parent_room"))
	_update_room_history_display()

func _on_room_button_pressed(room_name: String):
	GameManager.change_room(room_name)
	_update_room_history_display()

func _update_room_history_display():
	var history_text = "Room History:\n"
	history_text += GameManager.current_room + "\n"
	var reversed_history = GameManager.room_history.duplicate()
	reversed_history.reverse()
	for room in reversed_history:
		history_text += room + "\n"
	room_history_label.text = history_text
	room_history_label.fit_content = true
	room_history_label.size.y = room_history_label.get_content_height()
