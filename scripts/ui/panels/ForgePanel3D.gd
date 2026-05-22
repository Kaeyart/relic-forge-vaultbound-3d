extends "res://scripts/ui/panels/BaseTextPanel3D.gd"

const I: GDScript = preload("res://scripts/systems/ItemizationSystem3D.gd")
const C: GDScript = preload("res://scripts/systems/ItemCraftingSystem3D.gd")
const E: GDScript = preload("res://scripts/systems/ItemEndgameSystem3D.gd")
const ItemRuntimeScript: GDScript = preload("res://scripts/systems/ItemCombatIntegrationSystem3D.gd")
const ItemValidationScript: GDScript = preload("res://scripts/systems/ItemValidationSystem3D.gd")

var _basic_actions: Array[String] = [
	"appraise", "transmute", "augment", "regal", "exalt", "chaos", "annul", "alchemy",
	"essence_ember", "essence_storm", "essence_blood", "essence_iron", "essence_fleet", "essence_arcanist",
	"quality_weapon", "quality_armor", "socket", "rune_ash", "rune_storm", "rune_blood", "rune_iron", "rune_vault", "rune_seeker",
	"risky_forge", "restore_potential", "sell", "disenchant", "salvage"
]

var _endgame_actions: Array[String] = [
	"greater_transmute", "perfect_transmute", "greater_augment", "perfect_augment",
	"greater_regal", "perfect_regal", "greater_exalt", "perfect_exalt",
	"greater_chaos", "perfect_chaos",
	"oracle_lens", "binding_omen", "ash_omen", "null_omen", "perfecting_omen",
	"vaultbind", "relic_reforge", "extract_unique_rune",
	"rune_ancient_ash", "rune_ancient_storm", "rune_mythic_vault", "rune_ward", "rune_meta_forge"
]

func refresh_panel() -> void:
	_clear()
	var root: HBoxContainer = _hbox(8)
	_set_expand(root, true, true)
	add_child(root)

	var item_panel: PanelContainer = _panel("SELECTED ITEM")
	item_panel.custom_minimum_size = Vector2(300, 0)
	root.add_child(item_panel)
	_build_item(_panel_content(item_panel))

	var preview_panel: PanelContainer = _panel("CRAFT PREVIEW / CONSEQUENCE")
	_set_expand(preview_panel, true, true)
	root.add_child(preview_panel)
	_build_preview(_panel_content(preview_panel))

	var action_panel: PanelContainer = _panel("FORGE ACTIONS")
	action_panel.custom_minimum_size = Vector2(330, 0)
	root.add_child(action_panel)
	_build_actions(_panel_content(action_panel))

func _build_item(box: VBoxContainer) -> void:
	var item: Dictionary = I.normalize_item(_selected_backpack_item())
	var scroll: ScrollContainer = ScrollContainer.new()
	_set_expand(scroll, true, true)
	var inner: VBoxContainer = _vbox(6)
	scroll.add_child(inner)
	box.add_child(scroll)
	inner.add_child(_label(I.item_detail_text(item), 12))
	inner.add_child(_label(E.endgame_item_text(item), 12))
	box.add_child(_button("Open Inventory", self, "_open_inventory", [], Vector2(170, 34)))

func _build_preview(box: VBoxContainer) -> void:
	var selected_action: String = str(_state_get("selected_forge_action", "transmute"))
	var item: Dictionary = I.normalize_item(_selected_backpack_item())
	var scroll: ScrollContainer = ScrollContainer.new()
	_set_expand(scroll, true, true)
	var inner: VBoxContainer = _vbox(6)
	scroll.add_child(inner)
	box.add_child(scroll)
	inner.add_child(_label(C.preview_action(state_ref, selected_action), 13))
	if str(_state_get("item_oracle_preview", "")) != "":
		inner.add_child(_label("\n[color=#c59b4a]Oracle[/color]\n" + str(_state_get("item_oracle_preview", "")), 12))
	if not item.is_empty():
		inner.add_child(_label("\n" + I.build_relevance_text(item), 12))
		inner.add_child(_label(ItemRuntimeScript.selected_skill_impact_text(state_ref, item), 12))
		inner.add_child(_label(E.build_aware_delta(item, _equipped_for(item)), 12))
	inner.add_child(_label("\n" + ItemValidationScript.runtime_report_text(state_ref), 11))
	inner.add_child(_label("\n[color=#8f8777]Crafting rule: basic currency mutates rarity/affixes; higher-tier currency raises tier floors; omens prepare control; Vaultbinding is irreversible corruption; Relic Reforge upgrades uniques.[/color]", 12))
	box.add_child(_button("CONFIRM SELECTED CRAFT", self, "_confirm", [], Vector2(240, 44)))

