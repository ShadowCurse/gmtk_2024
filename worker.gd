extends CharacterBody3D
class_name Worker

@onready var marker_3d = $Marker3D

@export var red_resource: PackedScene
@export var green_resource: PackedScene
@export var blue_resource: PackedScene
@export var type: ResourcePoint.Type = ResourcePoint.Type.Red
@export var speed: float = 2.0

var resource_hub: ResourceHub
var resource_point: ResourcePoint
var item: Node3D
var target: Vector3
var has_item: bool = false

func _ready():
    self.target = self.resource_point.position
    match self.type:
        ResourcePoint.Type.Red: 
            var r = self.red_resource.instantiate()
            r.position = self.marker_3d.position
            r.visible = false
            self.add_child(r)
            self.item = r
        ResourcePoint.Type.Green: 
            var r = self.green_resource.instantiate()
            r.position = self.marker_3d.position
            r.visible = false
            self.add_child(r)
            self.item = r
        ResourcePoint.Type.Blue: 
            var r = self.blue_resource.instantiate()
            r.position = self.marker_3d.position
            r.visible = false
            self.add_child(r)
            self.item = r

func _process(delta):
    if Input.is_action_pressed("ui_up"):
        self.velocity += -global_transform.basis.z * speed * delta
    if Input.is_action_pressed("ui_down"):
        self.velocity += global_transform.basis.z * speed * delta
    if Input.is_action_pressed("ui_left"):
        self.velocity += -global_transform.basis.x * speed * delta
    if Input.is_action_pressed("ui_right"):
        self.velocity += global_transform.basis.x * speed * delta

    var from_center = self.position.normalized()
    self.up_direction = from_center
    self.rotation = Quaternion(Vector3.UP, from_center).get_euler()
    self.velocity += -from_center * 9.8 * delta


    var to_resource = self.position.direction_to(target).normalized()
    var normal = self.position.normalized()
    var angle = to_resource.angle_to(normal) - PI / 2
    var rotation_axis = to_resource.cross(normal).normalized()
    var to_resource_norm = to_resource.rotated(rotation_axis, angle).normalized()
    var rotation_angle = (-global_transform.basis.z).angle_to(to_resource_norm)
    if target.y < self.position.y:
        rotation_angle = 2.0 *PI - rotation_angle
    self.rotate(normal, rotation_angle)

    self.velocity += to_resource * speed * delta
    move_and_slide()

    for i in range(self.get_slide_collision_count()):
        var collision = self.get_slide_collision(i)
        var collider = collision.get_collider()
        if collider is ResourceHub:
            if self.has_item:
                collider.add_resource(self.type)
                self.has_item = false
                self.item_visible(false)
                self.target = self.resource_point.position
        elif collider is Worker:
            self.has_item = false
            self.velocity += self.position.normalized() * 5.0
            self.item_visible(false)
            self.target = self.resource_point.position
            match self.type:
                ResourcePoint.Type.Red: 
                    var r: WorkerResource = self.red_resource.instantiate()
                    r.position = self.to_global(self.item.position)
                    r.linear_velocity = self.velocity
                    r.start = true
                    get_tree().root.add_child(r)
                ResourcePoint.Type.Green: 
                    var r: WorkerResource = self.green_resource.instantiate()
                    r.position = self.to_global(self.item.position)
                    r.linear_velocity = self.velocity
                    r.start = true
                    get_tree().root.add_child(r)
                ResourcePoint.Type.Blue: 
                    var r: WorkerResource = self.blue_resource.instantiate()
                    r.position = self.to_global(self.item.position)
                    r.linear_velocity = self.velocity
                    r.start = true
                    get_tree().root.add_child(r)

func go_to_hub():
    self.has_item = true
    self.item_visible(true)
    self.target = self.resource_hub.position

func item_visible(v: bool):
    if self.item:
        item.visible = v
