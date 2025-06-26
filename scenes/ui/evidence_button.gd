@tool
class_name EvidenceButton
extends TextureButton

signal evidence_clicked(evidence_id: String)
@export var evidence_resource: EvidenceResource : set = set_evidence_resource

const DEFAULT_OUTLINE_ENABLED: bool = true
const DEFAULT_OUTLINE_SCALE: float = 1.08
const DEFAULT_OUTLINE_COLOR_NORMAL: Color = Color(1.0, 0.5, 0.0, 0.9)
const DEFAULT_OUTLINE_COLOR_HOVERED: Color = Color(1.0, 1.0, 0.0, 1.0)
const DEFAULT_OUTLINE_COLOR_CLICKED: Color = Color(0.7, 0.8, 0.6, 0.6)
const DEFAULT_BUTTON_COLOR_NORMAL: Color = Color.WHITE
const DEFAULT_BUTTON_COLOR_HOVERED: Color = Color(1.2, 1.1, 0.9, 1.0)
const DEFAULT_ROTATION_ENABLED: bool = false
const DEFAULT_ROTATION_RATE: float = -0.25

@export_group("Outline Settings")
@export var outline_enabled: bool = DEFAULT_OUTLINE_ENABLED : set = set_outline_enabled
@export var outline_scale: float = DEFAULT_OUTLINE_SCALE : set = set_outline_scale
@export var outline_color_normal: Color = DEFAULT_OUTLINE_COLOR_NORMAL : set = set_outline_color_normal
@export var outline_color_hovered: Color = DEFAULT_OUTLINE_COLOR_HOVERED : set = set_outline_color_hovered
@export var outline_color_clicked: Color = DEFAULT_OUTLINE_COLOR_CLICKED : set = set_outline_color_clicked
@export_group("Button Hover")
@export var button_color_normal: Color = DEFAULT_BUTTON_COLOR_NORMAL : set = set_button_color_normal
@export var button_color_hovered: Color = DEFAULT_BUTTON_COLOR_HOVERED : set = set_button_color_hovered
@export_group("Rotation Options")
@export var rotation_enabled: bool = DEFAULT_ROTATION_ENABLED : set = set_rotation_enabled
@export var rotation_rate: float = DEFAULT_ROTATION_RATE : set = set_rotation_rate
@export_group("Editor Tools")
@export var reset_button: bool = false : set = _on_reset_button_pressed

var outline_sprite: Sprite2D
var has_been_clicked: bool = false

func _ready():
    pressed.connect(_on_pressed)
    mouse_entered.connect(_on_mouse_entered)
    mouse_exited.connect(_on_mouse_exited)
    modulate = button_color_normal
    _update_outline_enabled_from_resource()
    _setup_outline()
    _update_texture()

func _enter_tree():
    if Engine.is_editor_hint() and evidence_resource:
        call_deferred("_setup_existing_button_in_editor")

func _setup_existing_button_in_editor():
    if Engine.is_editor_hint() and evidence_resource:
        _update_outline_enabled_from_resource()
        _setup_outline()

func _update_outline_enabled_from_resource():
    if evidence_resource:
        outline_enabled = evidence_resource.shows_in_background
    if Engine.is_editor_hint():
        _setup_outline()

func _setup_outline():
    if outline_sprite:
        outline_sprite.queue_free()
        outline_sprite = null

    if outline_enabled and evidence_resource and evidence_resource.image:
        outline_sprite = Sprite2D.new()
        add_child(outline_sprite)
        outline_sprite.show_behind_parent = true
        _update_outline()

func _update_outline():
    if not outline_sprite or not evidence_resource or not evidence_resource.image:
        return
    outline_sprite.texture = evidence_resource.image
    outline_sprite.flip_h = flip_h
    outline_sprite.flip_v = flip_v
    _update_outline_position()
    _update_outline_color()

func _update_outline_color():
    if not outline_sprite:
        return
    if has_been_clicked:
        outline_sprite.modulate = outline_color_clicked
    else:
        outline_sprite.modulate = outline_color_normal

func _get_configuration_warnings():
    var warnings = []
    if not evidence_resource:
        warnings.append("EvidenceButton is missing an EvidenceResource")
    return warnings

