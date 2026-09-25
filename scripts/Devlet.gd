extends CharacterBody3D

## Qırım Histori
## Главный герой — Devlet Giray.
##
## Центральная система персонажа:
## движение + здоровье + выносливость +
## бой + оружие + ранения + две сабли.


@export var walk_speed: float = 3.0
@export var run_speed: float = 6.0
@export var acceleration: float = 12.0
@export var gravity: float = 18.0


var health_component
var stamina_component
var combat_component
var weapon_component
var injury_component
var dual_wield_component


var is_running: bool = false


func _ready() -> void:
	_create_components()
	_setup_devlet()


func _create_components() -> void:
	var health_script = preload("res://scripts/HealthComponent.gd")
	var stamina_script = preload("res://scripts/StaminaComponent.gd")
	var combat_script = preload("res://scripts/CombatComponent.gd")
	var weapon_script = preload("res://scripts/WeaponComponent.gd")
	var injury_script = preload("res://scripts/InjuryComponent.gd")
	var dual_wield_script = preload("res://scripts/DualWieldComponent.gd")

	health_component = health_script.new()
	stamina_component = stamina_script.new()
	combat_component = combat_script.new()
	weapon_component = weapon_script.new()
	injury_component = injury_script.new()
	dual_wield_component = dual_wield_script.new()

	add_child(health_component)
	add_child(stamina_component)
	add_child(combat_component)
	add_child(weapon_component)
	add_child(injury_component)
	add_child(dual_wield_component)


func _setup_devlet() -> void:
	# Основное оружие — правая сабля.
	weapon_component.weapon_name = "Crimean Sabre"
	weapon_component.damage = 25.0
	weapon_component.stamina_cost = 15.0
	weapon_component.equip()

	# Левая и правая сабли.
	dual_wield_component.left_damage = 22.0
	dual_wield_component.right_damage = 25.0

	dual_wield_component.left_stamina_cost = 13.0
	dual_wield_component.right_stamina_cost = 15.0

	dual_wield_component.attack_cooldown = 0.45

	# Включаем режим двух сабель.
	dual_wield_component.enable_dual_wield()

	print("Devlet Giray initialized.")
	print("Weapon: ", weapon_component.weapon_name)
	print("Dual wield: ", dual_wield_component.is_dual_wielding())


func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_handle_movement(delta)
	_handle_combat_input()

	move_and_slide()


func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0


func _handle_movement(delta: float) -> void:
	var input_vector := Input.get_vector(
		"move_left",
		"move_right",
		"move_forward",
		"move_backward"
	)

	var direction := Vector3(
		input_vector.x,
		0.0,
		input_vector.y
	)

	is_running = Input.is_action_pressed("run")

	var current_speed := run_speed if is_running else walk_speed

	if direction.length() > 0.0:
		direction = direction.normalized()

		velocity.x = move_toward(
			velocity.x,
			direction.x * current_speed,
			acceleration * delta
		)

		velocity.z = move_toward(
			velocity.z,
			direction.z * current_speed,
			acceleration * delta
		)
	else:
		velocity.x = move_toward(
			velocity.x,
			0.0,
			acceleration * delta
		)

		velocity.z = move_toward(
			velocity.z,
			0.0,
			acceleration * delta
		)


func _handle_combat_input() -> void:
	# Левая сабля.
	if InputMap.has_action("attack_left"):
		if Input.is_action_just_pressed("attack_left"):
			attack_left()

	# Правая сабля.
	if InputMap.has_action("attack_right"):
		if Input.is_action_just_pressed("attack_right"):
			attack_right()

	# Одновременная атака двумя саблями.
	if InputMap.has_action("attack_dual"):
		if Input.is_action_just_pressed("attack_dual"):
			attack_dual()

	# Левая защита.
	if InputMap.has_action("block_left"):
		if Input.is_action_pressed("block_left"):
			start_left_block()
		else:
			stop_left_block()

	# Правая защита.
	if InputMap.has_action("block_right"):
		if Input.is_action_pressed("block_right"):
			start_right_block()
		else:
			stop_right_block()


