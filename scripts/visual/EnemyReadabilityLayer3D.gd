extends Node3D
class_name RVEnemyReadabilityLayer3D

const VisualPaletteScript := preload("res://scripts/visual/VisualPalette3D.gd")
const PrimitiveKitScript := preload("res://scripts/visual/PrimitiveKit3D.gd")
const EnemyModifierSystemScript := preload("res://scripts/systems/EnemyModifierSystem3D.gd")
const RuntimeDetectionSystemScript := preload("res://scripts/systems/RuntimeDetectionSystem3D.gd")

var game_root: Node = null
var _scan_timer: float = 0.0
var _decorated_ids: Dictionary = {}


func _ready() -> void:
	name = "EnemyReadabilityLayer096E"
	set_process(true)


func bind_game(root: Node) -> void:
	game_root = root


func _process(delta: float) -> void:
	if not _is_combat_mode():
		visible = false
		return

	visible = true
	_scan_timer -= delta
	if _scan_timer <= 0.0:
		_scan_timer = 0.35
		_scan_enemies()


func _scan_enemies() -> void:
	var scene: Node = get_tree().current_scene
	if scene == null:
		return

	var candidates: Array = []
	_collect_enemy_candidates(scene, candidates)

	for value: Variant in candidates:
		if value == null or not is_instance_valid(value):
			continue
		if not (value is Node3D):
			continue

		var enemy: Node3D = value as Node3D
		var id: int = enemy.get_instance_id()
		if _decorated_ids.has(id):
			continue

		_apply_enemy_contract(enemy)
		_decorate_enemy(enemy)
		_decorated_ids[id] = true


func _collect_enemy_candidates(root: Node, out: Array) -> void:
	RuntimeDetectionSystemScript.collect_enemy_candidates(root, out)

func _looks_like_enemy(node: Node) -> bool:
	return RuntimeDetectionSystemScript.is_real_enemy(node)

func _is_enemy_readability_generated_node(node: Node) -> bool:
	if node == null:
		return false

	var lower_name: String = str(node.name).to_lower()

	if lower_name.find("enemyreadabilitylayer096e") >= 0:
		return true
	if lower_name.find("enemyreadabilitydecorator096e") >= 0:
		return true

	if lower_name.find("enemyrarity") >= 0:
		return true
	if lower_name.find("enemymod") >= 0:
		return true
	if lower_name.find("enemybadge") >= 0:
		return true
	if lower_name.find("rarityring") >= 0:
		return true
	if lower_name.find("raritypillar") >= 0:
		return true
	if lower_name.find("raritylabel") >= 0:
		return true
	if lower_name.find("modbadge") >= 0:
		return true
	if lower_name.find("threatbadge") >= 0:
		return true

	if lower_name.find("magicmarker") >= 0:
		return true
	if lower_name.find("raremarker") >= 0:
		return true
	if lower_name.find("elitemarker") >= 0:
		return true
	if lower_name.find("normalmarker") >= 0:
		return true

	if lower_name.find("hpbar") >= 0:
		return true
	if lower_name.find("damagenumber") >= 0:
		return true
	if lower_name.find("hitflash") >= 0:
		return true
	if lower_name.find("deathburst") >= 0:
		return true

	return false


func _has_any_enemy_runtime_property(node: Object) -> bool:
	if node == null:
		return false

	if _has_enemy_property(node, "alive"):
		return true
	if _has_enemy_property(node, "hp"):
		return true
	if _has_enemy_property(node, "health"):
		return true
	if _has_enemy_property(node, "max_hp"):
		return true
	if _has_enemy_property(node, "enemy_level"):
		return true
	if _has_enemy_property(node, "is_elite"):
		return true
	if _has_enemy_property(node, "is_boss"):
		return true
	if _has_enemy_property(node, "damage"):
		return true
	if _has_enemy_property(node, "speed"):
		return true
	if _has_enemy_property(node, "radius"):
		return true

	return false


func _has_enemy_property(obj: Object, prop: String) -> bool:
	if obj == null:
		return false

	for value: Variant in obj.get_property_list():
		if typeof(value) != TYPE_DICTIONARY:
			continue

		var data: Dictionary = Dictionary(value)
		if str(data.get("name", "")) == prop:
			return true

	return false


func _apply_enemy_contract(enemy: Node3D) -> void:
	if enemy.has_meta("rv_enemy_rarity"):
		return

	var tier: int = _active_map_tier()
	var roll: Dictionary = EnemyModifierSystemScript.build_enemy_roll(tier)
	EnemyModifierSystemScript.apply_roll_to_enemy(enemy, roll)


