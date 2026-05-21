extends RefCounted

const MODE_INVENTORY: String = "inventory"
const MODE_STASH: String = "stash"
const MODE_CRAFTING: String = "crafting"
const MODE_SKILLS: String = "skills"
const MODE_MAPS: String = "maps"
const MODE_CHARACTER: String = "character"
const MODE_HELP: String = "help"

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
		MODE_HELP:
			return "Help"
		_:
			return "Vault Interface"

static func panel_hint(mode: String) -> String:
	match mode:
		MODE_INVENTORY:
			return "[ / ] select item · U equip · F open forge · compare selected item against equipped slot."
		MODE_STASH:
			return "Store loot between runs. Current patch keeps this readable; bulk sorting comes later."
		MODE_CRAFTING:
			return "1 seal · 2 reforge · 3 polish. Select an item in Inventory first."
		MODE_SKILLS:
			return "1-4 choose skill slot · A/D cycle active gem · S add support · W remove support · G spirit."
		MODE_MAPS:
			return "[ / ] choose map · T launch selected map · read tier, mods, and reward pressure before entering."
		MODE_CHARACTER:
			return "Readable combat sheet: core resources, defenses, damage tags, and build rules."
		MODE_HELP:
			return "Esc closes panels. E interacts with hub stations. T starts or exits maps."
		_:
			return ""

static func mode_order() -> Array[String]:
	return [MODE_INVENTORY, MODE_STASH, MODE_CRAFTING, MODE_SKILLS, MODE_MAPS, MODE_CHARACTER]
