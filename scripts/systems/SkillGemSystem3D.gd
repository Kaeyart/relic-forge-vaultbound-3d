extends RefCounted
const ACTIVE_ORDER: Array = [
	"fireball",
	"ember_mine",
	"storm_lance",
	"chain_spark",
	"arc_slash",
	"void_rift",
	"blood_cleave",
	"bone_spear",
	"ash_nova",
	"shield_burst",
	"heavy_slam",
	"ground_rupture",
	"piercing_shot",
	"rain_of_arrows",
	"snare_trap",
	"marked_shot",
	"infernal_step",
	"furnace_totem",
]

const SUPPORT_ORDER: Array = [
const ItemCombatIntegrationScript: GDScript = preload("res://scripts/systems/ItemCombatIntegrationSystem3D.gd")
	"split_projectile",
	"chain_current",
	"ignition",
	"focused_area",
	"wild_spread",
	"spell_echo",
	"molten_catalyst",
	"arcane_dampener",
	"chained_fury",
	"burning_focus",
	"brutality",
	"bloodletting",
]

const SPIRIT_ORDER: Array = [
	"clarity",
	"vitality",
	"iron_skin",
	"ember_pact",
	"storm_rhythm",
	"void_tithe",
	"revenant_guard",
	"execution_focus",
]

const MAX_ACTIVE_ROWS: int = 9
const HOTBAR_SIZE: int = 5
const MAX_SUPPORT_SOCKETS: int = 6
const BASE_SUPPORT_SOCKETS: int = 2

const KIND_ACTIVE: String = "active_gem"
const KIND_SUPPORT: String = "support_gem"
const KIND_SPIRIT: String = "spirit_gem"
const KIND_META: String = "meta_gem"
const KIND_UNCUT_ACTIVE: String = "uncut_active_gem"
const KIND_UNCUT_SUPPORT: String = "uncut_support_gem"
const KIND_UNCUT_SPIRIT: String = "uncut_spirit_gem"

const ACTIVE_DATA: Dictionary = {
	"fireball": {
		"name": "Fireball",
		"description": "Hurls a fire projectile that explodes on impact.",
		"tags": ["spell", "projectile", "fire", "hit", "area"],
		"damage": 28.0,
		"damage_per_level": 4.5,
		"mana_cost": 10,
		"cost_per_level": 1,
		"cast_time": 0.35,
		"cooldown": 0.12,
		"projectile_count": 1,
		"area_mult": 1.0,
		"ignite_chance": 0.15,
		"requirements": {"int": 8},
		"weapon_requirements": []
	},
	"storm_lance": {
		"name": "Storm Lance",
		"description": "Fires a fast lightning lance that rewards chains and shock.",
		"tags": ["spell", "projectile", "lightning", "hit"],
		"damage": 22.0,
		"damage_per_level": 3.8,
		"mana_cost": 9,
		"cost_per_level": 1,
		"cast_time": 0.25,
		"cooldown": 0.08,
		"projectile_count": 1,
		"chain": 0,
		"shock_chance": 0.18,
		"requirements": {"int": 10},
		"weapon_requirements": []
	},
	"arc_slash": {
		"name": "Arc Slash",
		"description": "A fast melee cleave for close range pressure.",
		"tags": ["attack", "melee", "physical", "hit"],
		"damage": 34.0,
		"damage_per_level": 4.2,
		"mana_cost": 6,
		"cost_per_level": 1,
		"cast_time": 0.20,
		"cooldown": 0.08,
		"area_mult": 0.85,
		"bleed_chance": 0.12,
		"requirements": {"str": 8},
		"weapon_requirements": ["sword", "axe", "scepter"]
	},
	"void_rift": {
		"name": "Void Rift",
		"description": "Opens a controlled area rupture that damages enemies inside.",
		"tags": ["spell", "area", "void", "duration", "hit"],
		"damage": 30.0,
		"damage_per_level": 4.8,
		"mana_cost": 14,
		"cost_per_level": 2,
		"cast_time": 0.45,
		"cooldown": 1.0,
		"area_mult": 1.25,
		"requirements": {"int": 14},
		"weapon_requirements": []
	},
	"ember_mine": {
		"name": "Ember Mine",
		"description": "Places an armed mine that detonates with fire damage.",
		"tags": ["mine", "fire", "area", "hit"],
		"damage": 42.0,
		"damage_per_level": 5.3,
		"mana_cost": 12,
		"cost_per_level": 1,
		"cast_time": 0.25,
		"cooldown": 0.55,
		"area_mult": 1.1,
		"mine_count": 1,
		"ignite_chance": 0.20,
		"requirements": {"int": 10},
		"weapon_requirements": []
	},
	"blood_cleave": {
		"name": "Blood Cleave",
		"description": "A heavy melee cut that favors bleed and execute effects.",
		"tags": ["attack", "melee", "physical", "bleed", "hit"],
		"damage": 46.0,
		"damage_per_level": 5.1,
		"mana_cost": 8,
		"cost_per_level": 1,
		"cast_time": 0.32,
		"cooldown": 0.20,
		"area_mult": 1.0,
		"bleed_chance": 0.25,
		"requirements": {"str": 12},
		"weapon_requirements": ["sword", "axe"]
	},
	"bone_spear": {
		"name": "Bone Spear",
		"description": "Launches a piercing physical projectile.",
		"tags": ["spell", "projectile", "physical", "hit"],
		"damage": 26.0,
		"damage_per_level": 4.4,
		"mana_cost": 11,
		"cost_per_level": 1,
		"cast_time": 0.34,
		"cooldown": 0.12,
		"projectile_count": 1,
		"pierce": 1,
		"requirements": {"int": 8},
		"weapon_requirements": []
	},
	"ash_nova": {
		"name": "Ash Nova",
		"description": "Releases a circular ash burst around the caster.",
		"tags": ["spell", "area", "fire", "hit"],
		"damage": 36.0,
		"damage_per_level": 4.7,
		"mana_cost": 13,
		"cost_per_level": 1,
		"cast_time": 0.40,
		"cooldown": 1.15,
		"area_mult": 1.45,
		"ignite_chance": 0.18,
		"requirements": {"int": 12},
		"weapon_requirements": []
	},
	"shield_burst": {
		"name": "Shield Burst",
		"description": "Expends guard momentum into a defensive burst.",
		"tags": ["attack", "area", "physical", "guard", "hit"],
		"damage": 32.0,
		"damage_per_level": 3.6,
		"mana_cost": 7,
		"cost_per_level": 1,
		"cast_time": 0.22,
		"cooldown": 1.35,
		"area_mult": 1.0,
		"requirements": {"str": 10},
		"weapon_requirements": ["shield"]
	},
	"infernal_step": {
		"name": "Infernal Step",
		"description": "A short movement skill that leaves burning ground.",
		"tags": ["movement", "fire", "area", "duration"],
		"damage": 18.0,
		"damage_per_level": 2.6,
		"mana_cost": 9,
		"cost_per_level": 1,
		"cast_time": 0.10,
		"cooldown": 2.2,
		"area_mult": 0.75,
		"requirements": {"dex": 8},
		"weapon_requirements": []
	},
	"furnace_totem": {
		"name": "Furnace Totem",
		"description": "Places a totem that pulses fire damage.",
		"tags": ["totem", "spell", "fire", "area", "duration"],
		"damage": 20.0,
		"damage_per_level": 3.2,
		"mana_cost": 16,
		"cost_per_level": 2,
		"cast_time": 0.55,
		"cooldown": 2.0,
		"area_mult": 1.0,
		"requirements": {"int": 14},
		"weapon_requirements": []
	},

	"heavy_slam": {
		"name": "Heavy Slam",
		"description": "A committed mace slam that crushes enemies in a short area.",
		"tags": ["attack", "melee", "physical", "slam", "area", "hit"],
		"damage": 48.0,
		"damage_per_level": 5.6,
		"mana_cost": 8,
		"cost_per_level": 1,
		"cast_time": 0.42,
		"cooldown": 0.28,
		"area_mult": 1.15,
		"stun_buildup": 0.35,
		"requirements": {"str": 12},
		"weapon_requirements": ["mace", "two_handed_mace"]
	},
	"ground_rupture": {
		"name": "Ground Rupture",
		"description": "Sends a cracking line of physical force through the ground.",
		"tags": ["attack", "melee", "physical", "slam", "area", "hit"],
		"damage": 40.0,
		"damage_per_level": 4.9,
		"mana_cost": 9,
		"cost_per_level": 1,
		"cast_time": 0.36,
		"cooldown": 0.45,
		"range": 5.0,
		"area_mult": 1.0,
		"requirements": {"str": 10},
		"weapon_requirements": ["mace", "two_handed_mace"]
	},
	"piercing_shot": {
		"name": "Piercing Shot",
		"description": "Fires a precise arrow that pierces enemies.",
		"tags": ["attack", "projectile", "physical", "bow", "hit"],
		"damage": 28.0,
		"damage_per_level": 4.0,
		"mana_cost": 6,
		"cost_per_level": 1,
		"cast_time": 0.22,
		"cooldown": 0.08,
		"projectile_count": 1,
		"pierce": 2,
		"projectile_speed": 16.0,
		"requirements": {"dex": 10},
		"weapon_requirements": ["bow"]
	},
	"rain_of_arrows": {
		"name": "Rain of Arrows",
		"description": "Marks an area and rains arrows after a short delay.",
		"tags": ["attack", "projectile", "physical", "bow", "area", "hit"],
		"damage": 24.0,
		"damage_per_level": 3.6,
		"mana_cost": 11,
		"cost_per_level": 1,
		"cast_time": 0.32,
		"cooldown": 0.75,
		"base_area": 2.4,
		"area_mult": 1.0,
		"requirements": {"dex": 12},
		"weapon_requirements": ["bow"]
	},
	"snare_trap": {
		"name": "Snare Trap",
		"description": "Throws a trap that damages and slows enemies in an area.",
		"tags": ["attack", "trap", "area", "physical", "duration", "hit"],
		"damage": 26.0,
		"damage_per_level": 3.8,
		"mana_cost": 10,
		"cost_per_level": 1,
		"cast_time": 0.20,
		"cooldown": 1.10,
		"base_area": 1.8,
		"area_mult": 1.0,
		"requirements": {"dex": 12},
		"weapon_requirements": []
	},
	"marked_shot": {
		"name": "Marked Shot",
		"description": "A projectile attack that marks prey for execution damage.",
		"tags": ["attack", "projectile", "physical", "bow", "mark", "hit"],
		"damage": 32.0,
		"damage_per_level": 4.2,
		"mana_cost": 8,
		"cost_per_level": 1,
		"cast_time": 0.25,
		"cooldown": 0.18,
		"projectile_count": 1,
		"pierce": 1,
		"requirements": {"dex": 12},
		"weapon_requirements": ["bow"]
	},
}