func set_evidence_resource(value: EvidenceResource):
    if evidence_resource and evidence_resource.changed.is_connected(_on_evidence_resource_changed):
        evidence_resource.changed.disconnect(_on_evidence_resource_changed)
    evidence_resource = value
    if evidence_resource:
        evidence_resource.changed.connect(_on_evidence_resource_changed)
    _on_evidence_resource_changed()
    if Engine.is_editor_hint():
        _update_outline_enabled_from_resource()
        _setup_outline()

func _on_evidence_resource_changed():
    _update_outline_enabled_from_resource()
    _update_texture()
    _setup_outline()
    update_configuration_warnings()
    if Engine.is_editor_hint():
        notify_property_list_changed()

func _update_texture():
    if evidence_resource and evidence_resource.image and evidence_resource.shows_in_background:
        texture_normal = evidence_resource.image
    else:
        texture_normal = null
    if Engine.is_editor_hint():
        notify_property_list_changed()

func _on_pressed():
    has_been_clicked = true
    _update_outline_color()
    evidence_clicked.emit(evidence_resource)
    EventBus.object_interacted.emit(evidence_resource)
    EventBus.evidence_popup_requested.emit(evidence_resource)

func _on_mouse_entered():
    if outline_sprite and not has_been_clicked:
        outline_sprite.modulate = outline_color_hovered
    modulate = button_color_hovered

func _on_mouse_exited():
    if outline_sprite:
        _update_outline_color()
    modulate = button_color_normal

func set_outline_enabled(value: bool):
    outline_enabled = value
    if is_inside_tree() or Engine.is_editor_hint():
        if not outline_enabled and outline_sprite and is_instance_valid(outline_sprite):
            outline_sprite.queue_free()
            outline_sprite = null
        else:
            _setup_outline()

func set_outline_scale(value: float):
    outline_scale = value
    if outline_sprite or Engine.is_editor_hint():
        _update_outline_position()

func set_outline_color_normal(value: Color):
    outline_color_normal = value
    if outline_sprite or Engine.is_editor_hint():
        _update_outline_color()

func set_outline_color_hovered(value: Color):
    outline_color_hovered = value

func set_outline_color_clicked(value: Color):
    outline_color_clicked = value
    if outline_sprite and has_been_clicked or Engine.is_editor_hint():
        _update_outline_color()

func set_button_color_normal(value: Color):
    button_color_normal = value
    if not is_hovered():
        modulate = button_color_normal

func set_button_color_hovered(value: Color):
    button_color_hovered = value
    if is_hovered():
        modulate = button_color_hovered

func set_rotation_enabled(value: bool):
    pass

func set_rotation_rate(value: float):
    pass

func _notification(what):
    match what:
        NOTIFICATION_RESIZED, NOTIFICATION_TRANSFORM_CHANGED:
            if outline_sprite:
                _update_outline_position()
                _update_outline()

func _update_outline_position():
    if not outline_sprite or not evidence_resource or not evidence_resource.image:
        return
    outline_sprite.position = size / 2
    var image_size = evidence_resource.image.get_size()
    var button_size = size
    var scale_x = (button_size.x / image_size.x) * outline_scale
    var scale_y = (button_size.y / image_size.y) * outline_scale
    outline_sprite.scale = Vector2(scale_x, scale_y)

func _exit_tree():
    if outline_sprite and is_instance_valid(outline_sprite):
        outline_sprite.queue_free()
        outline_sprite = null

func reset_to_defaults():
    outline_enabled = DEFAULT_OUTLINE_ENABLED
    outline_scale = DEFAULT_OUTLINE_SCALE
    outline_color_normal = DEFAULT_OUTLINE_COLOR_NORMAL
    outline_color_hovered = DEFAULT_OUTLINE_COLOR_HOVERED
    outline_color_clicked = DEFAULT_OUTLINE_COLOR_CLICKED
    button_color_normal = DEFAULT_BUTTON_COLOR_NORMAL
    button_color_hovered = DEFAULT_BUTTON_COLOR_HOVERED
    _setup_outline()
    modulate = button_color_normal

func _on_reset_button_pressed(value: bool):
    if value and Engine.is_editor_hint():
        reset_to_defaults()
        reset_button = false
        print("EvidenceButton reset to defaults")
