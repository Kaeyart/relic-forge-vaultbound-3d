extends RefCounted
class_name RVLootPresentationSystem3D

static func item_name_from_source(source: Variant) -> String:
	var data: Dictionary = _item_dict(source)
	if data.is_empty():
		if source is Node:
			var n: Node = source as Node
			return _clean_node_name(n.name)
		return "Item"

	var display_name: String = str(data.get("display_name", data.get("name", ""))).strip_edges()
	if display_name != "":
		return display_name

	var base_id: String = str(data.get("base_id", data.get("id", "Item")))
	return base_id.capitalize()


static func rarity_from_source(source: Variant) -> String:
	var data: Dictionary = _item_dict(source)
	var rarity: String = str(data.get("rarity", "normal")).strip_edges().to_lower()
	if rarity == "magic" or rarity == "rare" or rarity == "unique":
		return rarity
	return "normal"


static func kind_from_source(source: Variant) -> String:
	var data: Dictionary = _item_dict(source)
	var kind: String = str(data.get("kind", data.get("item_kind", data.get("category", "")))).strip_edges().to_lower()
	var slot: String = str(data.get("slot", "")).strip_edges().to_lower()
	var gem_type: String = str(data.get("gem_type", data.get("skill_gem_type", ""))).strip_edges().to_lower()

	if gem_type == "active" or gem_type == "support" or gem_type == "spirit":
		return "gem"
	if kind == "currency" or kind == "material" or kind == "shard":
		return "currency"
	if kind == "map" or kind == "map_item" or slot == "map" or data.has("map_tier") or data.has("tier"):
		return "map"
	if kind == "crystal" or kind == "crystallized":
		return "crystal"
	if rarity_from_source(source) == "unique":
		return "unique"
	if kind == "gem" or kind == "skill_gem" or kind == "active_gem" or kind == "support_gem" or kind == "spirit_gem":
		return "gem"
	return "gear"


static func kind_short_label(kind: String) -> String:
	match kind.strip_edges().to_lower():
		"currency":
			return "CUR"
		"gem":
			return "GEM"
		"map":
			return "MAP"
		"crystal":
			return "CRY"
		"unique":
			return "UNI"
		_:
			return "GEAR"


static func rarity_color(rarity: String) -> Color:
	match rarity.strip_edges().to_lower():
		"magic":
			return Color(0.34, 0.54, 1.0, 1.0)
		"rare":
			return Color(1.0, 0.82, 0.22, 1.0)
		"unique":
			return Color(1.0, 0.46, 0.12, 1.0)
		_:
			return Color(0.92, 0.92, 0.88, 1.0)


static func beam_height_for_rarity(rarity: String) -> float:
	match rarity.strip_edges().to_lower():
		"unique":
			return 3.6
		"rare":
			return 3.1
		"magic":
			return 2.6
		_:
			return 2.0


static func beam_radius_for_rarity(rarity: String) -> float:
	match rarity.strip_edges().to_lower():
		"unique":
			return 0.115
		"rare":
			return 0.095
		"magic":
			return 0.075
		_:
			return 0.055


static func ring_radius_for_kind(kind: String, rarity: String) -> float:
	var result: float = 0.44
	match kind.strip_edges().to_lower():
		"currency":
			result = 0.34
		"gem":
			result = 0.40
		"map":
			result = 0.55
		"crystal":
			result = 0.42
		"unique":
			result = 0.62
		_:
			result = 0.48

	if rarity.strip_edges().to_lower() == "rare":
		result += 0.08
	elif rarity.strip_edges().to_lower() == "unique":
		result += 0.14

	return result


static func pickup_text(source: Variant) -> String:
	var rarity: String = rarity_from_source(source)
	var kind: String = kind_from_source(source)
	var item_name: String = item_name_from_source(source)
	if rarity == "normal":
		return kind_short_label(kind) + " · " + item_name
	return rarity.capitalize() + " " + kind_short_label(kind) + " · " + item_name


static func _item_dict(source: Variant) -> Dictionary:
	if typeof(source) == TYPE_DICTIONARY:
		return Dictionary(source)

	if source is Object:
		var obj: Object = source as Object
		if obj.has_meta("item_data"):
			var meta_item: Variant = obj.get_meta("item_data")
			if typeof(meta_item) == TYPE_DICTIONARY:
				return Dictionary(meta_item)
		if obj.has_meta("rv_item"):
			var rv_item: Variant = obj.get_meta("rv_item")
			if typeof(rv_item) == TYPE_DICTIONARY:
				return Dictionary(rv_item)
		if obj.has_meta("drop_item"):
			var drop_item: Variant = obj.get_meta("drop_item")
			if typeof(drop_item) == TYPE_DICTIONARY:
				return Dictionary(drop_item)

		var direct: Dictionary = {}
		for key: String in ["display_name", "name", "id", "base_id", "rarity", "kind", "item_kind", "category", "slot", "gem_type", "skill_gem_type", "tier", "map_tier"]:
			if _has_property(obj, key):
				direct[key] = obj.get(key)
		return direct

	return {}


static func _has_property(obj: Object, prop: String) -> bool:
	if obj == null:
		return false
	var props: Array = obj.get_property_list()
	for value: Variant in props:
		if typeof(value) != TYPE_DICTIONARY:
			continue
		var data: Dictionary = Dictionary(value)
		if str(data.get("name", "")) == prop:
			return true
	return false


static func _clean_node_name(value: String) -> String:
	var clean: String = value.replace("_", " ").replace("-", " ").strip_edges()
	if clean == "":
		return "Item"
	return clean.capitalize()
