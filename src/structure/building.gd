class_name Building
extends Structure

@onready var mat_roof = preload("res://data/textures/building/mat-roof.tres")
@onready var mat_wall = preload("res://data/textures/building/mat-wall.tres")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if node_ref == null: return
	_build()

func _build() -> void:
	# set global position to first point in coordinates
	global_position = Vector3(node_ref.refs[0].long, 0, node_ref.refs[0].lat)
	
	# cleanup point data
	## remove last point if it is same as first point
	#if node_ref.refs.size() > 1 &&\
		#is_equal_approx(node_ref.refs[0].long, node_ref.refs[-1].long) &&\
		#is_equal_approx(node_ref.refs[0].lat, node_ref.refs[-1].lat):
		#node_ref.refs = node_ref.refs.slice(0, node_ref.refs.size() - 1)
	
	# create usable point data
	var points : Array[Vector2] = []
	for coord in node_ref.refs:
		points.append(Vector2(coord.long, coord.lat))
	var vertices : PackedInt32Array = Geometry2D.triangulate_polygon(points)
	
	# create roof mesh
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_color(Color(1.0, 1.0, 1.0, 1.0))
	st.set_uv(Vector2(0, 0))
	# sharp normals
	st.set_smooth_group(-1)
	st.set_material(mat_roof)
	for i in range(0, vertices.size(), 3):
		var a := points[vertices[i]]
		var b := points[vertices[i + 1]]
		var c := points[vertices[i + 2]]
		var uva : Vector2 = Vector2(a.x, a.y)
		var uvb : Vector2 = Vector2(b.x, b.y)
		var uvc : Vector2 = Vector2(c.x, c.y)
		_add_triangle(st, Vector3(a.x, node_ref.height, a.y),
							Vector3(b.x, node_ref.height, b.y),
							Vector3(c.x, node_ref.height, c.y),
							uva,
							uvb,
							uvc)
	
	var mesh : ArrayMesh = st.commit()
	
	# add walls mesh
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_smooth_group(-1)
	st.set_material(mat_wall)
	for i in range(points.size()):
		var a := points[i]
		var b := points[(i + 1) % points.size()]
		
		# bottom
		var a0 := Vector3(b.x, 0.0, b.y)
		var b0 := Vector3(a.x, 0.0, a.y)
		# top
		var a1 := Vector3(b.x, node_ref.height, b.y)
		var b1 := Vector3(a.x, node_ref.height, a.y)
		_add_triangle(st, a0, a1, b1,\
					Vector2(a0.x, a0.y),\
					Vector2(a1.x, a1.y),\
					Vector2(b1.x, b1.y))
		_add_triangle(st, a0, b1, b0,\
					Vector2(a0.x, a0.y),\
					Vector2(b1.x, b1.y),\
					Vector2(b0.x, b0.y))
	
	st.generate_normals()
	mesh = st.commit(mesh)
	
	# add mesh instance
	var mi : MeshInstance3D = MeshInstance3D.new()
	mi.mesh = mesh
	
	add_child(mi)
	mi.global_position = global_position
	
	_add_debug_label()
