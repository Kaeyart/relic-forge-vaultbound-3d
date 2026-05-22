class_name RVUIAccessSystem3D
extends RefCounted

# Patch 26: one source of truth for UI access.
# Global screens: Inventory and Skill Gems.
# Physical station screens: Map Device, Forge, Stash.
# Character shrine / extra stations are intentionally not exposed in this pass.

const GLOBAL_PANEL_MODES: Array[String] = ["inventory", "skills", "passives", "ascendancy"]
const STATION_PANEL_MODES: Array[String] = ["maps", "crafting", "stash"]

const STATION_NAMES: Dictionary = {
	"maps": "Map Device",
	"crafting": "Forge",
	"stash": "Stash",
}

static func normalize_mode(mode: String) -> String:
	var m: String = str(mode).strip_edges().to_lower()
	match m:
		"forge", "craft", "crafting_panel", "forge_panel":
			return "crafting"
		"skill", "gems", "gem", "skill_gems", "skillgem", "skill_gem":
			return "skills"
		"map", "map_device", "mapdevice", "atlas", "waystone":
			return "maps"
		"inventory", "inv", "bag", "backpack":
			return "inventory"
		"stash", "vault", "storage":
			return "stash"
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
		return false

	state.set("panel_mode", m)
	return true

static func request_station_panel(state: Object, mode: String) -> bool:
	return request_panel(state, mode, true)

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
		"passives":
			return "Passive Tree"
		"ascendancy":
			return "Ascendancy"
		"maps":
			return "Map Device"
		"crafting":
			return "Forge"
		"stash":
			return "Stash"
		_:
			return m.replace("_", " ").capitalize()

static func panel_hint(mode: String) -> String:
	var m: String = normalize_mode(mode)
	match m:
		"inventory":
			return "Inspect, equip, appraise, favorite, lock, stash, or drop items."
		"skills":
			return "Manage active gems, supports, spirit gems, uncut gems, and hotbar bindings."
		"maps":
			return "Physical station only. Choose Atlas node, Waystone, Tablets, then launch."
		"crafting":
			return "Physical station only. Select an item and apply forge actions."
		"stash":
			return "Physical station only. Store and retrieve long-term loot."
		_:
			return "Click visible rows, slots, and actions."

static func _near_station_allows(state: Object, mode: String) -> bool:
	var m: String = normalize_mode(mode)
	var near_mode: String = normalize_mode(str(_state_get(state, "near_station_mode", "")))
	var near_panel: String = normalize_mode(str(_state_get(state, "near_station_panel", "")))
	if near_mode == m or near_panel == m:
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
			return combined.find("stash") >= 0 or combined.find("vault") >= 0
		_:
			return false

static func _state_get(state: Object, key: String, fallback: Variant = null) -> Variant:
	if state == null:
		return fallback
	var value: Variant = state.get(key)
	if value == null:
		return fallback
	return value
