extends CharacterBody3D
class_name Worker

@onready var item = $item

@export var type: ResourcePoint.Type = ResourcePoint.Type.Red
@export var speed: float = 2.0

var resource_hub: ResourceHub
var resource_point: ResourcePoint

var target: Vector3

func _ready():
    self.target = self.resource_point.position
    self.item.visible = false
    match self.type:
        ResourcePoint.Type.Red: self.item.get_surface_override_material(0).albedo_color = Color.RED
        ResourcePoint.Type.Green: self.item.get_surface_override_material(0).albedo_color = Color.GREEN
        ResourcePoint.Type.Blue: self.item.get_surface_override_material(0).albedo_color = Color.BLUE

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
            self.item.visible = false
            self.target = self.resource_point.position
        elif collider is Worker:
            self.velocity += self.position.normalized() * 5.0
            self.item.visible = false
            self.target = self.resource_point.position

func go_to_hub():
    self.item.visible = true
    self.target = self.resource_hub.position
