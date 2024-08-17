extends Node3D
class_name Planet

@export var resource_point_scene: PackedScene

@onready var planet_mesh: MeshInstance3D = $planet_mesh
@onready var camera_3d: Camera3D = $Camera3D
@onready var debug_cursor = $debug_cursor

var planet_radius: float = 0.5
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
	
	var mouse_pos = camera_3d.get_viewport().get_mouse_position()
	var ray_origin = camera_3d.project_position(mouse_pos, position.z)
	var ray_direction = (ray_origin - camera_3d.global_position).normalized();
	
	var desc = pow(ray_direction.dot(ray_origin - planet_mesh.global_position), 2) \
	 		 - pow((ray_origin - planet_mesh.global_position).length(), 2) \
			 + pow(planet_mesh.scale.x * planet_radius, 2)
	if desc >= 0.0:
		var d1 = -ray_direction.dot(ray_origin - planet_mesh.global_position) + sqrt(desc)
		var d2 = -ray_direction.dot(ray_origin - planet_mesh.global_position) - sqrt(desc)
		var p1 = ray_origin + ray_direction * d1
		var p2 = ray_origin + ray_direction * d2
		debug_cursor.global_position = p2
		if Input.is_action_just_pressed("ui_accept"):
			var local_position = self.to_local(p2)
			var resource_point: Node3D = resource_point_scene.instantiate()
			resource_point.position = local_position
			
			# TODO find a more accurate version
			var up = local_position.normalized()
			var a = up.cross(Vector3.UP)
			var b = up.cross(a)
			var new_basis = Basis(a, up, b)
			resource_point.rotation = new_basis.get_euler()
			
			self.add_child(resource_point)

func _unhandled_input(event)-> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
		if event is InputEventMouseMotion:
			var viewport_transform: Transform2D = get_tree().root.get_final_transform()
			mouse_input += event.xformed_by(viewport_transform).relative

