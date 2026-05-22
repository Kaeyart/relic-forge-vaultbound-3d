extends RefCounted
class_name RVUIItemFormatSystem3D

static func item_detail_text(item: Dictionary) -> String:
	if item.is_empty():
		return "No item selected."

	var lines: PackedStringArray = PackedStringArray()
	lines.append("[b]" + str(item.get("display_name", item.get("name", item.get("label", "Item")))) + "[/b]")

	var rarity: String = str(item.get("rarity", "normal")).capitalize()
	var category: String = str(item.get("category", item.get("kind", item.get("item_kind", "")))).replace("_", " ").capitalize()
	var level: int = int(item.get("item_level", item.get("level", item.get("gem_level", 1))))

	if category != "":
		lines.append(rarity + " · " + category + " · Lv. " + str(level))
	else:
		lines.append(rarity + " · Lv. " + str(level))

	if item.has("slot") and str(item.get("slot", "")) != "":
		lines.append("Slot: " + str(item.get("slot", "")).replace("_", " ").capitalize())

	if item.has("item_power"):
		lines.append("Item Power: " + str(int(item.get("item_power", 0))))
	elif item.has("power"):
		lines.append("Power: " + str(int(item.get("power", 0))))

	var stats: Dictionary = _collect_stats(item)
	if not stats.is_empty():
		lines.append("")
		lines.append("[b]Stats[/b]")
		for key: Variant in stats.keys():
			var stat_key: String = str(key)
			var value: Variant = stats[key]
			lines.append("• " + stat_key + ": " + _signed_value(value))

	if item.has("quality"):
		lines.append("Quality: +" + str(int(item.get("quality", 0))) + "%")

	if item.has("forge_potential"):
		lines.append("Forge Potential: " + str(int(item.get("forge_potential", 0))))
	elif item.has("crafting_potential"):
		lines.append("Forge Potential: " + str(int(item.get("crafting_potential", 0))))

	var sockets: Array = Array(item.get("sockets", item.get("rune_sockets", [])))
	if not sockets.is_empty():
		lines.append("Sockets: " + str(sockets.size()))

	var tags: Array = Array(item.get("tags", []))
	if not tags.is_empty():
		var tag_text: PackedStringArray = PackedStringArray()
		for tag: Variant in tags:
			tag_text.append(str(tag))
		lines.append("Tags: " + ", ".join(tag_text))

	var description: String = str(item.get("description", item.get("flavor_text", ""))).strip_edges()
	if description != "":
		lines.append("")
		lines.append("[i]" + description + "[/i]")

	return "\n".join(lines)


static func compare_items_text(candidate: Dictionary, equipped: Dictionary) -> String:
	if candidate.is_empty():
		return ""

	if equipped.is_empty():
		return "No equipped item in this slot."

	var lines: PackedStringArray = PackedStringArray()
	lines.append("[b]Compare[/b]")
	lines.append("New: " + str(candidate.get("display_name", candidate.get("name", "Item"))))
	lines.append("Old: " + str(equipped.get("display_name", equipped.get("name", "Item"))))

	var candidate_stats: Dictionary = _collect_stats(candidate)
	var equipped_stats: Dictionary = _collect_stats(equipped)
	var keys: Array[String] = []

	for key: Variant in candidate_stats.keys():
		var stat_key: String = str(key)
		if not keys.has(stat_key):
			keys.append(stat_key)

	for key: Variant in equipped_stats.keys():
		var stat_key: String = str(key)
		if not keys.has(stat_key):
			keys.append(stat_key)

	if keys.is_empty():
		lines.append("No comparable stats.")
	else:
		lines.append("")
		for stat_key: String in keys:
			var new_value: float = float(candidate_stats.get(stat_key, 0.0))
			var old_value: float = float(equipped_stats.get(stat_key, 0.0))
			var delta: float = new_value - old_value
			if absf(delta) <= 0.001:
				continue
			lines.append("• " + stat_key + ": " + _signed_float(delta))

	return "\n".join(lines)


static func item_summary_text(item: Dictionary) -> String:
	if item.is_empty():
		return "Empty"
	return str(item.get("display_name", item.get("name", item.get("label", "Item"))))


static func _collect_stats(item: Dictionary) -> Dictionary:
	var out: Dictionary = {}

	if item.has("total_stats") and typeof(item["total_stats"]) == TYPE_DICTIONARY:
		_merge_stats(out, Dictionary(item["total_stats"]))

	if item.has("stats") and typeof(item["stats"]) == TYPE_DICTIONARY:
		_merge_stats(out, Dictionary(item["stats"]))

	if item.has("implicit_stats") and typeof(item["implicit_stats"]) == TYPE_DICTIONARY:
		_merge_stats(out, Dictionary(item["implicit_stats"]))

	if item.has("explicit_stats") and typeof(item["explicit_stats"]) == TYPE_DICTIONARY:
		_merge_stats(out, Dictionary(item["explicit_stats"]))

	if item.has("affixes") and typeof(item["affixes"]) == TYPE_ARRAY:
		for value: Variant in Array(item["affixes"]):
			if typeof(value) != TYPE_DICTIONARY:
				continue
			var affix: Dictionary = Dictionary(value)
			var stat_key: String = str(affix.get("stat", affix.get("stat_key", affix.get("id", ""))))
			if stat_key == "":
				continue
			out[stat_key] = float(out.get(stat_key, 0.0)) + float(affix.get("value", affix.get("amount", 0.0)))

	return out


static func _merge_stats(out: Dictionary, stats: Dictionary) -> void:
	for key: Variant in stats.keys():
		var stat_key: String = str(key)
		out[stat_key] = float(out.get(stat_key, 0.0)) + float(stats[key])


static func _signed_value(value: Variant) -> String:
	if typeof(value) == TYPE_INT or typeof(value) == TYPE_FLOAT:
		return _signed_float(float(value))
	return str(value)


static func _signed_float(value: float) -> String:
	var rounded: float = snappedf(value, 0.01)
	if rounded > 0.0:
		return "+" + str(rounded)
	return str(rounded)
