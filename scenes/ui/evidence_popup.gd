class_name EvidencePopup
extends Control

@onready var background: ColorRect = $Background
@onready var popup_container: Control = $PopupContainer
@onready var hero_layout: HBoxContainer = $PopupContainer/HeroLayout
@onready var hero_image: TextureRect = $PopupContainer/HeroLayout/HeroImage
@onready var hero_text_background: TextureRect = $PopupContainer/HeroLayout/TextBackgroundTexture
@onready var hero_text: RichTextLabel = $PopupContainer/HeroLayout/TextBackgroundTexture/HeroText
@onready var overlay_layout: Control = $PopupContainer/OverlayLayout
@onready var overlay_image: TextureRect = $PopupContainer/OverlayLayout/OverlayImage
@onready var description_texture: TextureRect = $PopupContainer/OverlayLayout/DescriptionTexture
@onready var description_label: RichTextLabel = $PopupContainer/OverlayLayout/DescriptionLabel
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

	if current_evidence.hero_image:
		hero_layout.show()
		overlay_layout.hide()
		hero_image.texture = current_evidence.hero_image
		hero_text.text = current_evidence.description
		hero_image.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hero_image.custom_minimum_size.x = 400
		hero_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hero_text.fit_content = true
	else:
		hero_layout.hide()
		overlay_layout.show()
		overlay_image.texture = current_evidence.image
		overlay_image.modulate = Color(1, 1, 1, 0.4)
		description_label.text = current_evidence.description

func _on_close_area_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed:
		hide()

func _input(event: InputEvent):
	if visible and event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			hide()
