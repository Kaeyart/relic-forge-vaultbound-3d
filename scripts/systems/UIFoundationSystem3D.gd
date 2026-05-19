extends RefCounted

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
			return "Manage gear and backpack items. Click to select. Double-click or right-click uses the primary item action. Deposit only works near the physical Stash."
		MODE_STASH:
			return "Store physical items. Quick Deposit All moves backpack items into the correct tab. Categories and affinities should make sorting automatic."
		MODE_CRAFTING:
			return "Workbench flow: choose item, choose operation, inspect preview and cost, then apply. Forge access requires the physical Forge."
		MODE_SKILLS:
			return "Loadout editor. Active gems hold supports. Spirit gems reserve spirit and can also be supported."
		MODE_MAPS:
			return "Run launcher. Choose a map item, inspect tier, rarity, objective, then open the map."
		MODE_CHARACTER:
			return "Readable stat sheet. Offense, defense, resources, utility, resistances, and build identity."
		_:
			return "Select something, inspect it, then use the action bar."

static func panel_actions(mode: String) -> Array[Dictionary]:
	match mode:
		MODE_INVENTORY:
			return [
				{"id":"primary", "label":"Equip / Use"},
				{"id":"compare", "label":"Compare"},
				{"id":"deposit", "label":"Deposit"},
				{"id":"sort", "label":"Sort"},
				{"id":"close", "label":"Close"}
			]
		MODE_STASH:
			return [
				{"id":"quick_deposit", "label":"Quick Deposit All"},
				{"id":"withdraw", "label":"Withdraw"},
				{"id":"customize_tab", "label":"Customize Tab"},
				{"id":"search", "label":"Search"},
				{"id":"close", "label":"Close"}
			]
		MODE_CRAFTING:
			return [
				{"id":"preview", "label":"Preview"},
				{"id":"apply_craft", "label":"Apply Craft"},
				{"id":"clear", "label":"Clear"},
				{"id":"close", "label":"Close"}
			]
		MODE_SKILLS:
			return [
				{"id":"gem_inventory_hint", "label":"Install From Inventory"},
				{"id":"toggle_spirit", "label":"Toggle Spirit"},
				{"id":"remove_gem", "label":"Remove Gem"},
				{"id":"close", "label":"Close"}
			]
		MODE_MAPS:
			return [
				{"id":"open_map", "label":"Open Map"},
				{"id":"sort", "label":"Sort"},
				{"id":"close", "label":"Close"}
			]
		MODE_CHARACTER:
			return [{"id":"close", "label":"Close"}]
		_:
			return [{"id":"close", "label":"Close"}]

static func item_card_text(item: Dictionary, compare_item: Dictionary = {}) -> String:
	if item.is_empty():
		return "[i]No item selected.[/i]"

	var lines: PackedStringArray = []
	var title: String = str(item.get("display_name", item.get("name", "Item")))
	var rarity: String = rarity_text(str(item.get("rarity", "normal")))
	var slot: String = slot_text(item)
	var kind: String = kind_text(item)

	lines.append("[b]" + title + "[/b]")
	lines.append(rarity + " · " + kind + " · " + slot)

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

	var stats: Dictionary = Dictionary(item.get("total_stats", item.get("stats", {})))
	if not stats.is_empty():
		lines.append("")
		lines.append("[b]Stats[/b]")
		for stat_key: Variant in stats.keys():
			lines.append("• " + stat_line(str(stat_key), stats[stat_key]))

	var affixes: Array = Array(item.get("affixes", []))
	if not affixes.is_empty():
		lines.append("")
		lines.append("[b]Affixes[/b]")
		for affix: Variant in affixes:
			if typeof(affix) == TYPE_DICTIONARY:
				var d: Dictionary = Dictionary(affix)
				lines.append("• " + stat_line(str(d.get("stat", d.get("id", "affix"))), d.get("value", 0)))
			else:
				lines.append("• " + str(affix))

	if not compare_item.is_empty():
		lines.append("")
		lines.append(compare_text(item, compare_item))

	return "\n".join(lines)

