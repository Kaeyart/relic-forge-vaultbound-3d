extends "res://scripts/ui/panels/BaseTextPanel3D.gd"

const AtlasSystemScript := preload("res://scripts/systems/AtlasSystem3D.gd")
const WaystoneSystemScript := preload("res://scripts/systems/WaystoneSystem3D.gd")
const TabletSystemScript := preload("res://scripts/systems/PrecursorTabletSystem3D.gd")
const MapLoopSystemScript := preload("res://scripts/systems/MapLoopSystem3D.gd")

func refresh_panel() -> void:
	_clear()
	if state_ref != null:
		MapLoopSystemScript.ensure_defaults(state_ref)

	var root: HBoxContainer = _hbox(6)
	_set_expand(root, true, true)
	add_child(root)

	var atlas_panel: PanelContainer = _panel("ATLAS")
	atlas_panel.custom_minimum_size = Vector2(230, 0)
	_set_expand(atlas_panel, false, true)
	root.add_child(atlas_panel)
	_build_atlas(_panel_content(atlas_panel))

	var waystone_panel: PanelContainer = _panel("WAYSTONE")
	waystone_panel.custom_minimum_size = Vector2(245, 0)
	_set_expand(waystone_panel, false, true)
	root.add_child(waystone_panel)
	_build_waystones(_panel_content(waystone_panel))

	var tablet_panel: PanelContainer = _panel("TABLETS")
	tablet_panel.custom_minimum_size = Vector2(240, 0)
	_set_expand(tablet_panel, false, true)
	root.add_child(tablet_panel)
	_build_tablets(_panel_content(tablet_panel))

	var summary_panel: PanelContainer = _panel("MAP DEVICE")
	_set_expand(summary_panel, true, true)
	root.add_child(summary_panel)
	_build_summary(_panel_content(summary_panel))


func _build_atlas(box: VBoxContainer) -> void:
	if state_ref == null:
		return
	var nodes: Array[Dictionary] = AtlasSystemScript.node_list(state_ref)
	var selected_id: String = str(_state_get("selected_atlas_node_id", ""))
	box.add_child(_label("[color=#8f8777]Choose a revealed Atlas node. Boss kill completes maps and unlocks neighbors.[/color]", 12))
	var scroll: ScrollContainer = _scroll(275)
	var list: VBoxContainer = _vbox(4)
	scroll.add_child(list)
	box.add_child(scroll)
	for node: Dictionary in nodes:
		var node_id: String = str(node.get("id", ""))
		var state_text: String = str(node.get("state", "locked")).capitalize()
		var marker: String = "▶ " if node_id == selected_id else ""
		var label: String = marker + AtlasSystemScript.node_display_name(node) + "\n" + AtlasSystemScript.node_type_label(node) + " · " + state_text
		var b: Button = _button(label, self, "_select_node", [node_id], Vector2(205, 52))
		if node_id == selected_id:
			b.modulate = Color(1.0, 0.82, 0.34, 1.0)
		if str(node.get("state", "locked")) == "locked":
			b.disabled = true
		list.add_child(b)


func _build_waystones(box: VBoxContainer) -> void:
	if state_ref == null:
		return
	var waystones: Array = _as_array(_state_get("waystone_inventory", []))
	var selected_uid: String = str(_state_get("selected_waystone_uid", ""))
	box.add_child(_label("[color=#8f8777]Waystones are map keys. Tier controls level. Mods add danger/reward and unlock tablet slots.[/color]", 12))
	if waystones.is_empty():
		box.add_child(_label("[color=#d65a32]No Waystones. Complete maps or bosses to sustain them.[/color]"))
		return
	var scroll: ScrollContainer = _scroll(275)
	var list: VBoxContainer = _vbox(4)
	scroll.add_child(list)
	box.add_child(scroll)
	for value: Variant in waystones:
		if typeof(value) != TYPE_DICTIONARY:
			continue
		var w: Dictionary = WaystoneSystemScript.normalize(Dictionary(value))
		var uid: String = str(w.get("uid", ""))
		var marker: String = "▶ " if uid == selected_uid else ""
		var mods: Array = _as_array(w.get("mods", []))
		var text: String = marker + str(w.get("display_name", "Waystone")) + "\nLv " + str(w.get("area_level", 1)) + " · " + str(w.get("rarity", "normal")).capitalize() + " · " + str(mods.size()) + " mods · " + str(WaystoneSystemScript.tablet_slots_for_waystone(w)) + " slots"
		var b: Button = _button(text, self, "_select_waystone", [uid], Vector2(220, 54))
		if uid == selected_uid:
			b.modulate = Color(1.0, 0.82, 0.34, 1.0)
		list.add_child(b)


