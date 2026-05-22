class_name RVUIAccessSystem3D
extends RefCounted

# Patch 18: one source of truth for UI access.
# Global screens: Inventory and Skill Gems.
# Station screens: Map Device, Forge, Stash, Character Shrine.

const GLOBAL_PANEL_MODES: Array[String] = ["inventory", "skills"]
const STATION_PANEL_MODES: Array[String] = ["maps", "crafting", "stash", "character"]

const STATION_NAMES: Dictionary = {
	"maps": "Map Device",
	"crafting": "Forge",
	"stash": "Stash",
	"character": "Character Shrine",
}

static func normalize_mode(mode: String) -> String:
	var m: String = str(mode).strip_edges().to_lower()
	match m:
		"forge", "craft", "crafting_panel":
			return "crafting"
		"skill", "gems", "gem", "skill_gems", "skillgem", "skill_gem":
			return "skills"
		"map", "map_device", "mapdevice":
			return "maps"
		"char", "stats", "character_sheet":
			return "character"
		_:
			return m

static func request_panel(state: Object, mode: String, from_station: bool = false) -> bool:
	if state == null:
		return false

	var m: String = normalize_mode(mode)
	if m == "":
		close_panel(state)
		return true

	if not can_open_panel(state, m, from_station):
		# Patch 18 intentionally avoids noisy screen notices here.
		return false

	state.set("panel_mode", m)
	return true

static func toggle_panel(state: Object, mode: String, from_station: bool = false) -> bool:
	if state == null:
		return false

	var m: String = normalize_mode(mode)
	if str(_state_get(state, "panel_mode", "")) == m:
		close_panel(state)
		return true

	return request_panel(state, m, from_station)

static func close_panel(state: Object) -> void:
	if state != null:
		state.set("panel_mode", "")

static func can_open_panel(state: Object, mode: String, from_station: bool = false) -> bool:
	if state == null:
		return false

	var m: String = normalize_mode(mode)

	if GLOBAL_PANEL_MODES.has(m):
		return true

	if not STATION_PANEL_MODES.has(m):
		return false

	if str(_state_get(state, "mode", "hub")) != "hub":
		return false

	if from_station:
		return true

	return _near_station_allows(state, m)

static func panel_title(mode: String) -> String:
	var m: String = normalize_mode(mode)
	match m:
		"inventory":
			return "Inventory"
		"skills":
			return "Skill Gems"
		"maps":
			return "Map Device"
		"crafting":
			return "Forge"
		"stash":
			return "Stash"
		"character":
			return "Character"
		_:
			return m.replace("_", " ").capitalize()

static func panel_hint(mode: String) -> String:
	var m: String = normalize_mode(mode)
	match m:
		"inventory":
			return "Inspect, equip, appraise, favorite, lock, stash, or drop items."
		"skills":
			return "Manage active gems, support sockets, spirit gems, uncut gems, and hotbar bindings."
		"maps":
			return "Map Device station. Select a map, inspect danger, then launch."
		"crafting":
			return "Forge station. Select an item and apply controlled upgrades."
		"stash":
			return "Stash station. Store and retrieve long-term loot."
		"character":
			return "Character Shrine. Review offense, defense, resources, and build rules."
		_:
			return "Click visible rows, slots, and actions."

static func _near_station_allows(state: Object, mode: String) -> bool:
	var m: String = normalize_mode(mode)

	var direct_keys: Array[String] = [
		"near_station_mode",
		"near_station_panel",
		"near_station_target",
		"near_station_panel_mode",
		"station_mode",
		"station_panel",
	]

	for key: String in direct_keys:
		var value: String = normalize_mode(str(_state_get(state, key, "")))
		if value == m:
			return true

	var id_text: String = str(_state_get(state, "near_station_id", "")).to_lower()
	var name_text: String = str(_state_get(state, "near_station_name", "")).to_lower()
	var combined: String = id_text + " " + name_text

	match m:
		"maps":
			return combined.find("map") >= 0 or combined.find("device") >= 0
		"crafting":
			return combined.find("forge") >= 0 or combined.find("craft") >= 0
		"stash":
			return combined.find("stash") >= 0
		"character":
			return combined.find("character") >= 0 or combined.find("shrine") >= 0
		_:
			return false

static func _state_get(state: Object, key: String, fallback: Variant = null) -> Variant:
	if state == null:
		return fallback
	var value: Variant = state.get(key)
	if value == null:
		return fallback
	return value
