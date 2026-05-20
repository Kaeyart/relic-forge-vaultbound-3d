extends Node3D
class_name RVLootPresentationLayer3D

const VisualPaletteScript := preload("res://scripts/visual/VisualPalette3D.gd")
const PrimitiveKitScript := preload("res://scripts/visual/PrimitiveKit3D.gd")
const LootPresentationSystemScript := preload("res://scripts/systems/LootPresentationSystem3D.gd")

var game_root: Node = null
var _scan_timer: float = 0.0
var _decorated_ids: Dictionary = {}
var _burst_nodes: Array = []


func _ready() -> void:
	name = "LootPresentationLayer096F"
	set_process(true)


func bind_game(root: Node) -> void:
	game_root = root


func _process(delta: float) -> void:
	_scan_timer -= delta
	if _scan_timer <= 0.0:
		_scan_timer = 0.45
		_scan_loot_nodes()
	_update_bursts(delta)


func spawn_loot_beam_at(world_pos: Vector3, item_data: Dictionary) -> Node3D:
	var anchor: Node3D = Node3D.new()
	anchor.name = "RuntimeLootAnchor096F"
	anchor.global_position = world_pos
	anchor.set_meta("item_data", item_data)
	add_child(anchor)
	_decorate_loot(anchor)
	return anchor


func spawn_reward_burst(world_pos: Vector3, rarity: String = "rare") -> void:
	var color: Color = LootPresentationSystemScript.rarity_color(rarity)
	var mat: Material = VisualPaletteScript.material("Reward Burst " + rarity, color, true, 1.1, 0.42)

	var root: Node3D = Node3D.new()
	root.name = "RewardBurst096F"
	root.global_position = world_pos
	add_child(root)

	for i: int in range(10):
		var angle: float = TAU * float(i) / 10.0
		var shard: MeshInstance3D = PrimitiveKitScript.box("RewardBurstShard", Vector3(0.12, 0.12, 0.65), Vector3.ZERO, mat)
		shard.rotation.y = angle
		root.add_child(shard)
		_burst_nodes.append({
			"node": shard,
			"dir": Vector3(sin(angle), 0.35, cos(angle)).normalized(),
			"time": 0.0,
			"duration": 0.55,
			"speed": 4.0,
		})


func _scan_loot_nodes() -> void:
	var scene: Node = get_tree().current_scene
	if scene == null:
		return

	var candidates: Array = []
	_collect_loot_candidates(scene, candidates)

	for value: Variant in candidates:
		if value == null or not is_instance_valid(value):
			continue
		if not (value is Node3D):
			continue

		var node: Node3D = value as Node3D
		var id: int = node.get_instance_id()
		if _decorated_ids.has(id):
			continue

		_decorate_loot(node)
		_decorated_ids[id] = true


func _collect_loot_candidates(root: Node, out: Array) -> void:
	for child: Node in root.get_children():
		if _looks_like_loot(child):
			out.append(child)
		_collect_loot_candidates(child, out)


func _looks_like_loot(node: Node) -> bool:
	if node == null:
		return false
	if not (node is Node3D):
		return false

	var lower_name: String = node.name.to_lower()

	if lower_name.find("decorator096f") >= 0:
		return false
	if lower_name.find("lootpresentationlayer") >= 0:
		return false
	if lower_name.find("dropbeam") >= 0:
		return false
	if lower_name.find("rewardburst") >= 0:
		return false

	if node.has_meta("item_data") or node.has_meta("rv_item") or node.has_meta("drop_item"):
		return true

	if node.is_in_group("loot") or node.is_in_group("drops") or node.is_in_group("items") or node.is_in_group("pickup"):
		return true

	if lower_name.find("loot") >= 0:
		return true
	if lower_name.find("drop") >= 0:
		return true
	if lower_name.find("pickup") >= 0:
		return true
	if lower_name.find("currency") >= 0:
		return true
	if lower_name.find("gem_drop") >= 0:
		return true
	if lower_name.find("map_drop") >= 0:
		return true

	return false


