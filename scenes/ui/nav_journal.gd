extends TextureButton

@export var min_unredact_duration: float = 1.5
@export var max_unredact_duration: float = 3.0
@export var slide_distance: float = 773
@export var slide_duration: float = 0.5

var is_slid_up: bool = true
var is_animating: bool = false
var current_tween: Tween
var initial_position: Vector2
var up_position: Vector2
var down_position: Vector2
var forward_button: TextureButton
var normal_nav_container: VBoxContainer
var nexus_nav_container: VBoxContainer
var is_in_nexus: bool = false

func _ready():
	initial_position = position
	up_position = position
	down_position = position + Vector2(0, slide_distance)
	normal_nav_container = $VBoxContainer
	_setup_nexus_navigation()
	$VBoxContainer/HouseExterior.pressed.connect(_on_room_button_pressed.bind("house_exterior"))
	$VBoxContainer/ParentRoom.pressed.connect(_on_room_button_pressed.bind("parent_room"))
	$VBoxContainer/Garage.pressed.connect(_on_room_button_pressed.bind("garage"))
	$VBoxContainer/GraceRoom.pressed.connect(_on_room_button_pressed.bind("grace_room"))
	$VBoxContainer/Kitchen.pressed.connect(_on_room_button_pressed.bind("kitchen"))
	$VBoxContainer/LivingRoom.pressed.connect(_on_room_button_pressed.bind("living_room"))
	EventBus.puzzle_solved.connect(_on_puzzle_solved)
	GameManager.room_changed.connect(_on_room_changed)
	pressed.connect(_on_nav_journal_clicked)
	_update_button_states()
	_on_room_changed()

func _update_button_states():
	$VBoxContainer/HouseExterior.disabled = $VBoxContainer/HouseExterior/HouseExteriorProgressBar.value > 0
	$VBoxContainer/ParentRoom.disabled = $VBoxContainer/ParentRoom/ProgressBar.value > 0
	$VBoxContainer/Garage.disabled = $VBoxContainer/Garage/GarageProgressBar.value > 0
	$VBoxContainer/GraceRoom.disabled = $VBoxContainer/GraceRoom/GraceProgressBar.value > 0
	$VBoxContainer/Kitchen.disabled = $VBoxContainer/Kitchen/KitchenProgressBar.value > 0
	$VBoxContainer/LivingRoom.disabled = $VBoxContainer/LivingRoom/LivingRoomProgressBar.value > 0

func _on_room_button_pressed(room_name: String):
	GameManager.change_room(room_name)

func _on_puzzle_solved(puzzle_id: String):
	match puzzle_id:
		"answer_key_1":
			_unredact_rooms([$VBoxContainer/HouseExterior/HouseExteriorProgressBar])
		"answer_key_2":
			_unredact_rooms([
				$VBoxContainer/LivingRoom/LivingRoomProgressBar,
				$VBoxContainer/Kitchen/KitchenProgressBar
			])
		"answer_key_3":
			_unredact_rooms([
				$VBoxContainer/GraceRoom/GraceProgressBar,
				$VBoxContainer/ParentRoom/ProgressBar
			])
		"answer_key_6":
			_unredact_rooms([$VBoxContainer/Garage/GarageProgressBar])

func _setup_nexus_navigation():
	nexus_nav_container = VBoxContainer.new()
	nexus_nav_container.name = "NexusNavContainer"
	nexus_nav_container.visible = false
	nexus_nav_container.position = normal_nav_container.position
	nexus_nav_container.size = normal_nav_container.size
	nexus_nav_container.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(nexus_nav_container)
	forward_button = TextureButton.new()
	forward_button.name = "ForwardButton"
	var forward_texture = load("res://assets/sprites/ui/nav_journal/navjournalforward.png") as Texture2D
	if forward_texture:
		forward_button.texture_normal = forward_texture
	forward_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	forward_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	forward_button.pressed.connect(_on_forward_pressed)
	nexus_nav_container.add_child(forward_button)

func _on_room_changed():
	var current_room = GameManager.current_room
	is_in_nexus = current_room.begins_with("nexus")
	_update_navigation_display()

func _update_navigation_display():
	if is_in_nexus:
		normal_nav_container.visible = false
		nexus_nav_container.visible = true
	else:
		normal_nav_container.visible = true
		nexus_nav_container.visible = false

func _on_forward_pressed():
	var current_room = GameManager.current_room
	match current_room:
		"nexus1":
			GameManager.change_room("nexus2")
		"nexus2":
			GameManager.change_room("nexus3")
		_:
			pass

func _unredact_rooms(progress_bars: Array[TextureProgressBar]):
	for i in range(progress_bars.size()):
		var progress_bar = progress_bars[i]
		var delay = i * randf_range(0.3, 0.8)
		var timer = get_tree().create_timer(delay)
		timer.timeout.connect(_unredact_room.bind(progress_bar))

func _unredact_room(progress_bar: TextureProgressBar):
	var room_tween = create_tween()
	room_tween.set_ease(Tween.EASE_OUT)
	room_tween.set_trans(Tween.TRANS_CUBIC)
	var random_duration = randf_range(min_unredact_duration, max_unredact_duration)
	room_tween.tween_property(progress_bar, "value", 0.0, random_duration)
	room_tween.tween_callback(_update_button_states)

func _on_nav_journal_clicked():
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

func _stop_current_tween():
	if current_tween and current_tween.is_valid():
		current_tween.kill()
		current_tween = null

func _on_animation_finished():
	is_animating = false
	if current_tween:
		current_tween = null
