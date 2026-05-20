extends RefCounted
class_name RVRuntimeDetectionSystem3D

static func mark_generated_visual(node: Node, source: String = "") -> void:
	if node == null:
		return

	node.set_meta("rv_generated_visual", true)
	if source != "":
		node.set_meta("rv_generated_visual_source", source)

	for child: Node in node.get_children():
		mark_generated_visual(child, source)


static func is_generated_visual(node: Node, check_ancestors: bool = false) -> bool:
	if node == null:
		return false

	if node.has_meta("rv_generated_visual") and bool(node.get_meta("rv_generated_visual")):
		return true

	if _is_generated_visual_name(str(node.name).to_lower()):
		return true

	if check_ancestors:
		var parent: Node = node.get_parent()
		while parent != null:
			if parent.has_meta("rv_generated_visual") and bool(parent.get_meta("rv_generated_visual")):
				return true
			if _is_generated_visual_name(str(parent.name).to_lower()):
				return true
			parent = parent.get_parent()

	return false


static func is_real_enemy(node: Node) -> bool:
	if node == null:
		return false
	if not (node is Node3D):
		return false

	if is_generated_visual(node, true):
		return false

	if node is Label3D:
		return false
	if node is MeshInstance3D:
		return false
	if node is CollisionShape3D:
		return false
	if node is Area3D:
		return false

	var lower_name: String = str(node.name).to_lower()

	if lower_name.ends_with("root"):
		return false
	if lower_name.find("decorator") >= 0:
		return false
	if lower_name.find("presentation") >= 0:
		return false
	if lower_name.find("feedback") >= 0:
		return false
	if lower_name.find("readability") >= 0:
		return false
	if lower_name.find("vfx") >= 0:
		return false

	if node.is_in_group("enemy") or node.is_in_group("enemies") or node.is_in_group("monsters"):
		return true

	if node.has_meta("rv_enemy_rarity"):
		return true
	if node.has_meta("rv_enemy_modifiers"):
		return true

	if node.has_method("take_damage"):
		return true

	if _has_property(node, "alive") and (
		_has_property(node, "hp")
		or _has_property(node, "health")
		or _has_property(node, "max_hp")
		or _has_property(node, "enemy_level")
	):
		return true

	if _name_looks_enemy(lower_name) and _has_any_enemy_runtime_property(node):
		return true

	return false


static func is_real_loot(node: Node) -> bool:
	if node == null:
		return false
	if not (node is Node3D):
		return false

	if is_generated_visual(node, true):
		return false

	var lower_name: String = str(node.name).to_lower()
	if lower_name == "lootroot":
		return false
	if lower_name.ends_with("root"):
		return false
	if lower_name.find("decorator") >= 0:
		return false
	if lower_name.find("presentation") >= 0:
		return false
	if lower_name.find("feedback") >= 0:
		return false
	if lower_name.find("readability") >= 0:
		return false
	if lower_name.find("vfx") >= 0:
		return false

	if node.has_meta("item_data"):
		return true
	if node.has_meta("rv_item"):
		return true
	if node.has_meta("drop_item"):
		return true

	if node.is_in_group("loot") or node.is_in_group("drops") or node.is_in_group("pickup"):
		return true

	var drop_data: Variant = node.get("drop_data")
	if typeof(drop_data) == TYPE_DICTIONARY and not Dictionary(drop_data).is_empty():
		return true

	return false


static func collect_enemy_candidates(root: Node, out: Array) -> void:
	if root == null:
		return

	if is_generated_visual(root, false):
		return

	for child: Node in root.get_children():
		if is_real_enemy(child):
			out.append(child)

		if not is_generated_visual(child, false):
			collect_enemy_candidates(child, out)


static func collect_loot_candidates(root: Node, out: Array) -> void:
	if root == null:
		return

	if is_generated_visual(root, false):
		return

	for child: Node in root.get_children():
		if is_real_loot(child):
			out.append(child)

		if not is_generated_visual(child, false):
			collect_loot_candidates(child, out)


static func scene_report(root: Node) -> Dictionary:
	var enemies: Array = []
	var loot: Array = []
	collect_enemy_candidates(root, enemies)
	collect_loot_candidates(root, loot)

	return {
		"enemy_count": enemies.size(),
		"loot_count": loot.size(),
		"generated_visual_count": count_generated_visual_nodes(root),
		"warnings": warnings_for_scene(root, enemies, loot),
	}


static func count_generated_visual_nodes(root: Node) -> int:
	if root == null:
		return 0

	var count: int = 1 if is_generated_visual(root, false) else 0
	for child: Node in root.get_children():
		count += count_generated_visual_nodes(child)
	return count


static func warnings_for_scene(root: Node, enemies: Array, loot: Array) -> Array:
	var warnings: Array = []

	if root == null:
		warnings.append("No current scene.")
		return warnings

	var suspicious: int = _count_suspicious_generated_candidates(root)
	if suspicious > 0:
		warnings.append(str(suspicious) + " generated-looking nodes still look like gameplay candidates.")

	if loot.size() > 80:
		warnings.append("Very high loot node count: " + str(loot.size()) + ". Check runaway loot decoration.")

	return warnings


static func _count_suspicious_generated_candidates(root: Node) -> int:
	if root == null:
		return 0

	var count: int = 0
	var generated_name: bool = _is_generated_visual_name(str(root.name).to_lower())
	if generated_name and (is_real_enemy(root) or is_real_loot(root)):
		count += 1

	for child: Node in root.get_children():
		count += _count_suspicious_generated_candidates(child)

	return count


static func _is_generated_visual_name(lower_name: String) -> bool:
	var needles: Array[String] = [
		"lootpresentationlayer096f",
		"lootpresentationdecorator096f",
		"lootgroundring",
		"lootraritybeam",
		"lootraritycrown",
		"lootlabel",
		"currencymarker",
		"gemmarker",
		"mapmarker",
		"crystalmarker",
		"uniquemarker",
		"gearmarker",
		"rewardburst",
		"enemyreadabilitylayer096e",
		"enemyreadabilitydecorator096e",
		"enemyrarity",
		"enemymod",
		"enemybadge",
		"rarityring",
		"raritypillar",
		"raritylabel",
		"modbadge",
		"threatbadge",
		"magicmarker",
		"raremarker",
		"elitemarker",
		"normalmarker",
		"combatfeedback",
		"hpbar",
		"damagenumber",
		"hitflash",
		"deathburst",
		"verticalslicedebugoverlay098a",
		"verticalslicedebugpanel",
	]

	for needle: String in needles:
		if lower_name.find(needle) >= 0:
			return true

	return false


static func _name_looks_enemy(lower_name: String) -> bool:
	var needles: Array[String] = ["enemy", "monster", "grunt", "lunger", "spitter", "wretch", "imp", "brute"]
	for needle: String in needles:
		if lower_name.find(needle) >= 0:
			return true
	return false


static func _has_any_enemy_runtime_property(node: Object) -> bool:
	if node == null:
		return false

	var props: Array[String] = ["alive", "hp", "health", "max_hp", "enemy_level", "is_elite", "is_boss", "damage", "speed", "radius"]
	for prop: String in props:
		if _has_property(node, prop):
			return true

	return false


static func _has_property(obj: Object, prop: String) -> bool:
	if obj == null:
		return false

	for value: Variant in obj.get_property_list():
		if typeof(value) != TYPE_DICTIONARY:
			continue
		var data: Dictionary = Dictionary(value)
		if str(data.get("name", "")) == prop:
			return true

	return false
