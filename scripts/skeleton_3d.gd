extends Skeleton3D

signal add_bones

@export_range(2,8) var legs: int = 4:
	set(count):
		legs = count
		emit_signal('add_bones',legs)

func _generate_bones(number):
	clear_bones()
	add_bone('body')
	for i in number:
		set_bone_parent(add_bone('leg'+str(i)),find_bone('body'))
		set_bone_rest(find_bone('leg'+str(i)),get_parent().get_node('leg'+str(i)).transform)

		set_bone_parent(add_bone('leg_in'+str(i)),find_bone('leg'+str(i)))
		set_bone_rest(find_bone('leg_in'+str(i)),get_parent().get_node("leg"+str(i)+'/leg_in').transform)
		
		set_bone_parent(add_bone('leg_center'+str(i)),find_bone('leg_in'+str(i)))
		set_bone_rest(find_bone('leg_center'+str(i)),get_parent().get_node("leg"+str(i)+'/leg_in/leg_center').transform)
		
		set_bone_parent(add_bone('leg_out'+str(i)),find_bone('leg_center'+str(i)))
		set_bone_rest(find_bone('leg_out'+str(i)),get_parent().get_node("leg"+str(i)+'/leg_in/leg_center/leg_out').transform)
		
		set_bone_parent(add_bone('leg_point'+str(i)),find_bone('leg_point'+str(i)))
		set_bone_rest(find_bone('leg_point'+str(i)),get_parent().get_node("leg"+str(i)+'/leg_in/leg_center/leg_out').transform)
	
	print(get_bone_count())
