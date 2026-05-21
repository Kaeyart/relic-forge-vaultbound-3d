class_name RVSkillGemSystem3D
extends RefCounted

# Patch 15: POE2-style gem page / hotbar split / uncut gems / spirit gems.
# User rule: support sockets are NOT gained through random orb currency.
# Active and spirit gems start with 2 support sockets, gain +1 every 5 gem levels, max 6.

const GEM_ACTIVE: String = "active"
const GEM_SUPPORT: String = "support"
const GEM_SPIRIT: String = "spirit"
const GEM_META: String = "meta"
const GEM_UNCUT_ACTIVE: String = "uncut_active"
const GEM_UNCUT_SUPPORT: String = "uncut_support"
const GEM_UNCUT_SPIRIT: String = "uncut_spirit"

const EQUIPPED_GEM_ROWS: int = 9
const HOTBAR_SLOTS: int = 5
const STARTING_SUPPORT_SOCKETS: int = 2
const MAX_SUPPORT_SOCKETS: int = 6
const SOCKET_LEVEL_INTERVAL: int = 5

const DEFAULT_ACTIVE_IDS: Array[String] = ["fireball", "storm_lance", "arc_slash", "void_rift", "ember_mine"]
const ACTIVE_ORDER: Array[String] = [
	"fireball",
	"storm_lance",
	"chain_spark",
	"arc_slash",
	"blood_cleave",
	"void_rift",
	"ember_mine",
	"bone_spear",
	"ash_nova",
	"shield_burst",
	"infernal_step",
	"furnace_totem",
	"relic_barrage",
	"vault_slam"
]

const SUPPORT_ORDER: Array[String] = [
	"controlled_power",
	"efficient_casting",
	"swift_casting",
	"rapid_strikes",
	"greater_area",
	"focused_area",
	"split_projectile",
	"volley_matrix",
	"piercing_force",
	"chain_current",
	"returning_orbit",
	"ignition",
	"searing_burst",
	"shock_charge",
	"bleed_edge",
	"executioner",
	"echoing_ritual",
	"blood_price",
	"minefield",
	"remote_detonator",
	"totem_fortify",
	"cooldown_focus",
	"mana_leech",
	"life_leech",
	"relic_resonance",
	"spirit_pressure"
]

const SPIRIT_ORDER: Array[String] = [
	"clarity",
	"vitality",
	"iron_skin",
	"ember_pact",
	"storm_rhythm",
	"void_tithe",
	"revenant_guard",
	"execution_focus",
	"furnace_aegis"
]

const ACTIVE_DATA: Dictionary = {
	"fireball": {"name": "Fireball", "color": "red", "tags": ["skill", "spell", "projectile", "fire", "hit"], "description": "Launch a fire projectile that can split, chain, ignite, and explode through supports.", "damage": 32.0, "mana": 10.0, "cooldown": 0.18, "range": 11.0, "radius": 0.42, "projectile_speed": 14.0, "required_level": 1, "requirements": {"int": 8}, "weapon_requirements": ["wand", "focus", "staff", "scepter"]},
	"storm_lance": {"name": "Storm Lance", "color": "blue", "tags": ["skill", "spell", "projectile", "lightning", "beam", "hit"], "description": "Fire a straight lightning lance with strong chain and shock scaling.", "damage": 28.0, "mana": 12.0, "cooldown": 0.22, "range": 10.5, "radius": 0.34, "projectile_speed": 19.0, "required_level": 1, "requirements": {"int": 10}, "weapon_requirements": ["wand", "focus", "staff", "scepter"]},
	"chain_spark": {"name": "Chain Spark", "color": "blue", "tags": ["skill", "spell", "projectile", "lightning", "chain", "hit"], "description": "Release an unstable spark that jumps between nearby enemies.", "damage": 20.0, "mana": 11.0, "cooldown": 0.24, "range": 8.0, "radius": 0.36, "projectile_speed": 12.0, "chain": 2, "required_level": 3, "requirements": {"int": 14}, "weapon_requirements": ["wand", "focus", "staff", "scepter"]},
	"arc_slash": {"name": "Arc Slash", "color": "red", "tags": ["skill", "attack", "melee", "physical", "hit"], "description": "A quick frontal weapon arc. Strong with bleed, execution, and attack supports.", "damage": 38.0, "mana": 8.0, "cooldown": 0.20, "range": 2.8, "area": 1.0, "required_level": 1, "requirements": {"str": 8}, "weapon_requirements": ["sword", "axe", "mace", "scepter"]},
	"blood_cleave": {"name": "Blood Cleave", "color": "red", "tags": ["skill", "attack", "melee", "physical", "blood", "area", "hit"], "description": "A heavy sweeping attack that wants bleed and life-cost supports.", "damage": 52.0, "mana": 13.0, "cooldown": 0.36, "range": 3.2, "area": 1.15, "required_level": 4, "requirements": {"str": 16}, "weapon_requirements": ["sword", "axe", "mace"]},
	"void_rift": {"name": "Void Rift", "color": "blue", "tags": ["skill", "spell", "area", "void", "duration", "hit"], "description": "Open a void rupture at the cursor. Excellent with area, echo, and control supports.", "damage": 44.0, "mana": 16.0, "cooldown": 0.42, "range": 8.0, "area": 2.15, "required_level": 5, "requirements": {"int": 18}, "weapon_requirements": ["wand", "focus", "staff"]},
	"ember_mine": {"name": "Ember Mine", "color": "red", "tags": ["skill", "spell", "mine", "fire", "area", "hit"], "description": "Throw a mine that detonates in a fiery burst. Mine supports change its rhythm.", "damage": 58.0, "mana": 15.0, "cooldown": 0.50, "range": 6.5, "area": 1.8, "required_level": 4, "requirements": {"int": 14, "dex": 8}, "weapon_requirements": []},
	"bone_spear": {"name": "Bone Spear", "color": "green", "tags": ["skill", "spell", "projectile", "physical", "pierce", "hit"], "description": "Fire a piercing physical spear. Scales well with pierce, volley, and bleed.", "damage": 34.0, "mana": 10.0, "cooldown": 0.22, "range": 12.0, "radius": 0.32, "projectile_speed": 17.0, "pierce": 1, "required_level": 2, "requirements": {"dex": 10, "int": 8}, "weapon_requirements": ["wand", "focus", "staff", "scepter"]},
	"ash_nova": {"name": "Ash Nova", "color": "red", "tags": ["skill", "spell", "area", "fire", "nova", "hit"], "description": "A close-range fire nova. Safe only if you build around area and recovery.", "damage": 46.0, "mana": 14.0, "cooldown": 0.34, "range": 0.0, "area": 2.7, "required_level": 3, "requirements": {"int": 12}, "weapon_requirements": []},
	"shield_burst": {"name": "Shield Burst", "color": "green", "tags": ["skill", "attack", "melee", "area", "guard", "hit"], "description": "Explode defensive force in a short cone. Works with guard and execution supports.", "damage": 42.0, "mana": 12.0, "cooldown": 0.38, "range": 2.6, "area": 1.2, "required_level": 2, "requirements": {"str": 10}, "weapon_requirements": ["shield"]},
	"infernal_step": {"name": "Infernal Step", "color": "red", "tags": ["skill", "attack", "movement", "fire", "area", "hit"], "description": "Dash pressure fantasy: burns a path and strikes at the endpoint.", "damage": 40.0, "mana": 13.0, "cooldown": 0.65, "range": 4.5, "area": 1.55, "required_level": 5, "requirements": {"dex": 12, "str": 10}, "weapon_requirements": []},
	"furnace_totem": {"name": "Furnace Totem", "color": "red", "tags": ["skill", "spell", "totem", "fire", "area", "duration", "hit"], "description": "Place a furnace focus that pulses fire damage. Prototype uses instant pulses for now.", "damage": 25.0, "mana": 18.0, "cooldown": 0.85, "range": 6.0, "area": 1.75, "pulses": 3, "required_level": 6, "requirements": {"int": 16}, "weapon_requirements": []},
	"relic_barrage": {"name": "Relic Barrage", "color": "green", "tags": ["skill", "attack", "projectile", "physical", "relic", "hit"], "description": "Fire relic shards in a narrow barrage. Scales with projectile and attack support gems.", "damage": 30.0, "mana": 12.0, "cooldown": 0.28, "range": 10.0, "radius": 0.30, "projectile_speed": 18.0, "required_level": 6, "requirements": {"dex": 18}, "weapon_requirements": ["crossbow", "bow", "relic"]},
	"vault_slam": {"name": "Vault Slam", "color": "red", "tags": ["skill", "attack", "melee", "area", "physical", "slam", "hit"], "description": "A slow vault-forged slam that rewards area, stun, and heavy hit supports.", "damage": 70.0, "mana": 18.0, "cooldown": 0.55, "range": 3.0, "area": 1.8, "required_level": 7, "requirements": {"str": 22}, "weapon_requirements": ["mace", "axe", "staff"]}
}

