class_name RVProgressionSystem3D
extends RefCounted

static func xp_to_next(level: int) -> int:
	var safe_level: int = max(1, level)
	return int(round(120.0 + pow(float(safe_level), 1.42) * 72.0))

static func enemy_xp(enemy_level: int, rank: String = "normal") -> int:
	var base: int = 10 + max(1, enemy_level) * 3
	if rank == "elite":
		base *= 4
	elif rank == "boss":
		base *= 12
	return base

static func award_enemy_kill(state: RVGameState3D, enemy_level: int, rank: String = "normal") -> void:
	if state == null:
		return
	state.kills += 1
	state.add_xp(enemy_xp(enemy_level, rank))
	if rank == "elite" or rank == "boss":
		state.health_flask_charges = min(state.health_flask_max_charges, state.health_flask_charges + 1)
		state.mana_flask_charges = min(state.mana_flask_max_charges, state.mana_flask_charges + 1)
