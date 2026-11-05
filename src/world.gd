extends Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	OSMParser.parse_osm("carleton.xml")
