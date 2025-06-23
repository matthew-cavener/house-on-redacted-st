class_name EvidencePopup
extends Control

@onready var background: ColorRect = $Background
@onready var popup_container: Control = $PopupContainer
@onready var hero_layout: HBoxContainer = $PopupContainer/HeroLayout
@onready var hero_image: TextureRect = $PopupContainer/HeroLayout/HeroImage
@onready var hero_text_background: TextureRect = $PopupContainer/HeroLayout/TextBackgroundTexture
@onready var hero_text: RichTextLabel = $PopupContainer/HeroLayout/TextBackgroundTexture/HeroText
@onready var close_area: Control = $CloseArea

var current_evidence: EvidenceResource

func _ready():
	hide()
	close_area.gui_input.connect(_on_close_area_input)

func show_evidence(evidence: EvidenceResource):
	current_evidence = evidence
	_setup_display()
	show()

func _setup_display():
	if not current_evidence:
		return
	hero_layout.show()
	hero_text.text = current_evidence.description
	var notepad_width = 350
	hero_text_background.custom_minimum_size.x = notepad_width
	hero_text_background.size_flags_horizontal = Control.SIZE_SHRINK_CENTER

	if current_evidence.hero_image:
		hero_image.show()
		hero_image.texture = current_evidence.hero_image
		hero_image.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hero_image.custom_minimum_size.x = 400
		hero_layout.alignment = BoxContainer.ALIGNMENT_BEGIN
	else:
		hero_image.hide()
		hero_layout.alignment = BoxContainer.ALIGNMENT_CENTER
	hero_text.fit_content = true

func _on_close_area_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed:
		hide()

func _input(event: InputEvent):
	if visible and event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			hide()
