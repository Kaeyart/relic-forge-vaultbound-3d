class_name RVItemDB3D
extends RefCounted

static var _cache_ready: bool = false
static var _bases: Dictionary = {}
static var _uid_counter: int = 1

static func make_starter_weapon(class_id: String = "sorceress") -> Dictionary:
	var base_id: String = "apprentice_focus"
	if class_id == "warden":
		base_id = "iron_sword"
	elif class_id == "machinist":
		base_id = "coil_launcher"
	elif class_id == "voidbinder":
		base_id = "hollow_focus"
	return make_item(base_id, 1, "Magic", RandomNumberGenerator.new())

static func make_item(base_id: String, item_level: int, rarity: String, rng: RandomNumberGenerator) -> Dictionary:
	_ensure_cache()
	if rng == null:
		rng = RandomNumberGenerator.new()
		rng.randomize()
	var base: Dictionary = Dictionary(_bases.get(base_id, _bases.get("apprentice_focus", {}))).duplicate(true)
	var item: Dictionary = base.duplicate(true)
	item["uid"] = "item_" + str(_uid_counter)
	_uid_counter += 1
	item["base_id"] = base_id
	item["item_level"] = max(1, item_level)
	item["rarity"] = rarity
	item["forge_potential"] = _roll_forge_potential(item, rarity, rng)
	item["affixes"] = RVAffixDB3D.roll_affixes(item, rarity, rng)
	item["stats"] = RVAffixDB3D.apply_affixes_to_stats(Dictionary(item.get("base_stats", {})), Array(item.get("affixes", [])))
	item["display_name"] = _display_name(item)
	return item

static func base(base_id: String) -> Dictionary:
	_ensure_cache()
	return Dictionary(_bases.get(base_id, {})).duplicate(true)

static func all_bases() -> Dictionary:
	_ensure_cache()
	return _bases

static func can_equip_in_slot(item: Dictionary, slot: String) -> bool:
	return str(item.get("slot", "")) == slot

static func _display_name(item: Dictionary) -> String:
	var rarity: String = str(item.get("rarity", "Normal"))
	var name: String = str(item.get("name", "Item"))
	if rarity == "Normal":
		return name
	return rarity + " " + name

static func _roll_forge_potential(item: Dictionary, rarity: String, rng: RandomNumberGenerator) -> int:
	var base_fp: int = int(item.get("base_forge_potential", 12))
	match rarity:
		"Normal": return rng.randi_range(base_fp + 4, base_fp + 12)
		"Magic": return rng.randi_range(base_fp, base_fp + 8)
		"Rare": return rng.randi_range(max(2, base_fp - 5), base_fp + 3)
		_: return max(0, base_fp)

static func _ensure_cache() -> void:
	if _cache_ready:
		return
	_cache_ready = true
	_bases = {
		"apprentice_focus": {"name":"Apprentice Focus", "item_type":"weapon", "slot":"weapon", "weapon_kind":"focus", "base_stats":{"spell_damage_pct":8.0}, "allowed_affix_tags":["spell","fire","lightning","void","mana","caster","damage"], "base_forge_potential":16},
		"hollow_focus": {"name":"Hollow Focus", "item_type":"weapon", "slot":"weapon", "weapon_kind":"focus", "base_stats":{"void_damage_pct":10.0}, "allowed_affix_tags":["spell","void","mana","caster","damage"], "base_forge_potential":15},
		"iron_sword": {"name":"Iron Sword", "item_type":"weapon", "slot":"weapon", "weapon_kind":"sword", "base_stats":{"attack_damage_pct":8.0}, "allowed_affix_tags":["attack","melee","physical","damage"], "base_forge_potential":17},
		"coil_launcher": {"name":"Coil Launcher", "item_type":"weapon", "slot":"weapon", "weapon_kind":"launcher", "base_stats":{"projectile_damage_pct":8.0}, "allowed_affix_tags":["projectile","attack","lightning","cooldown","damage"], "base_forge_potential":16},
		"patched_helm": {"name":"Patched Helm", "item_type":"armor", "slot":"head", "base_stats":{"armor":12.0}, "allowed_affix_tags":["life","armor","defense","resistance"], "base_forge_potential":14},
		"vault_chestguard": {"name":"Vault Chestguard", "item_type":"armor", "slot":"chest", "base_stats":{"armor":28.0}, "allowed_affix_tags":["life","armor","defense","resistance"], "base_forge_potential":15},
		"work_gloves": {"name":"Work Gloves", "item_type":"armor", "slot":"gloves", "base_stats":{"armor":9.0}, "allowed_affix_tags":["life","armor","defense","attack","cooldown"], "base_forge_potential":14},
		"ashwalkers": {"name":"Ashwalkers", "item_type":"armor", "slot":"boots", "base_stats":{"armor":8.0}, "allowed_affix_tags":["life","armor","defense","movement","speed","cooldown"], "base_forge_potential":14},
		"copper_ring": {"name":"Copper Ring", "item_type":"jewelry", "slot":"ring1", "base_stats":{}, "allowed_affix_tags":["life","mana","fire","lightning","void","spell","attack","damage"], "base_forge_potential":13},
		"ember_amulet": {"name":"Ember Amulet", "item_type":"jewelry", "slot":"amulet", "base_stats":{"fire_damage_pct":5.0}, "allowed_affix_tags":["life","mana","fire","lightning","void","spell","attack","damage","cooldown"], "base_forge_potential":13}
	}
