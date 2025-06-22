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
