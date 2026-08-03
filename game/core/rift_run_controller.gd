class_name RiftRunController
extends RefCounted

enum Status { IDLE, ACTIVE, COMPLETE, FAILED }

var status: Status = Status.IDLE
var wave_index: int = 0
var run_index: int = 0

func start() -> bool:
	if status == Status.ACTIVE:
		return false
	run_index += 1
	wave_index = 1
	status = Status.ACTIVE
	return true

func next_wave() -> bool:
	if status != Status.ACTIVE or wave_index >= RiftRules.TOTAL_WAVES:
		return false
	wave_index += 1
	return true

func complete() -> void:
	if status == Status.ACTIVE:
		status = Status.COMPLETE

func fail() -> void:
	if status == Status.ACTIVE:
		status = Status.FAILED

func exit() -> void:
	if status != Status.ACTIVE:
		status = Status.IDLE
		wave_index = 0

