@tool
class_name EvidenceResource
extends Resource

@export var id: String
@export var name: String
@export var description: String
@export var image: Texture2D : set = set_evidence_image
@export var hero_image: Texture2D : set = set_evidence_hero_image
@export var shows_in_background: bool = true : set = set_evidence_shows_in_background

func set_evidence_image(value: Texture2D):
    image = value
    emit_changed()

func set_evidence_hero_image(value: Texture2D):
    hero_image = value
    emit_changed()

func set_evidence_shows_in_background(value: bool):
    shows_in_background = value
    emit_changed()
