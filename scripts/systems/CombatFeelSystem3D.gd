extends RefCounted
class_name RVCombatFeelSystem3D

static func enemy_hp(enemy: Object) -> float:
	if enemy == null:
		return -1.0
	for key: String in ["hp", "health", "current_hp"]:
		if _has_property(enemy, key):
			return _to_float(enemy.get(key), -1.0)
	return -1.0


static func enemy_alive(enemy: Object) -> bool:
	if enemy == null:
		return false
	if _has_property(enemy, "alive"):
		return bool(enemy.get("alive"))
	var hp: float = enemy_hp(enemy)
	if hp >= 0.0:
		return hp > 0.0
	return true


static func enemy_radius(enemy: Object) -> float:
	if enemy == null:
		return 0.65
	if _has_property(enemy, "radius"):
		return clampf(_to_float(enemy.get("radius"), 0.65), 0.35, 2.4)
	return 0.65


static func enemy_rarity(enemy: Object) -> String:
	if enemy == null:
		return "normal"
	if enemy.has_meta("rv_enemy_rarity"):
		var meta_rarity: String = str(enemy.get_meta("rv_enemy_rarity")).strip_edges().to_lower()
		if meta_rarity in ["normal", "magic", "rare", "unique", "boss"]:
			return meta_rarity
	if _has_property(enemy, "is_boss") and bool(enemy.get("is_boss")):
		return "boss"
	if _has_property(enemy, "is_elite") and bool(enemy.get("is_elite")):
		return "magic"
	return "normal"


static func rarity_color(rarity: String) -> Color:
	match rarity.strip_edges().to_lower():
		"magic":
			return Color(0.30, 0.50, 1.0, 0.78)
		"rare":
			return Color(1.0, 0.82, 0.22, 0.86)
		"unique":
			return Color(1.0, 0.45, 0.14, 0.90)
		"boss":
			return Color(1.0, 0.18, 0.12, 0.92)
		_:
			return Color(0.88, 0.88, 0.82, 0.42)


static func threat_ring_radius(enemy: Object) -> float:
	var radius: float = enemy_radius(enemy)
	match enemy_rarity(enemy):
		"boss":
			return radius * 2.25
		"rare":
			return radius * 1.85
		"magic":
			return radius * 1.55
		_:
			return radius * 1.28


static func threat_ring_alpha(enemy: Object, pulse: float = 0.0) -> float:
	match enemy_rarity(enemy):
		"boss":
			return 0.55 + pulse * 0.25
		"rare":
			return 0.46 + pulse * 0.20
		"magic":
			return 0.34 + pulse * 0.16
		_:
			return 0.20


static func hit_label(amount: float) -> String:
	if amount <= 0.0:
		return "0"
	return str(int(round(amount)))


static func hit_color(amount: float, enemy: Object = null) -> Color:
	var rarity: String = enemy_rarity(enemy)
	if rarity == "rare" or rarity == "boss":
		return Color(1.0, 0.84, 0.24, 1.0)
	if amount >= 50.0:
		return Color(1.0, 0.44, 0.20, 1.0)
	return Color(0.96, 0.94, 0.86, 1.0)


static func player_focus_color() -> Color:
	return Color(0.35, 0.78, 1.0, 0.32)


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


static func _to_float(value: Variant, fallback: float = 0.0) -> float:
	if value == null:
		return fallback
	match typeof(value):
		TYPE_FLOAT:
			return float(value)
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
