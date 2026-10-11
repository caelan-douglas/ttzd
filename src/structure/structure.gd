## Base class for anything that is derived from the osm data
class_name Structure
extends Node3D

var node_ref : OSMParser.NodeRef

func _add_triangle(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3) -> void:
	# minus global possition for local offset
	st.add_vertex(a - global_position)
	st.add_vertex(b - global_position)
	st.add_vertex(c - global_position)

func _add_debug_label() -> void:
	var l : Label3D = Label3D.new()
	l.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	l.no_depth_test = true
	l.font_size = 24
	l.pixel_size = 0.00125
	l.shaded = false
	l.fixed_size = true
	l.modulate = Color.AQUAMARINE if node_ref.type == OSMParser.NodeRef.NodeType.BUILDING else Color.DODGER_BLUE
	l.text = str("--- Ref Info ---\n", "id: ", node_ref.id, "\nTags: ", node_ref.tags)
	add_child(l)
	l.position = Vector3.ZERO
