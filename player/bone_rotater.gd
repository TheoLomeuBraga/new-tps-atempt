@tool

extends SkeletonModifier3D
class_name BoneRotator

@export_enum(" ") var target_bone: String
@export var target_rotation_pivo : Vector3 = Vector3(0.0,1.0,0.0)
@export var target_rotation : float = 0.0
@export var reverse_rotation : bool = false


func _validate_property(property: Dictionary) -> void:
	for bone in ["target_bone"]:
		if property.name == bone:
			var skeleton: Skeleton3D = get_skeleton()
			if skeleton:
				property.hint = PROPERTY_HINT_ENUM
				property.hint_string = skeleton.get_concatenated_bone_names()

func _process_modification_with_delta(delta: float) -> void:
	var skeleton: Skeleton3D = get_skeleton()
	if !skeleton:
		return
	
	var rad_rot : float
	if reverse_rotation:
		rad_rot = -target_rotation
	else:
		rad_rot = target_rotation
	
	
	var target_idx: int = skeleton.find_bone(target_bone)
	var pose: Transform3D = skeleton.get_bone_pose(target_idx).rotated_local(target_rotation_pivo.normalized(),rad_rot)
	skeleton.set_bone_pose(target_idx,pose)
