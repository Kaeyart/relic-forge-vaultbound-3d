extends RefCounted

static func item_title(item: Dictionary) -> String:
	return str(item.get("display_name", item.get("name", "Item")))

static func item_rarity(item: Dictionary) -> String:
	return str(item.get("rarity", "normal")).strip_edges().to_lower()

static func normalized_slot(item: Dictionary) -> String:
	var slot: String = str(item.get("slot", "")).strip_edges().to_lower()
	match slot:
		"helm":
			return "head"
		"ring":
			return "ring1"
		_:
			return slot

static func is_gem_item(item: Dictionary) -> bool:
	var explicit: String = str(item.get("gem_type", item.get("skill_gem_type", ""))).to_lower()
	if explicit in ["active", "support", "spirit"]:
		return true
	var kind: String = str(item.get("kind", item.get("item_kind", item.get("category", "")))).to_lower()
	if kind in ["active_gem", "active_skill_gem", "support_gem", "spirit_gem", "skill_gem"]:
		return true
	return normalized_slot(item) in ["active_gem", "support_gem", "spirit_gem"]

static func affinity_guess(item: Dictionary) -> String:
	var kind: String = str(item.get("kind", item.get("item_kind", item.get("category", "")))).strip_edges().to_lower()
	var slot: String = normalized_slot(item)
	var rarity: String = item_rarity(item)
	var tags: Array[String] = []
	for tag_value: Variant in Array(item.get("tags", [])):
		tags.append(str(tag_value).strip_edges().to_lower())
	if kind in ["currency", "material", "crafting_currency", "shard"] or tags.has("currency") or tags.has("material"):
		return "Currency"
	if kind in ["map", "map_item"] or slot == "map" or tags.has("map"):
		return "Maps"
	if is_gem_item(item):
		return "Gems"
	if kind in ["crystal", "crystallized", "crystallized_mob_drop"] or tags.has("crystal") or tags.has("crystallized"):
		return "Crystals"
	if rarity == "unique":
		return "Uniques"
	return "Item Tab"

static func item_detail_text(item: Dictionary) -> String:
	if item.is_empty():
		return "[i]No item selected.[/i]"
	var lines: PackedStringArray = []
	lines.append("[b]" + item_title(item) + "[/b]")
	lines.append(_title_case(item_rarity(item)) + " · " + _title_case(str(item.get("kind", item.get("item_kind", "item"))).replace("_", " ")) + " · Slot: " + _title_case(normalized_slot(item).replace("_", " ")))
	lines.append("Routes to: " + affinity_guess(item))
	var stack: int = _safe_int(item.get("stack", item.get("amount", 0)), 0)
	if stack > 1:
		lines.append("Stack: " + str(stack))
	if normalized_slot(item) == "map" or str(item.get("kind", "")).to_lower() == "map":
		lines.append("Map Tier: " + str(_safe_int(item.get("tier", item.get("map_tier", 1)), 1)))
		lines.append("Map Bonus: " + _map_bonus_text(item))
	if is_gem_item(item):
		lines.append("Gem Type: " + _title_case(str(item.get("gem_type", item.get("skill_gem_type", "gem")))))
		lines.append("Gem Color: " + _title_case(str(item.get("base_color", item.get("gem_color", "none")))))
		lines.append("Level: " + str(_safe_int(item.get("level", item.get("gem_level", 1)), 1)) + "   XP: " + str(_safe_int(item.get("xp", item.get("gem_xp", 0)), 0)))
		lines.append("Quality: +" + str(_safe_int(item.get("quality", item.get("gem_quality", 0)), 0)) + "%")
	var stats: Dictionary = Dictionary(item.get("total_stats", item.get("stats", {})))
	if not stats.is_empty():
		lines.append("")
		lines.append("[b]Stats[/b]")
		for key: Variant in stats.keys():
			lines.append("• " + stat_line(str(key), stats[key]))
	return "\n".join(lines)

static func stat_line(key: String, value: Variant) -> String:
	var label: String = stat_label(key)
	if typeof(value) == TYPE_FLOAT:
		return label + ": " + str(int(round(float(value))))
	if typeof(value) == TYPE_INT:
		return label + ": " + str(int(value))
	var s: String = str(value)
	if s.is_valid_float():
		return label + ": " + str(int(round(s.to_float())))
	return label + ": " + s

static func stat_label(key: String) -> String:
	var clean: String = key.strip_edges().to_lower()
	var explicit: Dictionary = {
		"max_health": "Maximum Health",
		"fire_resistance": "Fire Resistance",
		"cold_resistance": "Cold Resistance",
		"lightning_resistance": "Lightning Resistance",
		"block_chance": "Block Chance",
		"crit_chance": "Critical Chance",
		"crit_multi": "Critical Multiplier",
		"spell_damage": "Spell Damage",
		"attack_damage": "Attack Damage",
		"cast_speed": "Cast Speed",
		"movement_speed": "Movement Speed"
	}
	if explicit.has(clean):
		return str(explicit[clean])
	return _title_case(clean.replace("_", " "))

static func action_hint_for_panel(mode: String) -> String:
	match mode:
		"inventory":
			return "[b]Inventory[/b]  Click select · Double-click equip/use · Sort cleans layout · Deposit works only near the physical Stash."
		"stash":
			return "[b]Stash[/b]  Quick Deposit All · Click inspect · Double-click/right-click withdraw · Right-click tab customize routing."
		"crafting":
			return "[b]Forge[/b]  Select item · choose operation · check cost/result · apply. Access requires the physical Forge."
		"skills":
			return "[b]Skills[/b]  Active gems hold support sockets · supports stay attached · spirit gems toggle reservation."
		"maps":
			return "[b]Maps[/b]  Pick a map item · check tier/rarity/bonus · open map."
		"character":
			return "[b]Character[/b]  Read offense, defense, resources, and build identity."
		_:
			return ""

static func _map_bonus_text(item: Dictionary) -> String:
	var tier: int = _safe_int(item.get("tier", item.get("map_tier", 1)), 1)
	if tier <= 5:
		return "Clear the map"
	if tier <= 9:
		return "Complete as Magic or Rare"
	return "Complete as Rare"

static func _title_case(value: String) -> String:
	var parts: PackedStringArray = value.split(" ", false)
	for i: int in range(parts.size()):
		if parts[i].length() > 0:
			parts[i] = parts[i].substr(0, 1).to_upper() + parts[i].substr(1).to_lower()
	return " ".join(parts)

static func _safe_int(value: Variant, fallback: int = 0) -> int:
	if value == null:
		return fallback
	match typeof(value):
		TYPE_INT:
			return value
		TYPE_FLOAT:
			return int(round(value))
		TYPE_BOOL:
			return 1 if bool(value) else 0
		TYPE_STRING:
			var s: String = str(value)
			if s.is_valid_int():
				return s.to_int()
			if s.is_valid_float():
				return int(round(s.to_float()))
			return fallback
		_:
			return fallback
