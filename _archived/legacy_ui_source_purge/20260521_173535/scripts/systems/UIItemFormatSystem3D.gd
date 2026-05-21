extends RefCounted

const SkillGemSystemScript := preload("res://scripts/systems/SkillGemSystem3D.gd")

static func item_title(item: Dictionary) -> String:
	return str(item.get("display_name", item.get("name", "Item")))

static func item_rarity(item: Dictionary) -> String:
	return str(item.get("rarity", "normal")).strip_edges().to_lower()

static func normalized_slot(item: Dictionary) -> String:
	var slot: String = str(item.get("slot", "")).strip_edges().to_lower()
	match slot:
		"helm": return "head"
		"ring": return "ring1"
		_: return slot

static func is_gem_item(item: Dictionary) -> bool:
	return SkillGemSystemScript.gem_type(item) != ""

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
	if is_gem_item(item):
		return _gem_detail_text(item)
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
	var stats: Dictionary = Dictionary(item.get("total_stats", item.get("stats", {})))
	if not stats.is_empty():
		lines.append("")
		lines.append("[b]Stats[/b]")
		for key: Variant in stats.keys():
			lines.append("• " + stat_line(str(key), stats[key]))
	return "\n".join(lines)

static func _gem_detail_text(item: Dictionary) -> String:
	var type := SkillGemSystemScript.gem_type(item)
	var id := SkillGemSystemScript.gem_id(item)
	var lines := PackedStringArray()
	lines.append("[b]" + item_title(item) + "[/b]")
	lines.append(_title_case(type) + " Skill Gem · " + _title_case(str(item.get("base_color", item.get("gem_color", "blue")))) + " socket color")
	lines.append(SkillGemSystemScript.gem_detail_text(item, type))
	if type == SkillGemSystemScript.GEM_SUPPORT:
		var data := SkillGemSystemScript.support_data(id)
		lines.append("")
		lines.append("Compatibility: " + ", ".join(_packed_strings(data.get("requires_any", []))))
	elif type == SkillGemSystemScript.GEM_ACTIVE:
		var data2 := SkillGemSystemScript.active_data(id)
		lines.append("")
		lines.append("Tags: " + ", ".join(_packed_strings(data2.get("tags", []))))
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
		"max_health": "Maximum Health", "max_hp": "Maximum Health", "maximum life": "Maximum Life",
		"fire_resistance": "Fire Resistance", "cold_resistance": "Cold Resistance", "lightning_resistance": "Lightning Resistance",
		"block_chance": "Block Chance", "crit_chance": "Critical Chance", "crit_multi": "Critical Multiplier",
		"spell_damage": "Spell Damage", "attack_damage": "Attack Damage", "fire_damage": "Fire Damage", "lightning_damage": "Lightning Damage", "void_damage": "Void Damage",
		"cast_speed": "Cast Speed", "movement_speed": "Movement Speed", "projectile_damage": "Projectile Damage"
	}
	if explicit.has(clean):
		return str(explicit[clean])
	return _title_case(clean.replace("_", " "))

static func action_hint_for_panel(mode: String) -> String:
	match mode:
		"inventory": return "[b]Inventory[/b] Click select · Double-click equip/use · Sort cleans layout · Deposit works only near the physical Stash."
		"stash": return "[b]Stash[/b] Quick Deposit All · Click inspect · Double-click/right-click withdraw · Right-click tab customize routing."
		"crafting": return "[b]Forge[/b] Select item · choose operation · check cost/result · apply.\nAccess requires the physical Forge."
		"skills": return "[b]Skills[/b] Active gems hold support sockets · supports must match skill tags · spirit gems reserve spirit."
		"maps": return "[b]Maps[/b] Pick a map item · check tier/rarity/bonus · open map."
		"character": return "[b]Character[/b] Read offense, defense, resources, and build identity."
		_: return ""

static func _map_bonus_text(item: Dictionary) -> String:
	var tier: int = _safe_int(item.get("tier", item.get("map_tier", 1)), 1)
	if tier <= 5:
		return "Clear the map"
	if tier <= 9:
		return "Complete as Magic or Rare"
	return "Complete as Rare"

static func _packed_strings(value: Variant) -> PackedStringArray:
	var out := PackedStringArray()
	if typeof(value) == TYPE_ARRAY:
		for v in Array(value):
			out.append(str(v))
	return out

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
		TYPE_INT: return value
		TYPE_FLOAT: return int(round(value))
		TYPE_BOOL: return 1 if bool(value) else 0
		TYPE_STRING:
			var s: String = str(value)
			if s.is_valid_int(): return s.to_int()
			if s.is_valid_float(): return int(round(s.to_float()))
			return fallback
		_: return fallback
