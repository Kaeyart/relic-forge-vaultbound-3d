extends RefCounted
class_name RVUIUXSystem3D

const UIStateSummarySystemScript := preload("res://scripts/systems/UIStateSummarySystem3D.gd")

const PANEL_ORDER: Array[String] = ["inventory", "stash", "crafting", "skills", "maps", "character"]

static func mode_label(mode: String) -> String:
	match mode:
		"inventory":
			return "Inventory"
		"stash":
			return "Stash"
		"crafting":
			return "Forge"
		"skills":
			return "Skill Gems"
		"maps":
			return "Map Device"
		"character":
			return "Character"
		_:
			return "Panel"


static func shortcut_for_mode(mode: String) -> String:
	match mode:
		"inventory":
			return "I"
		"stash":
			return "B"
		"crafting":
			return "F"
		"skills":
			return "G"
		"maps":
			return "M"
		"character":
			return "C"
		_:
			return "-"


static func mode_for_keycode(keycode: int) -> String:
	match keycode:
		KEY_I:
			return "inventory"
		KEY_B:
			return "stash"
		KEY_F:
			return "crafting"
		KEY_G:
			return "skills"
		KEY_M:
			return "maps"
		KEY_C:
			return "character"
		_:
			return ""


static func next_mode(current: String, backwards: bool = false) -> String:
	var index: int = PANEL_ORDER.find(current)
	if index < 0:
		return PANEL_ORDER[0]
	if backwards:
		index -= 1
		if index < 0:
			index = PANEL_ORDER.size() - 1
	else:
		index += 1
		if index >= PANEL_ORDER.size():
			index = 0
	return PANEL_ORDER[index]


static func action_bar_text(state: Object, mode: String) -> String:
	if mode == "":
		return ""

	var pieces: Array[String] = []
	pieces.append("[b]" + mode_label(mode) + "[/b]")
	var summary: String = UIStateSummarySystemScript.summary_for_mode(state, mode)
	if summary != "":
		pieces.append(summary)
	pieces.append(shortcut_text_for_mode(mode))
	return "  ·  ".join(pieces)


static func shortcut_text_for_mode(mode: String) -> String:
	var common: String = "Esc Close · Tab Next · Shift+Tab Previous"
	match mode:
		"inventory":
			return common + " · Double-click/right-click item · Sort · Compare"
		"stash":
			return common + " · Search · Quick Deposit · Right-click tab"
		"crafting":
			return common + " · Seal · Reforge · Polish · Upgrade · Remove"
		"skills":
			return common + " · Right-click gem · Toggle spirit · Drag/remove later"
		"maps":
			return common + " · Select map · Open map · Bonus objective matters"
		"character":
			return common + " · Inspect offense/defense/resources"
		_:
			return common


static func nav_strip_text(current: String) -> String:
	var out: Array[String] = []
	for mode: String in PANEL_ORDER:
		var label: String = shortcut_for_mode(mode) + " " + mode_label(mode)
		if mode == current:
			out.append("[b][" + label + "][/b]")
		else:
			out.append(label)
	return "   ".join(out)


static func panel_empty_state(mode: String) -> String:
	match mode:
		"inventory":
			return "No item selected. Pick an item to inspect, compare, equip, deposit, or salvage."
		"stash":
			return "No stash item selected. Use search or category tabs to find stored loot."
		"crafting":
			return "Select a backpack item. Good crafting starts with a promising base and enough Forge Potential."
		"skills":
			return "Install active gems, socket supports, and toggle spirit gems."
		"maps":
			return "Select a map. Tier controls difficulty; rarity/modifiers control pressure and reward."
		"character":
			return "Inspect your build summary after gear, gems, and passives modify it."
		_:
			return "Select something to inspect it."


static func accessibility_focus_note(mode: String) -> String:
	match mode:
		"inventory":
			return "Readable priority: rarity color, slot, item level, forge potential, compare deltas."
		"stash":
			return "Readable priority: category, affinity, tab count, search result, selected item."
		"crafting":
			return "Readable priority: cost, forge potential, current affixes, predicted action."
		"skills":
			return "Readable priority: active skill, support sockets, skill level, spirit reservation."
		"maps":
			return "Readable priority: tier, rarity, modifiers, completion, bonus requirement."
		"character":
			return "Readable priority: resource totals, offense, defense, rules, build identity."
		_:
			return ""
