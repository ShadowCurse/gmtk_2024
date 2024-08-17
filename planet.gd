extends Node3D
class_name Planet

@export var resource_point_scene: PackedScene
@export var resource_hub_scene: PackedScene

@export var axis_rotation_speed: float = 0.1
@export var camera_speed: float = 0.001 
@export var camera_follow_speed: float = 40.0
@export var camera_zoom_speed: float = 5.0
@export var camera_distance: float = 150.0
@export var camera_max_distance: float = 500.0
@export var camera_min_distance: float = 120.0

@onready var planet_mesh: MeshInstance3D = $planet_mesh
@onready var camera_3d: Camera3D = $Camera3D
@onready var debug_cursor = $debug_cursor

var planet_radius: float = 100.0
var mouse_input: Vector2

var camera_theta: float = 0.0
var camera_phi: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.rotate_y(axis_rotation_speed * delta)
	
	# update camera
	camera_phi -= mouse_input.x * camera_speed
	camera_theta -= mouse_input.y * camera_speed
	# clamp Y rotation
	if camera_theta < 0.1:
		camera_theta = 0.1
	if camera_theta > PI - 0.1:
		camera_theta = PI - 0.1
	var new_z = camera_distance * sin(camera_theta) * cos(camera_phi)
	var new_x = camera_distance * sin(camera_theta) * sin(camera_phi)
	var new_y = camera_distance * cos(camera_theta)
	var new_position = Vector3(new_x, new_y, new_z)
	camera_3d.position = new_position + (camera_3d.position - new_position) * exp(-camera_follow_speed * delta)
	camera_3d.look_at(planet_mesh.global_position)
	mouse_input = Vector2.ZERO
	
	var mouse_pos = camera_3d.get_viewport().get_mouse_position()
	var ray_origin = camera_3d.project_position(mouse_pos, position.z)
	var ray_direction = (ray_origin - camera_3d.global_position).normalized();
	
	var desc = pow(ray_direction.dot(ray_origin - planet_mesh.global_position), 2) \
	 		 - pow((ray_origin - planet_mesh.global_position).length(), 2) \
			 + pow(planet_radius, 2)
	if desc >= 0.0:
		#var d1 = -ray_direction.dot(ray_origin - planet_mesh.global_position) + sqrt(desc)
		var d2 = -ray_direction.dot(ray_origin - planet_mesh.global_position) - sqrt(desc)
		#var p1 = ray_origin + ray_direction * d1
		var p2 = ray_origin + ray_direction * d2
		debug_cursor.global_position = p2
		
		var local_position = self.to_local(p2)
		
		# TODO find a more accurate version
		var up = local_position.normalized()
		var a = up.cross(Vector3.UP)
		var b = up.cross(a)
		var new_basis = Basis(a, up, b)
		
		if Input.is_action_just_pressed("place_resource"):
			var resource_point: Node3D = resource_point_scene.instantiate()
			resource_point.position = local_position
			resource_point.rotation = new_basis.get_euler()
			self.add_child(resource_point)
		if Input.is_action_just_pressed("place_hub"):
			var resource_hub: Node3D = resource_hub_scene.instantiate()
			resource_hub.position = local_position
			resource_hub.rotation = new_basis.get_euler()
			self.add_child(resource_hub)

func _unhandled_input(event)-> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_WHEEL_UP):
		camera_distance -= camera_zoom_speed
		if camera_distance < camera_min_distance:
			camera_distance = camera_min_distance
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_WHEEL_DOWN):
		camera_distance += camera_zoom_speed
		if camera_max_distance < camera_distance:
			camera_distance = camera_max_distance

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
		if event is InputEventMouseMotion:
			var viewport_transform: Transform2D = get_tree().root.get_final_transform()
			mouse_input += event.xformed_by(viewport_transform).relative
			

