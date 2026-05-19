extends RichTextLabel

const UIFoundationSystemScript := preload("res://scripts/systems/UIFoundationSystem3D.gd")

var item_data: Dictionary = {}
var compare_data: Dictionary = {}

func _ready() -> void:
	bbcode_enabled = true
	scroll_active = true
	fit_content = false
	custom_minimum_size = Vector2(300, 260)
	_refresh()

func set_item(item: Dictionary, compare_item: Dictionary = {}) -> void:
	item_data = item.duplicate(true)
	compare_data = compare_item.duplicate(true)
	_refresh()

func clear_item() -> void:
	item_data = {}
	compare_data = {}
	_refresh()

func _refresh() -> void:
	text = UIFoundationSystemScript.item_card_text(item_data, compare_data)
