extends CanvasLayer
class_name RVFinalUIPanelRoot3D

const SchemaScript := preload("res://scripts/systems/FinalUISchema3D.gd")
const ActionsScript := preload("res://scripts/systems/FinalUIActions3D.gd")

var game_root: Node = null
var state_ref: Object = null
var mode: String = ""
var _palette: Dictionary = {}

var _dim: ColorRect = null
var _shell: PanelContainer = null
var _title: Label = null
var _subtitle: Label = null
var _nav: HBoxContainer = null
var _content: HBoxContainer = null
var _left: VBoxContainer = null
var _center: VBoxContainer = null
var _right: VBoxContainer = null
var _actions: HBoxContainer = null
var _notice: Label = null

var _selected_item: Dictionary = {}
var _selected_reward: Dictionary = {}
var _selected_stash_item: Dictionary = {}


func _ready() -> void:
	name = "FinalUIPanelRoot100A"
	layer = 80
	_palette = SchemaScript.shell_palette()
	_build_ui()
	visible = false
	set_process_unhandled_input(true)


func bind_game(root: Node) -> void:
	game_root = root
	state_ref = _state()
	_refresh()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE and visible:
			_close()
			get_viewport().set_input_as_handled()
			return

		if event.keycode == KEY_TAB and visible:
			_open_mode(SchemaScript.next_mode(mode, event.shift_pressed))
			get_viewport().set_input_as_handled()
			return

		var target: String = SchemaScript.mode_for_keycode(event.keycode)
		if target != "":
			_open_mode(target)
			get_viewport().set_input_as_handled()


func update_from_state(state: Object) -> void:
	state_ref = state
	var panel_mode_value: Variant = state_ref.get("panel_mode") if state_ref != null else null
	if panel_mode_value != null and str(panel_mode_value) != "":
		mode = str(panel_mode_value)
		visible = true
	_refresh()


func set_mode(new_mode: String) -> void:
	_open_mode(new_mode)


func _set_mode(new_mode: String) -> void:
	_open_mode(new_mode)


func _open_mode(new_mode: String) -> void:
	if not SchemaScript.nav_modes().has(new_mode):
		return
	state_ref = _state()
	mode = new_mode
	visible = true
	if state_ref != null:
		state_ref.set("panel_mode", mode)
	_refresh()


func _close() -> void:
	mode = ""
	visible = false
	if state_ref != null:
		state_ref.set("panel_mode", "")


func _build_ui() -> void:
	_dim = ColorRect.new()
	_dim.name = "FinalUIDim"
	_dim.color = _palette.get("dim", Color(0, 0, 0, 0.5))
	_dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_dim)

	_shell = PanelContainer.new()
	_shell.name = "FinalUIShell"
	_shell.set_anchors_preset(Control.PRESET_CENTER)
	_shell.custom_minimum_size = Vector2(1560, 860)
	_shell.offset_left = -780
	_shell.offset_top = -430
	_shell.offset_right = 780
	_shell.offset_bottom = 430
	_shell.add_theme_stylebox_override("panel", _panel_style(_palette.get("panel", Color.BLACK), _palette.get("border", Color.GOLD), 3, 16))
	add_child(_shell)

	var outer: VBoxContainer = VBoxContainer.new()
	outer.name = "Outer"
	outer.add_theme_constant_override("separation", 10)
	_shell.add_child(outer)

	var header: HBoxContainer = HBoxContainer.new()
	header.name = "Header"
	header.custom_minimum_size = Vector2(0, 72)
	header.add_theme_constant_override("separation", 10)
	outer.add_child(header)

	var title_box: VBoxContainer = VBoxContainer.new()
	title_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title_box)

	_title = Label.new()
	_title.name = "Title"
	_title.add_theme_font_size_override("font_size", 34)
	_title.add_theme_color_override("font_color", _palette.get("text", Color.WHITE))
	title_box.add_child(_title)

	_subtitle = Label.new()
	_subtitle.name = "Subtitle"
	_subtitle.add_theme_font_size_override("font_size", 16)
	_subtitle.add_theme_color_override("font_color", _palette.get("muted", Color.GRAY))
	title_box.add_child(_subtitle)

	var close_btn: Button = _button("X", "close", Vector2(56, 44))
	close_btn.pressed.connect(func() -> void: _close())
	header.add_child(close_btn)

	_nav = HBoxContainer.new()
	_nav.name = "Navigation"
	_nav.custom_minimum_size = Vector2(0, 48)
	_nav.add_theme_constant_override("separation", 8)
	outer.add_child(_nav)

	_content = HBoxContainer.new()
	_content.name = "Content"
	_content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_content.add_theme_constant_override("separation", 10)
	outer.add_child(_content)

	_left = _column("Left", 330)
	_center = _column("Center", 660)
	_right = _column("Right", 430)
	_content.add_child(_left)
	_content.add_child(_center)
	_content.add_child(_right)

	_actions = HBoxContainer.new()
	_actions.name = "Actions"
	_actions.custom_minimum_size = Vector2(0, 68)
	_actions.add_theme_constant_override("separation", 10)
	outer.add_child(_actions)

	_notice = Label.new()
	_notice.name = "Notice"
	_notice.add_theme_color_override("font_color", _palette.get("accent", Color.ORANGE))
	_notice.add_theme_font_size_override("font_size", 16)
	outer.add_child(_notice)


