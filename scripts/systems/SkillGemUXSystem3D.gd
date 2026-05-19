extends RefCounted

const MAX_SUPPORT_SOCKETS: int = 6
const STARTING_SUPPORT_SOCKETS: int = 2
const SOCKET_INTERVAL: int = 5

static func panel_hint() -> String:
	return "[b]Skill Gems[/b] Active gems are usable skills. Supports socket into active gems. Spirit gems reserve spirit and can be toggled."

static func selected_skill_detail(state: Object) -> String:
	if state == null:
		return "[i]No skill state bound.[/i]"
	var slots: Array = Array(_state_get(state, "active_skill_slots", []))
	if slots.is_empty():
		return "[i]No active skill gems installed.[/i]"
	var selected: int = clampi(_safe_int(_state_get(state, "selected_skill_slot", 0), 0), 0, max(0, slots.size() - 1))
	if selected < 0 or selected >= slots.size() or typeof(slots[selected]) != TYPE_DICTIONARY:
		return "[i]Select an active skill gem.[/i]"
	var slot: Dictionary = Dictionary(slots[selected])
	var lines: PackedStringArray = []
	lines.append("[b]Selected Active Skill[/b]")
	lines.append(active_summary(slot, selected))
	lines.append("")
	lines.append(support_socket_summary(slot))
	var supports: Array = Array(slot.get("supports", []))
	if supports.is_empty():
		lines.append("[i]No supports socketed. Right-click a support gem to socket it into the selected active skill.[/i]")
	else:
		lines.append("[b]Socketed Supports[/b]")
		for support_value: Variant in supports:
			lines.append("• " + support_summary(support_value))
	lines.append("")
	lines.append(spirit_overview(state))
	return "\n".join(lines)

static func loadout_overview(state: Object) -> String:
	if state == null:
		return ""
	var slots: Array = Array(_state_get(state, "active_skill_slots", []))
	var selected: int = _safe_int(_state_get(state, "selected_skill_slot", 0), 0)
	var lines: PackedStringArray = []
	lines.append("[b]Loadout[/b]")
	for i: int in range(slots.size()):
		if typeof(slots[i]) != TYPE_DICTIONARY:
			continue
		var prefix: String = "▶ " if i == selected else "  "
		lines.append(prefix + active_summary(Dictionary(slots[i]), i))
	return "\n".join(lines)

static func active_summary(slot: Dictionary, index: int = -1) -> String:
	var id: String = active_id(slot)
	var level: int = max(1, _safe_int(slot.get("level", 1), 1))
	var xp: int = max(0, _safe_int(slot.get("xp", 0), 0))
	var quality: int = clampi(_safe_int(slot.get("quality", 0), 0), 0, 100)
	var supports: Array = Array(slot.get("supports", []))
	var socket_count: int = unlocked_support_sockets(level)
	var slot_text: String = "Slot " + str(index + 1) + ": " if index >= 0 else ""
	return slot_text + gem_label(id) + " · Lv " + str(level) + " · XP " + str(xp) + "/" + str(xp_to_next(level)) + " · Q+" + str(quality) + "% · Supports " + str(supports.size()) + "/" + str(socket_count)

static func support_socket_summary(slot: Dictionary) -> String:
	var level: int = max(1, _safe_int(slot.get("level", 1), 1))
	var supports: Array = Array(slot.get("supports", []))
	var socket_count: int = unlocked_support_sockets(level)
	var line: String = "[b]Support Sockets[/b] " + str(supports.size()) + "/" + str(socket_count)
	if socket_count < MAX_SUPPORT_SOCKETS:
		line += " · next socket at gem level " + str(next_socket_unlock_level(level))
	else:
		line += " · all sockets unlocked"
	return line

static func support_summary(value: Variant) -> String:
	if typeof(value) == TYPE_DICTIONARY:
		var d: Dictionary = Dictionary(value)
		var id: String = support_id(value)
		var level: int = max(1, _safe_int(d.get("level", 1), 1))
		var quality: int = clampi(_safe_int(d.get("quality", 0), 0), 0, 100)
		return gem_label(id) + " · Lv " + str(level) + " · Q+" + str(quality) + "%"
	return gem_label(str(value))

static func spirit_overview(state: Object) -> String:
	var spirits: Array = Array(_state_get(state, "spirit_gem_slots", []))
	var max_spirit: int = _safe_int(_state_get(state, "spirit_max", 100), 100)
	var reserved: int = _safe_int(_state_get(state, "spirit_reserved", 0), 0)
	var lines: PackedStringArray = []
	lines.append("[b]Spirit[/b] " + str(reserved) + "/" + str(max_spirit) + " reserved")
	if spirits.is_empty():
		lines.append("[i]No spirit gems installed.[/i]")
	else:
		for spirit_value: Variant in spirits:
			if typeof(spirit_value) != TYPE_DICTIONARY:
				continue
			var spirit: Dictionary = Dictionary(spirit_value)
			var enabled: String = "ON" if bool(spirit.get("enabled", false)) else "OFF"
			lines.append("• " + gem_label(str(spirit.get("gem_id", spirit.get("id", "spirit")))) + " · " + enabled)
	return "\n".join(lines)

static func active_id(slot: Dictionary) -> String:
	return str(slot.get("gem_id", slot.get("active", slot.get("active_id", "unknown_skill"))))

static func support_id(value: Variant) -> String:
	if typeof(value) == TYPE_DICTIONARY:
		var d: Dictionary = Dictionary(value)
		return str(d.get("gem_id", d.get("support_id", d.get("id", "support"))))
	return str(value)

static func gem_label(id: String) -> String:
	var clean: String = id.strip_edges().replace("_", " ")
	if clean == "":
		return "Unknown Gem"
	var parts: PackedStringArray = clean.split(" ", false)
	for i: int in range(parts.size()):
		if parts[i].length() > 0:
			parts[i] = parts[i].substr(0, 1).to_upper() + parts[i].substr(1).to_lower()
	return " ".join(parts)

static func xp_to_next(level: int) -> int:
	return max(80, max(1, level) * 100)

static func unlocked_support_sockets(level: int) -> int:
	return clampi(STARTING_SUPPORT_SOCKETS + int(max(1, level) / SOCKET_INTERVAL), STARTING_SUPPORT_SOCKETS, MAX_SUPPORT_SOCKETS)

static func next_socket_unlock_level(level: int) -> int:
	var sockets: int = unlocked_support_sockets(level)
	if sockets >= MAX_SUPPORT_SOCKETS:
		return level
	return max(1, sockets - STARTING_SUPPORT_SOCKETS + 1) * SOCKET_INTERVAL

static func _state_get(state: Object, key: String, fallback: Variant = null) -> Variant:
	if state == null:
		return fallback
	var value: Variant = state.get(key)
	return fallback if value == null else value

static func _safe_int(value: Variant, fallback: int = 0) -> int:
	if value == null:
		return fallback
	match typeof(value):
		TYPE_INT:
			return value
		TYPE_FLOAT:
			return int(round(value))
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
