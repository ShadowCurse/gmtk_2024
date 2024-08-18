extends CharacterBody3D
class_name Worker

@export var speed: float = 2.0

var resource_point: ResourcePoint

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
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


    var to_resource = self.position.direction_to(resource_point.position).normalized()
    var normal = self.position.normalized()

    var angle = to_resource.angle_to(normal) - PI / 2
    var rotation_axis = to_resource.cross(normal)
    var to_resource_norm = to_resource.rotated(rotation_axis, angle).normalized()
    var rotation_angle = (-global_transform.basis.z).angle_to(to_resource_norm)

    if resource_point.position.y < self.position.y:
        rotation_angle = 2.0 *PI - rotation_angle

    self.rotate(normal, rotation_angle)
    print(rad_to_deg(rotation_angle))

    self.velocity += to_resource * speed * delta
    
    move_and_slide()
