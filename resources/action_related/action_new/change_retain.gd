extends Action
class_name ChangeRetainAction

@export var retain_name: String
@export var change_amount: int = 0

static var _retain_cache := {}

func open() -> void:
	super.open()

	var retain: Retain = _get_retain_instance(retain_name)
	if retain:
		retain._value += change_amount
		print("[ChangeRetainAction] '%s' changed by %+d -> now %d" % [retain_name, change_amount, retain._value])
	else:
		push_warning("[ChangeRetainAction] Retain not found: %s" % retain_name)

	call_deferred("_complete")


func _get_retain_instance(name: String) -> Retain:
	if not _retain_cache.has(name):
		var path := "res://resources/action_related/action_new/story_retains/%s.tres" % name
		var res := load(path) as Retain
		if res:
			_retain_cache[name] = res
		else:
			push_warning("Retain file not found: %s" % path)
			return null
	return _retain_cache[name]
