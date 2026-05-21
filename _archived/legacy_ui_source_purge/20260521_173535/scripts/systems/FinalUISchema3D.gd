extends RefCounted
class_name RVFinalUISchema3D

const MODES: Array[String] = ["skills", "inventory", "forge", "stash", "maps", "character", "rewards"]

static func mode_title(mode: String) -> String:
	match mode:
		"skills": return "Skill Gems"
		"inventory": return "Inventory"
		"forge": return "Forge"
		"stash": return "Stash"
		"maps": return "Map Device"
		"character": return "Character"
		"rewards": return "Map Clear Rewards"
		_: return "Panel"


static func mode_hint(mode: String) -> String:
	match mode:
		"skills": return "Cut uncut gems, install active skills, socket supports, and toggle spirit gems."
		"inventory": return "Inspect, compare, equip, stash, salvage, and sort loot."
		"forge": return "Preview deterministic forge actions before spending currency and Forge Potential."
		"stash": return "Deposit loot into mandatory affinity tabs or buy generic gear tabs."
		"maps": return "Choose a map, inspect rarity/modifiers, and open the next run."
		"character": return "Read your build as resources, offense, defense, utility, and identity."
		"rewards": return "Review clear rewards, take all, inspect, or return to hub."
		_: return ""


static func mode_shortcut(mode: String) -> String:
	match mode:
		"skills": return "G"
		"inventory": return "I"
		"forge": return "F"
		"stash": return "B"
		"maps": return "M"
		"character": return "C"
		"rewards": return "R"
		_: return "-"


static func mode_for_keycode(keycode: int) -> String:
	match keycode:
		KEY_G: return "skills"
		KEY_I: return "inventory"
		KEY_F: return "forge"
		KEY_B: return "stash"
		KEY_M: return "maps"
		KEY_C: return "character"
		KEY_R: return "rewards"
		_: return ""


static func action_specs(mode: String) -> Array[Dictionary]:
	match mode:
		"skills":
			return [
				{"id":"cut_gem", "label":"Cut Gem"},
				{"id":"install", "label":"Install"},
				{"id":"add_support", "label":"Add Support"},
				{"id":"toggle_spirit", "label":"Toggle Spirit"},
				{"id":"remove", "label":"Remove"},
				{"id":"close", "label":"Close"},
			]
		"inventory":
			return [
				{"id":"equip", "label":"Equip"},
				{"id":"compare", "label":"Compare"},
				{"id":"stash", "label":"Stash"},
				{"id":"salvage", "label":"Salvage"},
				{"id":"sort", "label":"Sort"},
				{"id":"close", "label":"Close"},
			]
		"forge":
			return [
				{"id":"seal", "label":"Seal"},
				{"id":"reforge", "label":"Reforge"},
				{"id":"polish", "label":"Polish"},
				{"id":"upgrade", "label":"Upgrade"},
				{"id":"remove_affix", "label":"Remove"},
				{"id":"close", "label":"Close"},
			]
		"stash":
			return [
				{"id":"deposit_all", "label":"Deposit All"},
				{"id":"withdraw", "label":"Withdraw"},
				{"id":"buy_tab", "label":"Buy Gear Tab"},
				{"id":"search", "label":"Search"},
				{"id":"close", "label":"Close"},
			]
		"maps":
			return [
				{"id":"open_map", "label":"Open Map"},
				{"id":"sort", "label":"Sort"},
				{"id":"close", "label":"Close"},
			]
		"character":
			return [{"id":"close", "label":"Close"}]
		"rewards":
			return [
				{"id":"take_all", "label":"Take All"},
				{"id":"inspect", "label":"Inspect"},
				{"id":"return_hub", "label":"Return Hub"},
				{"id":"close", "label":"Close"},
			]
		_:
			return [{"id":"close", "label":"Close"}]


static func nav_modes() -> Array[String]:
	return MODES.duplicate()


static func next_mode(current: String, backwards: bool = false) -> String:
	var modes: Array[String] = nav_modes()
	var index: int = modes.find(current)
	if index < 0:
		return modes[0]
	if backwards:
		index -= 1
		if index < 0:
			index = modes.size() - 1
	else:
		index += 1
		if index >= modes.size():
			index = 0
	return modes[index]


