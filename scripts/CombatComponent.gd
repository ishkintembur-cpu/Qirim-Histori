extends Node

## Qırım Histori
## Базовая система ближнего боя.
## Позже сюда добавим сабли, две сабли, кинжал,
## блокирование, парирование и разные типы оружия.

signal attack_started
signal attack_finished
signal attack_hit(target, damage: float)
signal attack_blocked

@export var attack_damage: float = 25.0
@export var attack_stamina_cost: float = 15.0
@export var attack_cooldown: float = 0.7

var can_attack: bool = true
var is_attacking: bool = false
var is_blocking: bool = false


func attack() -> bool:
	if not can_attack:
		return false

	if is_attacking:
		return false

	is_attacking = true
	can_attack = false

	attack_started.emit()

	# Временная задержка для прототипа.
	# Позже заменим её точным моментом попадания
	# из боевой анимации.
	await get_tree().create_timer(0.25).timeout

	attack_finished.emit()

	await get_tree().create_timer(attack_cooldown).timeout

	is_attacking = false
	can_attack = true

	return true


func start_block() -> void:
	if is_attacking:
		return

	is_blocking = true


func stop_block() -> void:
	is_blocking = false


func receive_attack(damage: float) -> float:
	if is_blocking:
		attack_blocked.emit()

		# Пока блок полностью защищает.
		# Позже добавим направление удара,
		# парирование и урон по выносливости.
		return 0.0

	return damage