const SUPPORT_DATA: Dictionary = {
	"controlled_power": {"name": "Controlled Power", "color": "red", "tier": 1, "requires_any": ["skill"], "description": "More damage, higher cost.", "damage_more": 0.30, "mana_more": 0.22},
	"efficient_casting": {"name": "Efficient Casting", "color": "blue", "tier": 1, "requires_any": ["spell", "skill"], "description": "Lower cost, slightly lower damage.", "damage_more": -0.06, "mana_more": -0.28},
	"swift_casting": {"name": "Swift Casting", "color": "blue", "tier": 1, "requires_any": ["spell"], "description": "Faster spell rhythm.", "cooldown_more": -0.18, "mana_more": 0.10},
	"rapid_strikes": {"name": "Rapid Strikes", "color": "green", "tier": 1, "requires_any": ["attack"], "description": "Faster attacks with slightly less damage.", "damage_more": -0.08, "cooldown_more": -0.22},
	"greater_area": {"name": "Greater Area", "color": "red", "tier": 1, "requires_any": ["area", "nova", "slam"], "description": "Larger area, lower direct damage.", "area_more": 0.45, "damage_more": -0.12, "mana_more": 0.15},
	"focused_area": {"name": "Focused Area", "color": "blue", "tier": 1, "requires_any": ["area", "nova", "slam"], "description": "Smaller area, much harder hits.", "area_more": -0.28, "damage_more": 0.42},
	"split_projectile": {"name": "Split Projectile", "color": "green", "tier": 1, "requires_any": ["projectile"], "description": "Adds two extra projectiles with spread.", "extra_projectiles": 2, "spread": 0.24, "damage_more": -0.12, "mana_more": 0.18},
	"volley_matrix": {"name": "Volley Matrix", "color": "green", "tier": 1, "requires_any": ["projectile"], "description": "Adds four projectiles, but each hit is weaker.", "extra_projectiles": 4, "spread": 0.34, "damage_more": -0.30, "mana_more": 0.32},
	"piercing_force": {"name": "Piercing Force", "color": "green", "tier": 1, "requires_any": ["projectile"], "description": "Projectiles pierce additional enemies.", "pierce": 2, "damage_more": 0.04},
	"chain_current": {"name": "Chain Current", "color": "blue", "tier": 1, "requires_any": ["projectile", "lightning"], "description": "Hits jump to nearby enemies.", "chain": 2, "damage_more": -0.08, "mana_more": 0.24},
	"returning_orbit": {"name": "Returning Orbit", "color": "green", "tier": 1, "requires_any": ["projectile"], "description": "Projectile skills get a second delayed hit in this prototype.", "echo_count": 1, "damage_more": -0.16, "mana_more": 0.18},
	"ignition": {"name": "Ignition", "color": "red", "tier": 1, "requires_any": ["fire"], "description": "Fire hits can ignite.", "ignite_chance": 0.55, "damage_more": 0.08},
	"searing_burst": {"name": "Searing Burst", "color": "red", "tier": 1, "requires_any": ["fire"], "description": "Fire kills and heavy hits reward area burst damage.", "on_hit_burst": 1, "area_more": 0.15, "damage_more": 0.12, "mana_more": 0.14},
	"shock_charge": {"name": "Shock Charge", "color": "blue", "tier": 1, "requires_any": ["lightning"], "description": "Lightning hits can shock and deal more chain damage.", "shock_chance": 0.50, "chain": 1, "damage_more": 0.06},
	"bleed_edge": {"name": "Bleed Edge", "color": "red", "tier": 1, "requires_any": ["attack", "physical"], "description": "Physical and attack hits can bleed.", "bleed_chance": 0.45, "damage_more": 0.10},
	"executioner": {"name": "Executioner", "color": "green", "tier": 1, "requires_any": ["skill"], "description": "Much stronger against low-health enemies.", "execute_more": 0.55},
	"echoing_ritual": {"name": "Echoing Ritual", "color": "blue", "tier": 1, "requires_any": ["spell"], "description": "Spell repeats once after the first hit in this prototype.", "echo_count": 1, "damage_more": -0.08, "mana_more": 0.22},
	"blood_price": {"name": "Blood Price", "color": "red", "tier": 1, "requires_any": ["skill"], "description": "Part of the cost is paid with life instead of mana. More damage.", "blood_price": 0.55, "damage_more": 0.22, "mana_more": -0.45},
	"minefield": {"name": "Minefield", "color": "green", "tier": 1, "requires_any": ["mine"], "description": "Throws extra mines with less damage each.", "extra_mines": 2, "damage_more": -0.22, "mana_more": 0.35},
	"remote_detonator": {"name": "Remote Detonator", "color": "blue", "tier": 1, "requires_any": ["mine"], "description": "Mine skills repeat their burst in this prototype.", "echo_count": 1, "damage_more": 0.08},
	"totem_fortify": {"name": "Totem Fortify", "color": "green", "tier": 1, "requires_any": ["totem"], "description": "Totem skills pulse longer and grant defensive flavor.", "extra_pulses": 2, "area_more": 0.12},
	"cooldown_focus": {"name": "Cooldown Focus", "color": "blue", "tier": 1, "requires_any": ["skill"], "description": "Reduces cooldown but raises cost.", "cooldown_more": -0.20, "mana_more": 0.18},
	"mana_leech": {"name": "Mana Leech", "color": "blue", "tier": 1, "requires_any": ["skill"], "description": "Hits recover some mana.", "mana_leech": 0.04, "damage_more": -0.04},
	"life_leech": {"name": "Life Leech", "color": "red", "tier": 1, "requires_any": ["attack", "physical"], "description": "Hits recover some life.", "life_leech": 0.035, "damage_more": -0.04},
	"relic_resonance": {"name": "Relic Resonance", "color": "green", "tier": 2, "requires_any": ["relic", "skill"], "description": "Adds relic scaling and small cooldown recovery.", "damage_more": 0.16, "cooldown_more": -0.08, "mana_more": 0.08},
	"spirit_pressure": {"name": "Spirit Pressure", "color": "blue", "tier": 2, "requires_any": ["persistent", "spirit", "skill"], "description": "Stronger effects while spirit is reserved.", "damage_more": 0.10, "mana_more": 0.05}
}

const SPIRIT_DATA: Dictionary = {
	"clarity": {"name": "Clarity", "color": "blue", "tags": ["spirit", "persistent", "mana"], "reservation": 20, "description": "Reserves spirit for mana sustain.", "stats": {"mana_regen": 3, "max_mana": 10}},
	"vitality": {"name": "Vitality", "color": "red", "tags": ["spirit", "persistent", "life"], "reservation": 25, "description": "Reserves spirit for life sustain.", "stats": {"health_regen": 2, "max_health": 18}},
	"iron_skin": {"name": "Iron Skin", "color": "green", "tags": ["spirit", "persistent", "guard"], "reservation": 25, "description": "Reserves spirit for armor.", "stats": {"armor": 18}},
	"ember_pact": {"name": "Ember Pact", "color": "red", "tags": ["spirit", "persistent", "fire"], "reservation": 30, "description": "Fire skills hit harder and ignite more often.", "stats": {"fire_damage": 18, "ignite_chance": 10}},
	"storm_rhythm": {"name": "Storm Rhythm", "color": "blue", "tags": ["spirit", "persistent", "lightning"], "reservation": 30, "description": "Lightning skills gain chain pressure.", "stats": {"lightning_damage": 15, "chain_bonus": 1}},
	"void_tithe": {"name": "Void Tithe", "color": "blue", "tags": ["spirit", "persistent", "void"], "reservation": 35, "description": "Void skills gain damage at a resource cost.", "stats": {"void_damage": 22, "mana_cost": 8}},
	"revenant_guard": {"name": "Revenant Guard", "color": "green", "tags": ["spirit", "persistent", "guard"], "reservation": 35, "description": "Defensive spirit for rough maps.", "stats": {"block_chance": 8, "armor": 14}},
	"execution_focus": {"name": "Execution Focus", "color": "green", "tags": ["spirit", "persistent", "execution"], "reservation": 25, "description": "More damage against injured enemies.", "stats": {"execute_more": 18}},
	"furnace_aegis": {"name": "Furnace Aegis", "color": "red", "tags": ["spirit", "persistent", "fire", "guard"], "reservation": 40, "description": "Gain armor and fire damage while any forge buff is active.", "stats": {"armor": 25, "fire_damage": 10}}
}

const META_DATA: Dictionary = {
	"cast_on_ignite": {"name": "Cast on Ignite", "color": "red", "tags": ["meta", "trigger", "fire", "spirit"], "reservation": 60, "description": "Prototype meta gem. Gains energy when you ignite enemies, then triggers a socketed skill later."},
	"cast_on_shock": {"name": "Cast on Shock", "color": "blue", "tags": ["meta", "trigger", "lightning", "spirit"], "reservation": 60, "description": "Prototype meta gem. Gains energy when you shock enemies."},
	"blood_retaliation": {"name": "Blood Retaliation", "color": "red", "tags": ["meta", "trigger", "blood", "guard"], "reservation": 50, "description": "Prototype meta gem. Gains energy when hit."}
}

static func ensure_defaults(state: Object) -> void:
	if state == null:
		return

	var equipped: Array = _as_array(_state_get(state, "equipped_skill_gems", []))
	var legacy_slots: Array = _as_array(_state_get(state, "active_skill_slots", []))

	if equipped.is_empty() and not legacy_slots.is_empty():
		for legacy_value: Variant in legacy_slots:
			if typeof(legacy_value) == TYPE_DICTIONARY:
				equipped.append(normalize_active(Dictionary(legacy_value)))

	while equipped.size() < EQUIPPED_GEM_ROWS:
		var next_index: int = equipped.size()
		if next_index < DEFAULT_ACTIVE_IDS.size():
			equipped.append(active_instance(str(DEFAULT_ACTIVE_IDS[next_index])))
		else:
			equipped.append({})

	for i: int in range(equipped.size()):
		if typeof(equipped[i]) == TYPE_DICTIONARY and not Dictionary(equipped[i]).is_empty():
			equipped[i] = normalize_active(Dictionary(equipped[i]))
		else:
			equipped[i] = {}

	state.set("equipped_skill_gems", equipped)

	var hotbar: Array = _as_array(_state_get(state, "hotbar_slots", []))
	while hotbar.size() < HOTBAR_SLOTS:
		var hotbar_index: int = hotbar.size()
		var uid_value: String = ""
		if hotbar_index < equipped.size() and typeof(equipped[hotbar_index]) == TYPE_DICTIONARY:
			uid_value = str(Dictionary(equipped[hotbar_index]).get("uid", ""))
		hotbar.append(uid_value)

	for h: int in range(hotbar.size()):
		if h >= HOTBAR_SLOTS:
			break
		var current_uid: String = str(hotbar[h])
		if current_uid == "" or _find_equipped_index_by_uid(equipped, current_uid) < 0:
			if h < equipped.size() and typeof(equipped[h]) == TYPE_DICTIONARY:
				hotbar[h] = str(Dictionary(equipped[h]).get("uid", ""))

	hotbar = hotbar.slice(0, HOTBAR_SLOTS)
	state.set("hotbar_slots", hotbar)

	var selected_hotbar: int = clampi(_to_int(_state_get(state, "selected_hotbar_slot", _state_get(state, "selected_skill_slot", 0))), 0, HOTBAR_SLOTS - 1)
	state.set("selected_hotbar_slot", selected_hotbar)
	state.set("selected_skill_slot", selected_hotbar)

	var selected_row: int = clampi(_to_int(_state_get(state, "selected_gem_row", selected_hotbar)), 0, EQUIPPED_GEM_ROWS - 1)
	state.set("selected_gem_row", selected_row)

	var spirits: Array = _as_array(_state_get(state, "spirit_gem_slots", []))
	for s_index: int in range(spirits.size()):
		if typeof(spirits[s_index]) == TYPE_DICTIONARY:
			spirits[s_index] = normalize_spirit(Dictionary(spirits[s_index]))
	state.set("spirit_gem_slots", spirits)

	if _state_get(state, "spirit_max", null) == null:
		state.set("spirit_max", 100)

	recompute_spirit_reservation(state)
	_sync_legacy_active_slots(state)