func _refresh() -> void:
	if not visible or mode == "":
		return

	_title.text = SchemaScript.mode_title(mode)
	_subtitle.text = SchemaScript.mode_hint(mode)

	_clear(_nav)
	for nav_mode: String in SchemaScript.nav_modes():
		var label: String = SchemaScript.mode_shortcut(nav_mode) + " " + SchemaScript.mode_title(nav_mode)
		var btn: Button = _button(label, "nav_" + nav_mode, Vector2(0, 38))
		btn.toggle_mode = true
		btn.button_pressed = nav_mode == mode
		btn.pressed.connect(func(m := nav_mode) -> void: _open_mode(m))
		_nav.add_child(btn)

	_clear(_left)
	_clear(_center)
	_clear(_right)
	_clear(_actions)

	match mode:
		"skills": _build_skills()
		"inventory": _build_inventory()
		"forge": _build_forge()
		"stash": _build_stash()
		"maps": _build_maps()
		"character": _build_character()
		"rewards": _build_rewards()
		_: _center.add_child(_text_block("Unknown panel.", 16))

	for spec: Dictionary in SchemaScript.action_specs(mode):
		var action_id: String = str(spec.get("id", ""))
		var btn2: Button = _button(str(spec.get("label", action_id)), action_id, Vector2(0, 46))
		btn2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn2.pressed.connect(func(a := action_id) -> void: _do_action(a))
		_actions.add_child(btn2)


func _build_inventory() -> void:
	_left.add_child(_section_title("Equipped"))
	var equipped: Dictionary = _state_dict("equipped")
	var equipment_columns: HBoxContainer = HBoxContainer.new()
	equipment_columns.add_theme_constant_override("separation", 8)
	_left.add_child(equipment_columns)

	for column: Array in SchemaScript.equipment_slots():
		var col: VBoxContainer = VBoxContainer.new()
		col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		col.add_theme_constant_override("separation", 8)
		equipment_columns.add_child(col)
		for slot_value: Variant in column:
			var slot: String = str(slot_value)
			var item: Dictionary = {}
			if equipped.has(slot) and typeof(equipped[slot]) == TYPE_DICTIONARY:
				item = Dictionary(equipped[slot])
			col.add_child(_item_slot(SchemaScript.slot_label(slot), item, func() -> void:
				_selected_item = item
				_refresh()
			))

	_center.add_child(_section_title("Backpack"))
	_center.add_child(_inventory_grid(_state_array("backpack")))

	_right.add_child(_section_title("Item Details"))
	if _selected_item.is_empty():
		_selected_item = _first_dict(_state_array("backpack"))
	_right.add_child(_details_text(_item_details_with_compare(_selected_item)))


func _build_skills() -> void:
	_left.add_child(_section_title("Active Skills"))
	var active: Array = _state_array("installed_active_gems")
	if active.is_empty():
		_left.add_child(_empty_card("No active skills installed.\nCut an Uncut Active Gem."))
	else:
		for i: int in range(active.size()):
			if typeof(active[i]) == TYPE_DICTIONARY:
				_left.add_child(_skill_card(Dictionary(active[i]), i))

	_left.add_child(_section_title("Spirit Skills"))
	var spirits: Array = _state_array("installed_spirit_gems")
	if spirits.is_empty():
		_left.add_child(_empty_card("No spirit gems installed.\nCut an Uncut Spirit Gem."))
	else:
		for s: int in range(spirits.size()):
			if typeof(spirits[s]) == TYPE_DICTIONARY:
				_left.add_child(_spirit_card(Dictionary(spirits[s]), s))

	var selected_index: int = clampi(_state_int("selected_skill_index", 0), 0, max(0, active.size() - 1))
	_center.add_child(_section_title("Selected Skill"))
	if active.is_empty() or selected_index >= active.size() or typeof(active[selected_index]) != TYPE_DICTIONARY:
		_center.add_child(_empty_card("Select or cut an active skill."))
	else:
		_center.add_child(_selected_skill_editor(Dictionary(active[selected_index])))

	_right.add_child(_section_title("Gem Inventory"))
	_right.add_child(_gem_inventory_panel())


