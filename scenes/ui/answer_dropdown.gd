@tool
class_name AnswerDropdown
extends OptionButton

@export var dropdown_field: DropdownField : set = set_dropdown_field

signal selection_changed(field_name: String, selected_value: String)

func _ready():
	if not Engine.is_editor_hint():
		item_selected.connect(_on_item_selected)
	_setup_redaction_style()

func set_dropdown_field(field: DropdownField):
	dropdown_field = field
	if field:
		if is_inside_tree():
			_setup_options()

func _setup_options():
	if not dropdown_field:
		return
	clear()
	for option in dropdown_field.options:
		add_item(option)
	select(-1)
	allow_reselect = true

func _on_item_selected(index: int):
	if not dropdown_field:
		return
	var selected_text = ""
	if index >= 0 and index < get_item_count():
		selected_text = get_item_text(index)
	selection_changed.emit(dropdown_field.field_name, selected_text)

func get_selected_value() -> String:
	if selected >= 0 and selected < get_item_count():
		return get_item_text(selected)
	return ""

func reset_selection():
	select(-1)

func _setup_redaction_style():
	var font = load("res://assets/fonts/Caveat-VariableFont_wght.ttf") as FontFile
	var transparent_style = StyleBoxFlat.new()
	transparent_style.bg_color = Color(0.0, 0.0, 0.0, 0.0)
	transparent_style.border_width_left = 0
	transparent_style.border_width_right = 0
	transparent_style.border_width_top = 0
	transparent_style.border_width_bottom = 0
	add_theme_stylebox_override("normal", transparent_style)
	add_theme_stylebox_override("hover", transparent_style)
	add_theme_stylebox_override("pressed", transparent_style)
	add_theme_stylebox_override("focus", transparent_style)
	add_theme_stylebox_override("disabled", transparent_style)
	if font:
		add_theme_font_override("font", font)
		_update_font_size_to_fit()
	add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
	add_theme_color_override("font_hover_color", Color(0.95, 0.95, 0.95, 1.0))
	add_theme_color_override("font_pressed_color", Color(0.9, 0.9, 0.9, 1.0))
	add_theme_color_override("font_focus_color", Color(1.0, 1.0, 1.0, 1.0))
	add_theme_color_override("font_disabled_color", Color(0.8, 0.8, 0.8, 1.0))
	var transparent_texture = ImageTexture.new()
	var image = Image.create(1, 1, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))  # Transparent
	transparent_texture.set_image(image)
	add_theme_icon_override("arrow", transparent_texture)
	alignment = HORIZONTAL_ALIGNMENT_CENTER

func _update_font_size_to_fit():
	if size.y <= 0:
		add_theme_font_size_override("font_size", 16)
		return
	var optimal_font_size = max(10, min(32, int(size.y * 0.8)))
	add_theme_font_size_override("font_size", optimal_font_size)

func _notification(what):
	if what == NOTIFICATION_RESIZED:
		_update_font_size_to_fit()
