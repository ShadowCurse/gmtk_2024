extends CharacterBody3D
class_name Worker

@export var speed: float = 2.0

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
    print(self.velocity)
    move_and_slide()
