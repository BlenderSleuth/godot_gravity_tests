extends StaticBody2D



func _ready():
	pass

# Finds the surface normal of 
#func find_surface(attractedBody):
#	var distance = position.distance_to(attractedBody.position)
#	var space_state = get_world_2d().direct_space_state
#
#	var raypoint = Vector2(0, distance).rotated(attractedBody.rotation)
#
#	var surfaceNorm = Vector2(0,0)
#
#	var result = space_state.intersect_ray(attractedBody.global_position, raypoint, [attractedBody])
#	if result:
##		print(result.position)
#		surfaceNorm = result.normal
#
#	return surfaceNorm

# Takes a body and returns the gravity vector
#func attract(attractedBody):
#	var pullVec = find_surface(attractedBody)
#
#	var upVec = Vector2(0, -1).rotated(attractedBody.rotation)
#	var rot_dif = 0
	