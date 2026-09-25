extends Node

## Qırım Histori
## Центральная система боевых состояний Девлета.
##
## Состояния:
## IDLE
## ATTACK
## BLOCK
## PARRY
## COUNTER
## DODGE
## STUN
## DEAD


signal state_changed(old_state, new_state)

signal attack_state_started
signal attack_state_finished

signal block_started
signal block_finished

signal parry_started
signal parry_success

signal counter_started
signal dodge_started

signal stunned
signal died


enum CombatState {
	IDLE,
	ATTACK,
	BLOCK,
	PARRY,
	COUNTER,
	DODGE,
	STUN,
	DEAD
}


@export var current_state: CombatState = CombatState.IDLE

@export var attack_duration: float = 0.55
@export var block_duration: float = 0.0
@export var parry_duration: float = 0.25
@export var counter_duration: float = 0.45
@export var dodge_duration: float = 0.35
@export var stun_duration: float = 0.8


var state_timer: float = 0.0


func _process(delta: float) -> void:
	if state_timer <= 0.0:
		return

	state_timer -= delta

	if state_timer <= 0.0:
		_finish_timed_state()


func _finish_timed_state() -> void:
	match current_state:
		CombatState.ATTACK:
			finish_attack()

		CombatState.PARRY:
			finish_parry()

		CombatState.COUNTER:
			finish_counter()

		CombatState.DODGE:
			finish_dodge()

		CombatState.STUN:
			finish_stun()

		_:
			state_timer = 0.0


func change_state(new_state: CombatState) -> bool:
	if current_state == CombatState.DEAD:
		return false

	if not can_enter_state(new_state):
		return false

	var old_state := current_state

	current_state = new_state

	state_changed.emit(old_state, new_state)

	return true


func can_enter_state(new_state: CombatState) -> bool:
	if current_state == CombatState.DEAD:
		return false

	if new_state == CombatState.DEAD:
		return true

	match current_state:
		CombatState.IDLE:
			return true

		CombatState.ATTACK:
			return new_state == CombatState.PARRY \
				or new_state == CombatState.DODGE \
				or new_state == CombatState.STUN \
				or new_state == CombatState.DEAD

		CombatState.BLOCK:
			return new_state == CombatState.PARRY \
				or new_state == CombatState.COUNTER \
				or new_state == CombatState.DODGE \
				or new_state == CombatState.IDLE \
				or new_state == CombatState.STUN \
				or new_state == CombatState.DEAD

		CombatState.PARRY:
			return new_state == CombatState.COUNTER \
				or new_state == CombatState.ATTACK \
				or new_state == CombatState.IDLE \
				or new_state == CombatState.STUN \
				or new_state == CombatState.DEAD

		CombatState.COUNTER:
			return new_state == CombatState.ATTACK \
				or new_state == CombatState.IDLE \
				or new_state == CombatState.STUN \
				or new_state == CombatState.DEAD

		CombatState.DODGE:
			return new_state == CombatState.IDLE \
				or new_state == CombatState.ATTACK \
				or new_state == CombatState.STUN \
				or new_state == CombatState.DEAD

		CombatState.STUN:
			return new_state == CombatState.IDLE \
				or new_state == CombatState.DEAD

		_:
			return false


# ============================================================
# ATTACK
# ============================================================

func start_attack() -> bool:
	if not can_enter_state(CombatState.ATTACK):
		return false

	if not change_state(CombatState.ATTACK):
		return false

	state_timer = attack_duration

	attack_state_started.emit()

	return true


func finish_attack() -> void:
	if current_state != CombatState.ATTACK:
		return

	state_timer = 0.0

	attack_state_finished.emit()

	change_state(CombatState.IDLE)


# ============================================================
# BLOCK
# ============================================================

func start_block() -> bool:
	if not can_enter_state(CombatState.BLOCK):
		return false

	if not change_state(CombatState.BLOCK):
		return false

	state_timer = block_duration

	block_started.emit()

	return true


func stop_block() -> void:
	if current_state != CombatState.BLOCK:
		return

	state_timer = 0.0

	block_finished.emit()

	change_state(CombatState.IDLE)


# ============================================================
# PARRY
# ============================================================

func start_parry() -> bool:
	if not can_enter_state(CombatState.PARRY):
		return false

	if not change_state(CombatState.PARRY):
		return false

	state_timer = parry_duration

	parry_started.emit()

	return true


func finish_parry() -> void:
	if current_state != CombatState.PARRY:
		return

	state_timer = 0.0

	change_state(CombatState.IDLE)


func successful_parry() -> bool:
	if current_state != CombatState.PARRY:
		return false

	parry_success.emit()

	# После успешного парирования
	# открываем возможность контратаки.
	return true


# ============================================================
# COUNTER
# ============================================================

func start_counter() -> bool:
	if not can_enter_state(CombatState.COUNTER):
		return false

	if not change_state(CombatState.COUNTER):
		return false

	state_timer = counter_duration

	counter_started.emit()

	return true


func finish_counter() -> void:
	if current_state != CombatState.COUNTER:
		return

	state_timer = 0.0

	change_state(CombatState.IDLE)


# ============================================================
# DODGE
# ============================================================

func start_dodge() -> bool:
	if not can_enter_state(CombatState.DODGE):
		return false

	if not change_state(CombatState.DODGE):
		return false

	state_timer = dodge_duration

	dodge_started.emit()

	return true


func finish_dodge() -> void:
	if current_state != CombatState.DODGE:
		return

	state_timer = 0.0

	change_state(CombatState.IDLE)


# ============================================================
# STUN
# ============================================================

func start_stun() -> bool:
	if current_state == CombatState.DEAD:
		return false

	current_state = CombatState.STUN
	state_timer = stun_duration

	stunned.emit()

	return true


func finish_stun() -> void:
	if current_state != CombatState.STUN:
		return

	state_timer = 0.0

	change_state(CombatState.IDLE)


# ============================================================
# DEATH
# ============================================================

func kill() -> void:
	if current_state == CombatState.DEAD:
		return

	state_timer = 0.0
	current_state = CombatState.DEAD

	died.emit()


# ============================================================
# ПРОВЕРКИ
# ============================================================

func is_idle() -> bool:
	return current_state == CombatState.IDLE


func is_attacking() -> bool:
	return current_state == CombatState.ATTACK


func is_blocking() -> bool:
	return current_state == CombatState.BLOCK


func is_parrying() -> bool:
	return current_state == CombatState.PARRY


func is_countering() -> bool:
	return current_state == CombatState.COUNTER


func is_dodging() -> bool:
	return current_state == CombatState.DODGE


func is_stunned() -> bool:
	return current_state == CombatState.STUN


func is_dead() -> bool:
	return current_state == CombatState.DEAD


func get_state_name() -> String:
	return CombatState.keys()[current_state]
