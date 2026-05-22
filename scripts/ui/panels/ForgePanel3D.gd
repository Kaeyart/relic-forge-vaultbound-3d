extends "res://scripts/ui/panels/BaseTextPanel3D.gd"

const I: GDScript = preload("res://scripts/systems/ItemizationSystem3D.gd")
const C: GDScript = preload("res://scripts/systems/ItemCraftingSystem3D.gd")

var _craft_actions: Array[String] = [
	"appraise", "transmute", "augment", "regal", "exalt", "chaos", "annul", "alchemy",
	"essence_ember", "essence_storm", "essence_blood", "essence_iron", "essence_fleet", "essence_arcanist",
	"quality_weapon", "quality_armor", "socket", "rune_ash", "rune_storm", "rune_blood", "rune_iron", "rune_vault", "rune_seeker",
	"risky_forge", "restore_potential", "sell", "disenchant", "salvage"
]

func refresh_panel() -> void:
	_clear()
	var root: HBoxContainer = _hbox(8)
	_set_expand(root, true, true)
	add_child(root)

	var item_panel: PanelContainer = _panel("SELECTED ITEM")
	item_panel.custom_minimum_size = Vector2(330, 0)
	root.add_child(item_panel)
	_build_item(_panel_content(item_panel))

	var preview_panel: PanelContainer = _panel("CRAFT PREVIEW")
	_set_expand(preview_panel, true, true)
	root.add_child(preview_panel)
	_build_preview(_panel_content(preview_panel))

	var action_panel: PanelContainer = _panel("FORGE ACTIONS")
	action_panel.custom_minimum_size = Vector2(300, 0)
	root.add_child(action_panel)
	_build_actions(_panel_content(action_panel))

func _build_item(box: VBoxContainer) -> void:
	var item: Dictionary = I.normalize_item(_selected_backpack_item())
	box.add_child(_label(I.item_detail_text(item), 12))
	box.add_child(_button("Open Inventory", self, "_open_inventory", [], Vector2(160, 34)))

func _build_preview(box: VBoxContainer) -> void:
	var selected_action: String = str(_state_get("selected_forge_action", "transmute"))
	var item: Dictionary = I.normalize_item(_selected_backpack_item())
	box.add_child(_label(C.preview_action(state_ref, selected_action), 13))
	box.add_child(_label("\n[color=#8f8777]Selected action[/color]\n[color=#c59b4a][b]" + selected_action.replace("_", " ").capitalize() + "[/b][/color]", 14))
	box.add_child(_button("CONFIRM CRAFT", self, "_confirm", [], Vector2(220, 44)))
	box.add_child(_label("\n[color=#8f8777]Crafting rule: currency mutates item state, Seals force themed modifiers, runes fill gear sockets, and high-risk forge actions spend Forge Potential.[/color]", 12))
	if not item.is_empty():
		box.add_child(_label("\n" + I.build_relevance_text(item), 12))

func _build_actions(box: VBoxContainer) -> void:
	var scroll: ScrollContainer = ScrollContainer.new()
	_set_expand(scroll, true, true)
	var list: VBoxContainer = _vbox(4)
	scroll.add_child(list)
	box.add_child(scroll)
	var selected_action: String = str(_state_get("selected_forge_action", "transmute"))
	for action: String in _craft_actions:
		var label: String = ("▶ " if action == selected_action else "") + action.replace("_", " ").capitalize()
		var b: Button = _button(label, self, "_select_action", [action], Vector2(270, 32))
		if action == selected_action:
			b.modulate = Color(1.0, 0.82, 0.34, 1.0)
		list.add_child(b)
	box.add_child(_label(_materials_text(), 11))

func _materials_text() -> String:
	var materials: Dictionary = _as_dict(_state_get("materials", {}))
	var keys: Array[String] = ["transmutation_orb", "augmentation_orb", "regal_orb", "exalted_orb", "chaos_orb", "annulment_orb", "alchemy_orb", "whetstone", "armour_scrap", "artificer_orb", "ember_seal_lesser", "storm_seal_lesser", "blood_seal_lesser", "iron_seal_lesser", "fleet_seal_lesser", "arcanist_seal_lesser", "ash_rune", "storm_rune", "blood_rune", "iron_rune", "vault_rune", "seeker_rune", "relic_core", "echo_glass", "essence_dust", "artificer_shard"]
	var lines: PackedStringArray = PackedStringArray()
	lines.append("\n[color=#c59b4a]Materials[/color]")
	for key: String in keys:
		var amount: int = int(materials.get(key, 0))
		if amount > 0:
			lines.append("• " + I.material_label(key) + ": " + str(amount))
	return "\n".join(lines)

func _select_action(action: String) -> void:
	_state_set("selected_forge_action", action)
	refresh_panel()

func _confirm() -> void:
	var selected_action: String = str(_state_get("selected_forge_action", "transmute"))
	C.apply_to_selected(state_ref, selected_action)
	refresh_panel()

func _open_inventory() -> void:
	_open_panel("inventory")