func _build_forge() -> void:
	_left.add_child(_section_title("Selected Item"))
	var item: Dictionary = _selected_item
	if item.is_empty():
		item = _first_gear_item(_state_array("backpack"))
	if item.is_empty():
		_left.add_child(_empty_card("Select a gear item in Inventory."))
	else:
		_left.add_child(_details_text(ActionsScript.describe_item(item)))

	_center.add_child(_section_title("Forge Actions"))
	var acts: Array[Dictionary] = [
		{"id":"seal", "title":"Seal Affix", "body":"Adds one crafted affix.\nCost: 2 Shards\nPotential: -3"},
		{"id":"reforge", "title":"Reforge Values", "body":"Rerolls numbers only.\nCost: 5 Embers\nPotential: -4"},
		{"id":"polish", "title":"Polish Quality", "body":"Improves quality.\nCost: 1 Rune\nPotential: -1"},
		{"id":"upgrade", "title":"Upgrade Rarity", "body":"Normal → Magic → Rare.\nFills missing affix slots."},
		{"id":"remove_affix", "title":"Remove Affix", "body":"Removes weakest prefix/suffix.\nPotential: -4"},
	]
	for spec: Dictionary in acts:
		_center.add_child(_action_card(spec))

	_right.add_child(_section_title("Result Preview"))
	if item.is_empty():
		_right.add_child(_empty_card("No item selected."))
	else:
		_right.add_child(_details_text("Choose a forge action.\n\nCurrent Forge Potential: " + str(item.get("forge_potential", 0)) + "\n\nBefore → After preview will be expanded after the shell is stable."))


func _build_stash() -> void:
	_ensure_stash_defaults_local()
	_left.add_child(_section_title("Categories"))
	for cat: Dictionary in SchemaScript.mandatory_stash_categories():
		var btn: Button = _button(str(cat.get("label", "")), "cat_" + str(cat.get("id", "")), Vector2(0, 42))
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.pressed.connect(func(id := str(cat.get("id", ""))) -> void:
			if state_ref != null:
				state_ref.set("selected_stash_category", id)
			_refresh()
		)
		_left.add_child(btn)

	_center.add_child(_section_title("Current Tab"))
	var tabs: Array = _state_array("final_stash_tabs")
	var selected_category: String = str(_state_value("selected_stash_category", "currency"))
	var shown_any: bool = false
	for i: int in range(tabs.size()):
		if typeof(tabs[i]) != TYPE_DICTIONARY:
			continue
		var tab: Dictionary = Dictionary(tabs[i])
		if not _tab_matches_category(tab, selected_category):
			continue
		shown_any = true
		_center.add_child(_stash_tab_card(tab, i))
	if not shown_any:
		_center.add_child(_empty_card("No tab in this category."))

	_right.add_child(_section_title("Item Details"))
	_right.add_child(_details_text(ActionsScript.describe_item(_selected_stash_item)))


func _build_maps() -> void:
	_left.add_child(_section_title("Map Inventory"))
	var maps: Array = _state_array("map_stash")
	if maps.is_empty():
		_left.add_child(_empty_card("No maps found."))
	else:
		for i: int in range(maps.size()):
			if typeof(maps[i]) != TYPE_DICTIONARY:
				continue
			var map_item: Dictionary = Dictionary(maps[i])
			var btn: Button = _button(_map_short(map_item), "map_" + str(i), Vector2(0, 46))
			btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			btn.pressed.connect(func(index := i) -> void:
				if state_ref != null:
					state_ref.set("map_cursor", index)
				_refresh()
			)
			_left.add_child(btn)

	_center.add_child(_section_title("Selected Map"))
	var selected_map: Dictionary = _selected_map()
	_center.add_child(_details_text(_map_details(selected_map)))

	_right.add_child(_section_title("Run Preview"))
	_right.add_child(_details_text(_map_preview(selected_map)))


