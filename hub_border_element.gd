extends Node3D
class_name ResourceHubBorderElement

@onready var mesh_instance_3d = $MeshInstance3D

var color: Color

func _ready():
	self.mesh_instance_3d.get_surface_override_material(0).albedo_color = self.color