const SUPPORT_DATA: Dictionary = {
	"split_projectile": {"name": "Split Projectile", "description": "Supported projectiles split into additional shots.", "requires_any": ["projectile"], "forbids_any": [], "tier": 1, "mods": {"extra_projectiles": 2, "spread": 0.24, "damage_more": -0.18, "mana_cost_more": 0.12}},
	"chain_current": {"name": "Chain Current", "description": "Supported projectiles chain between enemies.", "requires_any": ["projectile", "lightning"], "forbids_any": ["melee"], "tier": 1, "mods": {"chain": 2, "damage_more": -0.10, "mana_cost_more": 0.18}},
	"pierce": {"name": "Pierce", "description": "Supported projectiles pierce enemies.", "requires_any": ["projectile"], "forbids_any": [], "tier": 1, "mods": {"pierce": 2, "mana_cost_more": 0.08}},
	"greater_area": {"name": "Greater Area", "description": "Supported area skills cover more space.", "requires_any": ["area"], "forbids_any": [], "tier": 1, "mods": {"area_more": 0.45, "damage_more": -0.08, "mana_cost_more": 0.12}},
	"focused_area": {"name": "Focused Area", "description": "Supported area skills shrink but hit harder.", "requires_any": ["area"], "forbids_any": [], "tier": 1, "mods": {"area_more": -0.28, "damage_more": 0.28, "mana_cost_more": 0.10}},
	"ignition": {"name": "Ignition", "description": "Supported fire hits ignite more often.", "requires_any": ["fire", "hit"], "forbids_any": [], "tier": 1, "mods": {"ignite_chance": 0.35, "mana_cost_more": 0.10}},
	"shock_focus": {"name": "Shock Focus", "description": "Supported lightning hits shock more often.", "requires_any": ["lightning", "hit"], "forbids_any": [], "tier": 1, "mods": {"shock_chance": 0.35, "mana_cost_more": 0.10}},
	"bleed_edge": {"name": "Bleed Edge", "description": "Supported physical attacks bleed more often.", "requires_any": ["physical", "attack"], "forbids_any": ["spell"], "tier": 1, "mods": {"bleed_chance": 0.40, "mana_cost_more": 0.08}},
	"echoing_ritual": {"name": "Echoing Ritual", "description": "Supported spells repeat after a short delay.", "requires_any": ["spell"], "forbids_any": ["attack", "mine"], "tier": 1, "mods": {"echo_count": 1, "damage_more": -0.10, "mana_cost_more": 0.22}},
	"controlled_power": {"name": "Controlled Power", "description": "More damage, higher cost.", "requires_any": ["spell", "attack", "hit"], "forbids_any": [], "tier": 1, "mods": {"damage_more": 0.22, "mana_cost_more": 0.18}},
	"rapid_strikes": {"name": "Rapid Strikes", "description": "Supported attacks recover faster.", "requires_any": ["attack"], "forbids_any": ["spell"], "tier": 1, "mods": {"cooldown_more": -0.18, "damage_more": -0.06}},
	"minefield": {"name": "Minefield", "description": "Supported mine skills place more mines but arm slower.", "requires_any": ["mine"], "forbids_any": [], "tier": 1, "mods": {"mine_count": 2, "cooldown_more": 0.25, "mana_cost_more": 0.20}},
	"life_leech": {"name": "Life Leech", "description": "Supported hits recover life from damage.", "requires_any": ["hit"], "forbids_any": [], "tier": 1, "mods": {"life_leech": 0.04, "mana_cost_more": 0.08}},
	"blood_price": {"name": "Blood Price", "description": "Supported skills spend life instead of part of their mana cost.", "requires_any": ["spell", "attack"], "forbids_any": [], "tier": 1, "mods": {"life_cost_ratio": 0.45, "mana_cost_more": -0.35, "damage_more": 0.08}},
	"execution": {"name": "Execution", "description": "Supported skills deal more damage to injured enemies.", "requires_any": ["hit"], "forbids_any": [], "tier": 1, "mods": {"execute_more": 0.30, "mana_cost_more": 0.10}},

	"brutality": {"name": "Brutality", "description": "Supported physical attacks hit harder but lose elemental scaling.", "requires_any": ["physical", "attack"], "forbids_any": ["spell"], "tier": 1, "mods": {"damage_more": 0.30, "mana_cost_more": 0.12}},
	"bloodletting": {"name": "Bloodletting", "description": "Supported physical hits bleed more often.", "requires_any": ["physical", "hit"], "forbids_any": [], "tier": 1, "mods": {"bleed_chance": 0.35, "execute_more": 0.12, "mana_cost_more": 0.10}},
	"predator_focus": {"name": "Predator Focus", "description": "Supported mark/projectile skills execute wounded prey.", "requires_any": ["projectile", "mark"], "forbids_any": [], "tier": 1, "mods": {"execute_more": 0.25, "mana_cost_more": 0.12}},
}

const SPIRIT_DATA: Dictionary = {
	"ember_pact": {"name": "Ember Pact", "description": "Persistent fire focus. Fire skills gain ignite pressure.", "tags": ["spirit", "persistent", "fire", "buff"], "reservation": 30, "mods": {"fire_damage_more": 0.08, "ignite_chance": 0.15}},
	"storm_rhythm": {"name": "Storm Rhythm", "description": "Persistent lightning rhythm. Lightning skills gain chain pressure.", "tags": ["spirit", "persistent", "lightning", "buff"], "reservation": 35, "mods": {"lightning_damage_more": 0.08, "chain": 1}},
	"revenant_guard": {"name": "Revenant Guard", "description": "Persistent guard state. Improves survival after danger.", "tags": ["spirit", "persistent", "guard", "defense"], "reservation": 40, "mods": {"armor_more": 0.10, "ward_flat": 25}},
	"execution_focus": {"name": "Execution Focus", "description": "Persistent kill pressure. Hits are stronger against injured enemies.", "tags": ["spirit", "persistent", "hit", "buff"], "reservation": 30, "mods": {"execute_more": 0.16}}
}

const META_DATA: Dictionary = {
	"cast_on_ignite": {"name": "Cast on Ignite", "description": "Future meta gem. Gains energy when igniting enemies.", "tags": ["meta", "trigger", "fire"], "reservation": 60},
	"cast_on_crit": {"name": "Cast on Crit", "description": "Future meta gem. Gains energy from critical hits.", "tags": ["meta", "trigger", "critical"], "reservation": 60}
}

static func ensure_defaults(state: Object) -> void:
	if state == null:
		return

	if _state_get(state, "gem_uid_counter", null) == null:
		state.set("gem_uid_counter", 1)
	if _state_get(state, "selected_hotbar_slot", null) == null:
		state.set("selected_hotbar_slot", _to_int(_state_get(state, "selected_skill_slot", 0)))
	if _state_get(state, "selected_gem_uid", null) == null:
		state.set("selected_gem_uid", "")
	if _state_get(state, "selected_support_uid", null) == null:
		state.set("selected_support_uid", "")
	if _state_get(state, "selected_uncut_uid", null) == null:
		state.set("selected_uncut_uid", "")
	if _state_get(state, "gem_last_message", null) == null:
		state.set("gem_last_message", "Gem system ready.")

	var page: Array = _as_array(_state_get(state, "equipped_gem_page", []))
	if page.is_empty():
		page = _migrate_old_active_slots(state)
	if page.is_empty():
		page = _starter_gem_page(state)
	page = _normalize_page(state, page)
	state.set("equipped_gem_page", page)

	var hotbar: Array = _as_array(_state_get(state, "hotbar_slots", []))
	if hotbar.is_empty():
		hotbar = _starter_hotbar_from_page(page)
	hotbar = _normalize_hotbar(hotbar)
	state.set("hotbar_slots", hotbar)

	var spirits: Array = _as_array(_state_get(state, "spirit_gem_slots", []))
	if spirits.is_empty():
		spirits = [_make_spirit_instance(state, "ember_pact", 1), _make_spirit_instance(state, "revenant_guard", 1)]
	spirits = _normalize_spirits(state, spirits)
	state.set("spirit_gem_slots", spirits)

	var inventory: Array = _as_array(_state_get(state, "gem_inventory", []))
	if inventory.is_empty():
		inventory = _starter_gem_inventory(state)
	inventory = _normalize_inventory(state, inventory)
	inventory = _ensure_starter_gem_inventory_access(state, inventory)
	state.set("gem_inventory", inventory)
	_rf_102a_ensure_fresh_starter_loadout(state)

	_recalculate_spirit(state)
	_refresh_active_skill_slots_mirror(state)


static func selected_cast_data(state: Object) -> Dictionary:
	ensure_defaults(state)
	var active: Dictionary = selected_hotbar_active_gem(state)
	if active.is_empty():
		return ItemCombatIntegrationScript.enhance_cast_data(state, _fallback_cast_data())
	var cast_data: Dictionary = build_cast_data(state, active)
	return ItemCombatIntegrationScript.enhance_cast_data(state, cast_data)


