extends RayCast3D

@export var step_target : Node3D

func _ready():
	target_position = Vector3(0,-4.0,0.15)

func _physics_process(_delta):
	var hit_location = get_collision_point()
	if hit_location:
		$step_target.global_position = hit_location
	
	$step_target/label.global_position.y = hit_location.y
	$step_target/label.set_text('ray '+str(hit_location))
