extends Node

## Qırım Histori
## Система двух сабель Девлета.
##
## Левая и правая рука работают независимо.
## Поддерживается:
## - одна сабля;
## - две сабли;
## - независимая атака каждой рукой;
## - одновременная атака;
## - блок одной рукой;
## - контратака;
## - расход выносливости;
## - задержка между ударами.


signal left_attack_started
signal left_attack_finished

signal right_attack_started
signal right_attack_finished

signal both_attack_started
signal both_attack_finished

signal left_block_started
signal left_block_finished

signal right_block_started
signal right_block_finished

signal dual_wield_state_changed(enabled)


enum Hand {
	LEFT,
	RIGHT
}


@export var enabled: bool = false

@export var left_damage: float = 22.0
@export var right_damage: float = 25.0

@export var left_stamina_cost: float = 13.0
@export var right_stamina_cost: float = 15.0

@export var attack_cooldown: float = 0.45

@export var both_attack_stamina_multiplier: float = 1.35


var left_equipped: bool = false
var right_equipped: bool = true

var left_attacking: bool = false
var right_attacking: bool = false

var left_blocking: bool = false
var right_blocking: bool = false

var left_cooldown: float = 0.0
var right_cooldown: float = 0.0


func _process(delta: float) -> void:
	if left_cooldown > 0.0:
		left_cooldown = max(left_cooldown - delta, 0.0)

	if right_cooldown > 0.0:
		right_cooldown = max(right_cooldown - delta, 0.0)


func enable_dual_wield() -> void:
	enabled = true
	left_equipped = true
	right_equipped = true

	dual_wield_state_changed.emit(true)


func disable_dual_wield() -> void:
	enabled = false
	left_equipped = false
	right_equipped = true

	left_attacking = false
	right_attacking = false

	left_blocking = false
	right_blocking = false

	dual_wield_state_changed.emit(false)


func equip_left_sabre() -> void:
	left_equipped = true


func unequip_left_sabre() -> void:
	left_equipped = false
	left_attacking = false
	left_blocking = false


func equip_right_sabre() -> void:
	right_equipped = true


func unequip_right_sabre() -> void:
	right_equipped = false
	right_attacking = false
	right_blocking = false


func can_left_attack() -> bool:
	return (
		enabled
		and left_equipped
		and not left_attacking
		and left_cooldown <= 0.0
	)


func can_right_attack() -> bool:
	return (
		right_equipped
		and not right_attacking
		and right_cooldown <= 0.0
	)


func can_attack_with_hand(hand: Hand) -> bool:
	if hand == Hand.LEFT:
		return can_left_attack()

	return can_right_attack()


func start_left_attack() -> bool:
	if not can_left_attack():
		return false

	left_attacking = true
	left_cooldown = attack_cooldown

	left_attack_started.emit()

	return true


func finish_left_attack() -> void:
	if not left_attacking:
		return

	left_attacking = false
	left_attack_finished.emit()


func start_right_attack() -> bool:
	if not can_right_attack():
		return false

	right_attacking = true
	right_cooldown = attack_cooldown

	right_attack_started.emit()

	return true


func finish_right_attack() -> void:
	if not right_attacking:
		return

	right_attacking = false
	right_attack_finished.emit()


func start_both_attack() -> bool:
	if not enabled:
		return false

	if not left_equipped or not right_equipped:
		return false

	if left_attacking or right_attacking:
		return false

	if left_cooldown > 0.0 or right_cooldown > 0.0:
		return false

	left_attacking = true
	right_attacking = true

	left_cooldown = attack_cooldown
	right_cooldown = attack_cooldown

	both_attack_started.emit()

	return true


func finish_both_attack() -> void:
	if not left_attacking and not right_attacking:
		return

	left_attacking = false
	right_attacking = false

	both_attack_finished.emit()


func get_left_damage() -> float:
	return left_damage


func get_right_damage() -> float:
	return right_damage


func get_left_stamina_cost() -> float:
	return left_stamina_cost


func get_right_stamina_cost() -> float:
	return right_stamina_cost


func get_both_attack_stamina_cost() -> float:
	return (
		left_stamina_cost + right_stamina_cost
	) * both_attack_stamina_multiplier


func start_left_block() -> void:
	if not left_equipped:
		return

	left_blocking = true
	left_block_started.emit()


func stop_left_block() -> void:
	if not left_blocking:
		return

	left_blocking = false
	left_block_finished.emit()


func start_right_block() -> void:
	if not right_equipped:
		return

	right_blocking = true
	right_block_started.emit()


func stop_right_block() -> void:
	if not right_blocking:
		return

	right_blocking = false
	right_block_finished.emit()


func is_left_blocking() -> bool:
	return left_blocking


func is_right_blocking() -> bool:
	return right_blocking


func is_dual_wielding() -> bool:
	return enabled and left_equipped and right_equipped
