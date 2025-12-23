extends Camera3D

@export_node_path() var look_target
@export_node_path('Label') var label_path

@export var min_fov = 30.0
@export var max_fov = 90.0

func _process(delta):
	look_at(get_node(look_target).global_position)
	
	var distance_mod = global_position.distance_squared_to(get_node(look_target).global_position)
	fov = lerp(clamp(fov,min_fov,max_fov), -distance_mod + 100, delta)
	
	get_node(label_path).text = str(fov)
