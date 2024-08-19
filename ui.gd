extends Control
class_name UI

@onready var red_count = $VBoxContainer/HBoxContainer/red/HBoxContainer/red_count
@onready var green_count = $VBoxContainer/HBoxContainer/green/HBoxContainer/green_count
@onready var blue_count = $VBoxContainer/HBoxContainer/blue/HBoxContainer/blue_count

func _ready():
    pass

func _process(delta):
    pass

func update_red_count(count: int):
    self.red_count.text = "%d" % count

func update_green_count(count: int):
    self.green_count.text = "%d" % count

func update_blue_count(count: int):
    self.blue_count.text = "%d" % count