static func ensure_starter_gem_items(state: Object) -> void:
	if state == null:
		return
	ensure_defaults(state)
	if bool(_state_get(state, "gem_progression_seeded_v15", false)):
		return

	var backpack: Array = _as_array(_state_get(state, "backpack", []))
	backpack.append(make_uncut_gem_item(GEM_UNCUT_ACTIVE, 3))
	backpack.append(make_uncut_gem_item(GEM_UNCUT_ACTIVE, 5))
	backpack.append(make_uncut_gem_item(GEM_UNCUT_SUPPORT, 3))
	backpack.append(make_uncut_gem_item(GEM_UNCUT_SUPPORT, 5))
	backpack.append(make_uncut_gem_item(GEM_UNCUT_SPIRIT, 3))
	backpack.append(make_gem_item(GEM_SUPPORT, "split_projectile", 1, 0, 0))
	backpack.append(make_gem_item(GEM_SUPPORT, "chain_current", 1, 0, 0))
	backpack.append(make_gem_item(GEM_SUPPORT, "ignition", 1, 0, 0))
	backpack.append(make_gem_item(GEM_SPIRIT, "ember_pact", 1, 0, 0))
	state.set("backpack", backpack)
	state.set("gem_progression_seeded_v15", true)

static func active_instance(id: String, level: int = 1, xp: int = 0, quality: int = 0, supports: Array = []) -> Dictionary:
	return normalize_active({
		"uid": _uid("active", id),
		"kind": GEM_ACTIVE,
		"gem_id": id,
		"active": id,
		"active_id": id,
		"level": level,
		"xp": xp,
		"quality": quality,
		"support_sockets": supports
	})

static func support_instance(id: String, level: int = 1, xp: int = 0, quality: int = 0, tier: int = 1) -> Dictionary:
	return normalize_support({
		"uid": _uid("support", id),
		"kind": GEM_SUPPORT,
		"gem_id": id,
		"support_id": id,
		"level": level,
		"xp": xp,
		"quality": quality,
		"tier": tier
	})

static func spirit_instance(id: String, level: int = 1, xp: int = 0, quality: int = 0, enabled: bool = false, supports: Array = []) -> Dictionary:
	return normalize_spirit({
		"uid": _uid("spirit", id),
		"kind": GEM_SPIRIT,
		"gem_id": id,
		"spirit_id": id,
		"level": level,
		"xp": xp,
		"quality": quality,
		"enabled": enabled,
		"support_sockets": supports
	})

static func normalize_active(slot: Dictionary) -> Dictionary:
	var id: String = str(slot.get("gem_id", slot.get("active", slot.get("active_id", "fireball"))))
	if not ACTIVE_DATA.has(id):
		id = "fireball"

	var level: int = maxi(1, _to_int(slot.get("level", slot.get("gem_level", 1))))
	var xp: int = maxi(0, _to_int(slot.get("xp", slot.get("gem_xp", 0))))
	var quality: int = clampi(_to_int(slot.get("quality", slot.get("gem_quality", 0))), 0, 100)
	var uid: String = str(slot.get("uid", ""))
	if uid == "":
		uid = _uid("active", id)

	var supports: Array = []
	if slot.has("support_sockets"):
		supports = _normalize_support_socket_array(_as_array(slot.get("support_sockets", [])))
	else:
		supports = _normalize_support_socket_array(_as_array(slot.get("supports", [])))

	var socket_count: int = support_sockets_for_level(level)
	while supports.size() < socket_count:
		supports.append(null)
	if supports.size() > socket_count:
		supports = supports.slice(0, socket_count)

	var data: Dictionary = active_data(id)
	return {
		"uid": uid,
		"kind": GEM_ACTIVE,
		"gem_id": id,
		"active": id,
		"active_id": id,
		"level": level,
		"xp": xp,
		"quality": quality,
		"tags": _as_array(data.get("tags", [])),
		"required_level": _to_int(data.get("required_level", 1)),
		"requirements": Dictionary(data.get("requirements", {})),
		"weapon_requirements": _as_array(data.get("weapon_requirements", [])),
		"support_socket_count": socket_count,
		"support_sockets": supports,
		"unlocked_support_sockets": socket_count,
		"enabled": bool(slot.get("enabled", true))
	}

static func normalize_support_value(value: Variant) -> Dictionary:
	if typeof(value) == TYPE_DICTIONARY:
		return normalize_support(Dictionary(value))
	return support_instance(str(value), 1, 0, 0, 1)

static func normalize_support(support: Dictionary) -> Dictionary:
	var id: String = gem_id(support)
	if not SUPPORT_DATA.has(id):
		id = "controlled_power"
	var uid: String = str(support.get("uid", ""))
	if uid == "":
		uid = _uid("support", id)
	var data: Dictionary = support_data(id)
	return {
		"uid": uid,
		"kind": GEM_SUPPORT,
		"gem_id": id,
		"support_id": id,
		"tier": maxi(1, _to_int(support.get("tier", data.get("tier", 1)))),
		"level": maxi(1, _to_int(support.get("level", support.get("gem_level", 1)))),
		"xp": maxi(0, _to_int(support.get("xp", support.get("gem_xp", 0)))),
		"quality": clampi(_to_int(support.get("quality", support.get("gem_quality", 0))), 0, 100),
		"requires_any": _as_array(data.get("requires_any", [])),
		"forbids_any": _as_array(data.get("forbids_any", []))
	}

static func normalize_spirit(spirit: Dictionary) -> Dictionary:
	var id: String = str(spirit.get("gem_id", spirit.get("spirit_id", "clarity")))
	if not SPIRIT_DATA.has(id):
		id = "clarity"

	var level: int = maxi(1, _to_int(spirit.get("level", spirit.get("gem_level", 1))))
	var xp: int = maxi(0, _to_int(spirit.get("xp", spirit.get("gem_xp", 0))))
	var quality: int = clampi(_to_int(spirit.get("quality", spirit.get("gem_quality", 0))), 0, 100)
	var uid: String = str(spirit.get("uid", ""))
	if uid == "":
		uid = _uid("spirit", id)

	var supports: Array = []
	if spirit.has("support_sockets"):
		supports = _normalize_support_socket_array(_as_array(spirit.get("support_sockets", [])))
	else:
		supports = _normalize_support_socket_array(_as_array(spirit.get("supports", [])))

	var socket_count: int = support_sockets_for_level(level)
	while supports.size() < socket_count:
		supports.append(null)
	if supports.size() > socket_count:
		supports = supports.slice(0, socket_count)

	var data: Dictionary = spirit_data(id)
	return {
		"uid": uid,
		"kind": GEM_SPIRIT,
		"gem_id": id,
		"spirit_id": id,
		"enabled": bool(spirit.get("enabled", false)),
		"level": level,
		"xp": xp,
		"quality": quality,
		"tags": _as_array(data.get("tags", ["spirit", "persistent"])),
		"reservation": _reservation_for_spirit_id(id, level, quality, supports),
		"support_socket_count": socket_count,
		"support_sockets": supports,
		"unlocked_support_sockets": socket_count
	}

static func support_sockets_for_level(level: int) -> int:
	var safe_level: int = maxi(1, level)
	var gained: int = int(floor(float(safe_level) / float(SOCKET_LEVEL_INTERVAL)))
	return clampi(STARTING_SUPPORT_SOCKETS + gained, STARTING_SUPPORT_SOCKETS, MAX_SUPPORT_SOCKETS)

static func selected_cast_data(state: Object) -> Dictionary:
	if state == null:
		return {}
	ensure_defaults(state)
	var active: Dictionary = selected_active_gem(state)
	if active.is_empty():
		return {}
	return build_cast_data(state, active, _to_int(_state_get(state, "selected_hotbar_slot", _state_get(state, "selected_skill_slot", 0))))

static func selected_active_gem(state: Object) -> Dictionary:
	if state == null:
		return {}
	var equipped: Array = _as_array(_state_get(state, "equipped_skill_gems", []))
	var hotbar: Array = _as_array(_state_get(state, "hotbar_slots", []))
	var selected: int = clampi(_to_int(_state_get(state, "selected_hotbar_slot", _state_get(state, "selected_skill_slot", 0))), 0, max(0, hotbar.size() - 1))
	if selected >= hotbar.size():
		return {}
	var uid_value: String = str(hotbar[selected])
	var index: int = _find_equipped_index_by_uid(equipped, uid_value)
	if index < 0:
		index = clampi(selected, 0, max(0, equipped.size() - 1))
	if index < 0 or index >= equipped.size() or typeof(equipped[index]) != TYPE_DICTIONARY:
		return {}
	return normalize_active(Dictionary(equipped[index]))