func _build_character() -> void:
	var stats: Dictionary = _state_dict("build_stats")
	_left.add_child(_section_title("Resources"))
	_left.add_child(_stat_lines([
		["Level", _state_int("level", 1)],
		["Life", str(_state_int("player_hp", _state_int("hp", 0))) + " / " + str(_state_int("max_hp", 0))],
		["Mana", str(_state_int("player_mana", _state_int("mana", 0))) + " / " + str(_state_int("max_mana", 0))],
		["Spirit", str(_state_int("spirit_reserved", 0)) + " / " + str(_state_int("spirit_max", 60))],
	]))

	_center.add_child(_section_title("Offense"))
	_center.add_child(_stat_lines([
		["Spell Damage", _stat_value(stats, "Spell Damage")],
		["Fire Damage", _stat_value(stats, "Fire Damage")],
		["Lightning Damage", _stat_value(stats, "Lightning Damage")],
		["Void Damage", _stat_value(stats, "Void Damage")],
		["Cast Speed", _stat_value(stats, "Cast Speed")],
		["Critical Chance", _stat_value(stats, "Critical Chance")],
	]))

	_right.add_child(_section_title("Defense / Identity"))
	_right.add_child(_stat_lines([
		["Armor", _stat_value(stats, "Armor")],
		["Fire Resistance", _stat_value(stats, "Fire Resistance")],
		["Cold Resistance", _stat_value(stats, "Cold Resistance")],
		["Lightning Resistance", _stat_value(stats, "Lightning Resistance")],
		["Void Resistance", _stat_value(stats, "Void Resistance")],
	]))
	_right.add_child(_details_text("\nBuild Identity:\n" + _build_identity()))


func _build_rewards() -> void:
	_left.add_child(_section_title("Clear Summary"))
	_left.add_child(_details_text("MAP CLEAR\n\nReview rewards, take all, or return to hub."))

	_center.add_child(_section_title("Rewards Found"))
	var rewards: Array = _state_array("pending_rewards")
	if rewards.is_empty():
		_center.add_child(_empty_card("No pending rewards."))
	else:
		for i: int in range(rewards.size()):
			if typeof(rewards[i]) != TYPE_DICTIONARY:
				continue
			var reward: Dictionary = Dictionary(rewards[i])
			var btn: Button = _button(_item_name(reward), "reward_" + str(i), Vector2(0, 46))
			btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			btn.pressed.connect(func(item := reward) -> void:
				_selected_reward = item
				_refresh()
			)
			_center.add_child(btn)

	_right.add_child(_section_title("Reward Details"))
	_right.add_child(_details_text(ActionsScript.describe_item(_selected_reward)))


func _do_action(action_id: String) -> void:
	if action_id == "close":
		_close()
		return
	state_ref = _state()
	var msg: String = ActionsScript.perform(state_ref, action_id, {"mode":mode})
	_notice.text = msg
	_refresh()


func _item_details_with_compare(item: Dictionary) -> String:
	if item.is_empty():
		return "No item selected."
	var text: String = ActionsScript.describe_item(item)
	var compare: String = ActionsScript.compare_selected_text(state_ref, item)
	if compare != "":
		text += "\n\nCompare\n" + compare
	return text


func _inventory_grid(items: Array) -> ScrollContainer:
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var grid: GridContainer = GridContainer.new()
	grid.columns = 4
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	scroll.add_child(grid)

	if items.is_empty():
		grid.add_child(_empty_card("Backpack empty."))
		return scroll

	for i: int in range(items.size()):
		if typeof(items[i]) != TYPE_DICTIONARY:
			continue
		var item: Dictionary = Dictionary(items[i])
		var btn: Button = _button(_item_tile_text(item), "item_" + str(i), Vector2(142, 82))
		btn.add_theme_stylebox_override("normal", _panel_style(_palette.get("slot", Color.BLACK), SchemaScript.rarity_color(str(item.get("rarity", _item_kind_for_color(item)))), 2, 8))
		btn.pressed.connect(func(index := i, it := item) -> void:
			_selected_item = it
			if state_ref != null:
				state_ref.set("inventory_cursor", index)
				state_ref.set("crafting_selected_item_uid", str(it.get("uid", "")))
			_refresh()
		)
		grid.add_child(btn)

	return scroll


