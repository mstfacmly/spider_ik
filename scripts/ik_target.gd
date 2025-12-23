extends Marker3D

@export var step_target : Node3D
@export var step_distance : float = 0.42

var adjacent_target : Node3D
var opposite_target : Node3D

var stepping : bool = false
var resting : bool = true

func _ready():
	set_process(0)

func _process(_delta):
	if !stepping && !adjacent_target.stepping && abs(global_position.distance_to(step_target.global_position)) > step_distance:
			step()
#	$label.set_text('iktarget '+str(step_target.global_position.y))

func step():
	var half_way = (global_position + step_target.global_position) / 2
	stepping = true
	resting = false
	
	var t = get_tree().create_tween()
	t.tween_property(self, 'global_position', half_way + owner.basis.y , 0.1 )
	t.tween_property(self , 'global_position', step_target.global_position, 0.1 )
	t.tween_callback(func(): stepping = false)
	t.tween_callback(func(): resting = true)
	t.tween_callback(func(): set_process(false))
	
