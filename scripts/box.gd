extends RigidBody3D

func take_damage(dmg):
	if dmg <= 0:
		return
	
	queue_free()