func _gem_inventory_panel() -> ScrollContainer:
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	scroll.add_child(box)

	var backpack: Array = _state_array("backpack")
	var sections: Dictionary = {
		"Uncut Active Gems": [],
		"Uncut Support Gems": [],
		"Uncut Spirit Gems": [],
		"Cut / Stored Gems": _state_array("cut_gem_storage"),
	}
	for value: Variant in backpack:
		if typeof(value) != TYPE_DICTIONARY:
			continue
		var item: Dictionary = Dictionary(value)
		var kind: String = _uncut_gem_kind(item)
		if kind == "active":
			sections["Uncut Active Gems"].append(item)
		elif kind == "support":
			sections["Uncut Support Gems"].append(item)
		elif kind == "spirit":
			sections["Uncut Spirit Gems"].append(item)

	for title: Variant in sections.keys():
		box.add_child(_section_title(str(title)))
		var arr: Array = Array(sections[title])
		if arr.is_empty():
			box.add_child(_small_muted("None"))
		for item_value: Variant in arr:
			if typeof(item_value) == TYPE_DICTIONARY:
				box.add_child(_compact_item_button(Dictionary(item_value)))

	return scroll


func _skill_card(skill: Dictionary, index: int) -> Control:
	var btn: Button = _button(str(skill.get("label", "Skill")) + "\nLv " + str(skill.get("level", 1)) + " · Sockets " + str(Array(skill.get("supports", [])).size()) + "/" + str(skill.get("sockets_unlocked", 2)), "skill_" + str(index), Vector2(0, 70))
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.pressed.connect(func() -> void:
		if state_ref != null:
			state_ref.set("selected_skill_index", index)
		_refresh()
	)
	return btn


func _spirit_card(spirit: Dictionary, index: int) -> Control:
	var enabled: bool = bool(spirit.get("enabled", false))
	var txt: String = ("[ON] " if enabled else "[OFF] ") + str(spirit.get("label", "Spirit")) + "\nReserves " + str(spirit.get("reserve", 0)) + " Spirit"
	var btn: Button = _button(txt, "spirit_" + str(index), Vector2(0, 70))
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.pressed.connect(func() -> void:
		if state_ref != null:
			state_ref.set("selected_spirit_index", index)
		_refresh()
	)
	return btn


func _selected_skill_editor(skill: Dictionary) -> Control:
	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	box.add_child(_details_text(str(skill.get("label", "Skill")).to_upper() + "\nActive Skill · Level " + str(skill.get("level", 1)) + " · Quality +" + str(skill.get("quality", 0)) + "%\n\nMain Behavior:\n" + str(skill.get("tags", "Skill behavior"))))
	box.add_child(_section_title("Support Sockets"))

	var sockets: GridContainer = GridContainer.new()
	sockets.columns = 3
	sockets.add_theme_constant_override("h_separation", 8)
	sockets.add_theme_constant_override("v_separation", 8)
	box.add_child(sockets)

	var supports: Array = Array(skill.get("supports", [])) if typeof(skill.get("supports", [])) == TYPE_ARRAY else []
	var unlocked: int = int(skill.get("sockets_unlocked", 2))
	for i: int in range(6):
		var label: String = "Locked"
		if i < supports.size() and typeof(supports[i]) == TYPE_DICTIONARY:
			label = str(Dictionary(supports[i]).get("label", "Support"))
		elif i < unlocked:
			label = "Open Socket"
		sockets.add_child(_card(label, Vector2(190, 64)))

	box.add_child(_section_title("Current Result"))
	box.add_child(_details_text(_skill_result_text(skill)))
	return box


func _skill_result_text(skill: Dictionary) -> String:
	var lines: Array[String] = []
	lines.append("Base skill: " + str(skill.get("label", "Skill")))
	lines.append("Supports:")
	var supports: Array = Array(skill.get("supports", [])) if typeof(skill.get("supports", [])) == TYPE_ARRAY else []
	if supports.is_empty():
		lines.append(" • none")
	for value: Variant in supports:
		if typeof(value) == TYPE_DICTIONARY:
			var support: Dictionary = Dictionary(value)
			lines.append(" • " + str(support.get("label", "Support")) + " — " + str(support.get("effect", "")) + " / " + str(support.get("visual", "")))
	return "\n".join(lines)


func _item_slot(label: String, item: Dictionary, callback: Callable) -> Control:
	var txt: String = label + "\n"
	txt += _item_name(item) if not item.is_empty() else "Empty"
	var btn: Button = _button(txt, "slot_" + label, Vector2(0, 74))
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.pressed.connect(callback)
	return btn


