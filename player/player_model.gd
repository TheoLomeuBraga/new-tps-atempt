@tool
extends Node3D
class_name PlayerModel

@export var animation_tree : AnimationTree
@export var waist : BoneRotator
@export var arm : BoneRotator

@export_range(-1.0,1.0) var walk : float = 0.0 : 
	set(value):
		walk = value
		if animation_tree != null:
			animation_tree.set("parameters/walk_arms/blend_position",walk)
			animation_tree.set("parameters/walk_legs/blend_position",walk)

enum ArmEstate {NORMAL,GUN,AIR}
@export var arm_estate : ArmEstate : 
	set(value):
		arm_estate = value
		if animation_tree != null:
			match arm_estate:
				ArmEstate.NORMAL:
					animation_tree.set("parameters/arm_estate/transition_request","normal")
				ArmEstate.GUN:
					animation_tree.set("parameters/arm_estate/transition_request","gun")
				ArmEstate.AIR:
					animation_tree.set("parameters/arm_estate/transition_request","air")

enum LegEstate {FLOOR,AIR}
@export var leg_estate : LegEstate : 
	set(value):
		leg_estate = value
		if animation_tree != null:
			match leg_estate:
				LegEstate.FLOOR:
					animation_tree.set("parameters/leg_estate/transition_request","floor")
				LegEstate.AIR:
					animation_tree.set("parameters/leg_estate/transition_request","air")

@export var charged_shot : bool : 
	set(value):
		if animation_tree != null:
			if value:
				animation_tree.set("parameters/charged_shot/request",AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

@export var automatic_shot : bool : 
	set(value):
		
		if value != automatic_shot and animation_tree != null:
			if value:
				animation_tree.set("parameters/automatic_shot/request",AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
			else:
				animation_tree.set("parameters/automatic_shot/request",AnimationNodeOneShot.ONE_SHOT_REQUEST_FADE_OUT)
		
		automatic_shot = value

@export var waist_rotation : float :
	set(value):
		waist_rotation = value
		waist.target_rotation = value

@export var arm_rotation : float :
	set(value):
		arm_rotation = value
		arm.target_rotation = value