# ============================================================
# ОДНА САБЛЯ
# ============================================================

func attack() -> void:
	if weapon_component == null:
		return

	if not weapon_component.can_attack():
		return

	var stamina_cost: float = weapon_component.stamina_cost

	if not stamina_component.consume_stamina(stamina_cost):
		print("Devlet is too exhausted to attack.")
		return

	combat_component.attack()


# ============================================================
# ЛЕВАЯ САБЛЯ
# ============================================================

func attack_left() -> void:
	if dual_wield_component == null:
		return

	if not dual_wield_component.can_left_attack():
		return

	var stamina_cost := dual_wield_component.get_left_stamina_cost()

	if not stamina_component.consume_stamina(stamina_cost):
		print("Devlet is too exhausted for left-hand attack.")
		return

	if dual_wield_component.start_left_attack():
		combat_component.attack()

		# Пока нет анимационного контроллера,
		# завершаем атаку сразу.
		dual_wield_component.finish_left_attack()


# ============================================================
# ПРАВАЯ САБЛЯ
# ============================================================

func attack_right() -> void:
	if dual_wield_component == null:
		return

	if not dual_wield_component.can_right_attack():
		return

	var stamina_cost := dual_wield_component.get_right_stamina_cost()

	if not stamina_component.consume_stamina(stamina_cost):
		print("Devlet is too exhausted for right-hand attack.")
		return

	if dual_wield_component.start_right_attack():
		combat_component.attack()

		dual_wield_component.finish_right_attack()


# ============================================================
# ДВЕ САБЛИ ОДНОВРЕМЕННО
# ============================================================

func attack_dual() -> void:
	if dual_wield_component == null:
		return

	if not dual_wield_component.is_dual_wielding():
		return

	var stamina_cost := dual_wield_component.get_both_attack_stamina_cost()

	if not stamina_component.consume_stamina(stamina_cost):
		print("Devlet is too exhausted for dual attack.")
		return

	if dual_wield_component.start_both_attack():
		combat_component.attack()

		dual_wield_component.finish_both_attack()


# ============================================================
# БЛОК ЛЕВОЙ РУКОЙ
# ============================================================

func start_left_block() -> void:
	if dual_wield_component == null:
		return

	dual_wield_component.start_left_block()


func stop_left_block() -> void:
	if dual_wield_component == null:
		return

	dual_wield_component.stop_left_block()


# ============================================================
# БЛОК ПРАВОЙ РУКОЙ
# ============================================================

func start_right_block() -> void:
	if dual_wield_component == null:
		return

	dual_wield_component.start_right_block()


func stop_right_block() -> void:
	if dual_wield_component == null:
		return

	dual_wield_component.stop_right_block()


# ============================================================
# УПРАВЛЕНИЕ РЕЖИМОМ ДВУХ САБЕЛЬ
# ============================================================

func enable_dual_wield() -> void:
	if dual_wield_component == null:
		return

	dual_wield_component.enable_dual_wield()


func disable_dual_wield() -> void:
	if dual_wield_component == null:
		return

	dual_wield_component.disable_dual_wield()


func is_dual_wielding() -> bool:
	if dual_wield_component == null:
		return false

	return dual_wield_component.is_dual_wielding()


# ============================================================
# ЗДОРОВЬЕ
# ============================================================

func take_damage(amount: float) -> void:
	if health_component == null:
		return

	health_component.take_damage(amount)


func restore_health(amount: float) -> void:
	if health_component == null:
		return

	health_component.heal(amount)


func is_alive() -> bool:
	if health_component == null:
		return false

	return health_component.is_alive()


# ============================================================
# РАНЕНИЯ
# ============================================================

func receive_body_injury(
	body_part: InjuryComponent.BodyPart,
	damage: float
) -> void:
	if injury_component == null:
		return

	injury_component.apply_injury(body_part, damage)


# ============================================================
# ВЫНОСЛИВОСТЬ
# ============================================================

func restore_stamina(amount: float) -> void:
	if stamina_component == null:
		return

	stamina_component.restore_stamina(amount)
