extends RefCounted

const ItemDBScript := preload("res://scripts/data/ItemDB3D.gd")

const MODE_INVENTORY: String = "inventory"
const MODE_STASH: String = "stash"
const MODE_CRAFTING: String = "crafting"
const MODE_SKILLS: String = "skills"
const MODE_MAPS: String = "maps"
const MODE_CHARACTER: String = "character"

static func panel_title(mode: String) -> String:
	match mode:
		MODE_INVENTORY:
			return "Inventory"
		MODE_STASH:
			return "Stash"
		MODE_CRAFTING:
			return "Forge"
		MODE_SKILLS:
			return "Skill Gems"
		MODE_MAPS:
			return "Map Device"
		MODE_CHARACTER:
			return "Character"
		_:
			return "Panel"


static func panel_hint(mode: String) -> String:
	match mode:
		MODE_INVENTORY:
			return "Manage gear, compare items, sort, and move physical drops."
		MODE_STASH:
			return "Store items by affinity. Quick Deposit routes loot into the correct tab."
		MODE_CRAFTING:
			return "Choose an item, spend currency and Forge Potential, then apply a deterministic forge action."
		MODE_SKILLS:
			return "Install active, support, and spirit gems. Skills level and unlock sockets over time."
		MODE_MAPS:
			return "Choose a map, inspect tier, rarity, modifiers, and bonus objective."
		MODE_CHARACTER:
			return "Readable offense, defense, resources, utility, resistances, and build identity."
		_:
			return "Select something, inspect it, then use the action bar."


static func panel_actions(mode: String) -> Array:
	match mode:
		MODE_INVENTORY:
			return [{"id":"primary","label":"Equip / Use"},{"id":"compare","label":"Compare"},{"id":"deposit","label":"Deposit"},{"id":"sort","label":"Sort"},{"id":"close","label":"Close"}]
		MODE_STASH:
			return [{"id":"quick_deposit","label":"Quick Deposit All"},{"id":"withdraw","label":"Withdraw"},{"id":"customize_tab","label":"Customize Tab"},{"id":"search","label":"Search"},{"id":"close","label":"Close"}]
		MODE_CRAFTING:
			return [{"id":"seal","label":"Seal"},{"id":"reforge","label":"Reforge"},{"id":"polish","label":"Polish"},{"id":"upgrade","label":"Upgrade"},{"id":"remove","label":"Remove"},{"id":"close","label":"Close"}]
		MODE_SKILLS:
			return [{"id":"gem_inventory_hint","label":"Install From Inventory"},{"id":"toggle_spirit","label":"Toggle Spirit"},{"id":"remove_gem","label":"Remove Gem"},{"id":"close","label":"Close"}]
		MODE_MAPS:
			return [{"id":"open_map","label":"Open Map"},{"id":"sort","label":"Sort"},{"id":"close","label":"Close"}]
		MODE_CHARACTER:
			return [{"id":"close","label":"Close"}]
		_:
			return [{"id":"close","label":"Close"}]


static func item_card_text(item: Dictionary, compare_item: Dictionary = {}) -> String:
	if item.is_empty():
		return "[i]No item selected.[/i]"

	if str(item.get("kind", "")) == "item" or item.has("prefixes") or item.has("suffixes") or item.has("implicit_stats"):
		var text: String = ItemDBScript.item_detail_text(item)
		if not compare_item.is_empty():
			text += "\n\n[b]Compare[/b]\n" + ItemDBScript.compare_items_text(item, compare_item)
		return text

	var lines: Array[String] = []
	lines.append("[b]" + str(item.get("display_name", item.get("name", "Item"))) + "[/b]")
	lines.append(rarity_text(str(item.get("rarity", "normal"))) + " · " + kind_text(item) + " · " + slot_text(item))

	var level: int = _to_int(item.get("item_level", item.get("level", 0)), 0)
	if level > 0:
		lines.append("Item Level: " + str(level))

	if is_map_item(item):
		lines.append("Map Tier: " + str(_to_int(item.get("tier", item.get("map_tier", 1)), 1)))
		lines.append("Bonus: " + map_bonus_text(item))

	if is_gem_item(item):
		lines.append(gem_line(item))

	var stack: int = _to_int(item.get("stack", item.get("amount", 0)), 0)
	if stack > 1:
		lines.append("Stack: " + str(stack))

	var stats: Dictionary = _as_dict(item.get("total_stats", item.get("stats", {})))
	if not stats.is_empty():
		lines.append("")
		lines.append("[b]Stats[/b]")
		for stat_key: Variant in stats.keys():
			lines.append("• " + stat_line(str(stat_key), stats[stat_key]))

	return "\n".join(lines)


