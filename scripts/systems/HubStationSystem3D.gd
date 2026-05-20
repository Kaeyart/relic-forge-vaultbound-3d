extends RefCounted
class_name RVHubStationSystem3D

static func station_specs() -> Array[Dictionary]:
	return [
		{
			"id": "map_device",
			"name": "Map Device",
			"panel_mode": "maps",
			"position": Vector3(0.0, 0.0, -5.0),
			"size": Vector3(1.8, 1.2, 1.8),
			"color": Color(0.22, 0.52, 1.0, 0.88),
			"hint": "Open maps and begin the next run.",
		},
		{
			"id": "stash",
			"name": "Stash",
			"panel_mode": "stash",
			"position": Vector3(-4.2, 0.0, -1.4),
			"size": Vector3(2.1, 1.0, 1.2),
			"color": Color(0.72, 0.54, 0.28, 0.88),
			"hint": "Store gear, gems, maps, currency, and crystals.",
		},
		{
			"id": "forge",
			"name": "Forge",
			"panel_mode": "crafting",
			"position": Vector3(4.2, 0.0, -1.4),
			"size": Vector3(2.0, 1.1, 1.4),
			"color": Color(1.0, 0.34, 0.12, 0.88),
			"hint": "Spend currency and Forge Potential to improve items.",
		},
		{
			"id": "skill_altar",
			"name": "Skill Altar",
			"panel_mode": "skills",
			"position": Vector3(-3.6, 0.0, 3.4),
			"size": Vector3(1.6, 1.25, 1.6),
			"color": Color(0.62, 0.36, 1.0, 0.88),
			"hint": "Install active, support, and spirit gems.",
		},
		{
			"id": "character_mirror",
			"name": "Character Mirror",
			"panel_mode": "character",
			"position": Vector3(3.6, 0.0, 3.4),
			"size": Vector3(1.4, 1.55, 0.7),
			"color": Color(0.56, 0.88, 1.0, 0.82),
			"hint": "Inspect build stats and character state.",
		},
	]


static func station_by_id(id: String) -> Dictionary:
	for spec: Dictionary in station_specs():
		if str(spec.get("id", "")) == id:
			return spec
	return {}


static func nearest_station(player_pos: Vector3, station_nodes: Array, max_distance: float = 2.35) -> Node3D:
	var best: Node3D = null
	var best_dist: float = max_distance

	for value: Variant in station_nodes:
		if not (value is Node3D):
			continue
		var node: Node3D = value as Node3D
		if not is_instance_valid(node):
			continue
		var dist: float = node.global_position.distance_to(player_pos)
		if dist <= best_dist:
			best_dist = dist
			best = node

	return best


static func station_prompt(station: Node) -> String:
	if station == null:
		return ""

	var station_name: String = str(station.get_meta("station_name", station.name))
	var hint: String = str(station.get_meta("station_hint", ""))
	if hint != "":
		return "[E] " + station_name + " — " + hint
	return "[E] " + station_name


static func station_panel_mode(station: Node) -> String:
	if station == null:
		return ""
	return str(station.get_meta("panel_mode", ""))


static func should_show_hub_stations(state: Object) -> bool:
	if state == null:
		return true

	var mode_value: Variant = state.get("mode")
	if mode_value == null:
		return true

	var mode: String = str(mode_value).strip_edges().to_lower()
	return mode == "" or mode == "hub" or mode == "town" or mode == "base"


static func make_station_summary() -> String:
	var parts: Array[String] = []
	for spec: Dictionary in station_specs():
		parts.append(str(spec.get("name", "Station")) + " → " + str(spec.get("panel_mode", "")))
	return " · ".join(parts)
