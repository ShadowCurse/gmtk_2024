extends Node3D
class_name Planet

@onready var planet_mesh: MeshInstance3D = $planet_mesh
@onready var camera_3d: Camera3D = $Camera3D

var axis_rotation_speed: float = 0.1
var mouse_input: Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.rotate_y(axis_rotation_speed * delta)
	
	# update camera
	var to_camera = camera_3d.position - planet_mesh.position
	var r = to_camera.length()
	var theta = acos(to_camera.y / r)
	var phi = sign(to_camera.x) * acos(to_camera.z / sqrt(to_camera.z * to_camera.z + to_camera.x * to_camera.x))
	phi += mouse_input.x * 0.01
	theta += mouse_input.y * 0.01
	# clamp Y rotation
	if theta < 0.1:
		theta = 0.1
	if theta > PI - 0.1:
		theta = PI - 0.1
	var new_z = r * sin(theta) * cos(phi)
	var new_x = r * sin(theta) * sin(phi)
	var new_y = r * cos(theta)
	var new_position = Vector3(new_x, new_y, new_z)
	camera_3d.position = new_position
	camera_3d.look_at(planet_mesh.global_position)
	
	mouse_input = Vector2.ZERO

func _unhandled_input(event)-> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
		if event is InputEventMouseMotion:
			var viewport_transform: Transform2D = get_tree().root.get_final_transform()
			mouse_input += event.xformed_by(viewport_transform).relative

