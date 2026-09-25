extends Node

## Qırım Histori
## Центральная система состояний боя Девлета.

enum CombatState {
	IDLE,
	ATTACKING,
	BLOCKING,
	PARRYING,
	DODGING,
	STUNNED,
	RECOVERING
}

signal state_changed(old_state: CombatState, new_state: CombatState)

var current_state: CombatState = CombatState.IDLE


func get_state() -> CombatState:
	return current_state


func is_idle() -> bool:
	return current_state == CombatState.IDLE


func can_attack() -> bool:
	return current_state == CombatState.IDLE


func can_block() -> bool:
	return current_state == CombatState.IDLE \
		or current_state == CombatState.RECOVERING


func can_parry() -> bool:
	return current_state == CombatState.IDLE \
		or current_state == CombatState.BLOCKING


func can_dodge() -> bool:
	return current_state == CombatState.IDLE \
		or current_state == CombatState.RECOVERING


func set_state(new_state: CombatState) -> bool:
	if current_state == new_state:
		return false

	var old_state := current_state
	current_state = new_state

	state_changed.emit(old_state, new_state)

	return true


func start_attack() -> bool:
	if not can_attack():
		return false

	set_state(CombatState.ATTACKING)
	return true


func finish_attack() -> void:
	if current_state == CombatState.ATTACKING:
		set_state(CombatState.RECOVERING)


func start_block() -> bool:
	if not can_block():
		return false

	set_state(CombatState.BLOCKING)
	return true


func stop_block() -> void:
	if current_state == CombatState.BLOCKING:
		set_state(CombatState.IDLE)


func start_parry() -> bool:
	if not can_parry():
		return false

	set_state(CombatState.PARRYING)
	return true


func finish_parry() -> void:
	if current_state == CombatState.PARRYING:
		set_state(CombatState.RECOVERING)


func start_dodge() -> bool:
	if not can_dodge():
		return false

	set_state(CombatState.DODGING)
	return true


func finish_dodge() -> void:
	if current_state == CombatState.DODGING:
		set_state(CombatState.RECOVERING)


func apply_stun() -> void:
	set_state(CombatState.STUNNED)


func recover() -> void:
	if current_state == CombatState.RECOVERING:
		set_state(CombatState.IDLE)