static func build_cast_data(state: Object, active: Dictionary) -> Dictionary:
	var gem_id_value: String = str(active.get("gem_id", "fireball"))
	var data: Dictionary = active_data(gem_id_value)
	var level: int = max(1, _to_int(active.get("level", 1)))
	var quality: int = clampi(_to_int(active.get("quality", 0)), 0, 100)
	var tags: Array = _as_array(data.get("tags", []))
	var damage: float = _to_float(data.get("damage", 10.0)) + _to_float(data.get("damage_per_level", 0.0)) * float(level - 1)
	damage *= 1.0 + float(quality) * 0.005
	var mana_cost: float = float(_to_int(data.get("mana_cost", 5)) + _to_int(data.get("cost_per_level", 0)) * max(0, level - 1))
	var cooldown: float = _to_float(data.get("cooldown", 0.0))
	var cast_time: float = _to_float(data.get("cast_time", 0.25))
	var projectile_count: int = max(1, _to_int(data.get("projectile_count", 1)))
	var spread: float = _to_float(data.get("spread", 0.0))
	var chain_count: int = max(0, _to_int(data.get("chain", 0)))
	var pierce_count: int = max(0, _to_int(data.get("pierce", 0)))
	var area_mult: float = _to_float(data.get("area_mult", 1.0))
	var ignite_chance: float = _to_float(data.get("ignite_chance", 0.0))
	var shock_chance: float = _to_float(data.get("shock_chance", 0.0))
	var bleed_chance: float = _to_float(data.get("bleed_chance", 0.0))
	var echo_count: int = 0
	var mine_count: int = max(1, _to_int(data.get("mine_count", 1)))
	var rules: Array = []
	var execute_more: float = 0.0
	var life_leech: float = 0.0
	var life_cost_ratio: float = 0.0

	var socketed_supports: Array = socketed_support_instances(state, active)
	for support_value: Variant in socketed_supports:
		if typeof(support_value) != TYPE_DICTIONARY:
			continue
		var support: Dictionary = Dictionary(support_value)
		var support_id: String = str(support.get("gem_id", ""))
		var support_data_value: Dictionary = support_data(support_id)
		var mods: Dictionary = Dictionary(support_data_value.get("mods", {}))
		var support_level: int = max(1, _to_int(support.get("level", 1)))
		var support_quality: int = clampi(_to_int(support.get("quality", 0)), 0, 100)
		var scale: float = 1.0 + float(support_level - 1) * 0.025 + float(support_quality) * 0.004

		projectile_count += max(0, _to_int(mods.get("extra_projectiles", 0)))
		if mods.has("spread"):
			spread = max(spread, _to_float(mods.get("spread", 0.0)))
		chain_count += max(0, _to_int(mods.get("chain", 0)))
		pierce_count += max(0, _to_int(mods.get("pierce", 0)))
		mine_count += max(0, _to_int(mods.get("mine_count", 0)))
		echo_count += max(0, _to_int(mods.get("echo_count", 0)))
		area_mult *= max(0.15, 1.0 + _to_float(mods.get("area_more", 0.0)) * scale)
		damage *= max(0.05, 1.0 + _to_float(mods.get("damage_more", 0.0)) * scale)
		mana_cost *= max(0.05, 1.0 + _to_float(mods.get("mana_cost_more", 0.0)) * scale)
		cooldown *= max(0.05, 1.0 + _to_float(mods.get("cooldown_more", 0.0)) * scale)
		ignite_chance += _to_float(mods.get("ignite_chance", 0.0)) * scale
		shock_chance += _to_float(mods.get("shock_chance", 0.0)) * scale
		bleed_chance += _to_float(mods.get("bleed_chance", 0.0)) * scale
		execute_more += _to_float(mods.get("execute_more", 0.0)) * scale
		life_leech += _to_float(mods.get("life_leech", 0.0)) * scale
		life_cost_ratio = max(life_cost_ratio, _to_float(mods.get("life_cost_ratio", 0.0)))
		rules.append(str(support_data_value.get("name", support_id)))

	var spirit_mods: Dictionary = _active_spirit_mods(state)
	if _has_tag(tags, "fire"):
		damage *= 1.0 + _to_float(spirit_mods.get("fire_damage_more", 0.0))
		ignite_chance += _to_float(spirit_mods.get("ignite_chance", 0.0))
	if _has_tag(tags, "lightning"):
		damage *= 1.0 + _to_float(spirit_mods.get("lightning_damage_more", 0.0))
		chain_count += _to_int(spirit_mods.get("chain", 0))
	if execute_more > 0.0:
		rules.append("Execute +" + str(int(round(execute_more * 100.0))) + "%")
	if life_leech > 0.0:
		rules.append("Life Leech " + str(snappedf(life_leech * 100.0, 0.1)) + "%")
	if life_cost_ratio > 0.0:
		rules.append("Blood Price")

	return {
		"active_id": gem_id_value,
		"gem_uid": str(active.get("uid", "")),
		"display_name": str(data.get("name", gem_id_value.capitalize())),
		"tags": tags,
		"level": level,
		"quality": quality,
		"damage": max(1.0, damage),
		"mana_cost": max(0.0, mana_cost),
		"life_cost_ratio": clampf(life_cost_ratio, 0.0, 1.0),
		"cooldown": max(0.0, cooldown),
		"cast_time": max(0.0, cast_time),
		"projectile_count": max(1, projectile_count),
		"extra_projectiles": max(0, projectile_count - 1),
		"spread": spread,
		"chain": max(0, chain_count),
		"pierce": max(0, pierce_count),
		"area_mult": max(0.15, area_mult),
		"ignite_chance": clampf(ignite_chance, 0.0, 1.0),
		"shock_chance": clampf(shock_chance, 0.0, 1.0),
		"bleed_chance": clampf(bleed_chance, 0.0, 1.0),
		"echo_count": max(0, echo_count),
		"mine_count": max(1, mine_count),
		"execute_more": max(0.0, execute_more),
		"life_leech": max(0.0, life_leech),
		"rules": rules,
	}


static func carve_uncut_gem(state: Object, uncut_uid: String, target_gem_id: String) -> Dictionary:
	ensure_defaults(state)
	var inventory: Array = _as_array(_state_get(state, "gem_inventory", []))
	var index: int = _find_inventory_index_by_uid(inventory, uncut_uid)
	if index < 0:
		return _result(false, "No selected uncut gem found.", "")
	var uncut: Dictionary = Dictionary(inventory[index])
	var kind_value: String = str(uncut.get("kind", ""))
	var level_value: int = max(1, _to_int(uncut.get("gem_level", uncut.get("level", 1))))
	var new_uid: String = ""

	if kind_value == KIND_UNCUT_ACTIVE:
		if not ACTIVE_DATA.has(target_gem_id):
			return _result(false, "Cannot carve: unknown active gem.", "")
		var active: Dictionary = _make_active_instance(state, target_gem_id, level_value)
		new_uid = str(active.get("uid", ""))
		var page: Array = _as_array(_state_get(state, "equipped_gem_page", []))
		var row_index: int = _first_empty_page_row(page)
		if row_index >= 0:
			page[row_index] = active
			state.set("equipped_gem_page", page)
		else:
			active["inventory_only"] = true
			inventory.append(active)
		inventory.remove_at(index)
		state.set("gem_inventory", inventory)
		state.set("selected_gem_uid", new_uid)
		_set_message(state, "Carved " + active_display_name(active) + ".")
		_refresh_active_skill_slots_mirror(state)
		return _result(true, str(_state_get(state, "gem_last_message", "Carved gem.")), new_uid)

	if kind_value == KIND_UNCUT_SUPPORT:
		if not SUPPORT_DATA.has(target_gem_id):
			return _result(false, "Cannot carve: unknown support gem.", "")
		var support: Dictionary = _make_support_instance(state, target_gem_id, level_value)
		new_uid = str(support.get("uid", ""))
		inventory.remove_at(index)
		inventory.append(support)
		state.set("gem_inventory", inventory)
		state.set("selected_support_uid", new_uid)
		_set_message(state, "Carved " + support_display_name(support) + ".")
		return _result(true, str(_state_get(state, "gem_last_message", "Carved support.")), new_uid)

	if kind_value == KIND_UNCUT_SPIRIT:
		if not SPIRIT_DATA.has(target_gem_id):
			return _result(false, "Cannot carve: unknown spirit gem.", "")
		var spirit: Dictionary = _make_spirit_instance(state, target_gem_id, level_value)
		new_uid = str(spirit.get("uid", ""))
		var spirits: Array = _as_array(_state_get(state, "spirit_gem_slots", []))
		spirits.append(spirit)
		inventory.remove_at(index)
		state.set("gem_inventory", inventory)
		state.set("spirit_gem_slots", spirits)
		state.set("selected_spirit_uid", new_uid)
		_set_message(state, "Carved " + spirit_display_name(spirit) + ".")
		_recalculate_spirit(state)
		return _result(true, str(_state_get(state, "gem_last_message", "Carved spirit.")), new_uid)

	return _result(false, "Selected gem is not uncut.", "")


static func socket_support(state: Object, target_uid: String, support_uid: String, socket_index: int = -1) -> Dictionary:
	ensure_defaults(state)
	var target_result: Dictionary = _find_socket_owner(state, target_uid)
	if target_result.is_empty():
		return _result(false, "Select an active or spirit gem first.", "")
	var target: Dictionary = Dictionary(target_result.get("gem", {}))
	var owner_kind: String = str(target_result.get("owner", ""))
	var support_result: Dictionary = _find_support_in_inventory(state, support_uid)
	if support_result.is_empty():
		return _result(false, "Select an available support gem first.", "")
	var support: Dictionary = Dictionary(support_result.get("gem", {}))
	if str(support.get("equipped_to", "")) != "":
		return _result(false, "Support is already socketed.", "")
	if not can_support_socket_into(target, support):
		return _result(false, support_display_name(support) + " is not compatible with " + _generic_gem_display_name(target) + ".", "")
	var sockets: Array = _socket_array_for(target)
	var unlocked: int = support_socket_count_for_gem(target)
	if socket_index < 0:
		socket_index = _first_empty_socket(sockets, unlocked)
	if socket_index < 0 or socket_index >= unlocked:
		return _result(false, "No unlocked empty support socket.", "")
	if socket_index >= MAX_SUPPORT_SOCKETS:
		return _result(false, "Invalid support socket.", "")
	if str(sockets[socket_index]) != "":
		return _result(false, "That support socket is already occupied.", "")
	for socket_value: Variant in sockets:
		var existing_uid: String = str(socket_value)
		if existing_uid == "":
			continue
		var existing: Dictionary = _find_any_support_by_uid(state, existing_uid)
		if not existing.is_empty() and str(existing.get("gem_id", "")) == str(support.get("gem_id", "")):
			return _result(false, "That skill already has this support type.", "")

	sockets[socket_index] = support_uid
	target["support_sockets"] = sockets
	support["equipped_to"] = str(target.get("uid", ""))
	support["socket_index"] = socket_index
	_save_socket_owner(state, target, owner_kind, _to_int(target_result.get("index", -1)))
	_save_support_inventory_entry(state, support, _to_int(support_result.get("index", -1)))
	_refresh_active_skill_slots_mirror(state)
	_set_message(state, "Socketed " + support_display_name(support) + " into " + _generic_gem_display_name(target) + ".")
	return _result(true, str(_state_get(state, "gem_last_message", "Socketed support.")), support_uid)


static func unsocket_support(state: Object, target_uid: String, socket_index: int) -> Dictionary:
	ensure_defaults(state)
	var target_result: Dictionary = _find_socket_owner(state, target_uid)
	if target_result.is_empty():
		return _result(false, "Select an active or spirit gem first.", "")
	var target: Dictionary = Dictionary(target_result.get("gem", {}))
	var sockets: Array = _socket_array_for(target)
	if socket_index < 0 or socket_index >= sockets.size():
		return _result(false, "Invalid socket.", "")
	var support_uid: String = str(sockets[socket_index])
	if support_uid == "":
		return _result(false, "Socket is empty.", "")
	sockets[socket_index] = ""
	target["support_sockets"] = sockets
	_save_socket_owner(state, target, str(target_result.get("owner", "")), _to_int(target_result.get("index", -1)))
	var support_result: Dictionary = _find_support_in_inventory(state, support_uid, false)
	if not support_result.is_empty():
		var support: Dictionary = Dictionary(support_result.get("gem", {}))
		support["equipped_to"] = ""
		support["socket_index"] = -1
		_save_support_inventory_entry(state, support, _to_int(support_result.get("index", -1)))
	_refresh_active_skill_slots_mirror(state)
	_set_message(state, "Removed support from " + _generic_gem_display_name(target) + ".")
	return _result(true, str(_state_get(state, "gem_last_message", "Removed support.")), support_uid)