func _decorate_enemy(enemy: Node3D) -> void:
	var rarity: String = str(enemy.get_meta("rv_enemy_rarity", "normal"))
	var modifiers: Array = _as_array(enemy.get_meta("rv_enemy_modifiers", []))

	var root: Node3D = Node3D.new()
	root.name = "EnemyReadabilityDecorator096E"
	RuntimeDetectionSystemScript.mark_generated_visual(root, "enemy_readability")
	enemy.add_child(root)
	root.position = Vector3.ZERO

	var color: Color = EnemyModifierSystemScript.rarity_color(rarity)
	var ring_alpha: float = 0.18
	if rarity == "magic":
		ring_alpha = 0.34
	elif rarity == "rare":
		ring_alpha = 0.46

	var ring_mat: Material = VisualPaletteScript.material("Enemy " + rarity + " Ring", color, rarity != "normal", 0.55, ring_alpha)
	var radius: float = 0.62
	if rarity == "magic":
		radius = 0.76
	elif rarity == "rare":
		radius = 0.95

	var ring: MeshInstance3D = PrimitiveKitScript.ground_disc("EnemyRarityRing", radius, Vector3(0.0, 0.035, 0.0), ring_mat)
	root.add_child(ring)

	if rarity == "rare":
		_add_rare_aura(root, color)
	elif rarity == "magic":
		_add_magic_marker(root, color)

	if rarity != "normal":
		var label_text: String = EnemyModifierSystemScript.display_name_for_rarity(rarity)
		var label: Label3D = PrimitiveKitScript.label_3d("EnemyRarityLabel", label_text, Vector3(0.0, 2.05, 0.0), color)
		label.font_size = 22
		root.add_child(label)

	_add_modifier_badges(root, modifiers, color)


func _add_magic_marker(root: Node3D, color: Color) -> void:
	var mat: Material = VisualPaletteScript.material("Magic Marker", color, true, 0.8, 0.55)
	var marker: MeshInstance3D = PrimitiveKitScript.sphere("MagicMarker", 0.15, Vector3(0.0, 1.55, 0.0), mat)
	root.add_child(marker)


func _add_rare_aura(root: Node3D, color: Color) -> void:
	var aura_mat: Material = VisualPaletteScript.material("Rare Aura", color, true, 0.9, 0.20)
	var aura: MeshInstance3D = PrimitiveKitScript.cylinder("RareAuraColumn", 0.82, 1.9, Vector3(0.0, 0.95, 0.0), aura_mat, 32)
	root.add_child(aura)

	var diamond: MeshInstance3D = PrimitiveKitScript.box("RareDiamond", Vector3(0.26, 0.26, 0.26), Vector3(0.0, 2.38, 0.0), VisualPaletteScript.rarity_mat("rare", 0.85))
	diamond.rotation_degrees = Vector3(45.0, 45.0, 0.0)
	root.add_child(diamond)


func _add_modifier_badges(root: Node3D, modifiers: Array, color: Color) -> void:
	if modifiers.is_empty():
		return

	var count: int = min(modifiers.size(), 5)
	var radius: float = 1.05

	for i: int in range(count):
		var mod_id: String = str(modifiers[i])
		var data: Dictionary = EnemyModifierSystemScript.modifier_data(mod_id)
		var angle: float = TAU * float(i) / float(max(1, count))
		var pos: Vector3 = Vector3(sin(angle) * radius, 0.20, cos(angle) * radius)

		var badge_mat: Material = VisualPaletteScript.material("Mod Badge " + mod_id, color, true, 0.7, 0.72)
		var badge: MeshInstance3D = PrimitiveKitScript.box("ModifierBadge_" + mod_id, Vector3(0.24, 0.08, 0.24), pos, badge_mat)
		badge.rotation.y = angle
		root.add_child(badge)

		var short_label: Label3D = PrimitiveKitScript.label_3d("BadgeLabel_" + mod_id, str(data.get("short", "?")), pos + Vector3(0.0, 0.34, 0.0), color)
		short_label.font_size = 12
		root.add_child(short_label)


func _active_map_tier() -> int:
	var state_obj: Object = _state()
	if state_obj == null:
		return 1
	var value: Variant = state_obj.get("active_map_tier")
	if value == null:
		value = state_obj.get("map_tier")
	return clampi(_to_int(value, 1), 1, 15)


func _is_combat_mode() -> bool:
	var state_obj: Object = _state()
	if state_obj == null:
		return false
	return str(state_obj.get("mode")) == "combat"


func _state() -> Object:
	if game_root == null:
		return null
	var state_value: Variant = game_root.get("state")
	if state_value != null and state_value is Object:
		return state_value as Object
	return null


func _as_array(value: Variant) -> Array:
	if typeof(value) == TYPE_ARRAY:
		return value
	return []


func _to_int(value: Variant, fallback: int = 0) -> int:
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
