extends Node

signal transition_completed

# var crumple_shader = preload("res://assets/shaders/paper_crumple.gdshader")
var transition_duration: float = 1.5
var current_material: ShaderMaterial

# recursively apply the shader to all sprites and textures in the scene