static func build_cast_data(state: Object, active: Dictionary, selected_slot: int = 0) -> Dictionary:
	var id: String = str(active.get("gem_id", "fireball"))
	var data: Dictionary = active_data(id)
	var tags: Array = _as_array(data.get("tags", [])).duplicate(true)
	var level: int = maxi(1, _to_int(active.get("level", 1)))
	var quality: int = clampi(_to_int(active.get("quality", 0)), 0, 100)
	var damage: float = _to_float(data.get("damage", 10.0)) * (1.0 + float(level - 1) * 0.13) * (1.0 + float(quality) * 0.01)
	var mana_cost: float = _to_float(data.get("mana", 8.0)) * (1.0 + float(level - 1) * 0.035)
	var cooldown: float = _to_float(data.get("cooldown", 0.25))
	var area_mult: float = 1.0
	var extra_projectiles: int = 0
	var spread: float = 0.0
	var pierce: int = _to_int(data.get("pierce", 0))
	var chain: int = _to_int(data.get("chain", 0))
	var echo_count: int = 0
	var extra_mines: int = 0
	var extra_pulses: int = _to_int(data.get("pulses", 1)) - 1
	var ignite_chance: float = 0.0
	var shock_chance: float = 0.0
	var bleed_chance: float = 0.0
	var execute_more: float = 0.0
	var life_leech: float = 0.0
	var mana_leech: float = 0.0
	var blood_price: float = 0.0
	var on_hit_burst: bool = false
	var support_names: Array = []
	var applied_supports: Array = []

	for support_value: Variant in _as_array(active.get("support_sockets", [])):
		if typeof(support_value) != TYPE_DICTIONARY:
			continue
		var support: Dictionary = normalize_support(Dictionary(support_value))
		if not is_support_compatible(active, support):
			continue
		var sid: String = str(support.get("gem_id", ""))
		var sdata: Dictionary = support_data(sid)
		var slevel: int = maxi(1, _to_int(support.get("level", 1)))
		var squality: int = clampi(_to_int(support.get("quality", 0)), 0, 100)
		var stier: int = maxi(1, _to_int(support.get("tier", sdata.get("tier", 1))))
		var support_scale: float = 1.0 + float(slevel - 1) * 0.035 + float(squality) * 0.006 + float(stier - 1) * 0.08

		damage *= maxf(0.05, 1.0 + _to_float(sdata.get("damage_more", 0.0)) * support_scale)
		mana_cost *= maxf(0.05, 1.0 + _to_float(sdata.get("mana_more", 0.0)) * support_scale)
		cooldown *= maxf(0.05, 1.0 + _to_float(sdata.get("cooldown_more", 0.0)) * support_scale)
		area_mult *= maxf(0.20, 1.0 + _to_float(sdata.get("area_more", 0.0)) * support_scale)
		extra_projectiles += _to_int(sdata.get("extra_projectiles", 0))
		spread = maxf(spread, _to_float(sdata.get("spread", 0.0)))
		pierce += _to_int(sdata.get("pierce", 0))
		chain += _to_int(sdata.get("chain", 0))
		echo_count += _to_int(sdata.get("echo_count", 0))
		extra_mines += _to_int(sdata.get("extra_mines", 0))
		extra_pulses += _to_int(sdata.get("extra_pulses", 0))
		ignite_chance += _to_float(sdata.get("ignite_chance", 0.0)) * support_scale
		shock_chance += _to_float(sdata.get("shock_chance", 0.0)) * support_scale
		bleed_chance += _to_float(sdata.get("bleed_chance", 0.0)) * support_scale
		execute_more += _to_float(sdata.get("execute_more", 0.0)) * support_scale
		life_leech += _to_float(sdata.get("life_leech", 0.0)) * support_scale
		mana_leech += _to_float(sdata.get("mana_leech", 0.0)) * support_scale
		blood_price = maxf(blood_price, _to_float(sdata.get("blood_price", 0.0)))
		on_hit_burst = on_hit_burst or _to_int(sdata.get("on_hit_burst", 0)) > 0
		support_names.append(str(sdata.get("name", sid.capitalize())))
		applied_supports.append(sid)

	var stat_mult: float = _build_stat_damage_multiplier(state, tags)
	damage *= stat_mult
	var spirit_stats: Dictionary = spirit_total_stats(state)
	if tags.has("fire"):
		damage *= 1.0 + _to_float(spirit_stats.get("fire_damage", 0.0)) * 0.01
		ignite_chance += _to_float(spirit_stats.get("ignite_chance", 0.0)) * 0.01
	if tags.has("lightning"):
		damage *= 1.0 + _to_float(spirit_stats.get("lightning_damage", 0.0)) * 0.01
		chain += _to_int(spirit_stats.get("chain_bonus", 0))
	if tags.has("void"):
		damage *= 1.0 + _to_float(spirit_stats.get("void_damage", 0.0)) * 0.01
		mana_cost *= 1.0 + _to_float(spirit_stats.get("mana_cost", 0.0)) * 0.01
	if tags.has("attack"):
		damage *= 1.0 + _stat_percent(state, "attack_damage")
	if tags.has("spell"):
		damage *= 1.0 + _stat_percent(state, "spell_damage")
	if tags.has("projectile"):
		damage *= 1.0 + _stat_percent(state, "projectile_damage")

	mana_cost = maxf(0.0, mana_cost)
	var life_cost: float = 0.0
	if blood_price > 0.0:
		life_cost = mana_cost * blood_price
		mana_cost = mana_cost * (1.0 - blood_price)

	return {
		"name": str(data.get("name", id.capitalize())),
		"uid": str(active.get("uid", "")),
		"active_id": id,
		"gem_id": id,
		"selected_slot": selected_slot,
		"level": level,
		"quality": quality,
		"tags": tags,
		"damage": damage,
		"mana_cost": mana_cost,
		"life_cost": life_cost,
		"cooldown": cooldown,
		"range": _to_float(data.get("range", 8.0)),
		"radius": _to_float(data.get("radius", 0.4)),
		"base_area": _to_float(data.get("area", 1.0)),
		"area_mult": area_mult,
		"projectile_speed": _to_float(data.get("projectile_speed", 13.0)),
		"extra_projectiles": extra_projectiles,
		"projectile_count": 1 + extra_projectiles,
		"spread": spread,
		"pierce": pierce,
		"chain": chain,
		"echo_count": echo_count,
		"extra_mines": extra_mines,
		"extra_pulses": extra_pulses,
		"support_socket_count": _to_int(active.get("support_socket_count", support_sockets_for_level(level))),
		"rules": {
			"ignite_chance": clampf(ignite_chance, 0.0, 1.0),
			"shock_chance": clampf(shock_chance, 0.0, 1.0),
			"bleed_chance": clampf(bleed_chance, 0.0, 1.0),
			"execute_more": maxf(0.0, execute_more),
			"life_leech": maxf(0.0, life_leech),
			"mana_leech": maxf(0.0, mana_leech),
			"on_hit_burst": on_hit_burst,
			"applied_supports": applied_supports
		},
		"support_names": support_names
	}

static func cycle_active_slot_gem(state: Object, dir: int) -> void:
	if state == null:
		return
	ensure_defaults(state)
	var equipped: Array = _as_array(_state_get(state, "equipped_skill_gems", []))
	var selected_row: int = _selected_equipped_row_from_hotbar(state, equipped)
	if selected_row < 0 or selected_row >= equipped.size():
		return
	var active: Dictionary = normalize_active(Dictionary(equipped[selected_row]))
	var id: String = str(active.get("gem_id", "fireball"))
	var order_index: int = ACTIVE_ORDER.find(id)
	if order_index < 0:
		order_index = 0
	var next_id: String = str(ACTIVE_ORDER[wrapi(order_index + dir, 0, ACTIVE_ORDER.size())])
	var existing_supports: Array = _as_array(active.get("support_sockets", []))
	active = active_instance(next_id, _to_int(active.get("level", 1)), _to_int(active.get("xp", 0)), _to_int(active.get("quality", 0)), existing_supports)
	active["support_sockets"] = _filter_compatible_supports(active, existing_supports)
	equipped[selected_row] = normalize_active(active)
	state.set("equipped_skill_gems", equipped)
	_sync_legacy_active_slots(state)
	_add_notice(state, "Skill row " + str(selected_row + 1) + ": " + str(active_data(next_id).get("name", next_id)))

static func add_next_valid_support(state: Object) -> void:
	if state == null:
		return
	ensure_defaults(state)
	var equipped: Array = _as_array(_state_get(state, "equipped_skill_gems", []))
	var selected_row: int = _selected_equipped_row_from_hotbar(state, equipped)
	if selected_row < 0 or selected_row >= equipped.size():
		return
	var active: Dictionary = normalize_active(Dictionary(equipped[selected_row]))
	var supports: Array = _as_array(active.get("support_sockets", []))
	var free_index: int = _first_empty_socket_index(supports)
	if free_index < 0:
		_add_notice(state, "No empty support socket. Level this gem for more sockets.")
		return

	for support_id: String in SUPPORT_ORDER:
		if _support_list_has(supports, support_id):
			continue
		var candidate: Dictionary = support_instance(support_id, 1, 0, 0, _to_int(support_data(support_id).get("tier", 1)))
		if is_support_compatible(active, candidate):
			supports[free_index] = candidate
			active["support_sockets"] = supports
			equipped[selected_row] = normalize_active(active)
			state.set("equipped_skill_gems", equipped)
			_sync_legacy_active_slots(state)
			_add_notice(state, "Socketed " + support_display_name(candidate) + " into " + active_display_name(active) + ".")
			return

	_add_notice(state, "No compatible support found for " + active_display_name(active) + ".")

