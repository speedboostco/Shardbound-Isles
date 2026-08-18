class_name RenewableForageState
extends RefCounted

var available: bool = true
var regrow_remaining: float = 0.0

func deplete(regrow_seconds: float) -> bool:
	if not available or regrow_seconds <= 0.0:
		return false
	available = false
	regrow_remaining = regrow_seconds
	return true

func advance(delta: float) -> bool:
	if available or delta <= 0.0:
		return false
	regrow_remaining = maxf(0.0, regrow_remaining - delta)
	if regrow_remaining > 0.0:
		return false
	available = true
	return true

func to_dictionary() -> Dictionary:
	return {"available": available, "regrow_remaining": regrow_remaining}

func restore(data: Dictionary, maximum_regrow: float) -> bool:
	if not data.get("available") is bool or not (data.get("regrow_remaining") is int or data.get("regrow_remaining") is float):
		return false
	var saved_remaining := float(data.regrow_remaining)
	if maximum_regrow <= 0.0 or saved_remaining < 0.0 or saved_remaining > maximum_regrow:
		return false
	if bool(data.available) and saved_remaining > 0.0:
		return false
	if not bool(data.available) and saved_remaining <= 0.0:
		return false
	available = bool(data.available)
	regrow_remaining = saved_remaining
	return true

static func default_state() -> Dictionary:
	return {"available": true, "regrow_remaining": 0.0}