static func bind_gem_to_hotbar(state: Object, active_uid: String, hotbar_index: int) -> Dictionary:
	ensure_defaults(state)
	var page: Array = _as_array(_state_get(state, "equipped_gem_page", []))
	var found: bool = false
	for value: Variant in page:
		if typeof(value) == TYPE_DICTIONARY and str(Dictionary(value).get("uid", "")) == active_uid:
			found = true
			break
	if not found:
		return _result(false, "Only equipped active gems can be bound to the hotbar.", "")
	if hotbar_index < 0 or hotbar_index >= HOTBAR_SIZE:
		return _result(false, "Invalid hotbar slot.", "")
	var hotbar: Array = _normalize_hotbar(_as_array(_state_get(state, "hotbar_slots", [])))
	hotbar[hotbar_index] = active_uid
	state.set("hotbar_slots", hotbar)
	state.set("selected_hotbar_slot", hotbar_index)
	state.set("selected_skill_slot", hotbar_index)
	state.set("selected_gem_uid", active_uid)
	_refresh_active_skill_slots_mirror(state)
	var active: Dictionary = _find_active_by_uid(state, active_uid)
	_set_message(state, "Bound " + active_display_name(active) + " to hotbar " + str(hotbar_index + 1) + ".")
	return _result(true, str(_state_get(state, "gem_last_message", "Bound skill.")), active_uid)


static func toggle_spirit_gem(state: Object, spirit_uid: String = "") -> Dictionary:
	ensure_defaults(state)
	var spirits: Array = _as_array(_state_get(state, "spirit_gem_slots", []))
	if spirit_uid == "":
		spirit_uid = str(_state_get(state, "selected_spirit_uid", ""))
	if spirit_uid == "" and not spirits.is_empty():
		spirit_uid = str(Dictionary(spirits[0]).get("uid", ""))
	var index: int = _find_array_index_by_uid(spirits, spirit_uid)
	if index < 0:
		return _result(false, "No spirit gem selected.", "")
	var spirit: Dictionary = Dictionary(spirits[index])
	var currently_enabled: bool = bool(spirit.get("enabled", false))
	if currently_enabled:
		spirit["enabled"] = false
		spirits[index] = spirit
		state.set("spirit_gem_slots", spirits)
		_recalculate_spirit(state)
		_set_message(state, "Disabled " + spirit_display_name(spirit) + ".")
		return _result(true, str(_state_get(state, "gem_last_message", "Disabled spirit.")), spirit_uid)
	var reserved_now: int = _to_int(_state_get(state, "spirit_reserved", 0))
	var max_spirit: int = max(0, _to_int(_state_get(state, "spirit_max", 100)))
	var cost: int = spirit_reservation(spirit)
	if reserved_now + cost > max_spirit:
		return _result(false, "Not enough Spirit to enable " + spirit_display_name(spirit) + ".", "")
	spirit["enabled"] = true
	spirits[index] = spirit
	state.set("spirit_gem_slots", spirits)
	_recalculate_spirit(state)
	_set_message(state, "Enabled " + spirit_display_name(spirit) + ".")
	return _result(true, str(_state_get(state, "gem_last_message", "Enabled spirit.")), spirit_uid)


static func award_selected_active_xp(state: Object, amount: int) -> void:
	ensure_defaults(state)
	var hotbar_index: int = clampi(_to_int(_state_get(state, "selected_hotbar_slot", _state_get(state, "selected_skill_slot", 0))), 0, HOTBAR_SIZE - 1)
	var hotbar: Array = _normalize_hotbar(_as_array(_state_get(state, "hotbar_slots", [])))
	var uid: String = str(hotbar[hotbar_index])
	if uid == "":
		return
	award_gem_xp(state, uid, amount)


static func award_gem_xp(state: Object, gem_uid: String, amount: int) -> void:
	ensure_defaults(state)
	var result: Dictionary = _find_socket_owner(state, gem_uid)
	if result.is_empty():
		return
	var gem: Dictionary = Dictionary(result.get("gem", {}))
	var level: int = max(1, _to_int(gem.get("level", 1)))
	var xp: int = max(0, _to_int(gem.get("xp", 0))) + max(0, amount)
	var old_sockets: int = support_socket_count_for_level(level)
	var leveled: bool = false
	while xp >= xp_to_next(level):
		xp -= xp_to_next(level)
		level += 1
		leveled = true
	gem["level"] = level
	gem["xp"] = xp
	gem["support_socket_count"] = support_socket_count_for_level(level)
	gem["support_sockets"] = _ensure_socket_array(_as_array(gem.get("support_sockets", [])))
	_save_socket_owner(state, gem, str(result.get("owner", "")), _to_int(result.get("index", -1)))
	if leveled:
		var message: String = _generic_gem_display_name(gem) + " reached level " + str(level) + "."
		if support_socket_count_for_level(level) > old_sockets:
			message += " New support socket unlocked."
		_set_message(state, message)
	_refresh_active_skill_slots_mirror(state)


static func cycle_active_slot_gem(state: Object, dir: int) -> void:
	ensure_defaults(state)
	var hotbar_index: int = clampi(_to_int(_state_get(state, "selected_hotbar_slot", _state_get(state, "selected_skill_slot", 0))), 0, HOTBAR_SIZE - 1)
	var page: Array = _as_array(_state_get(state, "equipped_gem_page", []))
	var active_indices: Array = []
	for i: int in range(page.size()):
		if typeof(page[i]) == TYPE_DICTIONARY and not Dictionary(page[i]).is_empty():
			active_indices.append(i)
	if active_indices.is_empty():
		return
	var hotbar: Array = _normalize_hotbar(_as_array(_state_get(state, "hotbar_slots", [])))
	var current_uid: String = str(hotbar[hotbar_index])
	var current_pos: int = 0
	for j: int in range(active_indices.size()):
		var row: int = _to_int(active_indices[j])
		if str(Dictionary(page[row]).get("uid", "")) == current_uid:
			current_pos = j
			break
	var next_pos: int = wrapi(current_pos + dir, 0, active_indices.size())
	var next_row: int = _to_int(active_indices[next_pos])
	var next_uid: String = str(Dictionary(page[next_row]).get("uid", ""))
	bind_gem_to_hotbar(state, next_uid, hotbar_index)


static func add_next_valid_support(state: Object) -> void:
	ensure_defaults(state)
	var active: Dictionary = selected_hotbar_active_gem(state)
	if active.is_empty():
		_set_message(state, "No selected active skill.")
		return
	var supports: Array = support_gem_instances(state, true)
	for value: Variant in supports:
		if typeof(value) != TYPE_DICTIONARY:
			continue
		var support: Dictionary = Dictionary(value)
		var result: Dictionary = socket_support(state, str(active.get("uid", "")), str(support.get("uid", "")))
		if bool(result.get("ok", false)):
			return
	_set_message(state, "No compatible available support gem.")


static func remove_last_support(state: Object) -> void:
	ensure_defaults(state)
	var active: Dictionary = selected_hotbar_active_gem(state)
	if active.is_empty():
		return
	var sockets: Array = _socket_array_for(active)
	for i: int in range(sockets.size() - 1, -1, -1):
		if str(sockets[i]) != "":
			unsocket_support(state, str(active.get("uid", "")), i)
			return
	_set_message(state, "No support to remove.")


static func toggle_next_spirit(state: Object) -> void:
	ensure_defaults(state)
	var spirits: Array = _as_array(_state_get(state, "spirit_gem_slots", []))
	if spirits.is_empty():
		_set_message(state, "No spirit gems available.")
		return
	var uid: String = str(_state_get(state, "selected_spirit_uid", ""))
	if uid == "":
		uid = str(Dictionary(spirits[0]).get("uid", ""))
	toggle_spirit_gem(state, uid)


static func active_gem_instances(state: Object) -> Array:
	ensure_defaults(state)
	return _as_array(_state_get(state, "equipped_gem_page", [])).duplicate(true)


static func support_gem_instances(state: Object, available_only: bool = false) -> Array:
	ensure_defaults(state)
	var out: Array = []
	var inventory: Array = _as_array(_state_get(state, "gem_inventory", []))
	for value: Variant in inventory:
		if typeof(value) != TYPE_DICTIONARY:
			continue
		var gem: Dictionary = Dictionary(value)
		if str(gem.get("kind", "")) != KIND_SUPPORT:
			continue
		if available_only and str(gem.get("equipped_to", "")) != "":
			continue
		out.append(gem.duplicate(true))
	return out


static func uncut_gem_instances(state: Object) -> Array:
	ensure_defaults(state)
	var out: Array = []
	var inventory: Array = _as_array(_state_get(state, "gem_inventory", []))
	for value: Variant in inventory:
		if typeof(value) != TYPE_DICTIONARY:
			continue
		var gem: Dictionary = Dictionary(value)
		var kind_value: String = str(gem.get("kind", ""))
		if kind_value == KIND_UNCUT_ACTIVE or kind_value == KIND_UNCUT_SUPPORT or kind_value == KIND_UNCUT_SPIRIT:
			out.append(gem.duplicate(true))
	return out


static func spirit_gem_instances(state: Object) -> Array:
	ensure_defaults(state)
	return _as_array(_state_get(state, "spirit_gem_slots", [])).duplicate(true)


static func selected_hotbar_active_gem(state: Object) -> Dictionary:
	ensure_defaults(state)
	var hotbar_index: int = clampi(_to_int(_state_get(state, "selected_hotbar_slot", _state_get(state, "selected_skill_slot", 0))), 0, HOTBAR_SIZE - 1)
	var hotbar: Array = _normalize_hotbar(_as_array(_state_get(state, "hotbar_slots", [])))
	var uid: String = str(hotbar[hotbar_index])
	if uid == "":
		return {}
	return _find_active_by_uid(state, uid)


static func selected_gem_uid(state: Object) -> String:
	ensure_defaults(state)
	var uid: String = str(_state_get(state, "selected_gem_uid", ""))
	if uid != "":
		return uid
	var active: Dictionary = selected_hotbar_active_gem(state)
	return str(active.get("uid", ""))


static func socketed_support_instances(state: Object, gem: Dictionary) -> Array:
	var out: Array = []
	var sockets: Array = _socket_array_for(gem)
	for value: Variant in sockets:
		var uid: String = str(value)
		if uid == "":
			continue
		var support: Dictionary = _find_any_support_by_uid(state, uid)
		if not support.is_empty():
			out.append(support.duplicate(true))
	return out


static func compatible_supports_for_gem(state: Object, gem: Dictionary, available_only: bool = true) -> Array:
	var out: Array = []
	var supports: Array = support_gem_instances(state, available_only)
	for value: Variant in supports:
		if typeof(value) == TYPE_DICTIONARY:
			var support: Dictionary = Dictionary(value)
			if can_support_socket_into(gem, support):
				out.append(support.duplicate(true))
	return out