func _stash_tab_card(tab: Dictionary, index: int) -> Control:
	var items: Array = Array(tab.get("items", [])) if typeof(tab.get("items", [])) == TYPE_ARRAY else []
	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 5)
	box.add_child(_section_title(str(tab.get("label", "Tab")) + " · " + str(items.size()) + " items"))
	if items.is_empty():
		box.add_child(_small_muted("Empty"))
	else:
		for i: int in range(min(items.size(), 12)):
			if typeof(items[i]) != TYPE_DICTIONARY:
				continue
			var item: Dictionary = Dictionary(items[i])
			var btn: Button = _button(_item_name(item), "stash_item_" + str(i), Vector2(0, 36))
			btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			btn.pressed.connect(func(it := item) -> void:
				_selected_stash_item = it
				_refresh()
			)
			box.add_child(btn)
	return box


func _action_card(spec: Dictionary) -> Control:
	var btn: Button = _button(str(spec.get("title", "")) + "\n" + str(spec.get("body", "")), str(spec.get("id", "")), Vector2(0, 86))
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.pressed.connect(func(id := str(spec.get("id", ""))) -> void: _do_action(id))
	return btn


func _compact_item_button(item: Dictionary) -> Control:
	var btn: Button = _button(_item_name(item), "compact_item", Vector2(0, 40))
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.pressed.connect(func() -> void:
		_selected_item = item
		_refresh()
	)
	return btn


func _map_details(map_item: Dictionary) -> String:
	if map_item.is_empty():
		return "No map selected."
	var lines: Array[String] = []
	lines.append(str(map_item.get("display_name", "Map")))
	lines.append(str(map_item.get("rarity", "normal")).capitalize() + " · Tier " + str(map_item.get("tier", map_item.get("map_tier", 1))) + " · Entries " + str(map_item.get("entries", 6)))
	lines.append("")
	var mods: Array = Array(map_item.get("mods", [])) if typeof(map_item.get("mods", [])) == TYPE_ARRAY else []
	if mods.is_empty():
		lines.append("Mods: none")
	else:
		lines.append("Mods:")
		for value: Variant in mods:
			if typeof(value) == TYPE_DICTIONARY:
				lines.append(" • " + str(Dictionary(value).get("name", "Map Mod")))
	lines.append("")
	lines.append("Bonus: " + _map_bonus(map_item))
	return "\n".join(lines)


func _map_preview(map_item: Dictionary) -> String:
	if map_item.is_empty():
		return "Select a map."
	var tier: int = int(map_item.get("tier", map_item.get("map_tier", 1)))
	var rarity: String = str(map_item.get("rarity", "normal")).capitalize()
	var lines: Array[String] = []
	lines.append("Enemy Level: " + str(map_item.get("map_level", tier)))
	lines.append("Rarity: " + rarity)
	lines.append("Pack Pressure: " + ("Low" if tier <= 5 else ("Medium" if tier <= 9 else "High")))
	lines.append("")
	lines.append("Completion:\nClear the map")
	lines.append("")
	lines.append("Bonus:\n" + _map_bonus(map_item))
	return "\n".join(lines)


func _map_bonus(map_item: Dictionary) -> String:
	var tier: int = int(map_item.get("tier", map_item.get("map_tier", 1)))
	if tier <= 5:
		return "Clear the map"
	if tier <= 9:
		return "Complete as Magic or Rare"
	return "Complete as Rare"


func _selected_map() -> Dictionary:
	var maps: Array = _state_array("map_stash")
	if maps.is_empty():
		return {}
	var index: int = clampi(_state_int("map_cursor", 0), 0, maps.size() - 1)
	if typeof(maps[index]) == TYPE_DICTIONARY:
		return Dictionary(maps[index])
	return {}


func _map_short(map_item: Dictionary) -> String:
	return str(map_item.get("display_name", "Map")) + " T" + str(map_item.get("tier", map_item.get("map_tier", 1))) + " " + str(map_item.get("rarity", "normal")).capitalize()


func _stat_lines(lines: Array) -> Control:
	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	for value: Variant in lines:
		if typeof(value) != TYPE_ARRAY:
			continue
		var arr: Array = Array(value)
		var row: HBoxContainer = HBoxContainer.new()
		var left: Label = Label.new()
		left.text = str(arr[0])
		left.add_theme_color_override("font_color", _palette.get("muted", Color.GRAY))
		left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var right: Label = Label.new()
		right.text = str(arr[1])
		right.add_theme_color_override("font_color", _palette.get("text", Color.WHITE))
		row.add_child(left)
		row.add_child(right)
		box.add_child(row)
	return box


