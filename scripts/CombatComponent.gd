extends Node

## Qırım Histori
## Боевая система Девлета.
##
## Поддерживает:
## - обычную атаку
## - сильную атаку
## - блок
## - парирование
## - контратаку
## - уклонение
## - оглушение
## - задержку между ударами
## - отдельные состояния левой и правой руки
##
## Физические попадания и анимации будут подключены позже.


signal attack_started
signal attack_finished
signal block_started
signal block_finished
signal parry_success
signal counter_attack
signal dodge_started
signal stunned
signal combat_state_changed


enum CombatState {
	READY,
	ATTACKING,
	BLOCKING,
	PARRYING,
	DODGING,
	STUNNED
}


enum AttackType {
	LIGHT,
	HEAVY,
	RIGHT_HAND,
	LEFT_HAND,
	DUAL
}


@export var light_attack_stamina: float = 10.0
@export var heavy_attack_stamina: float = 22.0
@export var parry_stamina: float = 8.0
@export var dodge_stamina: float = 18.0

@export var light_attack_duration: float = 0.45
@export var heavy_attack_duration: float = 0.8
@export var parry_window: float = 0.25
@export var dodge_duration: float = 0.35
@export var stun_duration: float = 1.2

@export var attack_cooldown: float = 0.2


var combat_state: CombatState = CombatState.READY

var current_attack: AttackType = AttackType.LIGHT

var attack_timer: float = 0.0
var cooldown_timer: float = 0.0
var parry_timer: float = 0.0
var dodge_timer: float = 0.0
var stun_timer: float = 0.0

var can_counter: bool = false


func _process(delta: float) -> void:
	_update_timers(delta)


func _update_timers(delta: float) -> void:
	if attack_timer > 0.0:
		attack_timer -= delta

		if attack_timer <= 0.0:
			attack_finished.emit()

			if combat_state == CombatState.ATTACKING:
				_set_state(CombatState.READY)

	if cooldown_timer > 0.0:
		cooldown_timer -= delta

	if parry_timer > 0.0:
		parry_timer -= delta

		if parry_timer <= 0.0:
			if combat_state == CombatState.PARRYING:
				_set_state(CombatState.READY)

	if dodge_timer > 0.0:
		dodge_timer -= delta

		if dodge_timer <= 0.0:
			if combat_state == CombatState.DODGING:
				_set_state(CombatState.READY)

	if stun_timer > 0.0:
		stun_timer -= delta

		if stun_timer <= 0.0:
			if combat_state == CombatState.STUNNED:
				_set_state(CombatState.READY)
				can_counter = false


func attack() -> bool:
	return light_attack()


func light_attack() -> bool:
	if not _can_start_attack():
		return false

	current_attack = AttackType.LIGHT

	_set_state(CombatState.ATTACKING)

	attack_timer = light_attack_duration
	cooldown_timer = attack_cooldown

	attack_started.emit()

	return true


func heavy_attack() -> bool:
	if not _can_start_attack():
		return false

	current_attack = AttackType.HEAVY

	_set_state(CombatState.ATTACKING)

	attack_timer = heavy_attack_duration
	cooldown_timer = attack_cooldown

	attack_started.emit()

	return true


func right_hand_attack() -> bool:
	if not _can_start_attack():
		return false

	current_attack = AttackType.RIGHT_HAND

	_set_state(CombatState.ATTACKING)

	attack_timer = light_attack_duration
	cooldown_timer = attack_cooldown

	attack_started.emit()

	return true


func left_hand_attack() -> bool:
	if not _can_start_attack():
		return false

	current_attack = AttackType.LEFT_HAND

	_set_state(CombatState.ATTACKING)

	attack_timer = light_attack_duration
	cooldown_timer = attack_cooldown

	attack_started.emit()

	return true


func dual_attack() -> bool:
	if not _can_start_attack():
		return false

	current_attack = AttackType.DUAL

	_set_state(CombatState.ATTACKING)

	attack_timer = heavy_attack_duration
	cooldown_timer = attack_cooldown

	attack_started.emit()

	return true


func start_block() -> bool:
	if combat_state == CombatState.STUNNED:
		return false

	if combat_state == CombatState.ATTACKING:
		return false

	_set_state(CombatState.BLOCKING)

	block_started.emit()

	return true


func stop_block() -> void:
	if combat_state == CombatState.BLOCKING:
		_set_state(CombatState.READY)

		block_finished.emit()


func start_parry() -> bool:
	if combat_state == CombatState.STUNNED:
		return false

	if combat_state == CombatState.ATTACKING:
		return false

	_set_state(CombatState.PARRYING)

	parry_timer = parry_window

	can_counter = false

	return true


func receive_attack(
	attacker_damage: float
) -> Dictionary:

	var result := {
		"blocked": false,
		"parried": false,
		"counter": false,
		"damage": attacker_damage
	}

	if combat_state == CombatState.STUNNED:
		return result


	if combat_state == CombatState.PARRYING:
		result["parried"] = true
		result["damage"] = 0.0

		can_counter = true

		parry_success.emit()

		_set_state(CombatState.READY)

		return result


	if combat_state == CombatState.BLOCKING:
		result["blocked"] = true

		# Позже здесь будет зависеть от оружия,
		# угла удара и качества блока.
		result["damage"] = attacker_damage * 0.25

		return result


	return result


func perform_counter() -> bool:
	if not can_counter:
		return false

	if combat_state != CombatState.READY:
		return false

	can_counter = false

	current_attack = AttackType.RIGHT_HAND

	_set_state(CombatState.ATTACKING)

	attack_timer = light_attack_duration
	cooldown_timer = attack_cooldown

	counter_attack.emit()
	attack_started.emit()

	return true


func dodge() -> bool:
	if combat_state == CombatState.STUNNED:
		return false

	if combat_state == CombatState.ATTACKING:
		return false

	if combat_state == CombatState.DODGING:
		return false

	_set_state(CombatState.DODGING)

	dodge_timer = dodge_duration

	dodge_started.emit()

	return true


func apply_stun() -> void:
	attack_timer = 0.0
	parry_timer = 0.0
	dodge_timer = 0.0

	stun_timer = stun_duration

	can_counter = false

	_set_state(CombatState.STUNNED)

	stunned.emit()


func is_attacking() -> bool:
	return combat_state == CombatState.ATTACKING


func is_blocking() -> bool:
	return combat_state == CombatState.BLOCKING


func is_parrying() -> bool:
	return combat_state == CombatState.PARRYING


func is_dodging() -> bool:
	return combat_state == CombatState.DODGING


func is_stunned() -> bool:
	return combat_state == CombatState.STUNNED


func is_ready() -> bool:
	return combat_state == CombatState.READY


func _can_start_attack() -> bool:
	if combat_state != CombatState.READY:
		return false

	if cooldown_timer > 0.0:
		return false

	return true


func _set_state(new_state: CombatState) -> void:
	if combat_state == new_state:
		return

	combat_state = new_state

	combat_state_changed.emit(new_state)