static func can_support_socket_into(target: Dictionary, support: Dictionary) -> bool:
	if target.is_empty() or support.is_empty():
		return false
	var target_kind: String = str(target.get("kind", ""))
	if target_kind != KIND_ACTIVE and target_kind != KIND_SPIRIT and target_kind != KIND_META:
		return false
	var support_id: String = str(support.get("gem_id", ""))
	if not SUPPORT_DATA.has(support_id):
		return false
	var tags: Array = _as_array(target.get("tags", []))
	if tags.is_empty():
		var data: Dictionary = {}
		if target_kind == KIND_ACTIVE:
			data = active_data(str(target.get("gem_id", "")))
		elif target_kind == KIND_SPIRIT:
			data = spirit_data(str(target.get("gem_id", "")))
		tags = _as_array(data.get("tags", []))
	var sdata: Dictionary = support_data(support_id)
	var forbids: Array = _as_array(sdata.get("forbids_any", []))
	for forbidden: Variant in forbids:
		if _has_tag(tags, str(forbidden)):
			return false
	var requires: Array = _as_array(sdata.get("requires_any", []))
	if requires.is_empty():
		return true
	for required: Variant in requires:
		if _has_tag(tags, str(required)):
			return true
	return false


static func support_socket_count_for_level(level: int) -> int:
	return clampi(BASE_SUPPORT_SOCKETS + int(floor(float(max(1, level)) / 5.0)), BASE_SUPPORT_SOCKETS, MAX_SUPPORT_SOCKETS)


static func support_socket_count_for_gem(gem: Dictionary) -> int:
	return support_socket_count_for_level(max(1, _to_int(gem.get("level", 1))))


static func next_socket_level(level: int) -> int:
	var current: int = support_socket_count_for_level(level)
	if current >= MAX_SUPPORT_SOCKETS:
		return -1
	var l: int = max(1, level + 1)
	while support_socket_count_for_level(l) <= current and l < 100:
		l += 1
	return l


static func xp_to_next(level: int) -> int:
	return 80 + max(0, level - 1) * 55 + int(pow(float(max(1, level)), 1.35) * 18.0)


static func active_display_name(gem: Dictionary) -> String:
	var data: Dictionary = active_data(str(gem.get("gem_id", "fireball")))
	return str(data.get("name", str(gem.get("gem_id", "fireball")).capitalize()))


static func support_display_name(gem: Dictionary) -> String:
	var data: Dictionary = support_data(str(gem.get("gem_id", "")))
	return str(data.get("name", str(gem.get("gem_id", "support")).capitalize()))


static func spirit_display_name(gem: Dictionary) -> String:
	var data: Dictionary = spirit_data(str(gem.get("gem_id", "")))
	return str(data.get("name", str(gem.get("gem_id", "spirit")).capitalize()))


static func gem_detail_text(gem: Dictionary, assumed_type: String = "") -> String:
	if gem.is_empty():
		return "No gem selected."
	var kind_value: String = assumed_type
	if kind_value == "":
		kind_value = str(gem.get("kind", ""))
	var lines: PackedStringArray = PackedStringArray()
	if kind_value == KIND_ACTIVE:
		var data: Dictionary = active_data(str(gem.get("gem_id", "fireball")))
		var level: int = max(1, _to_int(gem.get("level", 1)))
		lines.append(active_display_name(gem) + " [Active]")
		lines.append("Level " + str(level) + " · XP " + str(_to_int(gem.get("xp", 0))) + "/" + str(xp_to_next(level)))
		lines.append("Tags: " + ", ".join(_string_array(data.get("tags", []))))
		lines.append("Support sockets: " + str(support_socket_count_for_level(level)) + "/" + str(MAX_SUPPORT_SOCKETS))
		var next_level: int = next_socket_level(level)
		if next_level > 0:
			lines.append("Next socket unlocks at gem level " + str(next_level) + ".")
		lines.append(str(data.get("description", "")))
		return "\n".join(lines)
	if kind_value == KIND_SUPPORT:
		var sdata: Dictionary = support_data(str(gem.get("gem_id", "")))
		lines.append(support_display_name(gem) + " [Support]")
		lines.append("Level " + str(_to_int(gem.get("level", 1))) + " · Tier " + str(_to_int(gem.get("tier", sdata.get("tier", 1)))))
		lines.append("Requires: " + ", ".join(_string_array(sdata.get("requires_any", []))))
		lines.append(str(sdata.get("description", "")))
		return "\n".join(lines)
	if kind_value == KIND_SPIRIT:
		var spdata: Dictionary = spirit_data(str(gem.get("gem_id", "")))
		var sp_level: int = max(1, _to_int(gem.get("level", 1)))
		lines.append(spirit_display_name(gem) + " [Spirit]")
		lines.append("Level " + str(sp_level) + " · Reserves " + str(spirit_reservation(gem)) + " Spirit")
		lines.append("Support sockets: " + str(support_socket_count_for_level(sp_level)) + "/" + str(MAX_SUPPORT_SOCKETS))
		lines.append("Tags: " + ", ".join(_string_array(spdata.get("tags", []))))
		lines.append(str(spdata.get("description", "")))
		return "\n".join(lines)
	lines.append(str(gem.get("kind", "Gem")))
	lines.append(str(gem))
	return "\n".join(lines)


static func behavior_preview_text(state: Object, gem: Dictionary) -> String:
	if gem.is_empty():
		return "No active gem selected."
	var base: Dictionary = build_cast_data(state, _copy_without_supports(gem))
	var final_data: Dictionary = build_cast_data(state, gem)
	var lines: PackedStringArray = PackedStringArray()
	lines.append("BEHAVIOR PREVIEW")
	lines.append("Projectiles: " + str(_to_int(base.get("projectile_count", 1))) + " → " + str(_to_int(final_data.get("projectile_count", 1))))
	lines.append("Chain: " + str(_to_int(base.get("chain", 0))) + " → " + str(_to_int(final_data.get("chain", 0))))
	lines.append("Pierce: " + str(_to_int(base.get("pierce", 0))) + " → " + str(_to_int(final_data.get("pierce", 0))))
	lines.append("Area: x" + str(snappedf(_to_float(base.get("area_mult", 1.0)), 0.01)) + " → x" + str(snappedf(_to_float(final_data.get("area_mult", 1.0)), 0.01)))
	lines.append("Ignite: " + str(int(round(_to_float(base.get("ignite_chance", 0.0)) * 100.0))) + "% → " + str(int(round(_to_float(final_data.get("ignite_chance", 0.0)) * 100.0))) + "%")
	lines.append("Damage: " + str(int(round(_to_float(base.get("damage", 0.0))))) + " → " + str(int(round(_to_float(final_data.get("damage", 0.0))))) )
	lines.append("Mana: " + str(int(round(_to_float(base.get("mana_cost", 0.0))))) + " → " + str(int(round(_to_float(final_data.get("mana_cost", 0.0))))) )
	return "\n".join(lines)


static func panel_text(state: Object) -> String:
	ensure_defaults(state)
	var active: Dictionary = selected_hotbar_active_gem(state)
	var text: String = "SKILL GEMS\n"
	text += "Hotbar: " + str(_state_get(state, "hotbar_slots", [])) + "\n"
	text += gem_detail_text(active, KIND_ACTIVE) + "\n\n"
	text += behavior_preview_text(state, active)
	return text


static func active_data(id: String) -> Dictionary:
	if ACTIVE_DATA.has(id):
		return Dictionary(ACTIVE_DATA[id]).duplicate(true)
	return Dictionary(ACTIVE_DATA["fireball"]).duplicate(true)


static func support_data(id: String) -> Dictionary:
	if SUPPORT_DATA.has(id):
		return Dictionary(SUPPORT_DATA[id]).duplicate(true)
	return {}


static func spirit_data(id: String) -> Dictionary:
	if SPIRIT_DATA.has(id):
		return Dictionary(SPIRIT_DATA[id]).duplicate(true)
	return {}


static func spirit_reservation(spirit: Dictionary) -> int:
	var data: Dictionary = spirit_data(str(spirit.get("gem_id", "")))
	var base: int = max(0, _to_int(data.get("reservation", spirit.get("reservation", 0))))
	var level: int = max(1, _to_int(spirit.get("level", 1)))
	var quality: int = clampi(_to_int(spirit.get("quality", 0)), 0, 100)
	var sockets_used: int = 0
	for socket_value: Variant in _socket_array_for(spirit):
		if str(socket_value) != "":
			sockets_used += 1
	var reservation: float = float(base) * (1.0 + float(sockets_used) * 0.12) * max(0.75, 1.0 - float(quality) * 0.003)
	reservation += float(max(0, level - 1)) * 0.25
	return int(ceil(reservation))


static func possible_carve_targets(uncut: Dictionary) -> Array:
	var kind_value: String = str(uncut.get("kind", ""))
	var out: Array = []
	if kind_value == KIND_UNCUT_ACTIVE:
		for key: Variant in ACTIVE_DATA.keys():
			out.append(str(key))
	elif kind_value == KIND_UNCUT_SUPPORT:
		for key2: Variant in SUPPORT_DATA.keys():
			out.append(str(key2))
	elif kind_value == KIND_UNCUT_SPIRIT:
		for key3: Variant in SPIRIT_DATA.keys():
			out.append(str(key3))
	return out


static func display_name_for_target(kind_value: String, gem_id: String) -> String:
	if kind_value == KIND_UNCUT_ACTIVE:
		return str(active_data(gem_id).get("name", gem_id.capitalize()))
	if kind_value == KIND_UNCUT_SUPPORT:
		return str(support_data(gem_id).get("name", gem_id.capitalize()))
	if kind_value == KIND_UNCUT_SPIRIT:
		return str(spirit_data(gem_id).get("name", gem_id.capitalize()))
	return gem_id.capitalize()


static func _ensure_starter_gem_inventory_access(state: Object, inventory: Array) -> Array:
	var has_available_support: bool = false
	var has_uncut_active: bool = false
	var has_uncut_support: bool = false
	var has_uncut_spirit: bool = false
	for value: Variant in inventory:
		if typeof(value) != TYPE_DICTIONARY:
			continue
		var gem: Dictionary = Dictionary(value)
		var kind_value: String = str(gem.get("kind", ""))
		if kind_value == KIND_SUPPORT and str(gem.get("equipped_to", "")) == "":
			has_available_support = true
		elif kind_value == KIND_UNCUT_ACTIVE:
			has_uncut_active = true
		elif kind_value == KIND_UNCUT_SUPPORT:
			has_uncut_support = true
		elif kind_value == KIND_UNCUT_SPIRIT:
			has_uncut_spirit = true
	if not has_available_support:
		inventory.append(_make_support_instance(state, "split_projectile", 1))
		inventory.append(_make_support_instance(state, "ignition", 1))
	if not has_uncut_active:
		inventory.append(_make_uncut_instance(state, KIND_UNCUT_ACTIVE, 3))
	if not has_uncut_support:
		inventory.append(_make_uncut_instance(state, KIND_UNCUT_SUPPORT, 3))
	if not has_uncut_spirit:
		inventory.append(_make_uncut_instance(state, KIND_UNCUT_SPIRIT, 2))
	return inventory


static func _starter_gem_page(state: Object) -> Array:
	var page: Array = []
	page.append(_make_active_instance(state, "fireball", 1))
	page.append(_make_active_instance(state, "storm_lance", 1))
	page.append(_make_active_instance(state, "arc_slash", 1))
	page.append(_make_active_instance(state, "void_rift", 1))
	while page.size() < MAX_ACTIVE_ROWS:
		page.append({})
	return page


