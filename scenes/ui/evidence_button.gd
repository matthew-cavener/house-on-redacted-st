@tool
class_name EvidenceButton
extends TextureButton

signal evidence_clicked(evidence_id: String)

@export var evidence_resource: EvidenceResource : set = set_evidence_resource

func _ready():
    pressed.connect(_on_pressed)
    _update_texture()

func _get_configuration_warnings():
    var warnings = []
    if not evidence_resource:
        warnings.append("EvidenceButton is missing an EvidenceResource")
    return warnings

func set_evidence_resource(value: EvidenceResource):
    evidence_resource = value
    _update_texture()
    update_configuration_warnings()

func _update_texture():
    if evidence_resource and evidence_resource.image:
        texture_normal = evidence_resource.image

func _on_pressed():
    evidence_clicked.emit(evidence_resource)
    EventBus.object_interacted.emit(evidence_resource)
    EventBus.evidence_popup_requested.emit(evidence_resource)