static func remove_last_support(state: Object) -> void:
	if state == null:
		return
	ensure_defaults(state)
	var equipped: Array = _as_array(_state_get(state, "equipped_skill_gems", []))
	var selected_row: int = _selected_equipped_row_from_hotbar(state, equipped)
	if selected_row < 0 or selected_row >= equipped.size():
		return
	var active: Dictionary = normalize_active(Dictionary(equipped[selected_row]))
	var supports: Array = _as_array(active.get("support_sockets", []))
	for i: int in range(supports.size() - 1, -1, -1):
		if typeof(supports[i]) == TYPE_DICTIONARY:
			var removed: Dictionary = normalize_support(Dictionary(supports[i]))
			supports[i] = null
			active["support_sockets"] = supports
			equipped[selected_row] = normalize_active(active)
			state.set("equipped_skill_gems", equipped)
			_sync_legacy_active_slots(state)
			_add_notice(state, "Removed " + support_display_name(removed) + ".")
			return
	_add_notice(state, "No support to remove.")

static func toggle_next_spirit(state: Object) -> void:
	if state == null:
		return
	ensure_defaults(state)
	var spirits: Array = _as_array(_state_get(state, "spirit_gem_slots", []))
	if spirits.is_empty():
		for id: String in ["clarity", "vitality", "ember_pact"]:
			spirits.append(spirit_instance(id, 1, 0, 0, false, []))
	var cursor: int = wrapi(_to_int(_state_get(state, "spirit_cursor", 0)), 0, spirits.size())
	var spirit: Dictionary = normalize_spirit(Dictionary(spirits[cursor]))
	var was_enabled: bool = bool(spirit.get("enabled", false))
	spirit["enabled"] = not was_enabled
	spirits[cursor] = normalize_spirit(spirit)
	state.set("spirit_gem_slots", spirits)
	recompute_spirit_reservation(state)
	if _to_int(_state_get(state, "spirit_reserved", 0)) > _to_int(_state_get(state, "spirit_max", 100)):
		spirit["enabled"] = false
		spirits[cursor] = normalize_spirit(spirit)
		state.set("spirit_gem_slots", spirits)
		recompute_spirit_reservation(state)
		_add_notice(state, "Not enough Spirit to enable " + spirit_display_name(spirit) + ".")
	else:
		_add_notice(state, ("Enabled " if bool(spirit.get("enabled", false)) else "Disabled ") + spirit_display_name(spirit) + ".")
	state.set("spirit_cursor", wrapi(cursor + 1, 0, spirits.size()))

static func assign_selected_row_to_hotbar(state: Object, hotbar_slot: int) -> void:
	if state == null:
		return
	ensure_defaults(state)
	var equipped: Array = _as_array(_state_get(state, "equipped_skill_gems", []))
	var row: int = clampi(_to_int(_state_get(state, "selected_gem_row", 0)), 0, max(0, equipped.size() - 1))
	if row >= equipped.size() or typeof(equipped[row]) != TYPE_DICTIONARY or Dictionary(equipped[row]).is_empty():
		_add_notice(state, "No active gem in selected row.")
		return
	var hotbar: Array = _as_array(_state_get(state, "hotbar_slots", []))
	while hotbar.size() < HOTBAR_SLOTS:
		hotbar.append("")
	var clamped_slot: int = clampi(hotbar_slot, 0, HOTBAR_SLOTS - 1)
	hotbar[clamped_slot] = str(Dictionary(equipped[row]).get("uid", ""))
	state.set("hotbar_slots", hotbar)
	state.set("selected_hotbar_slot", clamped_slot)
	state.set("selected_skill_slot", clamped_slot)
	_sync_legacy_active_slots(state)
	_add_notice(state, "Bound " + active_display_name(Dictionary(equipped[row])) + " to hotbar " + str(clamped_slot + 1) + ".")

static func carve_first_uncut(state: Object, target_kind: String = GEM_ACTIVE) -> String:
	if state == null:
		return "No state."
	ensure_defaults(state)
	var backpack: Array = _as_array(_state_get(state, "backpack", []))
	var wanted: String = _uncut_kind_for_target(target_kind)
	for i: int in range(backpack.size()):
		if typeof(backpack[i]) != TYPE_DICTIONARY:
			continue
		var item: Dictionary = Dictionary(backpack[i])
		if str(item.get("gem_type", item.get("skill_gem_type", ""))) != wanted and str(item.get("kind", "")) != wanted:
			continue
		var level: int = maxi(1, _to_int(item.get("gem_level", item.get("level", 1))))
		backpack.remove_at(i)
		state.set("backpack", backpack)
		if target_kind == GEM_ACTIVE:
			var active_id: String = _recommended_active_for_state(state)
			_install_active_to_selected_row(state, active_instance(active_id, level, 0, 0, []))
			_add_notice(state, "Carved Uncut Skill Gem into " + str(active_data(active_id).get("name", active_id)) + ".")
			return "Carved active gem."
		elif target_kind == GEM_SUPPORT:
			var support_id: String = _recommended_support_for_selected(state)
			_socket_support_into_selected(state, support_instance(support_id, level, 0, 0, _to_int(support_data(support_id).get("tier", 1))))
			_add_notice(state, "Carved Uncut Support Gem into " + str(support_data(support_id).get("name", support_id)) + ".")
			return "Carved support gem."
		else:
			var spirit_id: String = _recommended_spirit_for_state(state)
			var spirits: Array = _as_array(_state_get(state, "spirit_gem_slots", []))
			spirits.append(spirit_instance(spirit_id, level, 0, 0, false, []))
			state.set("spirit_gem_slots", spirits)
			recompute_spirit_reservation(state)
			_add_notice(state, "Carved Uncut Spirit Gem into " + str(spirit_data(spirit_id).get("name", spirit_id)) + ".")
			return "Carved spirit gem."
	_add_notice(state, "No matching uncut gem found.")
	return "No matching uncut gem."

static func award_selected_active_xp(state: Object, amount: int) -> void:
	if state == null:
		return
	ensure_defaults(state)
	var equipped: Array = _as_array(_state_get(state, "equipped_skill_gems", []))
	var selected_row: int = _selected_equipped_row_from_hotbar(state, equipped)
	if selected_row < 0 or selected_row >= equipped.size() or typeof(equipped[selected_row]) != TYPE_DICTIONARY:
		return
	var active: Dictionary = normalize_active(Dictionary(equipped[selected_row]))
	var level: int = _to_int(active.get("level", 1))
	var xp: int = _to_int(active.get("xp", 0)) + maxi(0, amount)
	var old_sockets: int = support_sockets_for_level(level)
	var leveled: bool = false
	while xp >= xp_to_next(level):
		xp -= xp_to_next(level)
		level += 1
		leveled = true
	active["level"] = level
	active["xp"] = xp
	active = normalize_active(active)
	equipped[selected_row] = active
	state.set("equipped_skill_gems", equipped)
	_sync_legacy_active_slots(state)
	if leveled:
		var msg: String = active_display_name(active) + " reached level " + str(level) + "."
		if support_sockets_for_level(level) > old_sockets:
			msg += " New support socket unlocked."
		_add_notice(state, msg)

static func award_all_enabled_gem_xp(state: Object, amount: int) -> void:
	if state == null:
		return
	ensure_defaults(state)
	var equipped: Array = _as_array(_state_get(state, "equipped_skill_gems", []))
	for i: int in range(equipped.size()):
		if typeof(equipped[i]) != TYPE_DICTIONARY or Dictionary(equipped[i]).is_empty():
			continue
		var active: Dictionary = normalize_active(Dictionary(equipped[i]))
		active["xp"] = _to_int(active.get("xp", 0)) + maxi(0, amount)
		equipped[i] = normalize_active(active)
	state.set("equipped_skill_gems", equipped)
	_sync_legacy_active_slots(state)

static func roll_gem_drop_to_backpack(state: Object, force: bool = false) -> bool:
	if state == null:
		return false
	var rng: RandomNumberGenerator = _rng(state)
	if not force and rng.randf() > 0.18:
		return false
	var roll: float = rng.randf()
	var level: int = maxi(1, _to_int(_state_get(state, "level", 1)) + rng.randi_range(-1, 2))
	var backpack: Array = _as_array(_state_get(state, "backpack", []))
	if roll < 0.52:
		backpack.append(make_uncut_gem_item(GEM_UNCUT_ACTIVE, level))
	elif roll < 0.82:
		backpack.append(make_uncut_gem_item(GEM_UNCUT_SUPPORT, level))
	else:
		backpack.append(make_uncut_gem_item(GEM_UNCUT_SPIRIT, level))
	state.set("backpack", backpack)
	_add_notice(state, "Uncut gem found.")
	return true

static func make_uncut_gem_item(kind: String, level: int = 1) -> Dictionary:
	var name_text: String = "Uncut Skill Gem"
	if kind == GEM_UNCUT_SUPPORT:
		name_text = "Uncut Support Gem"
	elif kind == GEM_UNCUT_SPIRIT:
		name_text = "Uncut Spirit Gem"
	return {
		"id": _uid(kind, "core"),
		"uid": _uid(kind, "core"),
		"base_id": kind,
		"name": name_text,
		"display_name": name_text + " Lv." + str(maxi(1, level)),
		"kind": kind,
		"item_kind": kind,
		"category": "skill_gem",
		"slot": kind,
		"rarity": "magic",
		"gem_type": kind,
		"skill_gem_type": kind,
		"gem_level": maxi(1, level),
		"level": maxi(1, level),
		"quality": 0,
		"identified": true,
		"grid_w": 1,
		"grid_h": 1,
		"tags": ["gem", "uncut", kind],
		"detail_text": name_text + "\nChoose what to carve at the Gem Bench.\nCreates a level " + str(maxi(1, level)) + " gem."
	}