static func _starter_hotbar_from_page(page: Array) -> Array:
	var hotbar: Array = []
	for i: int in range(HOTBAR_SIZE):
		if i < page.size() and typeof(page[i]) == TYPE_DICTIONARY and not Dictionary(page[i]).is_empty():
			hotbar.append(str(Dictionary(page[i]).get("uid", "")))
		else:
			hotbar.append("")
	return hotbar


static func _starter_gem_inventory(state: Object) -> Array:
	var out: Array = []
	out.append(_make_support_instance(state, "split_projectile", 1))
	out.append(_make_support_instance(state, "chain_current", 1))
	out.append(_make_support_instance(state, "ignition", 1))
	out.append(_make_support_instance(state, "greater_area", 1))
	out.append(_make_support_instance(state, "controlled_power", 1))
	out.append(_make_support_instance(state, "bleed_edge", 1))
	out.append(_make_uncut_instance(state, KIND_UNCUT_ACTIVE, 3))
	out.append(_make_uncut_instance(state, KIND_UNCUT_SUPPORT, 3))
	out.append(_make_uncut_instance(state, KIND_UNCUT_SPIRIT, 2))
	return out


static func _migrate_old_active_slots(state: Object) -> Array:
	var old_slots: Array = _as_array(_state_get(state, "active_skill_slots", []))
	var page: Array = []
	for value: Variant in old_slots:
		if typeof(value) != TYPE_DICTIONARY:
			continue
		var old: Dictionary = Dictionary(value)
		var gem_id_value: String = str(old.get("gem_id", old.get("active", old.get("active_id", "fireball"))))
		if not ACTIVE_DATA.has(gem_id_value):
			continue
		var active: Dictionary = _make_active_instance(state, gem_id_value, max(1, _to_int(old.get("level", old.get("gem_level", 1)))))
		active["xp"] = max(0, _to_int(old.get("xp", old.get("gem_xp", 0))))
		page.append(active)
	while page.size() < MAX_ACTIVE_ROWS:
		page.append({})
	if page.size() > MAX_ACTIVE_ROWS:
		page.resize(MAX_ACTIVE_ROWS)
	return page


static func _make_active_instance(state: Object, gem_id_value: String, level: int) -> Dictionary:
	var data: Dictionary = active_data(gem_id_value)
	var level_value: int = max(1, level)
	return {
		"uid": _new_uid(state, "active"),
		"kind": KIND_ACTIVE,
		"gem_id": gem_id_value,
		"level": level_value,
		"xp": 0,
		"quality": 0,
		"tags": _as_array(data.get("tags", [])),
		"requirements": Dictionary(data.get("requirements", {})).duplicate(true),
		"weapon_requirements": _as_array(data.get("weapon_requirements", [])),
		"support_socket_count": support_socket_count_for_level(level_value),
		"support_sockets": _empty_socket_array(),
		"enabled": true,
		"hotbar_slot": -1,
	}


static func _make_support_instance(state: Object, gem_id_value: String, level: int) -> Dictionary:
	var data: Dictionary = support_data(gem_id_value)
	return {
		"uid": _new_uid(state, "support"),
		"kind": KIND_SUPPORT,
		"gem_id": gem_id_value,
		"level": max(1, level),
		"xp": 0,
		"quality": 0,
		"tier": max(1, _to_int(data.get("tier", 1))),
		"requires_any": _as_array(data.get("requires_any", [])),
		"forbids_any": _as_array(data.get("forbids_any", [])),
		"equipped_to": "",
		"socket_index": -1,
	}


static func _make_spirit_instance(state: Object, gem_id_value: String, level: int) -> Dictionary:
	var data: Dictionary = spirit_data(gem_id_value)
	var level_value: int = max(1, level)
	return {
		"uid": _new_uid(state, "spirit"),
		"kind": KIND_SPIRIT,
		"gem_id": gem_id_value,
		"level": level_value,
		"xp": 0,
		"quality": 0,
		"tags": _as_array(data.get("tags", [])),
		"reservation": max(0, _to_int(data.get("reservation", 0))),
		"support_socket_count": support_socket_count_for_level(level_value),
		"support_sockets": _empty_socket_array(),
		"enabled": false,
	}


static func _make_uncut_instance(state: Object, kind_value: String, level: int) -> Dictionary:
	return {
		"uid": _new_uid(state, "uncut"),
		"kind": kind_value,
		"gem_level": max(1, level),
		"level": max(1, level),
		"quality": 0,
	}


static func _normalize_page(state: Object, page: Array) -> Array:
	var out: Array = []
	for i: int in range(MAX_ACTIVE_ROWS):
		if i < page.size() and typeof(page[i]) == TYPE_DICTIONARY and not Dictionary(page[i]).is_empty():
			out.append(_normalize_active(state, Dictionary(page[i])))
		else:
			out.append({})
	return out


static func _normalize_active(state: Object, gem: Dictionary) -> Dictionary:
	var gem_id_value: String = str(gem.get("gem_id", gem.get("active", gem.get("active_id", "fireball"))))
	if not ACTIVE_DATA.has(gem_id_value):
		gem_id_value = "fireball"
	var data: Dictionary = active_data(gem_id_value)
	var level_value: int = max(1, _to_int(gem.get("level", gem.get("gem_level", 1))))
	gem["uid"] = _ensure_uid(state, gem, "active")
	gem["kind"] = KIND_ACTIVE
	gem["gem_id"] = gem_id_value
	gem["level"] = level_value
	gem["xp"] = max(0, _to_int(gem.get("xp", gem.get("gem_xp", 0))))
	gem["quality"] = clampi(_to_int(gem.get("quality", 0)), 0, 100)
	gem["tags"] = _as_array(data.get("tags", []))
	gem["requirements"] = Dictionary(data.get("requirements", {})).duplicate(true)
	gem["weapon_requirements"] = _as_array(data.get("weapon_requirements", []))
	gem["support_socket_count"] = support_socket_count_for_level(level_value)
	gem["support_sockets"] = _ensure_socket_array(_as_array(gem.get("support_sockets", [])))
	gem["enabled"] = bool(gem.get("enabled", true))
	return gem


static func _normalize_spirits(state: Object, spirits: Array) -> Array:
	var out: Array = []
	for value: Variant in spirits:
		if typeof(value) == TYPE_DICTIONARY:
			var gem: Dictionary = Dictionary(value)
			var gem_id_value: String = str(gem.get("gem_id", "ember_pact"))
			if not SPIRIT_DATA.has(gem_id_value):
				gem_id_value = "ember_pact"
			var data: Dictionary = spirit_data(gem_id_value)
			var level_value: int = max(1, _to_int(gem.get("level", 1)))
			gem["uid"] = _ensure_uid(state, gem, "spirit")
			gem["kind"] = KIND_SPIRIT
			gem["gem_id"] = gem_id_value
			gem["level"] = level_value
			gem["xp"] = max(0, _to_int(gem.get("xp", 0)))
			gem["quality"] = clampi(_to_int(gem.get("quality", 0)), 0, 100)
			gem["tags"] = _as_array(data.get("tags", []))
			gem["reservation"] = max(0, _to_int(data.get("reservation", gem.get("reservation", 0))))
			gem["support_socket_count"] = support_socket_count_for_level(level_value)
			gem["support_sockets"] = _ensure_socket_array(_as_array(gem.get("support_sockets", [])))
			gem["enabled"] = bool(gem.get("enabled", false))
			out.append(gem)
	return out


static func _normalize_inventory(state: Object, inventory: Array) -> Array:
	var out: Array = []
	for value: Variant in inventory:
		if typeof(value) != TYPE_DICTIONARY:
			continue
		var gem: Dictionary = Dictionary(value)
		var kind_value: String = str(gem.get("kind", ""))
		if kind_value == KIND_SUPPORT:
			var support_id: String = str(gem.get("gem_id", "split_projectile"))
			if not SUPPORT_DATA.has(support_id):
				support_id = "split_projectile"
			var data: Dictionary = support_data(support_id)
			gem["uid"] = _ensure_uid(state, gem, "support")
			gem["kind"] = KIND_SUPPORT
			gem["gem_id"] = support_id
			gem["level"] = max(1, _to_int(gem.get("level", 1)))
			gem["quality"] = clampi(_to_int(gem.get("quality", 0)), 0, 100)
			gem["tier"] = max(1, _to_int(gem.get("tier", data.get("tier", 1))))
			gem["requires_any"] = _as_array(data.get("requires_any", []))
			gem["forbids_any"] = _as_array(data.get("forbids_any", []))
			gem["equipped_to"] = str(gem.get("equipped_to", ""))
			gem["socket_index"] = _to_int(gem.get("socket_index", -1))
			out.append(gem)
		elif kind_value == KIND_UNCUT_ACTIVE or kind_value == KIND_UNCUT_SUPPORT or kind_value == KIND_UNCUT_SPIRIT:
			gem["uid"] = _ensure_uid(state, gem, "uncut")
			gem["kind"] = kind_value
			gem["gem_level"] = max(1, _to_int(gem.get("gem_level", gem.get("level", 1))))
			gem["level"] = max(1, _to_int(gem.get("level", gem.get("gem_level", 1))))
			out.append(gem)
		elif kind_value == KIND_ACTIVE:
			out.append(_normalize_active(state, gem))
	return out


static func _normalize_hotbar(hotbar: Array) -> Array:
	var out: Array = []
	for i: int in range(HOTBAR_SIZE):
		if i < hotbar.size():
			out.append(str(hotbar[i]))
		else:
			out.append("")
	return out


static func _refresh_active_skill_slots_mirror(state: Object) -> void:
	var hotbar: Array = _normalize_hotbar(_as_array(_state_get(state, "hotbar_slots", [])))
	var mirror: Array = []
	for i: int in range(HOTBAR_SIZE):
		var uid: String = str(hotbar[i])
		var active: Dictionary = _find_active_by_uid(state, uid)
		if active.is_empty():
			mirror.append({"active": "fireball", "active_id": "fireball", "gem_id": "fireball", "level": 1, "supports": []})
		else:
			var support_ids: Array = []
			for support: Variant in socketed_support_instances(state, active):
				if typeof(support) == TYPE_DICTIONARY:
					support_ids.append(str(Dictionary(support).get("gem_id", "")))
			mirror.append({
				"uid": uid,
				"active": str(active.get("gem_id", "fireball")),
				"active_id": str(active.get("gem_id", "fireball")),
				"gem_id": str(active.get("gem_id", "fireball")),
				"level": max(1, _to_int(active.get("level", 1))),
				"xp": max(0, _to_int(active.get("xp", 0))),
				"quality": clampi(_to_int(active.get("quality", 0)), 0, 100),
				"supports": support_ids,
				"unlocked_support_sockets": support_socket_count_for_gem(active),
			})
	state.set("active_skill_slots", mirror)
	state.set("selected_skill_slot", clampi(_to_int(_state_get(state, "selected_hotbar_slot", 0)), 0, HOTBAR_SIZE - 1))


