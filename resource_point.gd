extends Node3D
class_name ResourcePoint

@onready var mesh_instance_3d = $MeshInstance3D

enum Type {
	Red,
	Green,
	Blue,
}

@export var type: Type = Type.Red

# Called when the node enters the scene tree for the first time.
func _ready():
	match type:
		Type.Red: mesh_instance_3d.get_surface_override_material(0).albedo_color = Color.RED
		Type.Green: mesh_instance_3d.get_surface_override_material(0).albedo_color = Color.GREEN
		Type.Blue: mesh_instance_3d.get_surface_override_material(0).albedo_color = Color.BLUE

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
