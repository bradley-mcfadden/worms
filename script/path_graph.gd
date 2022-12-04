# path_graph.gd
# Editor tool for building a AStar2D map that can be used for pathfinding.
# Its children should all be path_node.gd, and they'll be automatically connected
# to each other.
#
# This could be extended in the future with layer support, but for now this is fine.

tool
extends Node2D

class_name PathGraph

export (int) var layer := 0

onready var astar := AStar2D.new()
export (Font) var font: Font = null
export (bool) var draw_in_game = false

func _ready() -> void:
	update_graph()


func update_graph() -> void:
#
# update_graph
# Build the graph by looping over children's neighbours.
#
	var children := get_children()
	# astar.reserve_space(len(children))
	if len(children) > 0:
		astar.add_point(astar.get_available_point_id(), children[0].position)
	for child in children:
		var child_pos: Vector2 = child.global_position
		var closest_id := astar.get_closest_point(child_pos)
		var closest_pt := astar.get_point_position(closest_id)
		var next_id := 0
		if not close_enough(child_pos, closest_pt):
			next_id = astar.get_available_point_id()
			astar.add_point(next_id, child_pos)
			print("Adding point ", child_pos, " at ", next_id)
		else:
			print("Did not add point ", child_pos)
			next_id = closest_id
		for path in child.neighbours:
			var neighbour = child.get_node(path)
			var neighbour_pos: Vector2 = neighbour.global_position
			var closest_point_id = astar.get_closest_point(neighbour_pos)
			var closest_point = astar.get_point_position(closest_point_id)
			print("Closest pt ", closest_point, " neighbour_pos ", neighbour_pos)
			if close_enough(closest_point, neighbour_pos):
				astar.connect_points(next_id, closest_point_id, true)
				continue
			var neigh_id := astar.get_available_point_id()
			print("Adding neighbour ", neighbour_pos, " at ", neigh_id)
			astar.add_point(neigh_id, neighbour_pos)
			astar.connect_points(next_id, neigh_id, true)
	

func close_enough(vec1: Vector2, vec2: Vector2) -> bool:
	return (vec1 - vec2).length() < 50.0


func _draw() -> void:
	if !Engine.editor_hint and !draw_in_game:
		return
	var itform := global_transform.affine_inverse()
	for i in range(astar.get_point_count()):
		var pt: Vector2 = itform.xform(astar.get_point_position(i))
		#var pt: Vector2 = astar.get_point_position(i)
		var neighbours := astar.get_point_connections(i)
		for n in neighbours:
			var local_pos: Vector2 = astar.get_point_position(n)
			var world_pos: Vector2 = itform.xform(local_pos)
			draw_string(font, world_pos, "%.0f, %.0f" % [world_pos.x, world_pos.y])
			draw_line(pt, world_pos, Color.pink)


func closest_unobs_to(point: Vector2, collision_layer: int = 4096) -> Vector2:
#
# closest_unobs_to 
# Return the closest unobstructed point to @point, or @point if all points are obstructed.
# @point - Point to compare graph points to for distance and obstruction.
# @collision_layer - Layer collision checks occur on.
# @return - Closest unobstructed point or input point if nothing is obstructed.
#
	var space := get_world_2d().direct_space_state
	var min_distance := float(1000000.0)
	var closest := point
	for pt in all_points():
		var collision: Dictionary = space.intersect_ray(point, pt, [], collision_layer)
		if collision.has("collider") and collision["collider"] is StaticBody2D:
			var dist: float = pt.distance_to(point)
			if dist < min_distance:
				closest = pt
				min_distance = dist
	return closest


func closest_unobs_to_id(point: Vector2, collision_layer: int = 4096) -> int:
	#
	# closest_unobs_to 
	# Return the closest unobstructed point to @point, or @point if all points are obstructed.
	# @point - Point to compare graph points to for distance and obstruction.
	# @collision_layer - Layer collision checks occur on.
	# @return - Closest unobstructed point or input point if nothing is obstructed.
	#
		var space := get_world_2d().direct_space_state
		var min_distance := float(1000000.0)
		var closest := -1
		for id in range(astar.get_point_count()):
			var pt := astar.get_point_position(id)
			if space.intersect_ray(point, pt, [], collision_layer) != {}:
				var dist: float = pt.distance_to(point)
				if dist < min_distance:
					closest = id
					min_distance = dist
		return closest


func all_points() -> PoolVector2Array:
#
# Return all points or the graph in an unordered fashion.
#
	var arr := PoolVector2Array()
	arr.resize(astar.get_point_count())
	for i in range(astar.get_point_count()):
		var pt := astar.get_point_position(i)
		arr.append(pt)
	return arr
