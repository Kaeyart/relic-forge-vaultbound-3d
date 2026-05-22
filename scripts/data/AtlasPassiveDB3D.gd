class_name RVAtlasPassiveDB3D
extends RefCounted

const NODES: Dictionary = {
	"atlas_start": {"name": "Vault Cartography", "region": "center", "type": "start", "requires": [], "stats": {}, "rules": [], "description": "The center of your Atlas specialization."},

	"waystone_supply_1": {"name": "Stone Memory", "region": "waystones", "type": "small", "requires": ["atlas_start"], "stats": {"Waystone Drop Chance": 8.0}, "rules": [], "description": "Map bosses are more likely to drop Waystones."},
	"waystone_supply_2": {"name": "Deep Cartographer", "region": "waystones", "type": "notable", "requires": ["waystone_supply_1"], "stats": {"Waystone Drop Chance": 14.0}, "rules": ["atlas_waystone_plus_tier_chance"], "description": "Waystones have a chance to drop one tier higher."},
	"waystone_safe_path": {"name": "Safer Routes", "region": "waystones", "type": "small", "requires": ["waystone_supply_1"], "stats": {"Map Danger Reduction": 4.0}, "rules": [], "description": "Slightly reduces map danger score."},

	"tablet_supply_1": {"name": "Tablet Scraps", "region": "tablets", "type": "small", "requires": ["atlas_start"], "stats": {"Tablet Drop Chance": 8.0}, "rules": [], "description": "More Precursor Tablets from map bosses."},
	"tablet_charge_1": {"name": "Lingering Script", "region": "tablets", "type": "notable", "requires": ["tablet_supply_1"], "stats": {}, "rules": ["atlas_tablets_plus_charge"], "description": "Tablets dropped in your maps gain +1 charge."},
	"tablet_greed": {"name": "Tablet Greed", "region": "tablets", "type": "keystone", "requires": ["tablet_charge_1"], "stats": {"Tablet Drop Chance": 20.0, "Map Monster Damage": 8.0}, "rules": ["atlas_tablet_greed_keystone"], "description": "Much more tablet economy, but monsters hit harder."},

	"boss_relics_1": {"name": "Relic Pressure", "region": "bossing", "type": "small", "requires": ["atlas_start"], "stats": {"Boss Relic Chance": 6.0}, "rules": [], "description": "Bosses are more likely to drop relics or relic fragments."},
	"boss_relics_2": {"name": "Warden's Hoard", "region": "bossing", "type": "notable", "requires": ["boss_relics_1"], "stats": {"Boss Relic Chance": 12.0, "Item Rarity": 10.0}, "rules": ["atlas_powerful_boss_rewards"], "description": "Powerful boss nodes become more rewarding."},
	"boss_danger_reward": {"name": "Bloodied Vaults", "region": "bossing", "type": "keystone", "requires": ["boss_relics_2"], "stats": {"Boss Relic Chance": 18.0, "Map Monster Damage": 10.0}, "rules": ["atlas_boss_greed_keystone"], "description": "Bosses are more dangerous and more rewarding."},

	"gem_veins_1": {"name": "Gem Veins", "region": "gems", "type": "small", "requires": ["atlas_start"], "stats": {"Uncut Gem Chance": 10.0}, "rules": [], "description": "More Uncut Gems from maps."},
	"gem_veins_2": {"name": "Faceted Vaults", "region": "gems", "type": "notable", "requires": ["gem_veins_1"], "stats": {"Uncut Gem Chance": 15.0}, "rules": ["atlas_support_spirit_gem_bias"], "description": "More support and spirit gem opportunities."},
	"gem_overflow": {"name": "Gem Overflow", "region": "gems", "type": "keystone", "requires": ["gem_veins_2"], "stats": {"Uncut Gem Chance": 30.0, "Item Quantity": -5.0}, "rules": ["atlas_gem_overflow_keystone"], "description": "Strongly biases maps toward gem rewards, at the cost of generic loot."},

	"forge_seams_1": {"name": "Deep Seams", "region": "forge", "type": "small", "requires": ["atlas_start"], "stats": {"Forge Material Chance": 10.0}, "rules": [], "description": "More forge materials from maps."},
	"forge_seams_2": {"name": "Relic Ore", "region": "forge", "type": "notable", "requires": ["forge_seams_1"], "stats": {"Forge Material Chance": 18.0}, "rules": ["atlas_high_potential_bases"], "description": "Better chance for high forge-potential bases."},
	"forge_greed": {"name": "Greed of the Forge", "region": "forge", "type": "keystone", "requires": ["forge_seams_2"], "stats": {"Forge Material Chance": 28.0, "Map Monster Damage": 8.0}, "rules": ["atlas_forge_greed_keystone"], "description": "More forge economy, more danger."},
}

const REGIONS: Array[String] = ["center", "waystones", "tablets", "bossing", "gems", "forge"]

static func all_nodes() -> Dictionary:
	return NODES.duplicate(true)

static func node(id: String) -> Dictionary:
	if NODES.has(id):
		var out: Dictionary = Dictionary(NODES[id]).duplicate(true)
		out["id"] = id
		return out
	return {}

static func nodes_for_region(region: String) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for id: Variant in NODES.keys():
		var n: Dictionary = node(str(id))
		if str(n.get("region", "")) == region:
			out.append(n)
	return out
