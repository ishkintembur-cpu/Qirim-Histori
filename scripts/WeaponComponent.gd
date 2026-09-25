extends Node

## Qırım Histori
## Система двух рук.
##
## Поддерживает:
## ONE_WEAPON    — одна сабля
## DUAL_SABRES   — две сабли
## SABRE_DAGGER  — сабля + кинжал


enum CombatStyle {
	ONE_WEAPON,
	DUAL_SABRES,
	SABRE_DAGGER
}


var combat_style: CombatStyle = CombatStyle.ONE_WEAPON

var right_weapon: Node
var left_weapon: Node


func _ready() -> void:
	_create_weapons()


func _create_weapons() -> void:
	var weapon_script = preload("res://scripts/WeaponComponent.gd")

	right_weapon = weapon_script.new()
	left_weapon = weapon_script.new()

	add_child(right_weapon)
	add_child(left_weapon)

	_setup_right_weapon()
	_setup_left_weapon()


func _setup_right_weapon() -> void:
	right_weapon.hand = 1
	right_weapon.weapon_type = 0
	right_weapon.weapon_name = "Crimean Sabre"
	right_weapon.damage = 25.0
	right_weapon.stamina_cost = 15.0
	right_weapon.attack_speed = 1.0

	right_weapon.equip()


func _setup_left_weapon() -> void:
	left_weapon.hand = 0
	left_weapon.weapon_type = 0
	left_weapon.weapon_name = "Crimean Sabre"
	left_weapon.damage = 25.0
	left_weapon.stamina_cost = 15.0
	left_weapon.attack_speed = 1.0

	left_weapon.equip()


func equip_one_sabre() -> void:
	combat_style = CombatStyle.ONE_WEAPON

	_setup_right_weapon()
	left_weapon.unequip()


func equip_dual_sabres() -> void:
	combat_style = CombatStyle.DUAL_SABRES

	_setup_right_weapon()
	_setup_left_weapon()


func equip_sabre_and_dagger() -> void:
	combat_style = CombatStyle.SABRE_DAGGER

	_setup_right_weapon()

	left_weapon.hand = 0
	left_weapon.weapon_type = 1
	left_weapon.weapon_name = "Dagger"
	left_weapon.damage = 15.0
	left_weapon.stamina_cost = 8.0
	left_weapon.attack_speed = 1.3

	left_weapon.equip()


func attack_right() -> float:
	if right_weapon == null:
		return 0.0

	if not right_weapon.can_attack():
		return 0.0

	return right_weapon.use_weapon()


func attack_left() -> float:
	if left_weapon == null:
		return 0.0

	if not left_weapon.can_attack():
		return 0.0

	return left_weapon.use_weapon()


func attack_both() -> Array:
	var results: Array = []

	if combat_style == CombatStyle.ONE_WEAPON:
		results.append(attack_right())
		return results

	results.append(attack_right())
	results.append(attack_left())

	return results


func get_right_weapon_name() -> String:
	if right_weapon == null:
		return ""

	return right_weapon.weapon_name


func get_left_weapon_name() -> String:
	if left_weapon == null:
		return ""

	if not left_weapon.equipped:
		return ""

	return left_weapon.weapon_name
