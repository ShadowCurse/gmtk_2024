extends Node3D
class_name Worker

@export var speed: float = 20.0

@onready var ray_cast_3d = $RayCast3D

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    if Input.is_action_pressed("ui_up"):
        self.position += -global_transform.basis.z * speed * delta
    if Input.is_action_pressed("ui_down"):
        self.position += global_transform.basis.z * speed * delta
    if Input.is_action_pressed("ui_left"):
        self.position += -global_transform.basis.x * speed * delta
    if Input.is_action_pressed("ui_right"):
        self.position += global_transform.basis.x * speed * delta
        
    var to_center = self.position.normalized()
    self.position = to_center * 100.0
    rotation = Quaternion(Vector3.UP, to_center).get_euler()
    
