extends RefCounted

const SCRIPT_PATH: String = "res://game/core/health_component.gd"

var death_count: int = 0
var change_count: int = 0

func run(support: TestSupport) -> void:
	var health_script: Variant = load(SCRIPT_PATH)
	support.expect(health_script != null, "health component must load")
	if health_script == null:
		return
	var health: Variant = health_script.new(10, 0.5)
	health.died.connect(func() -> void: death_count += 1)
	health.changed.connect(func(_current: int, _maximum: int) -> void: change_count += 1)
	support.expect(health.current == 10 and health.maximum == 10, "health must start full")
	support.expect(health.damage(3) and health.current == 7, "damage must reduce current health")
	support.expect(health.is_invulnerable(), "successful damage must start invulnerability")
	support.expect(not health.damage(3) and health.current == 7, "damage during invulnerability must be ignored")
	health.advance(0.5)
	support.expect(health.damage(2) and health.current == 5, "damage must resume after invulnerability expires")
	support.expect(health.heal(99) and health.current == 10, "healing must clamp at maximum")
	health.advance(0.5)
	support.expect(health.damage(10) and health.current == 0 and health.is_dead(), "lethal damage must enter dead state")
	support.expect(death_count == 1, "lethal damage must emit death exactly once")
	support.expect(not health.damage(1), "dead health must reject repeated damage")
	support.expect(death_count == 1, "repeated death must not emit twice")
	health.revive(6)
	support.expect(health.current == 6 and not health.is_dead(), "revive must begin a new living state")
	support.expect(health.set_maximum(14, true) and health.maximum == 14 and health.current == 10, "maximum-health growth may preserve missing health")
	support.expect(not health.damage(0) and change_count >= 5, "nonpositive damage must be rejected while real mutations emit changes")
