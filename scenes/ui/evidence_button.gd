@tool
class_name EvidenceButton
extends TextureButton

signal evidence_clicked(evidence_id: String)

@export var evidence_resource: EvidenceResource : set = set_evidence_resource

func _ready():
    pressed.connect(_on_pressed)
    _update_texture()

func set_evidence_resource(value: EvidenceResource):
    evidence_resource = value
    _update_texture()

func _update_texture():
    if evidence_resource and evidence_resource.image:
        texture_normal = evidence_resource.image

func _on_pressed():
    evidence_clicked.emit(evidence_resource)
    EventBus.object_interacted.emit(evidence_resource)
