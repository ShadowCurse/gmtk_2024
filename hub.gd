extends Node3D
class_name ResourceHub

@export var planet: Node3D
@export var worker_scene: PackedScene
@export var border_element_scene: PackedScene
@export var border_angle: float = PI / 16.0
@export var border_elements: int = 32

enum Type {
    Red,
    Green,
    Blue,
}

@export var type: Type = Type.Red

@onready var hub_blue_lvl_1 = $hub_blue_lvl1
@onready var hub_blue_lvl_2 = $hub_blue_lvl2
@onready var hub_blue_lvl_3 = $hub_blue_lvl3
@onready var hub_green_lvl_1 = $hub_green_lvl1
@onready var hub_green_lvl_2 = $hub_green_lvl2
@onready var hub_green_lvl_3 = $hub_green_lvl3
@onready var hub_red_lvl_1 = $hub_red_lvl1
@onready var hub_red_lvl_2 = $hub_red_lvl2
@onready var hub_red_lvl_3 = $hub_red_lvl3

class ResourceInfo:
    var resource: ResourcePoint
    var workers: Array[Worker]

var resources: Array[ResourceInfo]
# Determine number of workes per resource
var level: int = 1

func _ready():
    match self.type:
        Type.Red: self.hub_red_lvl_1.visible = true
        Type.Green: self.hub_green_lvl_1.visible = true
        Type.Blue: self.hub_blue_lvl_1.visible = true
    
    self.create_border()
    self.update_workers()
    
    var random_angle = randf_range(0.0, 2.0 * PI)
    self.rotate_object_local(Vector3.UP, random_angle)

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

func select_resource_points(points: Array[ResourcePoint]):
    for p in points:
        # skip if already present
        var c = false
        for ri in self.resources:
            if p == ri.resource:
                c = true
                break
        if c:
            continue

        var angle = p.position.angle_to(self.position)
        if angle < self.border_angle:
            var ri = ResourceInfo.new()
            ri.resource = p
            self.resources.append(ri)

func update_workers():
    for ri in self.resources:
        self.spawn_worker_to_resource(ri)

func spawn_worker_to_resource(resource: ResourceInfo):
    if resource.workers.size() == self.level:
        return

    var to_resource = (resource.resource.position - self.position).normalized()
    var worker: Worker = self.worker_scene.instantiate()
    worker.position = self.position + to_resource * 3.0
    worker.resource_hub = self
    worker.resource_point = resource.resource
    resource.workers.append(worker)
    planet.add_child(worker)
