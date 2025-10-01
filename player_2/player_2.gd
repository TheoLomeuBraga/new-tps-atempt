extends CharacterBody3D
class_name Player2

@onready var player_model : PlayerModel = $demo_model
@onready var camera_suport : Node3D = $camera_suport
var player_model_rotation_basis : Node3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5


func _ready() -> void:
	player_model_rotation_basis = Node3D.new()
	player_model_rotation_basis.top_level = true
	add_child(player_model_rotation_basis)
	
	player_model.rotation.y = player_model_rotation_basis.rotation.y + PI
	
	camera_suport.global_rotation = global_rotation

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		camera_suport.rotation.y -= event.screen_relative.x / 100.0

enum Estates {NONE,FLOOR,AIR}
var estate : Estates = Estates.AIR

@export_range(0.0,1.0) var forgiveness_amount : float = 0.2

@export_group("camera")
@export var sensitivity : float = 6.0

@export_group("floor")
@export var speed : float = 8.0
@export var friction : float = 100.0

@export_group("air")
@export var jump_power : float = 4.5

var on_floor_recently : float = 0.0
var jump_pressed_recently : float = 0.0

func floor_process(delta: float) -> void:
	
	var input_dir : Vector2 = Input.get_vector("left", "right", "foward", "back")
	var direction : Vector3 = (camera_suport.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var vec_speed : Vector3 = direction * speed
	velocity.x = move_toward(velocity.x, vec_speed.x, friction * delta)
	velocity.z = move_toward(velocity.z, vec_speed.z, friction * delta)
	
	if not is_on_floor():
		estate = Estates.AIR
	
	
	
	

func air_process(delta: float) -> void:
	
	velocity += get_gravity() * delta
	
	if is_on_floor():
		estate = Estates.FLOOR

var shot_recently : float = 0.0
var input_dir_on_jump : Vector2 = Vector2.ZERO




@export_group("rotation")
var aim_rotation_lerp_value : float = 0.5

@export var charter_rotation_speed : float = 20.0

func warpf_rot(rot : float) -> float:
	return wrapf(rot,-PI,PI)

func animation_process(delta: float) -> void:
	
	shot_recently -= delta
	if Input.is_action_just_pressed("shot") or Input.is_action_pressed("alt_shot"):
		shot_recently = 1.0
	
	var input_dir : Vector2 = Input.get_vector("left", "right", "foward", "back")
	
	
	
	# rotate char
	
	if is_on_floor():
		
		player_model.leg_estate = PlayerModel.LegEstate.FLOOR
		
		if shot_recently > 0.0:
			
			player_model.arm_estate = PlayerModel.ArmEstate.GUN
			
			player_model_rotation_basis.global_position = global_position
			player_model_rotation_basis.look_at(player_model_rotation_basis.global_position - camera_suport.basis.z)
			rotation.y = rotate_toward(rotation.y,player_model_rotation_basis.rotation.y,charter_rotation_speed * delta)
			
			player_model.waist_rotation = rotate_toward(player_model.waist_rotation,-player_model.rotation.y + PI,charter_rotation_speed * delta)
			
			if input_dir.length() > 0.0:
				
				var new_input_dir : Vector2 = input_dir
				if new_input_dir.y > 0.0:
					new_input_dir.x = -new_input_dir.x
					player_model.walk = move_toward(player_model.walk,-input_dir.length(),charter_rotation_speed * delta)
				else:
					player_model.walk = move_toward(player_model.walk,input_dir.length(),charter_rotation_speed * delta)
				
				new_input_dir.y = -abs(new_input_dir.y)
				
				player_model_rotation_basis.global_position = global_position
				player_model_rotation_basis.look_at(player_model_rotation_basis.global_position + ( camera_suport.basis * Vector3(new_input_dir.x,0.0,new_input_dir.y)))
				player_model.global_rotation.y = rotate_toward(player_model.global_rotation.y,player_model_rotation_basis.global_rotation.y + PI,charter_rotation_speed * delta)
				
				player_model.rotation.y = warpf_rot(player_model.rotation.y + PI)
				player_model.rotation.y = clamp(player_model.rotation.y,-(PI/2.0) + 0.01,(PI/2.0) - 0.01)
				player_model.rotation.y -= PI
				
				
				
			else:
				player_model.walk = move_toward(player_model.walk,0.0,10.0 * delta)
				player_model.rotation.y = rotate_toward(player_model.rotation.y,PI,charter_rotation_speed * delta)
			
		else:
			
			player_model.arm_estate = PlayerModel.ArmEstate.NORMAL
			
			player_model.arm_rotation = rotate_toward(player_model.arm_rotation,0.0,charter_rotation_speed * delta)
			player_model.waist_rotation = rotate_toward(player_model.waist_rotation,0.0,charter_rotation_speed * delta)
			
			player_model.walk = move_toward(player_model.walk,input_dir.length(),10.0 * delta)
			
			player_model.rotation.y = rotate_toward(player_model.rotation.y,PI,charter_rotation_speed * delta)
			
			if input_dir.length() > 0.0:
				player_model_rotation_basis.global_position = global_position
				player_model_rotation_basis.look_at(player_model_rotation_basis.global_position + ( camera_suport.basis * Vector3(input_dir.x,0.0,input_dir.y)))
				rotation.y = rotate_toward(rotation.y,player_model_rotation_basis.rotation.y,charter_rotation_speed * delta)
				
	else:
		player_model.arm_estate = PlayerModel.ArmEstate.AIR
		player_model.leg_estate = PlayerModel.LegEstate.AIR
		
		player_model.arm_rotation = rotate_toward(player_model.arm_rotation,0.0,charter_rotation_speed * delta)
		player_model.waist_rotation = rotate_toward(player_model.waist_rotation,0.0,charter_rotation_speed * delta)
		
		player_model.rotation.y = rotate_toward(player_model.rotation.y,0.0,charter_rotation_speed * delta)
		
	



func geral_process(delta: float) -> void:
	
	jump_pressed_recently -= delta
	if Input.is_action_just_pressed("jump"):
		jump_pressed_recently = forgiveness_amount
	
	on_floor_recently -= delta
	if is_on_floor():
		on_floor_recently = forgiveness_amount
	
	if jump_pressed_recently > 0.0 and on_floor_recently > 0.0:
		velocity.y = jump_power
		
		
		var pmgr_y : float = player_model.global_rotation.y
		look_at(global_position - Vector3(velocity.x,0.0,velocity.z))
		player_model.global_rotation.y = warpf_rot(pmgr_y)
	
	


func _process(delta: float) -> void:
	camera_suport.global_position = global_position
	animation_process(delta)


func _physics_process(delta: float) -> void:
	
	
	
	geral_process(delta)
	
	
	
	match estate:
		Estates.FLOOR:
			floor_process(delta)
		Estates.AIR:
			air_process(delta)
	
	
	move_and_slide()
	
	