static func make_gem_item(type: String, id: String, level: int = 1, xp: int = 0, quality: int = 0, supports: Array = []) -> Dictionary:
	var data: Dictionary = gem_data(type, id)
	var kind: String = type + "_gem"
	return {
		"id": _uid(kind, id),
		"uid": _uid(kind, id),
		"base_id": id,
		"gem_id": id,
		"name": str(data.get("name", id.capitalize())),
		"display_name": str(data.get("name", id.capitalize())),
		"kind": kind,
		"item_kind": kind,
		"category": "skill_gem",
		"slot": kind,
		"rarity": "magic",
		"gem_type": type,
		"skill_gem_type": type,
		"base_color": str(data.get("color", "blue")),
		"gem_color": str(data.get("color", "blue")),
		"level": maxi(1, level),
		"gem_level": maxi(1, level),
		"xp": maxi(0, xp),
		"gem_xp": maxi(0, xp),
		"quality": clampi(quality, 0, 100),
		"gem_quality": clampi(quality, 0, 100),
		"support_sockets": supports.duplicate(true),
		"supports": supports.duplicate(true),
		"tags": ["gem", kind, type],
		"grid_w": 1,
		"grid_h": 1,
		"identified": true,
		"detail_text": gem_detail_text({"gem_type": type, "gem_id": id, "level": level, "xp": xp, "quality": quality, "support_sockets": supports})
	}

static func make_gem_item_from_drop(drop_kind: String, gem_id_value: String) -> Dictionary:
	var kind_text: String = str(drop_kind)
	if kind_text.find("uncut") >= 0:
		return make_uncut_gem_item(kind_text.replace("_gem", ""), 1)
	var type: String = GEM_SUPPORT
	match kind_text:
		"active_gem":
			type = GEM_ACTIVE
		"support_gem":
			type = GEM_SUPPORT
		"spirit_gem":
			type = GEM_SPIRIT
		_:
			type = kind_text.replace("_gem", "")
	return make_gem_item(type, gem_id_value)

static func panel_text(state: Object) -> String:
	ensure_defaults(state)
	var lines: PackedStringArray = PackedStringArray()
	var equipped: Array = _as_array(_state_get(state, "equipped_skill_gems", []))
	var hotbar: Array = _as_array(_state_get(state, "hotbar_slots", []))
	var selected_hotbar: int = clampi(_to_int(_state_get(state, "selected_hotbar_slot", _state_get(state, "selected_skill_slot", 0))), 0, HOTBAR_SLOTS - 1)
	lines.append("SKILL GEM PAGE")
	lines.append("9 equipped skill rows · 5 hotbar bindings · sockets from gem levels: 2 base, +1 every 5 levels, max 6")
	lines.append("1-5 select hotbar · A/D change selected skill · S add support · W remove support · G toggle spirit")
	lines.append("Y carve uncut skill · T carve uncut support · B carve uncut spirit")
	lines.append("")
	lines.append("HOTBAR")
	for h: int in range(min(HOTBAR_SLOTS, hotbar.size())):
		var uid_value: String = str(hotbar[h])
		var row_index: int = _find_equipped_index_by_uid(equipped, uid_value)
		var label: String = "Empty"
		if row_index >= 0 and typeof(equipped[row_index]) == TYPE_DICTIONARY:
			label = active_display_name(Dictionary(equipped[row_index])) + " Row " + str(row_index + 1)
		lines.append(("> " if h == selected_hotbar else "  ") + str(h + 1) + ". " + label)
	lines.append("")
	lines.append("EQUIPPED GEM ROWS")
	for i: int in range(equipped.size()):
		if typeof(equipped[i]) != TYPE_DICTIONARY or Dictionary(equipped[i]).is_empty():
			lines.append("  " + str(i + 1) + ". Empty")
			continue
		var active: Dictionary = normalize_active(Dictionary(equipped[i]))
		var supports: Array = _as_array(active.get("support_sockets", []))
		lines.append("  " + str(i + 1) + ". " + active_display_name(active) + " Lv" + str(active.get("level", 1)) + " · Sockets " + str(_filled_socket_count(supports)) + "/" + str(supports.size()))
		lines.append("     Tags: " + ", ".join(_as_string_array(active.get("tags", []))))
		lines.append("     Supports: " + _support_socket_text(supports))
	lines.append("")
	lines.append("SPIRIT")
	lines.append("Reserved: " + str(_to_int(_state_get(state, "spirit_reserved", 0))) + "/" + str(_to_int(_state_get(state, "spirit_max", 100))))
	var spirits: Array = _as_array(_state_get(state, "spirit_gem_slots", []))
	if spirits.is_empty():
		lines.append("  No spirit gems installed.")
	else:
		for spirit_value: Variant in spirits:
			if typeof(spirit_value) != TYPE_DICTIONARY:
				continue
			var spirit: Dictionary = normalize_spirit(Dictionary(spirit_value))
			lines.append("  " + ("ON" if bool(spirit.get("enabled", false)) else "off") + " · " + spirit_display_name(spirit) + " Lv" + str(spirit.get("level", 1)) + " · reserves " + str(spirit.get("reservation", 0)) + " · sockets " + str(_filled_socket_count(_as_array(spirit.get("support_sockets", [])))) + "/" + str(spirit.get("support_socket_count", 2)))
	return "\n".join(lines)

static func is_support_compatible(active: Dictionary, support: Dictionary) -> bool:
	var active_id: String = str(active.get("gem_id", active.get("active_id", "")))
	var adata: Dictionary = active_data(active_id)
	var active_tags: Array = _as_array(adata.get("tags", active.get("tags", [])))
	var sid: String = str(support.get("gem_id", support.get("support_id", "")))
	if not SUPPORT_DATA.has(sid):
		return false
	var sdata: Dictionary = support_data(sid)
	var forbids_any: Array = _as_array(sdata.get("forbids_any", []))
	for forbidden: Variant in forbids_any:
		if active_tags.has(str(forbidden)):
			return false
	var requires_any: Array = _as_array(sdata.get("requires_any", []))
	if requires_any.is_empty():
		return true
	for tag_value: Variant in requires_any:
		if active_tags.has(str(tag_value)):
			return true
	return false

static func install_active_from_inventory(state: Object, backpack_index: int, slot_index: int) -> String:
	if state == null:
		return "No state."
	ensure_defaults(state)
	var backpack: Array = _as_array(_state_get(state, "backpack", []))
	if backpack_index < 0 or backpack_index >= backpack.size() or typeof(backpack[backpack_index]) != TYPE_DICTIONARY:
		return "No active gem selected."
	var item: Dictionary = Dictionary(backpack[backpack_index])
	if gem_type(item) != GEM_ACTIVE:
		return "That is not an active gem."
	var incoming: Dictionary = active_instance(gem_id(item), _to_int(item.get("level", item.get("gem_level", 1))), _to_int(item.get("xp", item.get("gem_xp", 0))), _to_int(item.get("quality", item.get("gem_quality", 0))), _as_array(item.get("support_sockets", item.get("supports", []))))
	backpack.remove_at(backpack_index)
	state.set("backpack", backpack)
	_install_active_to_row(state, incoming, slot_index)
	return "Installed active gem into row " + str(slot_index + 1) + "."

static func install_support_from_inventory_to_active(state: Object, backpack_index: int, active_index: int) -> String:
	if state == null:
		return "No state."
	ensure_defaults(state)
	var backpack: Array = _as_array(_state_get(state, "backpack", []))
	if backpack_index < 0 or backpack_index >= backpack.size() or typeof(backpack[backpack_index]) != TYPE_DICTIONARY:
		return "No support gem selected."
	var item: Dictionary = Dictionary(backpack[backpack_index])
	if gem_type(item) != GEM_SUPPORT:
		return "That is not a support gem."
	var support: Dictionary = support_instance(gem_id(item), _to_int(item.get("level", item.get("gem_level", 1))), _to_int(item.get("xp", item.get("gem_xp", 0))), _to_int(item.get("quality", item.get("gem_quality", 0))), _to_int(item.get("tier", 1)))
	var result: String = _socket_support_into_row(state, support, active_index)
	if result.begins_with("Socketed"):
		backpack.remove_at(backpack_index)
		state.set("backpack", backpack)
	return result

static func install_spirit_from_inventory(state: Object, backpack_index: int) -> String:
	if state == null:
		return "No state."
	ensure_defaults(state)
	var backpack: Array = _as_array(_state_get(state, "backpack", []))
	if backpack_index < 0 or backpack_index >= backpack.size() or typeof(backpack[backpack_index]) != TYPE_DICTIONARY:
		return "No spirit gem selected."
	var item: Dictionary = Dictionary(backpack[backpack_index])
	if gem_type(item) != GEM_SPIRIT:
		return "That is not a spirit gem."
	var spirits: Array = _as_array(_state_get(state, "spirit_gem_slots", []))
	spirits.append(spirit_instance(gem_id(item), _to_int(item.get("level", item.get("gem_level", 1))), _to_int(item.get("xp", item.get("gem_xp", 0))), _to_int(item.get("quality", item.get("gem_quality", 0))), false, _as_array(item.get("support_sockets", item.get("supports", [])))))
	backpack.remove_at(backpack_index)
	state.set("backpack", backpack)
	state.set("spirit_gem_slots", spirits)
	recompute_spirit_reservation(state)
	return "Installed spirit gem disabled."

static func install_support_from_inventory_to_spirit(state: Object, backpack_index: int, spirit_index: int) -> String:
	return "Spirit support socketing is scaffolded; use active supports first."

