extends Node

# to be used for globals (game state)
const DIST_METRES = 111133
var world_origin_lat : float = 45.38552
var world_origin_long : float = -75.69642

func latitude_to_world_coordinates(lat : float) -> float:
	return (project_mercator_latitude(lat) - project_mercator_latitude(world_origin_lat)) * -DIST_METRES;

func longitude_to_world_coordinates(long : float) -> float:
	return (long - (world_origin_long)) * DIST_METRES;
	
# mercator projection for Y values to prevent stretching
func project_mercator_latitude(lat : float) -> float:
	var lat_to_rad : float = deg_to_rad(lat)
	return rad_to_deg(log((tan(lat_to_rad) + 1 / cos(lat_to_rad))))
