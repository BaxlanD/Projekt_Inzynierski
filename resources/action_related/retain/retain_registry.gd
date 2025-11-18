extends Node
class_name RetainRegistry

var retains := {}

func get_retain(name: String) -> Retain:
	if not retains.has(name):
		var path = "res://resources/action_related/action_new/story_retains/%s.tres" % name
		var res = load(path) as Retain
		if res:
			retains[name] = res
		else:
			push_warning("Retain not found: %s" % name)
			return null
	return retains[name]
