extends Sprite2D
var rotation_speed = -0.5

func _physics_process(_delta):
    rotation_degrees += rotation_speed