func _build_identity() -> String:
	var active: Array = _state_array("installed_active_gems")
	if active.is_empty() or typeof(active[0]) != TYPE_DICTIONARY:
		return "No active skill identity yet."
	var first: Dictionary = Dictionary(active[0])
	var supports: Array = Array(first.get("supports", [])) if typeof(first.get("supports", [])) == TYPE_ARRAY else []
	return str(first.get("label", "Skill")) + " build · " + str(supports.size()) + " supports · Spirit " + str(_state_int("spirit_reserved", 0)) + "/" + str(_state_int("spirit_max", 60))


func _stat_value(stats: Dictionary, key: String) -> String:
	if not stats.has(key):
		return "0"
	var value: Variant = stats[key]
	if typeof(value) == TYPE_FLOAT:
		if abs(float(value)) < 1.0:
			return str(int(round(float(value) * 100.0))) + "%"
		return str(int(round(float(value))))
	return str(value)


func _section_title(text: String) -> Label:
	var label: Label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 20)
	label.add_theme_color_override("font_color", _palette.get("accent", Color.ORANGE))
	return label


func _details_text(text: String) -> RichTextLabel:
	var label: RichTextLabel = RichTextLabel.new()
	label.bbcode_enabled = true
	label.text = text
	label.fit_content = false
	label.scroll_active = true
	label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	label.add_theme_color_override("default_color", _palette.get("text", Color.WHITE))
	return label


func _text_block(text: String, size: int = 16) -> Label:
	var label: Label = Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", _palette.get("text", Color.WHITE))
	return label


func _small_muted(text: String) -> Label:
	var label: Label = _text_block(text, 14)
	label.add_theme_color_override("font_color", _palette.get("muted", Color.GRAY))
	return label


func _empty_card(text: String) -> Control:
	return _card(text, Vector2(0, 88))


func _card(text: String, min_size: Vector2) -> PanelContainer:
	var panel: PanelContainer = PanelContainer.new()
	panel.custom_minimum_size = min_size
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _panel_style(_palette.get("slot", Color.BLACK), _palette.get("border_soft", Color.DIM_GRAY), 1, 8))
	var label: Label = _text_block(text, 15)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	panel.add_child(label)
	return panel


func _button(text: String, action_id: String, min_size: Vector2) -> Button:
	var btn: Button = Button.new()
	btn.name = "Btn_" + action_id
	btn.text = text
	btn.custom_minimum_size = min_size
	btn.clip_text = true
	btn.add_theme_font_size_override("font_size", 15)
	btn.add_theme_color_override("font_color", _palette.get("text", Color.WHITE))
	btn.add_theme_stylebox_override("normal", _panel_style(_palette.get("slot", Color.BLACK), _palette.get("border_soft", Color.DIM_GRAY), 1, 8))
	btn.add_theme_stylebox_override("hover", _panel_style(_palette.get("slot_hover", Color.DARK_GRAY), _palette.get("border", Color.GOLD), 2, 8))
	btn.add_theme_stylebox_override("pressed", _panel_style(_palette.get("panel_alt", Color.DARK_GRAY), _palette.get("accent", Color.ORANGE), 2, 8))
	return btn


func _column(node_name: String, width: int) -> VBoxContainer:
	var box: VBoxContainer = VBoxContainer.new()
	box.name = node_name
	box.custom_minimum_size = Vector2(width, 0)
	box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 8)
	return box


func _panel_style(bg: Color, border: Color, border_width: int, radius: int) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(radius)
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	return style


func _clear(node: Node) -> void:
	for child: Node in node.get_children():
		child.queue_free()


func _state() -> Object:
	if game_root == null:
		game_root = get_parent()
	if game_root == null:
		return null
	var value: Variant = game_root.get("state")
	if value != null and value is Object:
		return value as Object
	return null


func _state_array(key: String) -> Array:
	state_ref = _state()
	if state_ref == null:
		return []
	var value: Variant = state_ref.get(key)
	if typeof(value) == TYPE_ARRAY:
		return Array(value)
	return []


func _state_dict(key: String) -> Dictionary:
	state_ref = _state()
	if state_ref == null:
		return {}
	var value: Variant = state_ref.get(key)
	if typeof(value) == TYPE_DICTIONARY:
		return Dictionary(value)
	return {}