func _decorate_loot(node: Node3D) -> void:
	if node.get_node_or_null("LootPresentationDecorator096F") != null:
		return

	var rarity: String = LootPresentationSystemScript.rarity_from_source(node)
	var kind: String = LootPresentationSystemScript.kind_from_source(node)
	var color: Color = LootPresentationSystemScript.rarity_color(rarity)
	var label_text: String = LootPresentationSystemScript.pickup_text(node)

	var root: Node3D = Node3D.new()
	root.name = "LootPresentationDecorator096F"
	node.add_child(root)
	root.position = Vector3.ZERO

	var beam_height: float = LootPresentationSystemScript.beam_height_for_rarity(rarity)
	var beam_radius: float = LootPresentationSystemScript.beam_radius_for_rarity(rarity)
	var ring_radius: float = LootPresentationSystemScript.ring_radius_for_kind(kind, rarity)

	var beam_mat: Material = VisualPaletteScript.material("Loot Beam " + rarity, color, rarity != "normal", 1.0, 0.42)
	var ring_mat: Material = VisualPaletteScript.material("Loot Ring " + rarity, color, rarity != "normal", 0.75, 0.34)

	var ring: MeshInstance3D = PrimitiveKitScript.ground_disc("LootGroundRing", ring_radius, Vector3(0.0, 0.045, 0.0), ring_mat)
	root.add_child(ring)

	var beam: MeshInstance3D = PrimitiveKitScript.cylinder("LootRarityBeam", beam_radius, beam_height, Vector3(0.0, beam_height * 0.5, 0.0), beam_mat, 24)
	root.add_child(beam)

	var kind_marker: MeshInstance3D = _make_kind_marker(kind, color)
	kind_marker.position = Vector3(0.0, 0.36, 0.0)
	root.add_child(kind_marker)

	var label: Label3D = PrimitiveKitScript.label_3d("LootLabel", label_text, Vector3(0.0, beam_height + 0.35, 0.0), color)
	label.font_size = 20 if rarity == "normal" else 24
	root.add_child(label)

	if rarity == "rare" or rarity == "unique":
		var crown: MeshInstance3D = PrimitiveKitScript.box("LootRarityCrown", Vector3(0.34, 0.10, 0.34), Vector3(0.0, beam_height + 0.05, 0.0), beam_mat)
		crown.rotation_degrees = Vector3(0.0, 45.0, 0.0)
		root.add_child(crown)


func _make_kind_marker(kind: String, color: Color) -> MeshInstance3D:
	var mat: Material = VisualPaletteScript.material("Loot Kind " + kind, color, true, 0.75, 0.75)
	match kind:
		"currency":
			return PrimitiveKitScript.cylinder("CurrencyMarker", 0.18, 0.12, Vector3.ZERO, mat, 24)
		"gem":
			var gem: MeshInstance3D = PrimitiveKitScript.box("GemMarker", Vector3(0.22, 0.22, 0.22), Vector3.ZERO, mat)
			gem.rotation_degrees = Vector3(45.0, 35.0, 0.0)
			return gem
		"map":
			return PrimitiveKitScript.box("MapMarker", Vector3(0.42, 0.045, 0.30), Vector3.ZERO, mat)
		"crystal":
			var crystal: MeshInstance3D = PrimitiveKitScript.box("CrystalMarker", Vector3(0.18, 0.42, 0.18), Vector3.ZERO, mat)
			crystal.rotation_degrees = Vector3(0.0, 45.0, 0.0)
			return crystal
		"unique":
			return PrimitiveKitScript.sphere("UniqueMarker", 0.20, Vector3.ZERO, mat)
		_:
			return PrimitiveKitScript.box("GearMarker", Vector3(0.32, 0.16, 0.24), Vector3.ZERO, mat)


func _update_bursts(delta: float) -> void:
	for i: int in range(_burst_nodes.size() - 1, -1, -1):
		var value: Variant = _burst_nodes[i]
		if typeof(value) != TYPE_DICTIONARY:
			_burst_nodes.remove_at(i)
			continue

		var data: Dictionary = Dictionary(value)
		var node_value: Variant = data.get("node", null)
		if node_value == null or not is_instance_valid(node_value):
			_burst_nodes.remove_at(i)
			continue

		var node: Node3D = node_value as Node3D
		if node == null:
			_burst_nodes.remove_at(i)
			continue

		var time: float = _to_float(data.get("time", 0.0), 0.0) + delta
		var duration: float = max(0.01, _to_float(data.get("duration", 0.5), 0.5))
		var direction: Vector3 = _dict_vec3(data, "dir", Vector3.UP)
		var speed: float = _to_float(data.get("speed", 4.0), 4.0)
		var ratio: float = clampf(time / duration, 0.0, 1.0)

		node.global_position += direction * speed * delta * (1.0 - ratio * 0.5)
		node.scale = Vector3.ONE * (1.0 - ratio * 0.72)
		data["time"] = time
		_burst_nodes[i] = data

		if time >= duration:
			node.queue_free()
			_burst_nodes.remove_at(i)


func _dict_vec3(data: Dictionary, key: String, fallback: Vector3) -> Vector3:
	var value: Variant = data.get(key, fallback)
	if typeof(value) == TYPE_VECTOR3:
		return value
	return fallback


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
		_:
			return fallback
