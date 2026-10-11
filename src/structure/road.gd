class_name Road
extends Structure


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
	
	# create usable point data
	var points : Array[Vector2] = []
	for coord in node_ref.refs:
		points.append(Vector2(coord.long, coord.lat))
	if points.size() < 2: return
	
	var left := PackedVector3Array()
	var right := PackedVector3Array()
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
		_add_triangle(st, left[i], right[i + 1], left[i + 1])
		_add_triangle(st, left[i], right[i], right[i + 1])
	
	st.generate_normals()
	var mesh : ArrayMesh = st.commit()
	
	# add material
	var mat : StandardMaterial3D = StandardMaterial3D.new()
	# TODO: find way to better set front faces based on wall winding order
	# for now just disable cull
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.albedo_color = Color.BLACK
	mat.roughness = 0.8
	mesh.surface_set_material(0, mat)
	
	# add mesh instance
	var mi : MeshInstance3D = MeshInstance3D.new()
	mi.mesh = mesh
	
	add_child(mi)
	mi.global_position = global_position
	
	_add_debug_label()
