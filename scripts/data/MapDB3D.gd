class_name RVMapDB3D
extends RefCounted

static var _cache_ready: bool = false
static var _maps: Dictionary = {}
static var _uid_counter: int = 1

static func make_map_item(map_id: String, tier: int = 1, rarity: String = "Normal") -> Dictionary:
	_ensure_cache()
	var data: Dictionary = Dictionary(_maps.get(map_id, _maps.get("ash_vault_01", {}))).duplicate(true)
	data["uid"] = "map_" + str(_uid_counter)
	_uid_counter += 1
	data["item_type"] = "map"
	data["map_id"] = map_id
	data["tier"] = max(1, tier)
	data["area_level"] = 1 + max(0, tier - 1) * 3
	data["rarity"] = rarity
	data["entries"] = 6
	data["display_name"] = rarity + " " + str(data.get("name", map_id)) if rarity != "Normal" else str(data.get("name", map_id))
	return data

static func map_data(map_id: String) -> Dictionary:
	_ensure_cache()
	return Dictionary(_maps.get(map_id, {})).duplicate(true)

static func all_maps() -> Dictionary:
	_ensure_cache()
	return _maps

static func _ensure_cache() -> void:
	if _cache_ready:
		return
	_cache_ready = true
	_maps = {
		"ash_vault_01": {"id":"ash_vault_01", "name":"Ash Vault", "layout_id":"layout_ruin_rect_01", "tags":["ash","vault","starter"], "boss_id":"ash_warden"},
		"chain_court_01": {"id":"chain_court_01", "name":"Chain Court", "layout_id":"layout_cross_vault_01", "tags":["chain","court"], "boss_id":"chain_judicator"},
		"ember_ring_01": {"id":"ember_ring_01", "name":"Ember Ring", "layout_id":"layout_ring_arena_01", "tags":["ember","arena"], "boss_id":"ember_sentinel"}
	}