static func compare_text(candidate: Dictionary, equipped: Dictionary) -> String:
	var lines: PackedStringArray = []
	lines.append("[b]Compare[/b]")
	lines.append("Equipped: " + str(equipped.get("display_name", equipped.get("name", "None"))))

	var c_stats: Dictionary = Dictionary(candidate.get("total_stats", candidate.get("stats", {})))
	var e_stats: Dictionary = Dictionary(equipped.get("total_stats", equipped.get("stats", {})))
	var keys: Array[String] = []

	for key_c: Variant in c_stats.keys():
		var kc: String = str(key_c)
		if not keys.has(kc):
			keys.append(kc)
	for key_e: Variant in e_stats.keys():
		var ke: String = str(key_e)
		if not keys.has(ke):
			keys.append(ke)

	if keys.is_empty():
		lines.append("No comparable numeric stats.")
		return "\n".join(lines)

	for key: String in keys:
		var c: int = _to_int(c_stats.get(key, 0), 0)
		var e: int = _to_int(e_stats.get(key, 0), 0)
		var delta: int = c - e
		if delta > 0:
			lines.append("[color=green]+" + str(delta) + " " + stat_label(key) + "[/color]")
		elif delta < 0:
			lines.append("[color=red]" + str(delta) + " " + stat_label(key) + "[/color]")
		else:
			lines.append("±0 " + stat_label(key))

	return "\n".join(lines)

static func stat_line(key: String, value: Variant) -> String:
	return stat_label(key) + ": " + value_text(value)

static func stat_label(key: String) -> String:
	var clean: String = key.strip_edges().to_lower()
	var labels: Dictionary = {
		"max_health": "Maximum Health",
		"health": "Health",
		"max_mana": "Maximum Mana",
		"mana": "Mana",
		"damage": "Damage",
		"spell_damage": "Spell Damage",
		"attack_damage": "Attack Damage",
		"fire_damage": "Fire Damage",
		"cold_damage": "Cold Damage",
		"lightning_damage": "Lightning Damage",
		"void_damage": "Void Damage",
		"armor": "Armor",
		"evasion": "Evasion",
		"block_chance": "Block Chance",
		"crit_chance": "Critical Chance",
		"crit_multi": "Critical Multiplier",
		"fire_resistance": "Fire Resistance",
		"cold_resistance": "Cold Resistance",
		"lightning_resistance": "Lightning Resistance",
		"movement_speed": "Movement Speed",
		"attack_speed": "Attack Speed",
		"cast_speed": "Cast Speed",
		"spirit": "Spirit"
	}
	if labels.has(clean):
		return str(labels[clean])
	return title_case(clean.replace("_", " "))

static func value_text(value: Variant) -> String:
	match typeof(value):
		TYPE_INT:
			return str(int(value))
		TYPE_FLOAT:
			return str(int(round(float(value))))
		TYPE_STRING:
			var s: String = str(value)
			if s.is_valid_float():
				return str(int(round(s.to_float())))
			return s
		_:
			return str(value)

static func rarity_text(value: String) -> String:
	var r: String = value.strip_edges().to_lower()
	match r:
		"normal":
			return "Normal"
		"magic":
			return "Magic"
		"rare":
			return "Rare"
		"unique":
			return "Unique"
		_:
			return title_case(r)

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

static func _to_int(value: Variant, fallback: int = 0) -> int:
	if value == null:
		return fallback
	match typeof(value):
		TYPE_INT:
			return int(value)
		TYPE_FLOAT:
			return int(round(float(value)))
		TYPE_STRING:
			var s: String = str(value)
			if s.is_valid_int():
				return s.to_int()
			if s.is_valid_float():
				return int(round(s.to_float()))
			return fallback
		TYPE_BOOL:
			return 1 if bool(value) else 0
		_:
			return fallback

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