func _build_actions(box: VBoxContainer) -> void:
	var scroll: ScrollContainer = ScrollContainer.new()
	_set_expand(scroll, true, true)
	var list: VBoxContainer = _vbox(4)
	scroll.add_child(list)
	box.add_child(scroll)
	var selected_action: String = str(_state_get("selected_forge_action", "transmute"))
	list.add_child(_label("[color=#8f8777]Basic Currency / Seals / Runes[/color]", 12))
	for action: String in _basic_actions:
		_add_action_button(list, action, selected_action)
	list.add_child(_label("\n[color=#c59b4a]Endgame Currency / Omens / Vaultbinding[/color]", 12))
	for action2: String in _endgame_actions:
		_add_action_button(list, action2, selected_action)
	box.add_child(_label(_materials_text(), 11))

func _add_action_button(list: VBoxContainer, action: String, selected_action: String) -> void:
	var label: String = ("▶ " if action == selected_action else "") + action.replace("_", " ").capitalize()
	var b: Button = _button(label, self, "_select_action", [action], Vector2(300, 30))
	if action == selected_action:
		b.modulate = Color(1.0, 0.82, 0.34, 1.0)
	list.add_child(b)

func _materials_text() -> String:
	var materials: Dictionary = _as_dict(_state_get("materials", {}))
	var keys: Array[String] = [
		"transmutation_orb", "augmentation_orb", "regal_orb", "exalted_orb", "chaos_orb", "annulment_orb", "alchemy_orb",
		"greater_transmutation_orb", "perfect_transmutation_orb", "greater_augmentation_orb", "perfect_augmentation_orb", "greater_regal_orb", "perfect_regal_orb", "greater_exalted_orb", "perfect_exalted_orb", "greater_chaos_orb", "perfect_chaos_orb",
		"whetstone", "armour_scrap", "artificer_orb", "ember_seal_lesser", "storm_seal_lesser", "blood_seal_lesser", "iron_seal_lesser", "fleet_seal_lesser", "arcanist_seal_lesser",
		"oracle_lens", "binding_omen", "ash_omen", "null_omen", "perfecting_omen", "vaultbinding_orb", "relic_reforge_core",
		"ash_rune", "storm_rune", "blood_rune", "iron_rune", "vault_rune", "seeker_rune", "ancient_ash_rune", "ancient_storm_rune", "mythic_vault_rune", "ward_rune", "meta_forge_rune",
		"relic_core", "echo_glass", "boss_relic_fragment", "vault_ward_shard", "essence_dust", "artificer_shard", "shards", "embers"
	]
	var lines: PackedStringArray = PackedStringArray()
	lines.append("\n[color=#c59b4a]Materials[/color]")
	for key: String in keys:
		var amount: int = int(materials.get(key, 0))
		if amount > 0:
			lines.append("• " + E.material_label(key) + ": " + str(amount))
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

func _equipped_for(item: Dictionary) -> Dictionary:
	if item.is_empty():
		return {}
	var equipped: Dictionary = _as_dict(_state_get("equipped", {}))
	var slot: String = str(item.get("slot", ""))
	var raw: Variant = equipped.get(slot, {})
	if typeof(raw) == TYPE_DICTIONARY:
		return Dictionary(raw)
	return {}