func _build_tablets(box: VBoxContainer) -> void:
	if state_ref == null:
		return
	var waystone: Dictionary = WaystoneSystemScript.selected_waystone(state_ref)
	var max_slots: int = WaystoneSystemScript.tablet_slots_for_waystone(waystone)
	var selected: Array = _as_array(_state_get("selected_tablet_uids", []))
	box.add_child(_label("[color=#8f8777]Select up to " + str(max_slots) + " tablet(s). Charges are consumed on launch.[/color]", 12))
	var tablets: Array = _as_array(_state_get("tablet_inventory", []))
	if tablets.is_empty():
		box.add_child(_label("No Tablets. Towers and bosses drop more."))
		return
	var scroll: ScrollContainer = _scroll(275)
	var list: VBoxContainer = _vbox(4)
	scroll.add_child(list)
	box.add_child(scroll)
	for value: Variant in tablets:
		if typeof(value) != TYPE_DICTIONARY:
			continue
		var tablet: Dictionary = Dictionary(value)
		var uid: String = str(tablet.get("uid", ""))
		var is_selected: bool = selected.has(uid)
		var marker: String = "▶ " if is_selected else ""
		var text: String = marker + str(tablet.get("display_name", "Tablet")) + "\nCharges " + str(tablet.get("charges", 1))
		var b: Button = _button(text, self, "_toggle_tablet", [uid], Vector2(215, 52))
		if is_selected:
			b.modulate = Color(1.0, 0.82, 0.34, 1.0)
		list.add_child(b)


func _build_summary(box: VBoxContainer) -> void:
	if state_ref == null:
		return
	var activity: Dictionary = MapLoopSystemScript.preview_selected_activity(state_ref)
	if activity.is_empty():
		box.add_child(_label("Select an available Atlas node and a Waystone."))
		return
	var lines: PackedStringArray = PackedStringArray()
	lines.append("[font_size=22][color=#c59b4a][b]" + str(activity.get("display_name", "Map")) + "[/b][/color][/font_size]")
	lines.append(str(activity.get("node_type_label", "Map")) + " · Tier " + str(activity.get("tier", 1)) + " · Area " + str(activity.get("area_level", 1)))
	lines.append("Boss: " + str(activity.get("boss_name", "Vault Warden")))
	lines.append("Completion: " + str(activity.get("completion_rule", "Kill boss")))
	lines.append("\n[color=#c59b4a]Danger[/color] " + str(activity.get("danger_score", 0)) + "    [color=#69a84f]Reward[/color] " + str(activity.get("reward_score", 0)))
	lines.append("Waystone: " + str(activity.get("waystone_name", "Waystone")))
	var tablets: Array = _as_array(activity.get("tablet_names", []))
	if tablets.is_empty():
		lines.append("Tablets: none")
	else:
		lines.append("Tablets: " + ", ".join(_strings(tablets)))
	lines.append("\n[color=#8f8777]Modifiers[/color]")
	var mods: Array = _as_array(activity.get("mods", []))
	if mods.is_empty():
		lines.append("• No explicit modifiers")
	else:
		for mod_value: Variant in mods:
			if typeof(mod_value) == TYPE_DICTIONARY:
				lines.append("• " + str(Dictionary(mod_value).get("display_name", Dictionary(mod_value).get("id", "modifier"))))
	box.add_child(_label("\n".join(lines), 13))
	box.add_child(_button("LAUNCH MAP", self, "_launch_map", [], Vector2(260, 50)))
	box.add_child(_label("[color=#8f8777]Launch consumes the selected Waystone and one charge from each selected Tablet.[/color]", 12))


func _select_node(node_id: String) -> void:
	if state_ref != null:
		AtlasSystemScript.select_node(state_ref, node_id)
	refresh_panel()


func _select_waystone(uid: String) -> void:
	if state_ref != null:
		WaystoneSystemScript.select_waystone(state_ref, uid)
		var w: Dictionary = WaystoneSystemScript.selected_waystone(state_ref)
		var max_slots: int = WaystoneSystemScript.tablet_slots_for_waystone(w)
		var selected: Array = _as_array(_state_get("selected_tablet_uids", []))
		while selected.size() > max_slots:
			selected.pop_back()
		_state_set("selected_tablet_uids", selected)
	refresh_panel()


func _toggle_tablet(uid: String) -> void:
	if state_ref != null:
		var w: Dictionary = WaystoneSystemScript.selected_waystone(state_ref)
		var max_slots: int = WaystoneSystemScript.tablet_slots_for_waystone(w)
		if not TabletSystemScript.toggle_tablet(state_ref, uid, max_slots):
			_notice("No free tablet slot. Use a Waystone with more modifiers.")
	refresh_panel()


func _launch_map() -> void:
	if state_ref == null:
		return
	var activity: Dictionary = MapLoopSystemScript.preview_selected_activity(state_ref)
	if activity.is_empty():
		_notice("Cannot launch: select an Atlas node and Waystone.")
		return
	_state_set("panel_mode", "")
	var scene: Node = get_tree().current_scene
	if scene != null and scene.has_method("_start_map"):
		scene.call("_start_map")
	else:
		_notice("Launch failed: current scene has no _start_map method.")


func _scroll(height: int) -> ScrollContainer:
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, height)
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.mouse_filter = Control.MOUSE_FILTER_PASS
	return scroll


func _strings(values: Array) -> PackedStringArray:
	var out: PackedStringArray = PackedStringArray()
	for value: Variant in values:
		out.append(str(value))
	return out
