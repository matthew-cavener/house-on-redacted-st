@tool
class_name EvidenceButton
extends TextureButton

signal evidence_clicked(evidence_id: String)

@export var evidence_resource: EvidenceResource : set = set_evidence_resource
var evidence_indicator: AnimatedSprite2D

func _ready():
    _create_evidence_indicator()
    randomize()
    var random_frame = randi() % evidence_indicator.sprite_frames.get_frame_count("indicator")
    evidence_indicator.frame = random_frame
    evidence_indicator.play("indicator")
    pressed.connect(_on_pressed)
    _update_texture()

func _create_evidence_indicator():
    evidence_indicator = AnimatedSprite2D.new()
    evidence_indicator.name = "EvidenceIndicator"
    var sprite_frames = _create_indicator_sprite_frames()
    evidence_indicator.sprite_frames = sprite_frames
    evidence_indicator.animation = "indicator"
    evidence_indicator.position = size / 2
    evidence_indicator.scale = Vector2(2, 2)
    evidence_indicator.z_index = 1
    add_child(evidence_indicator)

func _create_indicator_sprite_frames() -> SpriteFrames:
    var sprite_frames = SpriteFrames.new()
    var atlas_texture = load("res://assets/sprites/S001_nyknck.png") as Texture2D
    var regions = [
        Rect2(0, 0, 32, 32),
        Rect2(32, 0, 32, 32),
        Rect2(64, 0, 32, 32),
        Rect2(96, 0, 32, 32),
        Rect2(64, 0, 32, 32),
        Rect2(32, 0, 32, 32)
    ]

    sprite_frames.add_animation("indicator")
    sprite_frames.set_animation_loop("indicator", true)
    sprite_frames.set_animation_speed("indicator", 5.0)

    for region in regions:
        var atlas_frame = AtlasTexture.new()
        atlas_frame.atlas = atlas_texture
        atlas_frame.region = region
        sprite_frames.add_frame("indicator", atlas_frame)

    return sprite_frames

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

func _on_evidence_resource_changed():
    _update_texture()
    update_configuration_warnings()

func _update_texture():
    if evidence_resource and evidence_resource.image and evidence_resource.shows_in_background:
        texture_normal = evidence_resource.image
    else:
        texture_normal = null
    if Engine.is_editor_hint():
        notify_property_list_changed()

func _on_pressed():
    evidence_clicked.emit(evidence_resource)
    EventBus.object_interacted.emit(evidence_resource)
    EventBus.evidence_popup_requested.emit(evidence_resource)
