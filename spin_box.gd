extends SpinBox

@export_node_path("Node3D") var spider_bot_path

func _ready():
	var spider_bot = get_node(spider_bot_path)
	connect('value_changed',spider_bot.set_legs_count)

func on_value_changed():
	print(value_changed)
	