static func shell_palette() -> Dictionary:
	return {
		"dim": Color(0.0, 0.0, 0.0, 0.56),
		"panel": Color(0.045, 0.047, 0.055, 0.96),
		"panel_alt": Color(0.075, 0.072, 0.066, 0.96),
		"slot": Color(0.105, 0.105, 0.115, 0.96),
		"slot_hover": Color(0.16, 0.15, 0.13, 0.98),
		"border": Color(0.55, 0.42, 0.22, 1.0),
		"border_soft": Color(0.30, 0.25, 0.18, 1.0),
		"text": Color(0.91, 0.88, 0.78, 1.0),
		"muted": Color(0.58, 0.57, 0.53, 1.0),
		"accent": Color(0.95, 0.62, 0.20, 1.0),
		"green": Color(0.38, 0.82, 0.42, 1.0),
		"red": Color(0.95, 0.32, 0.24, 1.0),
	}


static func rarity_color(rarity: String) -> Color:
	match rarity.strip_edges().to_lower():
		"normal": return Color(0.86, 0.86, 0.82, 1.0)
		"magic": return Color(0.34, 0.52, 1.0, 1.0)
		"rare": return Color(1.0, 0.84, 0.22, 1.0)
		"unique": return Color(1.0, 0.48, 0.18, 1.0)
		"gem": return Color(0.65, 0.42, 1.0, 1.0)
		"currency": return Color(0.78, 0.64, 0.36, 1.0)
		"map": return Color(0.55, 0.80, 1.0, 1.0)
		_: return Color(0.86, 0.86, 0.82, 1.0)


static func slot_label(slot: String) -> String:
	match slot:
		"head": return "Helm"
		"chest": return "Chest"
		"gloves": return "Gloves"
		"boots": return "Boots"
		"weapon": return "Weapon"
		"amulet": return "Amulet"
		"ring_1": return "Ring 1"
		"ring_2": return "Ring 2"
		"ring": return "Ring"
		"relic": return "Relic"
		"offhand": return "Offhand"
		_: return _title_case(slot.replace("_", " "))


static func equipment_slots() -> Array[Array]:
	return [
		["head", "chest", "gloves", "boots", "weapon"],
		["amulet", "ring_1", "ring_2", "relic", "offhand"],
	]


static func mandatory_stash_categories() -> Array[Dictionary]:
	return [
		{"id":"currency", "label":"Currency"},
		{"id":"maps", "label":"Maps"},
		{"id":"gems", "label":"Gems"},
		{"id":"crystals", "label":"Crystals"},
		{"id":"uniques", "label":"Uniques"},
		{"id":"gear", "label":"Gear Tabs"},
	]


static func active_skill_choices() -> Array[Dictionary]:
	return [
		{"id":"fireball", "label":"Fireball", "tags":"Projectile / AoE / Ignite"},
		{"id":"storm_lance", "label":"Storm Lance", "tags":"Beam / Pierce / Shock"},
		{"id":"arc_slash", "label":"Arc Slash", "tags":"Cone / Cleave / Bleed"},
		{"id":"void_rift", "label":"Void Rift", "tags":"Zone / Control / Slow"},
		{"id":"ember_mine", "label":"Ember Mine", "tags":"Setup / Burst / Ignite"},
	]


static func support_choices() -> Array[Dictionary]:
	return [
		{"id":"extra_projectiles", "label":"Extra Projectiles", "effect":"+projectiles, wider spread", "visual":"more projectile lanes"},
		{"id":"expanded_area", "label":"Expanded Area", "effect":"+area radius", "visual":"larger impact rings"},
		{"id":"faster_casting", "label":"Faster Casting", "effect":"lower cast time", "visual":"shorter windup"},
		{"id":"chain_current", "label":"Chain Current", "effect":"forks/chains lightning", "visual":"branching beams"},
		{"id":"bleed_edge", "label":"Bleed Edge", "effect":"adds bleed to slashes", "visual":"red slash trail"},
		{"id":"echoing_void", "label":"Echoing Void", "effect":"repeating void pulses", "visual":"delayed echo rings"},
	]


static func spirit_choices() -> Array[Dictionary]:
	return [
		{"id":"ember_pact", "label":"Ember Pact", "reserve":20, "effect":"fire skills build ignite pressure"},
		{"id":"comet_omen", "label":"Comet Omen", "reserve":25, "effect":"condition stacks call down a comet"},
		{"id":"storm_mantle", "label":"Storm Mantle", "reserve":18, "effect":"periodic shock retaliation"},
		{"id":"void_choir", "label":"Void Choir", "reserve":22, "effect":"void pulses slow nearby enemies"},
		{"id":"iron_benediction", "label":"Iron Benediction", "reserve":15, "effect":"defensive guard while casting"},
	]


static func _title_case(value: String) -> String:
	var words: PackedStringArray = value.split(" ", false)
	for i: int in range(words.size()):
		var word: String = words[i]
		if word.length() > 0:
			words[i] = word.substr(0, 1).to_upper() + word.substr(1).to_lower()
	return " ".join(words)