static func gem_type(item: Dictionary) -> String:
	var explicit: String = str(item.get("gem_type", item.get("skill_gem_type", ""))).to_lower()
	if explicit in [GEM_ACTIVE, GEM_SUPPORT, GEM_SPIRIT, GEM_META, GEM_UNCUT_ACTIVE, GEM_UNCUT_SUPPORT, GEM_UNCUT_SPIRIT]:
		return explicit
	var kind: String = str(item.get("kind", item.get("item_kind", item.get("category", "")))).to_lower()
	if kind == "active_gem" or kind == "active_skill_gem":
		return GEM_ACTIVE
	if kind == "support_gem":
		return GEM_SUPPORT
	if kind == "spirit_gem":
		return GEM_SPIRIT
	if kind == GEM_UNCUT_ACTIVE or kind == "uncut_skill_gem":
		return GEM_UNCUT_ACTIVE
	if kind == GEM_UNCUT_SUPPORT or kind == "uncut_support_gem":
		return GEM_UNCUT_SUPPORT
	if kind == GEM_UNCUT_SPIRIT or kind == "uncut_spirit_gem":
		return GEM_UNCUT_SPIRIT
	return ""

static func gem_id(d: Dictionary) -> String:
	for key: String in ["gem_id", "active_id", "support_id", "spirit_id", "base_id", "id"]:
		var value: String = str(d.get(key, ""))
		if value != "":
			if value.begins_with("gem_") and d.has("base_id"):
				return str(d.get("base_id", value))
			return value
	return str(d.get("name", "unknown_gem")).to_lower().replace(" ", "_")

static func gem_data(type: String, id: String) -> Dictionary:
	match type:
		GEM_ACTIVE:
			return active_data(id)
		GEM_SUPPORT:
			return support_data(id)
		GEM_SPIRIT:
			return spirit_data(id)
		GEM_META:
			return meta_data(id)
		_:
			return {"name": id.capitalize(), "color": "blue", "tags": []}

static func active_data(id: String) -> Dictionary:
	return Dictionary(ACTIVE_DATA.get(id, {"name": id.capitalize(), "color": "red", "tags": ["skill"], "damage": 10.0, "mana": 5.0, "cooldown": 0.25, "requirements": {}, "weapon_requirements": []}))

static func support_data(id: String) -> Dictionary:
	return Dictionary(SUPPORT_DATA.get(id, {"name": id.capitalize() + " Support", "color": "green", "requires_any": ["skill"], "description": "Generic support.", "tier": 1}))

static func spirit_data(id: String) -> Dictionary:
	return Dictionary(SPIRIT_DATA.get(id, {"name": id.capitalize(), "color": "blue", "tags": ["spirit", "persistent"], "reservation": 25, "description": "Spirit reservation.", "stats": {}}))

static func meta_data(id: String) -> Dictionary:
	return Dictionary(META_DATA.get(id, {"name": id.capitalize(), "color": "blue", "tags": ["meta", "trigger"], "reservation": 50, "description": "Meta gem scaffold."}))

static func gem_detail_text(d: Dictionary, assumed_type: String = "") -> String:
	var type: String = assumed_type if assumed_type != "" else gem_type(d)
	if type == "":
		type = str(d.get("gem_type", GEM_SUPPORT))
	if type in [GEM_UNCUT_ACTIVE, GEM_UNCUT_SUPPORT, GEM_UNCUT_SPIRIT]:
		return str(d.get("display_name", "Uncut Gem")) + "\nCarve at the Gem Bench.\nCreates a level " + str(_to_int(d.get("gem_level", d.get("level", 1)))) + " gem."
	var id: String = gem_id(d)
	var data: Dictionary = gem_data(type, id)
	var level: int = maxi(1, _to_int(d.get("level", d.get("gem_level", 1))))
	var xp: int = maxi(0, _to_int(d.get("xp", d.get("gem_xp", 0))))
	var quality: int = clampi(_to_int(d.get("quality", d.get("gem_quality", 0))), 0, 100)
	var lines: PackedStringArray = PackedStringArray()
	lines.append(str(data.get("name", id.capitalize())) + " [" + type.capitalize() + " Gem]")
	lines.append("Level " + str(level) + " · XP " + str(xp) + "/" + str(xp_to_next(level)) + " · Quality +" + str(quality) + "%")
	if type == GEM_ACTIVE:
		lines.append("Tags: " + ", ".join(_as_string_array(data.get("tags", []))))
		lines.append(str(data.get("description", "")))
		lines.append("Support sockets: " + str(support_sockets_for_level(level)) + "/" + str(MAX_SUPPORT_SOCKETS))
	elif type == GEM_SUPPORT:
		lines.append("Requires: " + ", ".join(_as_string_array(data.get("requires_any", []))))
		lines.append(str(data.get("description", "")))
	elif type == GEM_SPIRIT:
		lines.append("Reserves " + str(_to_int(data.get("reservation", 25))) + " Spirit")
		lines.append("Support sockets: " + str(support_sockets_for_level(level)) + "/" + str(MAX_SUPPORT_SOCKETS))
		lines.append(str(data.get("description", "")))
	else:
		lines.append(str(data.get("description", "")))
	return "\n".join(lines)

static func collect_spirit_bundle(state: Object) -> Dictionary:
	if state == null:
		return {"stats": {}, "rules": [], "reserved": 0}
	ensure_defaults(state)
	var raw_stats: Dictionary = spirit_total_stats(state)
	var stats: Dictionary = {}
	var rules: Array = []
	for key: Variant in raw_stats.keys():
		var k: String = str(key)
		var v: float = _to_float(raw_stats[key])
		stats[k] = v
		match k:
			"max_health":
				stats["Maximum Life"] = _to_float(stats.get("Maximum Life", 0.0)) + v
			"max_mana":
				stats["Maximum Mana"] = _to_float(stats.get("Maximum Mana", 0.0)) + v
			"spirit", "spirit_max":
				stats["Maximum Spirit"] = _to_float(stats.get("Maximum Spirit", 0.0)) + v
			"armor":
				stats["Armor"] = _to_float(stats.get("Armor", 0.0)) + v
			"fire_damage":
				stats["Fire Damage"] = _to_float(stats.get("Fire Damage", 0.0)) + v
			"lightning_damage":
				stats["Lightning Damage"] = _to_float(stats.get("Lightning Damage", 0.0)) + v
			"void_damage":
				stats["Void Damage"] = _to_float(stats.get("Void Damage", 0.0)) + v
			_:
				pass
	var spirits: Array = _as_array(_state_get(state, "spirit_gem_slots", []))
	for value: Variant in spirits:
		if typeof(value) != TYPE_DICTIONARY:
			continue
		var spirit: Dictionary = normalize_spirit(Dictionary(value))
		if bool(spirit.get("enabled", false)):
			rules.append("spirit:" + str(spirit.get("gem_id", "")))
	return {"stats": stats, "rules": rules, "reserved": _to_int(_state_get(state, "spirit_reserved", 0))}

static func spirit_total_stats(state: Object) -> Dictionary:
	var out: Dictionary = {}
	if state == null:
		return out
	var spirits: Array = _as_array(_state_get(state, "spirit_gem_slots", []))
	for value: Variant in spirits:
		if typeof(value) != TYPE_DICTIONARY:
			continue
		var spirit: Dictionary = normalize_spirit(Dictionary(value))
		if not bool(spirit.get("enabled", false)):
			continue
		var stats: Dictionary = Dictionary(spirit_data(str(spirit.get("gem_id", ""))).get("stats", {}))
		var level_scale: float = 1.0 + float(_to_int(spirit.get("level", 1)) - 1) * 0.05 + float(_to_int(spirit.get("quality", 0))) * 0.006
		for key: Variant in stats.keys():
			out[key] = _to_float(out.get(key, 0.0)) + _to_float(stats[key]) * level_scale
	return out

static func recompute_spirit_reservation(state: Object) -> void:
	if state == null:
		return
	var total: int = 0
	var spirits: Array = _as_array(_state_get(state, "spirit_gem_slots", []))
	for value: Variant in spirits:
		if typeof(value) != TYPE_DICTIONARY:
			continue
		var spirit: Dictionary = normalize_spirit(Dictionary(value))
		if bool(spirit.get("enabled", false)):
			total += _to_int(spirit.get("reservation", 0))
	state.set("spirit_reserved", total)

static func xp_to_next(level: int) -> int:
	return maxi(80, 85 + level * 95 + int(pow(float(level), 1.35) * 18.0))

static func unlocked_support_sockets(level: int) -> int:
	return support_sockets_for_level(level)

static func active_display_name(active: Dictionary) -> String:
	var id: String = str(active.get("gem_id", active.get("active_id", "fireball")))
	return str(active_data(id).get("name", id.capitalize()))

static func support_display_name(support: Dictionary) -> String:
	var id: String = str(support.get("gem_id", support.get("support_id", "controlled_power")))
	return str(support_data(id).get("name", id.capitalize()))

static func spirit_display_name(spirit: Dictionary) -> String:
	var id: String = str(spirit.get("gem_id", spirit.get("spirit_id", "clarity")))
	return str(spirit_data(id).get("name", id.capitalize()))

static func _install_active_to_selected_row(state: Object, active: Dictionary) -> void:
	var row: int = clampi(_to_int(_state_get(state, "selected_gem_row", _state_get(state, "selected_skill_slot", 0))), 0, EQUIPPED_GEM_ROWS - 1)
	_install_active_to_row(state, active, row)

static func _install_active_to_row(state: Object, active: Dictionary, row: int) -> void:
	var equipped: Array = _as_array(_state_get(state, "equipped_skill_gems", []))
	while equipped.size() < EQUIPPED_GEM_ROWS:
		equipped.append({})
	var clamped_row: int = clampi(row, 0, EQUIPPED_GEM_ROWS - 1)
	equipped[clamped_row] = normalize_active(active)
	state.set("equipped_skill_gems", equipped)
	state.set("selected_gem_row", clamped_row)
	_sync_legacy_active_slots(state)

