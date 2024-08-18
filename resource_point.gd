extends Node3D
class_name ResourcePoint

@onready var pile_red = $pile_red
@onready var pile_green = $pile_green
@onready var pile_blue = $pile_blue

enum Type {
    Red,
    Green,
    Blue,
}

@export var type: Type = Type.Red

# Called when the node enters the scene tree for the first time.
func _ready():
    match type:
        Type.Red: pile_red.visible = true
        Type.Green: pile_green.visible = true
        Type.Blue: pile_blue.visible = true
        
    var random_angle = randf_range(0.0, 2.0 * PI)
    self.rotate_object_local(Vector3.UP, random_angle)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass
