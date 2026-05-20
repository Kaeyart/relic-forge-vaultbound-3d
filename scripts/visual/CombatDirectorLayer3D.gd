extends Node3D
class_name RVCombatDirectorLayer3D

const EnemySpawnContractSystemScript := preload("res://scripts/systems/EnemySpawnContractSystem3D.gd")
const EnemyModifierRuntimeSystemScript := preload("res://scripts/systems/EnemyModifierRuntimeSystem3D.gd")
const LootDropContractSystemScript := preload("res://scripts/systems/LootDropContractSystem3D.gd")
const RuntimeDetectionSystemScript := preload("res://scripts/systems/RuntimeDetectionSystem3D.gd")

var game_root: Node = null
var _scan_timer: float = 0.0
var _known_dead: Dictionary = {}


func _ready() -> void:
	name = "CombatDirectorLayer097A"
	set_process(true)


func bind_game(root: Node) -> void:
	game_root = root


func _process(delta: float) -> void:
	if not _is_combat_mode():
		visible = false
		return

	visible = true
	var enemies: Array = _collect_enemies()

	_scan_timer -= delta
	if _scan_timer <= 0.0:
		_scan_timer = 0.25
		var result: Dictionary = EnemySpawnContractSystemScript.apply_to_existing_enemies(enemies, _state())
		if int(result.get("assigned", 0)) > 0:
			_set_notice("Enemies: " + str(result.get("normal", 0)) + " normal, " + str(result.get("magic", 0)) + " magic, " + str(result.get("rare", 0)) + " rare")

	EnemyModifierRuntimeSystemScript.update_enemies(enemies, delta)
	_watch_deaths(enemies)


func _collect_enemies() -> Array:
	var scene: Node = get_tree().current_scene
	var result: Array = []
	if scene == null:
		return result
	_collect_enemy_candidates(scene, result)
	return result


func _collect_enemy_candidates(root: Node, out: Array) -> void:
	for child: Node in root.get_children():
		if _looks_like_enemy(child):
			out.append(child)
		_collect_enemy_candidates(child, out)


func _looks_like_enemy(node: Node) -> bool:
	return RuntimeDetectionSystemScript.is_real_enemy(node)

func _watch_deaths(enemies: Array) -> void:
	for value: Variant in enemies:
		if value == null or not is_instance_valid(value):
			continue
		var enemy: Node3D = value as Node3D
		if enemy == null:
			continue

		var id: int = enemy.get_instance_id()
		if _known_dead.has(id):
			continue

		if _read_hp(enemy) <= 0.0:
			_known_dead[id] = true
			var drops: Array = LootDropContractSystemScript.roll_drops_for_enemy(enemy, _state())
			enemy.set_meta("rv_097a_rolled_drops", drops)
			if not drops.is_empty():
				_set_notice("Loot rolled: " + str(drops.size()) + " drop(s)")


func _read_hp(enemy: Object) -> float:
	for prop: String in ["hp", "current_hp", "health", "current_health"]:
		if _has_property(enemy, prop):
			return _to_float(enemy.get(prop), 1.0)
	return 1.0


func _has_property(obj: Object, prop: String) -> bool:
	if obj == null:
		return false
	var props: Array = obj.get_property_list()
	for value: Variant in props:
		if typeof(value) != TYPE_DICTIONARY:
			continue
		var data: Dictionary = value
		if str(data.get("name", "")) == prop:
			return true
	return false


func _set_notice(text: String) -> void:
	var state_obj: Object = _state()
	if state_obj == null:
		return
	if state_obj.has_method("add_notice"):
		state_obj.call("add_notice", text)
		return
	if _has_property(state_obj, "notice_text"):
		state_obj.set("notice_text", text)
	if _has_property(state_obj, "notice_time"):
		state_obj.set("notice_time", 2.0)


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


func _to_float(value: Variant, fallback: float = 0.0) -> float:
	if value == null:
		return fallback
	match typeof(value):
		TYPE_FLOAT:
			return value
		TYPE_INT:
			return float(int(value))
		TYPE_STRING:
			var s: String = str(value)
			if s.is_valid_float():
				return s.to_float()
			return fallback
		TYPE_BOOL:
			return 1.0 if bool(value) else 0.0
		_:
			return fallback
