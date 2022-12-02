# path_graph.gd
# Editor tool for building a AStar2D map that can be used for pathfinding.
# Its children should all be path_node.gd, and they'll be automatically connected
# to each other.
#
# This could be extended in the future with layer support, but for now this is fine.

tool
extends Node2D

export (int) var layer := 0

onready var astar := AStar2D.new()

func _ready() -> void:
    update_graph()


func update_graph() -> void:
#
# update_graph
# Build the graph by looping over children's neighbours.
#
    var children := get_children()
    # astar.reserve_space(len(children))
    for child in children:
        print(child)
        var child_pos: Vector2 = child.global_position
        var next_id := astar.get_available_point_id()
        astar.add_point(next_id, child_pos)
        for path in child.neighbours:
            var neighbour = child.get_node(path)
            var neighbour_pos: Vector2 = neighbour.global_position
            var neigh_id := astar.get_available_point_id()
            astar.add_point(neigh_id, neighbour_pos)
            astar.connect_points(next_id, neigh_id, true)
    


func _draw() -> void:
    var itform := transform.affine_inverse()
    for i in range(astar.get_point_count()):
        var pt: Vector2 = itform.xform(astar.get_point_position(i))
        var neighbours := astar.get_point_connections(i)
        for n in neighbours:
            draw_line(pt, itform.xform(astar.get_point_position(n)), Color.pink)
