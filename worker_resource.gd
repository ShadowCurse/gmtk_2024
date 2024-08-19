extends RigidBody3D
class_name WorkerResource

@onready var timer = $Timer

var start: bool = false

func _ready():
    if self.start:
        self.timer.start()

func _on_timer_timeout():
    self.queue_free()