static func _recalculate_spirit(state: Object) -> void:
	var spirits: Array = _as_array(_state_get(state, "spirit_gem_slots", []))
	var reserved: int = 0
	for value: Variant in spirits:
		if typeof(value) == TYPE_DICTIONARY:
			var spirit: Dictionary = Dictionary(value)
			if bool(spirit.get("enabled", false)):
				reserved += spirit_reservation(spirit)
	state.set("spirit_reserved", reserved)
	if _state_get(state, "spirit_max", null) == null:
		state.set("spirit_max", 100)


static func _active_spirit_mods(state: Object) -> Dictionary:
	var out: Dictionary = {}
	var spirits: Array = _as_array(_state_get(state, "spirit_gem_slots", []))
	for value: Variant in spirits:
		if typeof(value) != TYPE_DICTIONARY:
			continue
		var spirit: Dictionary = Dictionary(value)
		if not bool(spirit.get("enabled", false)):
			continue
		var data: Dictionary = spirit_data(str(spirit.get("gem_id", "")))
		var mods: Dictionary = Dictionary(data.get("mods", {}))
		for key: Variant in mods.keys():
			out[str(key)] = _to_float(out.get(str(key), 0.0)) + _to_float(mods[key])
	return out


static func _find_active_by_uid(state: Object, uid: String) -> Dictionary:
	if uid == "":
		return {}
	var page: Array = _as_array(_state_get(state, "equipped_gem_page", []))
	for value: Variant in page:
		if typeof(value) == TYPE_DICTIONARY:
			var gem: Dictionary = Dictionary(value)
			if str(gem.get("uid", "")) == uid:
				return gem.duplicate(true)
	var inventory: Array = _as_array(_state_get(state, "gem_inventory", []))
	for inv_value: Variant in inventory:
		if typeof(inv_value) == TYPE_DICTIONARY:
			var inv_gem: Dictionary = Dictionary(inv_value)
			if str(inv_gem.get("uid", "")) == uid and str(inv_gem.get("kind", "")) == KIND_ACTIVE:
				return inv_gem.duplicate(true)
	return {}


static func _find_socket_owner(state: Object, uid: String) -> Dictionary:
	var page: Array = _as_array(_state_get(state, "equipped_gem_page", []))
	for i: int in range(page.size()):
		if typeof(page[i]) == TYPE_DICTIONARY:
			var gem: Dictionary = Dictionary(page[i])
			if str(gem.get("uid", "")) == uid:
				return {"owner": "page", "index": i, "gem": gem.duplicate(true)}
	var spirits: Array = _as_array(_state_get(state, "spirit_gem_slots", []))
	for j: int in range(spirits.size()):
		if typeof(spirits[j]) == TYPE_DICTIONARY:
			var spirit: Dictionary = Dictionary(spirits[j])
			if str(spirit.get("uid", "")) == uid:
				return {"owner": "spirit", "index": j, "gem": spirit.duplicate(true)}
	return {}


static func _save_socket_owner(state: Object, gem: Dictionary, owner: String, index: int) -> void:
	if owner == "page":
		var page: Array = _as_array(_state_get(state, "equipped_gem_page", []))
		if index >= 0 and index < page.size():
			page[index] = gem
			state.set("equipped_gem_page", page)
	elif owner == "spirit":
		var spirits: Array = _as_array(_state_get(state, "spirit_gem_slots", []))
		if index >= 0 and index < spirits.size():
			spirits[index] = gem
			state.set("spirit_gem_slots", spirits)
			_recalculate_spirit(state)


static func _find_support_in_inventory(state: Object, uid: String, available_only: bool = true) -> Dictionary:
	var inventory: Array = _as_array(_state_get(state, "gem_inventory", []))
	for i: int in range(inventory.size()):
		if typeof(inventory[i]) == TYPE_DICTIONARY:
			var gem: Dictionary = Dictionary(inventory[i])
			if str(gem.get("uid", "")) == uid and str(gem.get("kind", "")) == KIND_SUPPORT:
				if available_only and str(gem.get("equipped_to", "")) != "":
					return {}
				return {"index": i, "gem": gem.duplicate(true)}
	return {}


static func _find_any_support_by_uid(state: Object, uid: String) -> Dictionary:
	var result: Dictionary = _find_support_in_inventory(state, uid, false)
	if result.is_empty():
		return {}
	return Dictionary(result.get("gem", {})).duplicate(true)


static func _save_support_inventory_entry(state: Object, support: Dictionary, index: int) -> void:
	var inventory: Array = _as_array(_state_get(state, "gem_inventory", []))
	if index >= 0 and index < inventory.size():
		inventory[index] = support
		state.set("gem_inventory", inventory)


static func _find_inventory_index_by_uid(inventory: Array, uid: String) -> int:
	for i: int in range(inventory.size()):
		if typeof(inventory[i]) == TYPE_DICTIONARY and str(Dictionary(inventory[i]).get("uid", "")) == uid:
			return i
	return -1


static func _find_array_index_by_uid(arr: Array, uid: String) -> int:
	for i: int in range(arr.size()):
		if typeof(arr[i]) == TYPE_DICTIONARY and str(Dictionary(arr[i]).get("uid", "")) == uid:
			return i
	return -1


static func _first_empty_page_row(page: Array) -> int:
	for i: int in range(page.size()):
		if typeof(page[i]) != TYPE_DICTIONARY or Dictionary(page[i]).is_empty():
			return i
	return -1


static func _first_empty_socket(sockets: Array, unlocked: int) -> int:
	for i: int in range(min(unlocked, sockets.size())):
		if str(sockets[i]) == "":
			return i
	return -1


static func _socket_array_for(gem: Dictionary) -> Array:
	return _ensure_socket_array(_as_array(gem.get("support_sockets", [])))


static func _ensure_socket_array(sockets: Array) -> Array:
	var out: Array = []
	for i: int in range(MAX_SUPPORT_SOCKETS):
		if i < sockets.size():
			out.append(str(sockets[i]))
		else:
			out.append("")
	return out


static func _empty_socket_array() -> Array:
	var out: Array = []
	for _i: int in range(MAX_SUPPORT_SOCKETS):
		out.append("")
	return out


static func _copy_without_supports(gem: Dictionary) -> Dictionary:
	var out: Dictionary = gem.duplicate(true)
	out["support_sockets"] = _empty_socket_array()
	return out


static func _generic_gem_display_name(gem: Dictionary) -> String:
	var kind_value: String = str(gem.get("kind", ""))
	if kind_value == KIND_ACTIVE:
		return active_display_name(gem)
	if kind_value == KIND_SUPPORT:
		return support_display_name(gem)
	if kind_value == KIND_SPIRIT:
		return spirit_display_name(gem)
	return str(gem.get("gem_id", kind_value)).replace("_", " ").capitalize()


static func _result(ok: bool, message: String, uid: String) -> Dictionary:
	return {"ok": ok, "message": message, "uid": uid}


static func _set_message(state: Object, message: String) -> void:
	if state == null:
		return
	state.set("gem_last_message", message)
	if state.has_method("add_notice"):
		state.call("add_notice", message)
	else:
		state.set("notice_text", message)
		state.set("notice_time", 2.4)


static func _new_uid(state: Object, prefix: String) -> String:
	var counter: int = max(1, _to_int(_state_get(state, "gem_uid_counter", 1)))
	state.set("gem_uid_counter", counter + 1)
	return prefix + "_gem_" + str(counter)


static func _ensure_uid(state: Object, gem: Dictionary, prefix: String) -> String:
	var uid: String = str(gem.get("uid", ""))
	if uid == "":
		uid = _new_uid(state, prefix)
	return uid


static func _fallback_cast_data() -> Dictionary:
	return {
		"active_id": "fireball",
		"display_name": "Fireball",
		"tags": ["spell", "projectile", "fire", "hit"],
		"level": 1,
		"damage": 20.0,
		"mana_cost": 8.0,
		"cooldown": 0.1,
		"cast_time": 0.25,
		"projectile_count": 1,
		"extra_projectiles": 0,
		"spread": 0.0,
		"chain": 0,
		"pierce": 0,
		"area_mult": 1.0,
		"ignite_chance": 0.10,
		"shock_chance": 0.0,
		"bleed_chance": 0.0,
		"echo_count": 0,
		"mine_count": 1,
		"rules": [],
	}


static func _has_tag(tags: Array, tag: String) -> bool:
	for value: Variant in tags:
		if str(value) == tag:
			return true
	return false


static func _string_array(value: Variant) -> Array[String]:
	var out: Array[String] = []
	for item: Variant in _as_array(value):
		out.append(str(item))
	return out


static func _as_array(value: Variant) -> Array:
	if typeof(value) == TYPE_ARRAY:
		return Array(value)
	return []


static func _state_get(state: Object, key: String, fallback: Variant = null) -> Variant:
	if state == null:
		return fallback
	var value: Variant = state.get(key)
	if value == null:
		return fallback
	return value


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
			return float(int(value))
		TYPE_BOOL:
			return 1.0 if bool(value) else 0.0
		TYPE_STRING:
			var s: String = str(value)
			if s.is_valid_float():
				return s.to_float()
			if s.is_valid_int():
				return float(s.to_int())
			return fallback
		_:
			return fallback

static func collect_spirit_bundle(state: Object) -> Dictionary:
	var bundle: Dictionary = {
		"reserved": 0,
		"stats": {},
		"rules": [],
	}

	if state == null:
		return bundle

	var spirit_entries: Array = []

	var direct_spirits: Variant = state.get("spirit_gems")
	if typeof(direct_spirits) == TYPE_ARRAY:
		for value: Variant in Array(direct_spirits):
			if typeof(value) == TYPE_DICTIONARY:
				spirit_entries.append(Dictionary(value))

	var equipped_page: Variant = state.get("equipped_gem_page")
	if typeof(equipped_page) == TYPE_ARRAY:
		for value: Variant in Array(equipped_page):
			if typeof(value) != TYPE_DICTIONARY:
				continue

			var gem: Dictionary = Dictionary(value)
			var kind: String = str(gem.get("kind", gem.get("gem_type", "")))
			if kind == "spirit_gem" or kind == "spirit":
				spirit_entries.append(gem)

	var legacy_spirits: Variant = state.get("spirit_gem_slots")
	if typeof(legacy_spirits) == TYPE_ARRAY:
		for value: Variant in Array(legacy_spirits):
			if typeof(value) == TYPE_DICTIONARY:
				spirit_entries.append(Dictionary(value))

	var seen_uids: Dictionary = {}

	for spirit: Dictionary in spirit_entries:
		var uid: String = str(spirit.get("uid", spirit.get("gem_uid", spirit.get("gem_id", spirit.get("spirit_id", "")))))
		if uid != "":
			if seen_uids.has(uid):
				continue
			seen_uids[uid] = true

		if not bool(spirit.get("enabled", false)):
			continue

		var gem_id: String = str(spirit.get("gem_id", spirit.get("spirit_id", "")))
		if gem_id == "":
			continue

		var data: Dictionary = _rf_spirit_bundle_data(gem_id)
		var reservation: int = int(spirit.get("reservation", data.get("reservation", 0)))

		bundle["reserved"] = int(bundle.get("reserved", 0)) + maxi(0, reservation)

		_rf_merge_spirit_stats(bundle, Dictionary(data.get("stats", {})))
		_rf_merge_spirit_stats(bundle, Dictionary(spirit.get("stats", {})))

		var data_rules: Variant = data.get("rules", [])
		if typeof(data_rules) == TYPE_ARRAY:
			for rule: Variant in Array(data_rules):
				Array(bundle["rules"]).append(rule)

		var gem_rules: Variant = spirit.get("rules", [])
		if typeof(gem_rules) == TYPE_ARRAY:
			for rule: Variant in Array(gem_rules):
				Array(bundle["rules"]).append(rule)

		Array(bundle["rules"]).append("spirit:" + gem_id)

	return bundle