static func _socket_support_into_selected(state: Object, support: Dictionary) -> void:
	var equipped: Array = _as_array(_state_get(state, "equipped_skill_gems", []))
	var row: int = _selected_equipped_row_from_hotbar(state, equipped)
	_socket_support_into_row(state, support, row)

static func _socket_support_into_row(state: Object, support: Dictionary, row: int) -> String:
	var equipped: Array = _as_array(_state_get(state, "equipped_skill_gems", []))
	if row < 0 or row >= equipped.size() or typeof(equipped[row]) != TYPE_DICTIONARY:
		return "No active target."
	var active: Dictionary = normalize_active(Dictionary(equipped[row]))
	if not is_support_compatible(active, support):
		return "Support tags do not match " + active_display_name(active) + "."
	var supports: Array = _as_array(active.get("support_sockets", []))
	if _support_list_has(supports, str(support.get("gem_id", ""))):
		return "That support is already socketed."
	var free_index: int = _first_empty_socket_index(supports)
	if free_index < 0:
		return "No empty support socket."
	supports[free_index] = normalize_support(support)
	active["support_sockets"] = supports
	equipped[row] = normalize_active(active)
	state.set("equipped_skill_gems", equipped)
	_sync_legacy_active_slots(state)
	return "Socketed " + support_display_name(support) + " into " + active_display_name(active) + "."

static func _selected_equipped_row_from_hotbar(state: Object, equipped: Array) -> int:
	var hotbar: Array = _as_array(_state_get(state, "hotbar_slots", []))
	var selected: int = clampi(_to_int(_state_get(state, "selected_hotbar_slot", _state_get(state, "selected_skill_slot", 0))), 0, max(0, hotbar.size() - 1))
	if selected >= 0 and selected < hotbar.size():
		var uid_value: String = str(hotbar[selected])
		var found: int = _find_equipped_index_by_uid(equipped, uid_value)
		if found >= 0:
			return found
	return clampi(selected, 0, max(0, equipped.size() - 1))

static func _find_equipped_index_by_uid(equipped: Array, uid_value: String) -> int:
	if uid_value == "":
		return -1
	for i: int in range(equipped.size()):
		if typeof(equipped[i]) == TYPE_DICTIONARY and str(Dictionary(equipped[i]).get("uid", "")) == uid_value:
			return i
	return -1

static func _sync_legacy_active_slots(state: Object) -> void:
	if state == null:
		return
	var equipped: Array = _as_array(_state_get(state, "equipped_skill_gems", []))
	var hotbar: Array = _as_array(_state_get(state, "hotbar_slots", []))
	var legacy: Array = []
	for i: int in range(HOTBAR_SLOTS):
		var active: Dictionary = {}
		if i < hotbar.size():
			var found: int = _find_equipped_index_by_uid(equipped, str(hotbar[i]))
			if found >= 0 and typeof(equipped[found]) == TYPE_DICTIONARY:
				active = normalize_active(Dictionary(equipped[found]))
		elif i < equipped.size() and typeof(equipped[i]) == TYPE_DICTIONARY:
			active = normalize_active(Dictionary(equipped[i]))
		if not active.is_empty():
			legacy.append(active)
	state.set("active_skill_slots", legacy)
	var selected: int = clampi(_to_int(_state_get(state, "selected_hotbar_slot", _state_get(state, "selected_skill_slot", 0))), 0, HOTBAR_SLOTS - 1)
	state.set("selected_skill_slot", selected)
	state.set("selected_hotbar_slot", selected)

static func _normalize_support_socket_array(values: Array) -> Array:
	var out: Array = []
	for value: Variant in values:
		if typeof(value) == TYPE_DICTIONARY:
			out.append(normalize_support(Dictionary(value)))
		elif value == null:
			out.append(null)
		elif str(value) == "":
			out.append(null)
		else:
			out.append(normalize_support_value(value))
	return out

static func _filter_compatible_supports(active: Dictionary, supports: Array) -> Array:
	var out: Array = []
	var socket_count: int = _to_int(active.get("support_socket_count", support_sockets_for_level(_to_int(active.get("level", 1)))))
	for support: Variant in supports:
		if typeof(support) != TYPE_DICTIONARY:
			out.append(null)
			continue
		var normalized: Dictionary = normalize_support(Dictionary(support))
		if is_support_compatible(active, normalized) and not _support_list_has(out, str(normalized.get("gem_id", ""))):
			out.append(normalized)
		else:
			out.append(null)
	while out.size() < socket_count:
		out.append(null)
	if out.size() > socket_count:
		out = out.slice(0, socket_count)
	return out

static func _first_empty_socket_index(supports: Array) -> int:
	for i: int in range(supports.size()):
		if typeof(supports[i]) != TYPE_DICTIONARY:
			return i
	return -1

static func _filled_socket_count(supports: Array) -> int:
	var count: int = 0
	for value: Variant in supports:
		if typeof(value) == TYPE_DICTIONARY:
			count += 1
	return count

static func _support_socket_text(supports: Array) -> String:
	var labels: PackedStringArray = PackedStringArray()
	for value: Variant in supports:
		if typeof(value) == TYPE_DICTIONARY:
			labels.append(support_display_name(Dictionary(value)))
		else:
			labels.append("empty")
	return ", ".join(labels)

static func _support_list_has(supports: Array, id: String) -> bool:
	for support: Variant in supports:
		if typeof(support) == TYPE_DICTIONARY and str(normalize_support(Dictionary(support)).get("gem_id", "")) == id:
			return true
	return false

static func _build_stat_damage_multiplier(state: Object, tags: Array) -> float:
	var mult: float = 1.0
	if tags.has("fire"):
		mult *= 1.0 + _stat_percent(state, "fire_damage")
	if tags.has("lightning"):
		mult *= 1.0 + _stat_percent(state, "lightning_damage")
	if tags.has("void"):
		mult *= 1.0 + _stat_percent(state, "void_damage")
	if tags.has("physical"):
		mult *= 1.0 + _stat_percent(state, "physical_damage")
	return mult

static func _stat_percent(state: Object, key: String) -> float:
	if state == null:
		return 0.0
	var build_stats: Dictionary = Dictionary(_state_get(state, "build_stats", {}))
	var combined: float = _to_float(_state_get(state, key, 0.0))
	combined += _to_float(build_stats.get(key, 0.0))
	combined += _to_float(build_stats.get(_title_stat_key(key), 0.0))
	return combined * 0.01

static func _title_stat_key(key: String) -> String:
	var words: PackedStringArray = str(key).replace("-", "_").split("_")
	var out: PackedStringArray = PackedStringArray()
	for word: String in words:
		if word == "":
			continue
		out.append(word.substr(0, 1).to_upper() + word.substr(1).to_lower())
	return " ".join(out)

static func _reservation_for_spirit_id(id: String, level: int, quality: int, supports: Array) -> int:
	var data: Dictionary = spirit_data(id)
	var base: int = _to_int(data.get("reservation", 25))
	var support_count: int = _filled_socket_count(supports)
	var quality_multiplier: float = maxf(0.70, 1.0 - float(clampi(quality, 0, 100)) * 0.004)
	var value: float = float(base) * (1.0 + float(support_count) * 0.15) * quality_multiplier
	return int(ceil(value))

static func _recommended_active_for_state(_state: Object) -> String:
	return "fireball"

static func _recommended_support_for_selected(state: Object) -> String:
	var active: Dictionary = selected_active_gem(state)
	for support_id: String in SUPPORT_ORDER:
		var candidate: Dictionary = support_instance(support_id)
		if is_support_compatible(active, candidate):
			return support_id
	return "controlled_power"

static func _recommended_spirit_for_state(_state: Object) -> String:
	return "ember_pact"

static func _uncut_kind_for_target(target_kind: String) -> String:
	if target_kind == GEM_SUPPORT:
		return GEM_UNCUT_SUPPORT
	if target_kind == GEM_SPIRIT:
		return GEM_UNCUT_SPIRIT
	return GEM_UNCUT_ACTIVE

static func _add_notice(state: Object, text: String) -> void:
	if state != null and state.has_method("add_notice"):
		state.call("add_notice", text)

static func _rng(state: Object) -> RandomNumberGenerator:
	if state != null:
		var value: Variant = state.get("rng")
		if value is RandomNumberGenerator:
			return value as RandomNumberGenerator
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.randomize()
	return rng

static func _state_get(state: Object, key: String, fallback: Variant = null) -> Variant:
	if state == null:
		return fallback
	var value: Variant = state.get(key)
	if value == null:
		return fallback
	return value

static func _as_array(value: Variant) -> Array:
	if typeof(value) == TYPE_ARRAY:
		return Array(value)
	return []

static func _as_string_array(value: Variant) -> PackedStringArray:
	var out: PackedStringArray = PackedStringArray()
	for v: Variant in _as_array(value):
		out.append(str(v))
	return out

static func _to_int(value: Variant, fallback: int = 0) -> int:
	if value == null:
		return fallback
	match typeof(value):
		TYPE_INT:
			return int(value)
		TYPE_FLOAT:
			return int(round(float(value)))
		TYPE_BOOL:
			return 1 if bool(value) else 0
		TYPE_STRING:
			var s: String = str(value)
			if s.is_valid_int():
				return s.to_int()
			if s.is_valid_float():
				return int(round(s.to_float()))
			return fallback
		_:
			return fallback

static func _to_float(value: Variant, fallback: float = 0.0) -> float:
	if value == null:
		return fallback
	match typeof(value):
		TYPE_FLOAT:
			return float(value)
		TYPE_INT:
			return float(value)
		TYPE_BOOL:
			return 1.0 if bool(value) else 0.0
		TYPE_STRING:
			var s: String = str(value)
			return s.to_float() if s.is_valid_float() else fallback
		_:
			return fallback

static func _uid(prefix: String, id: String) -> String:
	return prefix + "_" + id + "_" + str(Time.get_ticks_usec()) + "_" + str(randi() % 99999)
