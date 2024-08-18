extends Node3D
class_name Planet

@export var new_resource_safe_zone: float = PI / 128.0

@export var resource_point_scene: PackedScene
@export var resource_hub_scene: PackedScene

@export var axis_rotation_speed: float = 0.0
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

var selection_point_selected: bool
var selection_point_position: Vector3
var selection_point_normal: Vector3

var resource_points: Array[ResourcePoint]
var resource_hubs: Array[ResourceHub]

func _ready():
    pass # Replace with function body.

func _physics_process(_delta):
    var space_state = get_world_3d().direct_space_state
    var mouse_pos = camera_3d.get_viewport().get_mouse_position()
    var from = camera_3d.project_ray_origin(mouse_pos)
    var to = from + camera_3d.project_ray_normal(mouse_pos) * 1000.0

    var query = PhysicsRayQueryParameters3D.create(from, to)
    var result = space_state.intersect_ray(query)
    if !result.is_empty():
        self.debug_cursor.global_position = result.position

        self.selection_point_selected = true
        self.selection_point_position = result.position
        self.selection_point_normal = result.normal
    else:
        self.selection_point_selected = false

func _process(delta):
    self.rotate_y(self.axis_rotation_speed * delta)
    
    # update camera
    self.camera_phi -= self.mouse_input.x * self.camera_speed
    self.camera_theta -= self.mouse_input.y * self.camera_speed
    # clamp Y rotation
    if self.camera_theta < 0.1:
        self.camera_theta = 0.1
    if self.camera_theta > PI - 0.1:
        self.camera_theta = PI - 0.1
    var new_z = self.camera_distance * sin(self.camera_theta) * cos(self.camera_phi)
    var new_x = self.camera_distance * sin(self.camera_theta) * sin(self.camera_phi)
    var new_y = self.camera_distance * cos(self.camera_theta)
    var new_position = Vector3(new_x, new_y, new_z)
    self.camera_3d.position = new_position + (self.camera_3d.position - new_position) * exp(-self.camera_follow_speed * delta)
    self.camera_3d.look_at(planet_mesh.global_position)
    self.mouse_input = Vector2.ZERO

    if self.selection_point_selected:
        var local_position = self.to_local(self.selection_point_position)
        var local_rotation = Quaternion(Vector3.UP, local_position.normalized()).get_euler()
        
        if Input.is_action_just_pressed("place_resource"):
            var resource_point: ResourcePoint = self.resource_point_scene.instantiate()
            resource_point.position = local_position
            resource_point.rotation = local_rotation
            self.add_child(resource_point)
            self.resource_points.append(resource_point)

        if Input.is_action_just_pressed("place_hub"):
            var resource_hub: ResourceHub = self.resource_hub_scene.instantiate()
            resource_hub.planet = self
            resource_hub.position = local_position
            resource_hub.rotation = local_rotation
            resource_hub.select_resource_points(self.resource_points)
            self.add_child(resource_hub)
            self.resource_hubs.append(resource_hub)

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
            
func _on_timer_timeout():
    var random_theta = randf_range(0.0, 2.0 * PI)
    var random_phi = randf_range(-PI / 2.0, PI / 2)

    var x = 100.0 * sin(random_theta) * cos(random_phi)
    var y = 100.0 * sin(random_theta) * sin(random_phi)
    var z = 100.0 * cos(random_theta)

    var random_position = Vector3(x, y, z)

    const MAX_ITERATIONS: int = 2
    for i in range(MAX_ITERATIONS):
        for hub in self.resource_hubs:
            if hub.position.angle_to(random_position) < self.new_resource_safe_zone:
                var delta_angle = self.new_resource_safe_zone - hub.position.angle_to(random_position)
                var axis = (hub.position.cross(random_position)).normalized()
                random_position = random_position.rotated(axis, delta_angle)
                if i == MAX_ITERATIONS - 1:
                    return

        for point in self.resource_points:
            if point.position.angle_to(random_position) < self.new_resource_safe_zone:
                var delta_angle = self.new_resource_safe_zone - point.position.angle_to(random_position)
                var axis = (point.position.cross(random_position)).normalized()
                random_position = random_position.rotated(axis, delta_angle)
                if i == MAX_ITERATIONS - 1:
                    return

    var local_position = self.to_local(random_position)
    var local_rotation = Quaternion(Vector3.UP, local_position.normalized()).get_euler()
    var resource_point: ResourcePoint = self.resource_point_scene.instantiate()
    resource_point.position = local_position
    resource_point.rotation = local_rotation
    self.add_child(resource_point)
    self.resource_points.append(resource_point)


