class_name RVProgressionSystem3D
extends RefCounted

static func award_enemy_kill(state: Object, enemy_data: Dictionary) -> void:
	if state == null:
		return
	var level: int = max(1, int(enemy_data.get("level", state.get("level"))))
	var xp: float = 18.0 + float(level) * 7.5
	if bool(enemy_data.get("elite", false)):
		xp *= 2.3
	if bool(enemy_data.get("boss", false)):
		xp *= 6.0
	state.call("add_xp", xp)
	state.set("kills", int(state.get("kills")) + 1)
	state.call("refill_flasks_from_kill", bool(enemy_data.get("elite", false)), bool(enemy_data.get("boss", false)))
