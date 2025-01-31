class_name VersionHint


static func are_equal(a: String, b: String):
	if a == b:
		return true
	return parse(a).eq(parse(b))


static func same_version(a: String, b: String):
	return parse(a).version == parse(b).version


static func parse(version_hint: String) -> Item:
	var tags = version_hint.to_lower().split(" ")
	var item = Item.new()
	var parsers = [
		_ParsedVersion.new(),
		_ParsedIsMono.new(),
		_ParsedStage.new(PackedStringArray([
			"stable",
			"dev",
			"rc",
			"alpha",
			"beta",
			"pre-alpha"
		]))
	]
	for parser in parsers:
		parser.fill(item, tags)
	return item


static func _as_version(tag: String):
	if tag.begins_with("v") and tag.substr(1, 3).is_valid_float():
		return tag.substr(1)
	elif tag.substr(0, 3).is_valid_float():
		return tag
	else:
		return null


static func _is_version(tag: String):
	return _as_version(tag) != null


class Item:
	var version
	var stage = 'stable'
	var is_mono = false
	var is_valid = false

	func eq(other: Item):
		if not self.is_valid:
			return false
		if not other.is_valid:
			return false
		return self.version == other.version and self.stage == other.stage and self.is_mono == other.is_mono


class _ParsedVersion:
	func fill(item: Item, tags: PackedStringArray):
		for tag in tags:
			var version = VersionHint._as_version(tag)
			if version != null:
				item.version = version
				item.is_valid = true
				return
		item.is_valid = false


class _ParsedStage:
	var _known_stages: PackedStringArray

	func _init(known_stages: PackedStringArray):
		_known_stages = known_stages

	func fill(item: Item, tags: PackedStringArray):
		for tag in tags:
			if VersionHint._is_version(tag):
				continue
			if tag == 'mono':
				continue
			if tag in _known_stages:
				item.stage = tag


class _ParsedIsMono:
	func fill(item: Item, tags: PackedStringArray):
		for tag in tags:
			if tag == 'mono':
				item.is_mono = true
				return
		item.is_mono = false