static func compare_text(candidate: Dictionary, equipped: Dictionary) -> String:
	return ItemDBScript.compare_items_text(candidate, equipped)


static func stat_line(key: String, value: Variant) -> String:
	return ItemDBScript.stat_line(key, value)


static func stat_label(key: String) -> String:
	return ItemDBScript.stat_label(key)


static func value_text(value: Variant) -> String:
	match typeof(value):
		TYPE_INT:
			return str(value)
		TYPE_FLOAT:
			return str(int(round(value)))
		TYPE_STRING:
			var s: String = str(value)
			if s.is_valid_float():
				return str(int(round(s.to_float())))
			return s
		_:
			return str(value)


static func rarity_text(value: String) -> String:
	match value.strip_edges().to_lower():
		"normal":
			return "Normal"
		"magic":
			return "Magic"
		"rare":
			return "Rare"
		"unique":
			return "Unique"
		_:
			return title_case(value)


static func kind_text(item: Dictionary) -> String:
	var kind: String = str(item.get("kind", item.get("item_kind", item.get("category", ""))))
	if kind == "":
		kind = "item"
	return title_case(kind.replace("_", " "))


static func slot_text(item: Dictionary) -> String:
	var slot: String = str(item.get("slot", ""))
	if slot == "":
		return "No Slot"
	return title_case(slot.replace("_", " "))


static func is_map_item(item: Dictionary) -> bool:
	var kind: String = str(item.get("kind", item.get("item_kind", item.get("category", "")))).to_lower()
	var slot: String = str(item.get("slot", "")).to_lower()
	return kind == "map" or kind == "map_item" or slot == "map"


static func is_gem_item(item: Dictionary) -> bool:
	var gem_type: String = str(item.get("gem_type", item.get("skill_gem_type", ""))).to_lower()
	if gem_type in ["active", "support", "spirit"]:
		return true
	var kind: String = str(item.get("kind", item.get("item_kind", ""))).to_lower()
	return kind in ["active_gem", "support_gem", "spirit_gem", "skill_gem"]


static func gem_line(item: Dictionary) -> String:
	var gem_type: String = str(item.get("gem_type", item.get("skill_gem_type", "gem")))
	var level: int = _to_int(item.get("level", item.get("gem_level", 1)), 1)
	var xp: int = _to_int(item.get("xp", item.get("gem_xp", 0)), 0)
	var quality: int = _to_int(item.get("quality", item.get("gem_quality", 0)), 0)
	return "Gem: " + title_case(gem_type) + " · Level " + str(level) + " · XP " + str(xp) + " · Quality +" + str(quality) + "%"


static func map_bonus_text(item: Dictionary) -> String:
	var tier: int = _to_int(item.get("tier", item.get("map_tier", 1)), 1)
	if tier <= 5:
		return "Clear the map"
	if tier <= 9:
		return "Complete as Magic or Rare"
	return "Complete as Rare"


static func title_case(value: String) -> String:
	var words: PackedStringArray = value.split(" ", false)
	for i: int in range(words.size()):
		var word: String = words[i]
		if word.length() > 0:
			words[i] = word.substr(0, 1).to_upper() + word.substr(1).to_lower()
	return " ".join(words)


static func rarity_color(value: String) -> Color:
	match value.strip_edges().to_lower():
		"normal":
			return Color(0.92, 0.92, 0.92, 1.0)
		"magic":
			return Color(0.45, 0.62, 1.0, 1.0)
		"rare":
			return Color(1.0, 0.86, 0.28, 1.0)
		"unique":
			return Color(1.0, 0.52, 0.20, 1.0)
		_:
			return Color(1.0, 1.0, 1.0, 1.0)


static func _as_dict(value: Variant) -> Dictionary:
	if typeof(value) == TYPE_DICTIONARY:
		return value
	return {}


static func _to_int(value: Variant, fallback: int = 0) -> int:
	if value == null:
		return fallback
	match typeof(value):
		TYPE_INT:
			return value
		TYPE_FLOAT:
			return roundi(value)
		TYPE_STRING:
			var s: String = str(value)
			if s.is_valid_int():
				return s.to_int()
			if s.is_valid_float():
				return roundi(s.to_float())
			return fallback
		TYPE_BOOL:
			return 1 if bool(value) else 0
		_:
			return fallback
