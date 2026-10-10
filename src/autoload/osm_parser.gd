extends Node

class Ref:
	var id : String
	var tags : Array[String]

class CoordinateRef extends Ref:
	var lat : float
	var long : float

class NodeRef extends Ref:
	enum NodeType {
		UNUSED,
		BUILDING,
		PATH,
		NATURAL
	}
	var type : NodeType = NodeType.UNUSED
	var refs : Array[CoordinateRef]

var _coord_refs : Dictionary[String, CoordinateRef] = {}
var _node_refs : Dictionary[String, NodeRef] = {}
var _last_ref : Ref

func _ready() -> void:
	parse_osm("carleton.xml")

# TODO: Handle relations, area paths, and multipolygons.
func parse_osm(filename : String) -> Array[Node]:
	var nodes : Array[Node] = []
	var xml_parser = XMLParser.new()
	
	var start_time : float = Time.get_ticks_msec()
	# parse stray points of data with lat/long
	xml_parser.open(str("res://data/osm/", filename))
	while xml_parser.read() != ERR_FILE_EOF:
		if xml_parser.get_node_type() == XMLParser.NODE_ELEMENT:
			var node_name = xml_parser.get_node_name()
			var attributes = {}
			for idx in range(xml_parser.get_attribute_count()):
				attributes[xml_parser.get_attribute_name(idx)] = xml_parser.get_attribute_value(idx)
			
			# 'node' in osm data has lat and long attributes
			# these are primarily just datapoints referenced by ways
			if node_name == "node":
				var ref : CoordinateRef = CoordinateRef.new()
				if attributes.has("id"):
					ref.id = attributes["id"]
				if attributes.has("lat"):
					ref.lat = Context.latitude_to_world_coordinates(float(attributes["lat"]))
				if attributes.has("lon"):
					ref.long = Context.longitude_to_world_coordinates(float(attributes["lon"]))
				_coord_refs[ref.id] = ref
			
			# buildings and such
			# by the time these are reached all coordinate refs
			# will have been defined as they are always
			# first in the xml
			if node_name == "way" || node_name == "osm":
				var ref : NodeRef = NodeRef.new()
				if attributes.has("id"):
					ref.id = attributes["id"]
				_node_refs[ref.id] = ref
				_last_ref = ref
			
			if _last_ref != null:
				if node_name == "tag":
					_parse_tags(attributes)
				# nd is coordinate reference
				if node_name == "nd":
					if _coord_refs.has(attributes["ref"]):
						# if the last ref was a node ref (ie building)
						# add this node to its coord refs list
						if _last_ref is NodeRef:
							_last_ref.refs.append(_coord_refs[attributes["ref"]])
						# add orphan tags from associated coord ref to the node
						_last_ref.tags += _coord_refs[attributes["ref"]].tags
						# clear orphan tags
						_coord_refs[attributes["ref"]].tags = []
	
	var end_time : float = Time.get_ticks_msec()
	print("OSM node ref parse took ", (end_time - start_time)/1000, " seconds")
	
	# debug print
	for ref : NodeRef in _node_refs.values():
		if ref.type == NodeRef.NodeType.BUILDING:
			var b : Building = Building.new()
			b.node_ref = ref
			get_tree().current_scene.add_child(b)
	
	return []

func _parse_tags(attributes):
	# parse in order, so tags belong to last ref
	if !_last_ref.tags.has(attributes["v"]):
		# general tags
		if attributes["k"] == "shop" ||\
			attributes["k"] == "amenity" ||\
			attributes["k"] == "cuisine" ||\
			attributes["k"] == "craft" ||\
			attributes["k"] == "natural" ||\
			attributes["k"] == "building":
			_last_ref.tags.append(attributes["v"])
		
		# define node ref type if available
		if _last_ref is NodeRef:
			# building
			if attributes["k"] == "building":
				_last_ref.type = NodeRef.NodeType.BUILDING
			# osm tags any type of road as a highway
			# regardless of what it actually is
			if attributes["k"] == "highway":
				_last_ref.type = NodeRef.NodeType.PATH
			if attributes["k"] == "natural":
				_last_ref.type = NodeRef.NodeType.NATURAL
