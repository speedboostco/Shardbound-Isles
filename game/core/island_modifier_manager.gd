class_name IslandModifierManager
extends RefCounted

var _components: Array[RefCounted] = []
var _definitions: Array[Dictionary] = []
var _effects: Dictionary = {}

func sync(modifier_ids: Array[String], context: Dictionary) -> bool:
	clear()
	for modifier_id: String in modifier_ids:
		var definition := IslandModifierRegistry.definition(modifier_id)
		if definition.is_empty():
			clear()
			return false
		var script := load(String(definition.script_path)) as Script
		if script == null or not script.can_instantiate():
			clear()
			return false
		var component := script.new() as RefCounted
		var component_effects: Dictionary = component.effects(context)
		for key: String in component_effects:
			if _effects.has(key) and component_effects[key] is float:
				_effects[key] = float(_effects[key]) * float(component_effects[key])
			elif _effects.has(key) and component_effects[key] is int:
				_effects[key] = int(_effects[key]) + int(component_effects[key])
			else:
				_effects[key] = component_effects[key]
		_components.append(component)
		_definitions.append(definition)
	return true

func clear() -> void:
	_components.clear()
	_definitions.clear()
	_effects.clear()

func effects() -> Dictionary:
	return _effects.duplicate(true)

func active_ids() -> Array[String]:
	var result: Array[String] = []
	for definition: Dictionary in _definitions:
		result.append(String(definition.id))
	return result

func indicators() -> Array[String]:
	var result: Array[String] = []
	for definition: Dictionary in _definitions:
		result.append(String(definition.indicator))
	return result
