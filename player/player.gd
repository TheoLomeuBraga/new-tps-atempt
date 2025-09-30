extends CharacterBody3D
class_name Player

@onready var player_model : PlayerModel = $demo_model
@onready var camera_suport : Node3D = $camera_suport
var player_model_rotation_basis : Node3D

func _ready() -> void:
	player_model_rotation_basis = Node3D.new()
	add_child(player_model_rotation_basis)
	
	player_model.rotation.y = player_model_rotation_basis.rotation.y + PI

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

const charter_rotation_speed : float = 10.0

func animation_process(delta: float) -> void:
	
	var input_dir : Vector2 = Input.get_vector("left", "right", "foward", "back")
	
	if is_on_floor():
		
		if shot_recently > 0:
			
			
			
			
			
			if input_dir.y > 0.0:
				player_model.walk = move_toward(player_model.walk,-abs(input_dir.length()),speed * delta)
			else:
				player_model.walk = move_toward(player_model.walk,abs(input_dir.length()),speed * delta)
			
			if input_dir.y > 0.0:
				input_dir.x = -input_dir.x
			input_dir.y = -abs(input_dir.y)
			
			#rotate
			
			if input_dir.length() > 0.0:
				player_model_rotation_basis.look_at(player_model_rotation_basis.global_position + (Vector3(input_dir.x,0.0,input_dir.y) - (camera_suport.basis.z * 0.2)))
				player_model_rotation_basis.rotation.y += camera_suport.rotation.y + PI
				
				player_model.rotation.y = rotate_toward(player_model.rotation.y,player_model_rotation_basis.rotation.y,charter_rotation_speed * delta)
				
				if player_model.rotation.y < player_model.rotation.y-(PI/2.0):
					player_model.rotation.y = - player_model.rotation.y
				
				if player_model.rotation.y > player_model.rotation.y+(PI/2.0): 
					player_model.rotation.y = - player_model.rotation.y
				
				
				player_model_rotation_basis.look_at(player_model_rotation_basis.global_position + camera_suport.transform.basis.z)
				player_model.waist_rotation = -angle_difference(player_model_rotation_basis.rotation.y,player_model.rotation.y)
				
				
			
			else:
				
				player_model_rotation_basis.look_at(player_model_rotation_basis.global_position + camera_suport.basis.z)
				player_model.rotation.y = rotate_toward(player_model.rotation.y,player_model_rotation_basis.rotation.y,charter_rotation_speed * delta)
				
				
				player_model.waist_rotation = rotate_toward(player_model.waist_rotation,0.0,charter_rotation_speed * delta)
				
			
			
			player_model.leg_estate = PlayerModel.LegEstate.FLOOR
			player_model.arm_estate = PlayerModel.ArmEstate.GUN
			
			
		else:
			
			player_model.walk = move_toward(player_model.walk,abs(input_dir.length()),speed * delta)
			
			#rotate
			
			if input_dir.length() > 0.0:
				player_model_rotation_basis.look_at(player_model_rotation_basis.global_position + Vector3(input_dir.x,0.0,input_dir.y))
				player_model_rotation_basis.rotation.y += camera_suport.rotation.y + PI
				player_model.rotation.y = rotate_toward(player_model.rotation.y,player_model_rotation_basis.rotation.y,charter_rotation_speed * delta)
			
			player_model.waist_rotation = rotate_toward(player_model.waist_rotation,0.0,charter_rotation_speed * delta)
			
			player_model.leg_estate = PlayerModel.LegEstate.FLOOR
			player_model.arm_estate = PlayerModel.ArmEstate.NORMAL
	
	else:
		
		player_model_rotation_basis.look_at(player_model_rotation_basis.global_position + Vector3(input_dir_on_jump.x,0.0,input_dir_on_jump.y))
		player_model_rotation_basis.rotation.y += camera_suport.rotation.y + PI
		player_model.rotation.y = player_model_rotation_basis.rotation.y
		
		player_model.waist_rotation = rotate_toward(player_model.waist_rotation,0.0,charter_rotation_speed * delta)
		
		player_model.leg_estate = PlayerModel.LegEstate.AIR
		player_model.arm_estate = PlayerModel.ArmEstate.AIR
	
	shot_recently -= delta
	
	if Input.is_action_just_pressed("shot") or Input.is_action_pressed("alt_shot"):
		shot_recently = 1.0
	
	if Input.is_action_just_pressed("shot"):
		player_model.charged_shot = true
	
	player_model.automatic_shot = Input.is_action_pressed("alt_shot")
	
	if Input.is_action_just_pressed("jump"):
		input_dir_on_jump = input_dir


func gun_process(delta: float) -> void:
	pass

func geral_process(delta: float) -> void:
	
	jump_pressed_recently -= delta
	if Input.is_action_just_pressed("jump"):
		jump_pressed_recently = forgiveness_amount
	
	on_floor_recently -= delta
	if is_on_floor():
		on_floor_recently = forgiveness_amount
	
	if jump_pressed_recently > 0.0 and on_floor_recently > 0.0:
		velocity.y = jump_power
	
	




func _physics_process(delta: float) -> void:
	
	geral_process(delta)
	
	animation_process(delta)
	
	gun_process(delta)
	
	match estate:
		Estates.FLOOR:
			floor_process(delta)
		Estates.AIR:
			air_process(delta)
	
	
	move_and_slide()
	
	
