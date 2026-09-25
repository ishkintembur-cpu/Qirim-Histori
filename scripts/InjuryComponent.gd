extends Node

## Qırım Histori
## Система локальных ранений.
## Ранения влияют на состояние персонажа,
## а позже будут связаны с анимациями и боевыми возможностями.

signal injury_received(body_part: BodyPart, damage: float)
signal body_part_disabled(body_part: BodyPart)


enum BodyPart {
	HEAD,
	TORSO,
	LEFT_ARM,
	RIGHT_ARM,
	LEFT_LEG,
	RIGHT_LEG
}


@export var max_part_health: float = 100.0
@export var severe_injury_threshold: float = 30.0


var part_health: Dictionary = {}


func _ready() -> void:
	for body_part in BodyPart.values():
		part_health[body_part] = max_part_health


func apply_injury(body_part: BodyPart, damage: float) -> void:
	if damage <= 0.0:
		return

	if not part_health.has(body_part):
		return

	part_health[body_part] = max(
		part_health[body_part] - damage,
		0.0
	)

	injury_received.emit(body_part, damage)

	if part_health[body_part] <= severe_injury_threshold:
		body_part_disabled.emit(body_part)


func get_part_health(body_part: BodyPart) -> float:
	if not part_health.has(body_part):
		return 0.0

	return part_health[body_part]


func get_part_health_percent(body_part: BodyPart) -> float:
	if not part_health.has(body_part):
		return 0.0

	if max_part_health <= 0.0:
		return 0.0

	return part_health[body_part] / max_part_health


func is_part_severely_injured(body_part: BodyPart) -> bool:
	return get_part_health(body_part) <= severe_injury_threshold


func restore_part(body_part: BodyPart, amount: float) -> void:
	if amount <= 0.0:
		return

	if not part_health.has(body_part):
		return

	part_health[body_part] = min(
		part_health[body_part] + amount,
		max_part_health
	)


func restore_all() -> void:
	for body_part in BodyPart.values():
		part_health[body_part] = max_part_health
