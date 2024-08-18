extends Node3D
class_name ResourceHub

@export var border_element_scene: PackedScene
@export var border_angle: float = PI / 32.0
@export var border_elements: int = 32

@onready var mesh_instance_3d = $MeshInstance3D

enum Type {
    Red,
    Green,
    Blue,
}

@export var type: Type = Type.Red

func _ready():
    var color = self.type_to_color(self.type)
    mesh_instance_3d.get_surface_override_material(0).albedo_color = color

func _process(delta):
    pass

func type_to_color(t: Type) -> Color:
    match t:
        Type.Red: return Color.RED
        Type.Green: return  Color.GREEN
        Type.Blue: return  Color.BLUE
    return Color.WHITE

func create_border():
    var to_self = self.position.normalized()
    var right = Vector3.UP.cross(to_self).normalized()
    var first_border_element_position = self.position.rotated(right, self.border_angle)
    var color = self.type_to_color(self.type)
    var angle = 2 * PI / self.border_elements
    for i in range(self.border_elements):
        var p = first_border_element_position.rotated(to_self, angle * i)
        var e: ResourceHubBorderElement = self.border_element_scene.instantiate()
        e.position = self.to_local(p)
        e.color = color
        self.add_child(e)

