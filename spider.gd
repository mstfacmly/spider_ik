extends Node3D

signal add_legs
signal remove_legs
signal move_legs

@export var move_speed : float = 0.76
@export var turn_speed : float = 1.5
@export var ground_offset: float = 8.0

@export_range(2,9) var legs_count: int = 4:
	set = set_legs_count

func _ready():
	set_process(0)
	connect("remove_legs",_clear_legs)
	connect("add_legs",_generate_legs)
	emit_signal('add_legs')
	
	"""
	for i in range(1,31):
		if i % 2 != 0:
			print(i)
	"""

func _process(delta):
	"""
	transform.basis.slerp(
		_basis_from_normal(_avg_normal_calc(_split_threes()).normalized()),
		move_speed * delta).orthonormalized()
	"""
	transform.basis = lerp(transform.basis 
						, _basis_from_normal(_avg_normal_calc(_split_threes()).normalized())
						, move_speed * delta).orthonormalized()
	_movement(Input.get_axis('ui_down','ui_up'), Input.get_axis('ui_right','ui_left') ,delta)

func _movement(dir, a_dir, delta):
	translate(Vector3(0,0,-dir) * move_speed * delta)
	rotate_object_local(Vector3.UP, a_dir * turn_speed * delta)
	
#	if abs(dir) > 0 or abs(a_dir) > 0:
	emit_signal('move_legs',1)
	
	position = lerp(position ,position + transform.basis.y * _target_pos(_avg_legs_calc($legs_root.get_children())),move_speed * delta)

func set_legs_count(count):
		legs_count = count
		emit_signal('remove_legs')

func _clear_legs():
	set_process(0)

	for i in $step_targets.get_children():
		$step_targets.remove_child(i)
	for i in $legs_root.get_children():
		$legs_root.remove_child(i)
	
	emit_signal('add_legs')

func _generate_legs():
	_set_base_rotation()
	
	for i in legs_count:
		var leg = load('res://spider_leg.tscn').instantiate()
		var steps = load('res://step_target.tscn').instantiate()
	
		leg.set_name('leg' + str(i))
		steps.set_name('leg' + str(i))
	
		$legs_root.add_child(leg,1)
		$step_targets.add_child(steps,1)
	
		@warning_ignore("integer_division")
		$legs_root.get_child(i).rotate_y(absf(fmod(deg_to_rad(i*(360/legs_count)),360)))
		$legs_root.get_child(i).get_node('ik_target').step_target = $step_targets.get_child(i).get_node('step_target')
	
		connect('move_legs',leg.get_node('ik_target').set_process)
		leg.get_node('ik_target').set_as_top_level(1)
	
		$step_targets.get_child(i).global_position = $legs_root.get_child(i).get_node('ik_target').global_position
		$step_targets.get_child(i).global_rotation.y = $legs_root.get_child(i).global_rotation.y
		$step_targets.get_child(i).global_position.y -= $step_targets.get_child(i).target_position.y * 0.6 #-ground_offset / 8
	
	_set_adjacent_opposing_legs()

func _set_adjacent_opposing_legs():
	for i in $legs_root.get_child_count():
		if $legs_root.get_children()[i] != $legs_root.get_children().front():
			get_node('legs_root/leg'+str(i)+'/ik_target').adjacent_target = get_node('legs_root/leg'+str(i-1)+'/ik_target')
		else:
			get_node('legs_root/leg0/ik_target').adjacent_target = $legs_root.get_children().back().get_node('ik_target')
		if $legs_root.get_children()[i].get_index() < $legs_root.get_children().size() - 1:
			get_node('legs_root/leg'+str(i)+'/ik_target').opposite_target = get_node('legs_root/leg'+str(i+1)+'/ik_target')
		else:
			get_node('legs_root/leg'+str(i)+'/ik_target').opposite_target = get_node('legs_root/leg0/ik_target')
	
	set_process(1)

func _basis_from_normal(normal: Vector3) -> Basis:
	var result = Basis()
	
	result.x = normal.cross(transform.basis.z)
	result.y = normal
	result.z = transform.basis.x.cross(normal)

	result = result.orthonormalized()
	result.x *= scale.x 
	result.y *= scale.y 
	result.z *= scale.z 
	
	return result

func _avg_normal_calc(normal_in:Array):
	var avg = Vector3()
	for i in normal_in:
		avg += -i.normal
	
	return avg / normal_in.size()

func _avg_legs_calc(legs_in:Array):
	var avg = Vector3()
	for i in legs_in:
		avg += i.position
	
	return avg / legs_in.size()

func _target_pos(legs_pos_avg : Vector3):
	return legs_pos_avg * transform.basis.y * ground_offset

func _distance(target_position: Vector3):
	return transform.basis.y.dot(target_position - position)

func _split_threes():
	# https://www.terrychan.org/post/detail/1488/
	var threes : Array
	
	for i in range( 0, len( $legs_root.get_children() ), 3 ):
		threes.append( $legs_root.get_children().slice( i , i + 3 ))
		
	if threes.back().size() < threes.front().size():
		for i in threes.front().size() - threes.back().size():
			threes.back().push_back($legs_root.get_children()[i])
	elif threes.size() <= 1:
		threes.front().push_back($legs_root.get_children()[0])
	
	var planes : Array
	for i in threes:
		planes.append(Plane(i[0].get_node('ik_target').global_position,i[1].get_node('ik_target').global_position,i[2].get_node('ik_target').global_position))
	
	return planes

func sum(accum:Plane):
#	https://docs.godotengine.org/en/stable/classes/class_array.html#class-array-method-reduce
	return accum.normal

func _set_base_rotation():
	@warning_ignore("integer_division")
	$legs_root.rotation_degrees.y = absf(fmod(360/(legs_count * 2),360))

func _turn_light():
#	https://forum.godotengine.org/t/rotation-degrees-not-being-the-actual-rotation-degrees/118833/4

#	var rotation_clamp = fmod($light.rotation_degrees.y,45)
	var rotation_clamp = clampf($light.rotation_degrees.y,-30,30)
	$light.rotate_y(Input.get_axis('ui_right','ui_left') * rotation_clamp)

func _labels(i):
	$Label3D.text = str($legs_root.rotation_degrees.y)+'\n'+str($step_targets.rotation_degrees.y)
	$legs_root.get_child(i).get_node('leg_number').text = str($legs_root.get_child(i).get_node('ik_target').step_target)+'\n'+str($legs_root.get_child(i).rotation_degrees.y)
	$step_targets.get_child(i).get_node('label').text = str($step_targets.get_child(i).name)+'\n'+str($step_targets.get_child(i).rotation_degrees.y)
	
	"""
	('ik_leg',str(i),'	,	',get_node('legs_root/leg'+str(i)+'/ik_target')
	+'\nadjacent	,	' + get_node('legs_root/leg'+str(i)+'/ik_target').adjacent_target
	+'\nopposite	,	' + get_node('legs_root/leg'+str(i)+'/ik_target').opposite_target
	)
	"""
