class_name LumberMillSimulation
extends RefCounted

const INPUT_PER_CYCLE: int = 2
const OUTPUT_PER_CYCLE: int = 1
const INTERVAL_SECONDS: float = 3.0
const INPUT_CAPACITY: int = 12
const OUTPUT_CAPACITY: int = 8

var input_wood: int = 0
var output_planks: int = 0
var progress_seconds: float = 0.0
var blocked_output: bool = false

func add_input(amount: int) -> int:
	var accepted := mini(maxi(0, amount), INPUT_CAPACITY - input_wood)
	input_wood += accepted
	return amount - accepted

func advance(delta_seconds: float) -> Dictionary:
	if delta_seconds <= 0.0:
		return {"cycles": 0, "wood_consumed": 0, "planks_produced": 0}
	if input_wood < INPUT_PER_CYCLE:
		progress_seconds = 0.0
		blocked_output = false
		return {"cycles": 0, "wood_consumed": 0, "planks_produced": 0}
	if output_planks + OUTPUT_PER_CYCLE > OUTPUT_CAPACITY:
		blocked_output = true
		return {"cycles": 0, "wood_consumed": 0, "planks_produced": 0}
	progress_seconds += delta_seconds
	var cycles := mini(int(floor((progress_seconds + 0.000001) / INTERVAL_SECONDS)), mini(input_wood / INPUT_PER_CYCLE, (OUTPUT_CAPACITY - output_planks) / OUTPUT_PER_CYCLE))
	if cycles > 0:
		input_wood -= cycles * INPUT_PER_CYCLE
		output_planks += cycles * OUTPUT_PER_CYCLE
		progress_seconds -= float(cycles) * INTERVAL_SECONDS
	blocked_output = input_wood >= INPUT_PER_CYCLE and output_planks + OUTPUT_PER_CYCLE > OUTPUT_CAPACITY
	if blocked_output:
		progress_seconds = minf(progress_seconds, INTERVAL_SECONDS)
	return {"cycles": cycles, "wood_consumed": cycles * INPUT_PER_CYCLE, "planks_produced": cycles * OUTPUT_PER_CYCLE}

func take_output(amount: int) -> int:
	var taken := mini(maxi(0, amount), output_planks)
	output_planks -= taken
	if taken > 0:
		blocked_output = false
	return taken

func progress_ratio() -> float:
	return clampf(progress_seconds / INTERVAL_SECONDS, 0.0, 1.0)

func to_dictionary() -> Dictionary:
	return {"input_wood": input_wood, "output_planks": output_planks, "progress_seconds": progress_seconds, "blocked_output": blocked_output}

func restore(data: Dictionary) -> bool:
	var input_value := int(data.get("input_wood", -1))
	var output_value := int(data.get("output_planks", -1))
	var progress_value := float(data.get("progress_seconds", -1.0))
	if input_value < 0 or input_value > INPUT_CAPACITY or output_value < 0 or output_value > OUTPUT_CAPACITY or progress_value < 0.0 or progress_value > INTERVAL_SECONDS:
		return false
	input_wood = input_value
	output_planks = output_value
	progress_seconds = progress_value
	blocked_output = bool(data.get("blocked_output", false))
	return true