func _state_value(key: String, fallback: Variant = null) -> Variant:
	state_ref = _state()
	if state_ref == null:
		return fallback
	var value: Variant = state_ref.get(key)
	if value == null:
		return fallback
	return value


func _state_int(key: String, fallback: int = 0) -> int:
	var value: Variant = _state_value(key, fallback)
	match typeof(value):
		TYPE_INT: return int(value)
		TYPE_FLOAT: return int(round(float(value)))
		TYPE_STRING:
			var s: String = str(value)
			if s.is_valid_int():
				return s.to_int()
			if s.is_valid_float():
				return int(round(s.to_float()))
			return fallback
		TYPE_BOOL: return 1 if bool(value) else 0
		_: return fallback


func _first_dict(arr: Array) -> Dictionary:
	for value: Variant in arr:
		if typeof(value) == TYPE_DICTIONARY:
			return Dictionary(value)
	return {}


func _first_gear_item(arr: Array) -> Dictionary:
	for value: Variant in arr:
		if typeof(value) == TYPE_DICTIONARY:
			var item: Dictionary = Dictionary(value)
			if item.has("slot") and str(item.get("slot", "")) != "map":
				return item
	return {}


func _item_name(item: Dictionary) -> String:
	if item.is_empty():
		return "Empty"
	return str(item.get("display_name", item.get("name", item.get("label", item.get("base_name", "Item")))))


func _item_tile_text(item: Dictionary) -> String:
	var name: String = _item_name(item)
	if name.length() > 28:
		name = name.substr(0, 25) + "..."
	var slot: String = str(item.get("slot", _item_kind_for_color(item)))
	var level: String = str(item.get("item_level", item.get("level", "")))
	return name + "\n" + slot.capitalize() + (" · Lv " + level if level != "" else "")


func _item_kind_for_color(item: Dictionary) -> String:
	var kind: String = str(item.get("kind", item.get("item_kind", item.get("category", "")))).to_lower()
	if kind.find("map") >= 0:
		return "map"
	if kind.find("gem") >= 0 or _uncut_gem_kind(item) != "":
		return "gem"
	if kind.find("currency") >= 0 or kind == "material":
		return "currency"
	return str(item.get("rarity", "normal"))


func _uncut_gem_kind(item: Dictionary) -> String:
	var kind: String = str(item.get("kind", item.get("item_kind", item.get("category", "")))).to_lower()
	var gem_kind: String = str(item.get("gem_kind", item.get("gem_type", ""))).to_lower()
	var name: String = str(item.get("display_name", item.get("name", ""))).to_lower()

	if kind.find("uncut_active") >= 0 or (gem_kind == "active" and name.find("uncut") >= 0) or name.find("uncut active") >= 0:
		return "active"
	if kind.find("uncut_support") >= 0 or (gem_kind == "support" and name.find("uncut") >= 0) or name.find("uncut support") >= 0:
		return "support"
	if kind.find("uncut_spirit") >= 0 or (gem_kind == "spirit" and name.find("uncut") >= 0) or name.find("uncut spirit") >= 0:
		return "spirit"
	return ""


func _ensure_stash_defaults_local() -> void:
	if state_ref == null:
		state_ref = _state()
	if state_ref == null:
		return
	var tabs: Array = _state_array("final_stash_tabs")
	if not tabs.is_empty():
		return
	state_ref.set("final_stash_tabs", [
		{"id":"currency", "label":"Currency", "kind":"currency", "items":[]},
		{"id":"maps", "label":"Maps", "kind":"maps", "items":[]},
		{"id":"gems", "label":"Gems", "kind":"gems", "items":[]},
		{"id":"crystals", "label":"Crystals", "kind":"crystals", "items":[]},
		{"id":"uniques", "label":"Uniques", "kind":"uniques", "items":[]},
		{"id":"gear_1", "label":"Gear Tab 1", "kind":"gear", "items":[]},
	])


func _tab_matches_category(tab: Dictionary, category: String) -> bool:
	var kind: String = str(tab.get("kind", ""))
	if category == "gear":
		return kind == "gear"
	return kind == category or (category == "maps" and kind == "maps") or (category == "gems" and kind == "gems")


func _looks_like_item(item: Dictionary) -> bool:
	return item.has("slot") or item.has("prefixes") or item.has("suffixes") or item.has("implicit_stats") or str(item.get("item_kind", "")) == "gear"
