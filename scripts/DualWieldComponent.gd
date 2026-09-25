extends Node

## Qırım Histori
## Система двух рук.
##
## Поддерживает:
## 1. одна сабля
## 2. две сабли
## 3. сабля + кинжал
##
## Левая и правая руки управляются отдельно.

enum CombatStyle {
	ONE_WEAPON,
	DUAL_SABRES,
	SABRE_DAGGER
}


@export var combat_style: CombatStyle = CombatStyle.ONE_WEAPON

var right_weapon = null
var left_weapon = null

var right_attacking: bool = false
var left_attacking: bool = false


func _ready() -> void:
	_create_weapons()


func _create_weapons() -> void:
	var weapon_script = preload("res://scripts/WeaponComponent.gd")

	right_weapon = weapon_script.new()
	left_weapon = weapon_script.new()

	add_child(right_weapon)
	add_child(left_weapon)

	_configure_weapons()


func _configure_weapons() -> void:
	# Правая рука
	right_weapon.hand = right_weapon.Hand.RIGHT
	right_weapon.weapon_type = right_weapon.WeaponType.SABRE
	right_weapon.weapon_name = "Crimean Sabre"
	right_weapon.damage = 25.0
	right_weapon.stamina_cost = 15.0
	right_weapon.equip()

	# Левая рука
	left_weapon.hand = left_weapon.Hand.LEFT
	left_weapon.weapon_type = left_weapon.WeaponType.SABRE
	left_weapon.weapon_name = "Crimean Sabre"
	left_weapon.damage = 25.0
	left_weapon.stamina_cost = 15.0


func equip_dual_sabres() -> void:
	combat_style = CombatStyle.DUAL_SABRES

	right_weapon.weapon_type = right_weapon.WeaponType.SABRE
	right_weapon.weapon_name = "Crimean Sabre"
	right_weapon.damage = 25.0
	right_weapon.equip()

	left_weapon.weapon_type = left_weapon.WeaponType.SABRE
	left_weapon.weapon_name = "Crimean Sabre"
	left_weapon.damage = 25.0
	left_weapon.equip()


func equip_sabre_and_dagger() -> void:
	combat_style = CombatStyle.SABRE_DAGGER

	right_weapon.weapon_type = right_weapon.WeaponType.SABRE
	right_weapon.weapon_name = "Crimean Sabre"
	right_weapon.damage = 25.0
	right_weapon.equip()

	left_weapon.weapon_type = left_weapon.WeaponType.DAGGER
	left_weapon.weapon_name = "Dagger"
	left_weapon.damage = 15.0
	left_weapon.equip()


func equip_one_sabre() -> void:
	combat_style = CombatStyle.ONE_WEAPON

	right_weapon.weapon_type = right_weapon.WeaponType.SABRE
	right_weapon.weapon_name = "Crimean Sabre"
	right_weapon.damage = 25.0
	right_weapon.equip()

	left_weapon.unequip()


func attack_right() -> float:
	if not right_weapon.can_attack():
		return 0.0

	right_attacking = true

	var damage: float = right_weapon.use_weapon()

	right_attacking = false

	return damage


func attack_left() -> float:
	if not left_weapon.can_attack():
		return 0.0

	left_attacking = true

	var damage: float = left_weapon.use_weapon()

	left_attacking = false

	return damage


func attack_both() -> Array:
	var attacks: Array = []

	if combat_style == CombatStyle.ONE_WEAPON:
		attacks.append(attack_right())
		return attacks

	attacks.append(attack_right())
	attacks.append(attack_left())

	return attacks


func get_right_weapon_name() -> String:
	return right_weapon.weapon_name if right_weapon != null else ""


func get_left_weapon_name() -> String:
	return left_weapon.weapon_name if left_weapon != null and left_weapon.equipped else ""