static func _rf_spirit_bundle_data(gem_id: String) -> Dictionary:
	match gem_id:
		"clarity":
			return {"reservation": 20, "stats": {"Maximum Mana": 10.0, "Mana Regeneration": 3.0}, "rules": []}
		"vitality":
			return {"reservation": 25, "stats": {"Maximum Life": 18.0, "Life Regeneration": 2.0}, "rules": []}
		"iron_skin":
			return {"reservation": 25, "stats": {"Armor": 18.0}, "rules": []}
		"ember_pact":
			return {"reservation": 30, "stats": {"Fire Damage": 18.0, "Ignite Chance": 10.0}, "rules": []}
		"storm_rhythm":
			return {"reservation": 30, "stats": {"Lightning Damage": 15.0, "Chain Bonus": 1.0}, "rules": []}
		"void_tithe":
			return {"reservation": 35, "stats": {"Void Damage": 22.0, "Mana Cost": 8.0}, "rules": []}
		"revenant_guard":
			return {"reservation": 35, "stats": {"Block Chance": 8.0, "Armor": 14.0}, "rules": []}
		"execution_focus":
			return {"reservation": 25, "stats": {"Execute More": 18.0}, "rules": []}
		_:
			return {"reservation": 25, "stats": {}, "rules": []}


static func _rf_merge_spirit_stats(bundle: Dictionary, stats: Dictionary) -> void:
	if not bundle.has("stats") or typeof(bundle["stats"]) != TYPE_DICTIONARY:
		bundle["stats"] = {}

	for key: Variant in stats.keys():
		var raw_key: String = str(key)
		var stat_key: String = _rf_normalize_spirit_stat_key(raw_key)
		var current_value: float = float(Dictionary(bundle["stats"]).get(stat_key, 0.0))
		Dictionary(bundle["stats"])[stat_key] = current_value + float(stats[key])


static func _rf_normalize_spirit_stat_key(key: String) -> String:
	match key:
		"max_health", "health", "life", "maximum_life":
			return "Maximum Life"
		"max_mana", "mana", "maximum_mana":
			return "Maximum Mana"
		"spirit", "spirit_max", "maximum_spirit":
			return "Maximum Spirit"
		"armor":
			return "Armor"
		"movement_speed":
			return "Movement Speed"
		"fire_damage":
			return "Fire Damage"
		"lightning_damage":
			return "Lightning Damage"
		"void_damage":
			return "Void Damage"
		"spell_damage":
			return "Spell Damage"
		"attack_damage":
			return "Attack Damage"
		"mana_regen":
			return "Mana Regeneration"
		"health_regen":
			return "Life Regeneration"
		"ignite_chance":
			return "Ignite Chance"
		"chain_bonus":
			return "Chain Bonus"
		"block_chance":
			return "Block Chance"
		"execute_more":
			return "Execute More"
		"mana_cost":
			return "Mana Cost"
		_:
			return key.replace("_", " ").capitalize()

static func _rf_102a_ensure_fresh_starter_loadout(state: Object) -> void:
	if state == null:
		return

	# Fresh-save testability rule:
	# the player must always have a usable active gem, one spirit gem,
	# several supports, and one uncut gem of each category to test carving.
	var page: Array = _as_array(_state_get(state, "equipped_gem_page", []))
	if page.is_empty():
		page = []
	while page.size() < MAX_ACTIVE_ROWS:
		page.append({})

	var first_uid: String = _rf_102a_first_active_uid(page)
	if first_uid == "":
		var starter_active: Dictionary = _make_active_instance(state, "fireball", 1)
		page[0] = starter_active
		first_uid = str(starter_active.get("uid", ""))
	state.set("equipped_gem_page", page)
	state.set("selected_gem_uid", str(_state_get(state, "selected_gem_uid", first_uid)) if str(_state_get(state, "selected_gem_uid", "")) != "" else first_uid)

	var hotbar: Array = _as_array(_state_get(state, "hotbar_slots", []))
	while hotbar.size() < HOTBAR_SIZE:
		hotbar.append("")
	if str(hotbar[0]) == "" and first_uid != "":
		hotbar[0] = first_uid
	state.set("hotbar_slots", hotbar)
	state.set("selected_hotbar_slot", clampi(_to_int(_state_get(state, "selected_hotbar_slot", 0)), 0, HOTBAR_SIZE - 1))
	state.set("selected_skill_slot", clampi(_to_int(_state_get(state, "selected_skill_slot", 0)), 0, HOTBAR_SIZE - 1))

	var inventory: Array = _as_array(_state_get(state, "gem_inventory", []))
	var starter_supports: Array[String] = [
		"split_projectile",
		"ignition",
		"controlled_power",
		"greater_area",
		"chain_current",
		"life_leech",
	]
	for support_id: String in starter_supports:
		if not _rf_102a_inventory_has_gem(inventory, KIND_SUPPORT, support_id):
			inventory.append(_make_support_instance(state, support_id, 1))

	if not _rf_102a_has_uncut(inventory, KIND_UNCUT_ACTIVE):
		inventory.append(_make_uncut_instance(state, KIND_UNCUT_ACTIVE, 1))
	if not _rf_102a_has_uncut(inventory, KIND_UNCUT_SUPPORT):
		inventory.append(_make_uncut_instance(state, KIND_UNCUT_SUPPORT, 1))
	if not _rf_102a_has_uncut(inventory, KIND_UNCUT_SPIRIT):
		inventory.append(_make_uncut_instance(state, KIND_UNCUT_SPIRIT, 1))
	state.set("gem_inventory", inventory)

	var spirits: Array = _as_array(_state_get(state, "spirit_gem_slots", []))
	if not _rf_102a_has_spirit(spirits, "ember_pact"):
		spirits.append(_make_spirit_instance(state, "ember_pact", 1))
	state.set("spirit_gem_slots", spirits)

	if str(_state_get(state, "gem_last_message", "")) == "" or str(_state_get(state, "gem_last_message", "")) == "Gem system ready.":
		_set_message(state, "Starter gem loadout granted: Fireball, Ember Pact, supports, and uncut gems.")

	_recalculate_spirit(state)
	_refresh_active_skill_slots_mirror(state)


static func _rf_102a_inventory_has_gem(inventory: Array, kind_value: String, gem_id_value: String) -> bool:
	for value: Variant in inventory:
		if typeof(value) != TYPE_DICTIONARY:
			continue
		var gem: Dictionary = Dictionary(value)
		if str(gem.get("kind", "")) == kind_value and str(gem.get("gem_id", "")) == gem_id_value and str(gem.get("equipped_to", "")) == "":
			return true
	return false


static func _rf_102a_has_uncut(inventory: Array, kind_value: String) -> bool:
	for value: Variant in inventory:
		if typeof(value) == TYPE_DICTIONARY and str(Dictionary(value).get("kind", "")) == kind_value:
			return true
	return false


static func _rf_102a_has_spirit(spirits: Array, gem_id_value: String) -> bool:
	for value: Variant in spirits:
		if typeof(value) == TYPE_DICTIONARY and str(Dictionary(value).get("gem_id", "")) == gem_id_value:
			return true
	return false


static func _rf_102a_first_active_uid(page: Array) -> String:
	for value: Variant in page:
		if typeof(value) != TYPE_DICTIONARY:
			continue
		var gem: Dictionary = Dictionary(value)
		if gem.is_empty():
			continue
		if str(gem.get("kind", "")) == KIND_ACTIVE:
			var uid: String = str(gem.get("uid", ""))
			if uid != "":
				return uid
	return ""

static func make_gem_item_from_drop(drop_or_kind: Variant, gem_id_arg: String = "") -> Dictionary:
	var source_kind: String = ""
	var gem_id_value: String = ""
	var gem_level: int = 1

	if typeof(drop_or_kind) == TYPE_DICTIONARY:
		var drop: Dictionary = Dictionary(drop_or_kind)
		source_kind = str(drop.get("kind", drop.get("item_kind", "")))
		gem_id_value = str(drop.get("gem_id", gem_id_arg))
		gem_level = maxi(1, int(drop.get("gem_level", drop.get("level", 1))))
	else:
		source_kind = str(drop_or_kind)
		gem_id_value = gem_id_arg

	var uncut_kind: String = "uncut_skill_gem"
	var display_type: String = "Uncut Skill Gem"
	var can_create: String = "active"

	match source_kind:
		"active_gem", "skill_gem", "active", "skill", "uncut_skill_gem", "uncut_active_gem":
			uncut_kind = "uncut_skill_gem"
			display_type = "Uncut Skill Gem"
			can_create = "active"
		"support_gem", "support", "uncut_support_gem":
			uncut_kind = "uncut_support_gem"
			display_type = "Uncut Support Gem"
			can_create = "support"
		"spirit_gem", "spirit", "uncut_spirit_gem":
			uncut_kind = "uncut_spirit_gem"
			display_type = "Uncut Spirit Gem"
			can_create = "spirit"
		_:
			if source_kind.find("support") >= 0:
				uncut_kind = "uncut_support_gem"
				display_type = "Uncut Support Gem"
				can_create = "support"
			elif source_kind.find("spirit") >= 0:
				uncut_kind = "uncut_spirit_gem"
				display_type = "Uncut Spirit Gem"
				can_create = "spirit"

	var uid: String = uncut_kind + "_" + str(Time.get_ticks_msec()) + "_" + str(randi() % 100000)

	return {
		"uid": uid,
		"id": uid,
		"kind": uncut_kind,
		"item_kind": uncut_kind,
		"category": "gem",
		"slot": "",
		"rarity": "gem",
		"gem_id": gem_id_value,
		"gem_level": gem_level,
		"gem_tier": gem_level,
		"level": gem_level,
		"can_create": can_create,
		"display_name": display_type + " Lv. " + str(gem_level),
		"name": display_type + " Lv. " + str(gem_level),
		"label": display_type + " Lv. " + str(gem_level),
		"description": "Use at the Gem Bench to carve this into a " + can_create + " gem.",
		"identified": true,
		"new_item": true,
		"favorite": false,
		"locked": false,
		"grid_w": 1,
		"grid_h": 1,
	}
