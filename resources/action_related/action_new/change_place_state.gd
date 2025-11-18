extends Action
class_name ChangePlaceState

@export var place_name: String = ""   
@export var state_name: String = "" 
@export var target_value_name: String = ""

var _place_ref: Place = null

func create(character_: NPCActions, place_name_: String, state_name_: String, target_value_name_: String) -> ChangePlaceState:
	character = character_
	place_name = place_name_
	state_name = state_name_
	target_value_name = target_value_name_
	return self

func open() -> void:
	for node in character.get_tree().get_nodes_in_group("Places"):
		if node.name == place_name:
			_place_ref = node
			break

	if not _place_ref:
		push_warning("ChangePlaceProperty: place '%s' not found!" % place_name)
		_complete()
		return

	var final_value: Variant = target_value_name
	if _place_ref.has_meta("_enums"):
		var enums: Dictionary = _place_ref.get_meta("_enums")
		if enums.has(state_name):
			var enum_dict: Dictionary = enums[state_name]
			if enum_dict.has(target_value_name):
				final_value = enum_dict[target_value_name]

	if _place_ref.has_method("set_state"):
		_place_ref.set_state(final_value)
	else:
		push_warning("Place '%s' has no set_state method" % place_name)

	_complete()

func update(_delta: float) -> void:
	pass

func close() -> void:
	action_closed.emit()
