class_name RVLootFilterSystem3D
extends RefCounted

const EndgameScript: GDScript = preload("res://scripts/systems/ItemEndgameSystem3D.gd")
const ItemizationScript: GDScript = preload("res://scripts/systems/ItemizationSystem3D.gd")

static func priority_for_item(item: Dictionary) -> int:
	if item.is_empty():
		return 0
	if ItemizationScript.is_equipment(item):
		return EndgameScript.endgame_loot_priority(item)
	var kind: String = str(item.get("kind", item.get("item_kind", "")))
	if kind.find("gem") >= 0:
		return 85
	if kind == "map" or kind.find("waystone") >= 0:
		return 80
	if kind == "currency" or kind == "material":
		return 70
	return 10

static func label_for_item(item: Dictionary) -> String:
	var p: int = priority_for_item(item)
	if p >= 115:
		return "CHASE · always show"
	if p >= 95:
		return "UNIQUE/BOSS · gold beam"
	if p >= 80:
		return "IMPORTANT · strong label"
	if p >= 65:
		return "VALUABLE · show"
	if p >= 35:
		return "OPTIONAL"
	return "FILTERED LATER"

static func should_show_item(item: Dictionary) -> bool:
	return priority_for_item(item) >= 25

static func drop_label(drop: Dictionary) -> String:
	if drop.is_empty():
		return "Loot"
	var kind: String = str(drop.get("kind", ""))
	if kind == "item" and typeof(drop.get("item", {})) == TYPE_DICTIONARY:
		var item: Dictionary = ItemizationScript.normalize_item(Dictionary(drop.get("item", {})))
		return str(item.get("display_name", "Item")) + " · " + label_for_item(item)
	if kind == "material":
		return EndgameScript.material_label(str(drop.get("material_id", "material")))
	return str(drop.get("label", "Loot"))
