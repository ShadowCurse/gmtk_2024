extends Node3D

@onready var planet = $planet
@onready var sun = $sun
@onready var directional_light_3d = $DirectionalLight3D

var planet_distance: float = 1000.0
var planet_rotation: float = PI / 2.0
var planet_rotation_speed: float = 0.1

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    planet_rotation += planet_rotation_speed * delta
    sun.position = Vector3(sin(planet_rotation) * planet_distance, 0.0, cos(planet_rotation) * planet_distance)
    sun.look_at(planet.global_position)
    pass
