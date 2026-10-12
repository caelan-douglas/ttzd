class_name Road
extends Structure

const UV_TILE_SIZE = 0.125
@onready var mat_shoulder_grass : StandardMaterial3D = preload("res://data/textures/road/mat-road-shoulder-grass.tres")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if node_ref == null: return
	
	var width : float = 7
	if node_ref.tags.has("footway") || node_ref.tags.has("path") || node_ref.tags.has("cycleway"):
		width = 2
	elif node_ref.tags.has("primary"):
		width = 12
	_build(width)

func _build(width : float = 7) -> void:
	# set global position to first point in coordinates
	global_position = Vector3(node_ref.refs[0].long, 0, node_ref.refs[0].lat)
	
	# cleanup point data
	## remove last point if it is same as first point
	#if node_ref.refs.size() > 1 &&\
		#is_equal_approx(node_ref.refs[0].long, node_ref.refs[-1].long) &&\
		#is_equal_approx(node_ref.refs[0].lat, node_ref.refs[-1].lat):
		#node_ref.refs = node_ref.refs.slice(0, node_ref.refs.size() - 1)
	
	# create mesh
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_color(Color(1.0, 1.0, 1.0, 1.0))
	st.set_uv(Vector2(0, 0))
	# sharp normals
	st.set_smooth_group(-1)
	st.set_material(mat_shoulder_grass)
	
	# create usable point data
	var points : Array[Vector2] = []
	for coord in node_ref.refs:
		points.append(Vector2(coord.long, coord.lat))
	if points.size() < 2: return
	
	var left := PackedVector3Array()
	var right := PackedVector3Array()
	
	var distance : float = 0
	for i in range(points.size()):
		var tangent : Vector2
		# roads get extruded left and right
		if i == 0:
			tangent = (points[1] - points[0]).normalized()
		elif i == points.size() - 1:
			tangent = (points[i] - points[i - 1]).normalized()
		else:
			var a := (points[i] - points[i - 1]).normalized()
			var b := (points[i + 1] - points[i]).normalized()
			tangent = (a + b).normalized()
			if tangent.is_zero_approx():
				tangent = b
		var perpendicular := Vector2(-tangent.y, tangent.x) * (width * 0.5)
		left.append(Vector3(points[i].x + perpendicular.x, 0.01, points[i].y + perpendicular.y))
		right.append(Vector3(points[i].x - perpendicular.x, 0.01, points[i].y - perpendicular.y))
	
	for i in range(points.size() - 1):
		# uvs
		var length := points[i].distance_to(points[i + 1])
		var u0 := 0.0
		var u1 := width
		var v0 := distance
		var v1 := distance + length
		_add_triangle(st, left[i], right[i + 1], left[i + 1],\
							Vector2(u0, v0) * UV_TILE_SIZE, Vector2(u1, v1) * UV_TILE_SIZE, Vector2(u0, v1) * UV_TILE_SIZE)
		_add_triangle(st, left[i], right[i], right[i + 1],\
							Vector2(u0, v0) * UV_TILE_SIZE, Vector2(u1, v0) * UV_TILE_SIZE, Vector2(u1, v1) * UV_TILE_SIZE)
		distance += length
	
	st.generate_normals()
	var mesh : ArrayMesh = st.commit()
	
	# add mesh instance
	var mi : MeshInstance3D = MeshInstance3D.new()
	mi.mesh = mesh
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	
	add_child(mi)
	mi.global_position = global_position
	
	#_add_debug_label()
