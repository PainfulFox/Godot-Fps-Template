extends CharacterBody3D

#Node References
@onready var bob_pivot = $Head/BobPivot
@onready var camera_3d = $Head/BobPivot/Camera3D
@onready var head = $Head

@onready var player_collision = $PlayerCollision
@onready var head_check = $HeadCheck

@onready var Audio_Player = $AudioStreamPlayer3D

#Move
@export var Current_Speed = 5.0
const Walking_Speed = 5.0
const Sprinting_Speed = 8.0
const Crouching_Speed = 3.0
const jumpVelocity = 4.5

#footSteps
var Footsteptimer = 0

#States
var walking = false
var sprinting = false
var crouching = false

#input vars
var lerpSpeed = 10
var direction = Vector3.ZERO
@export var MouseSensitivity = 0.06
var crouchingDepth = -0.5

#head bobbing vars
const Bob_Sprinting_Speed = 15
const Bob_Walking_Speed = 10
const Bob_Crouching_Speed = 5

const Bob_Sprinting_Intensity = 0.05
const Bob_Walking_Intensity = 0.025
const Bob_Crouching_Intensity = 0.025

var Bob_Vector = Vector2.ZERO 
var Bob_Index = 0
var Bob_Current_Intensity = 0.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):

	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * MouseSensitivity))
		head.rotate_x(deg_to_rad(-event.relative.y * MouseSensitivity))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))
		
	if event.is_action_pressed("pause"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if event.is_action_pressed("shoot"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	#handle movement state
	if	Input.is_action_pressed("crouch"):
		if is_on_floor():
			Current_Speed = Crouching_Speed
		head.position.y = lerp(head.position.y,1.75 + crouchingDepth, delta * lerpSpeed)
		player_collision.shape.height = 1.2
		player_collision.position.y = 0.6
		
		walking = false
		sprinting = false
		crouching = true
	elif !head_check.is_colliding():
		head.position.y = lerp(head.position.y,1.75, delta * lerpSpeed)
		player_collision.shape.height = 2
		player_collision.position.y = 1
		
		if	Input.is_action_pressed("sprint"):
			Current_Speed = Sprinting_Speed
			walking = false
			sprinting = true
			crouching = false
		else:
			Current_Speed = Walking_Speed
			walking = true
			sprinting = false
			crouching = false
	#Head Bobbing
	if sprinting:
		Bob_Current_Intensity = Bob_Sprinting_Intensity
		Bob_Index += Bob_Sprinting_Speed * delta
		Footsteps(delta, 0.35, input_dir)
	elif walking:
		Bob_Current_Intensity = Bob_Walking_Intensity
		Bob_Index += Bob_Walking_Speed * delta 
		Footsteps(delta, 0.6, input_dir)
	elif crouching:
		Bob_Current_Intensity = Bob_Crouching_Intensity
		Bob_Index += Bob_Crouching_Speed * delta 
		#Footsteps(delta, 0.75, input_dir)
		
	if is_on_floor() && input_dir != Vector2.ZERO:
		Bob_Vector.y = sin(Bob_Index)
		Bob_Vector.x = sin(Bob_Index/2) + 0.5
		
		bob_pivot.position.y = lerp(bob_pivot.position.y, Bob_Vector.y * (Bob_Current_Intensity/2.0), delta * lerpSpeed)
		bob_pivot.position.x = lerp(bob_pivot.position.x, Bob_Vector.x * Bob_Current_Intensity, delta * lerpSpeed)
	else:
		bob_pivot.position.y = lerp(bob_pivot.position.y, 0.0, delta * lerpSpeed)
		bob_pivot.position.x = lerp(bob_pivot.position.x, 0.0, delta * lerpSpeed)

	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jumpVelocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * lerpSpeed)
	
	
	if direction:
		velocity.x = direction.x * Current_Speed
		velocity.z = direction.z * Current_Speed
	else:
		velocity.x = move_toward(velocity.x, 0, Current_Speed)
		velocity.z = move_toward(velocity.z, 0, Current_Speed)

	move_and_slide()	

func Footsteps(delta,FootstepInterval, input):
	if is_on_floor():
		if input != Vector2.ZERO:
			Footsteptimer += delta
			if Footsteptimer >= FootstepInterval:
				Audio_Player.pitch_scale = randf_range(0.65,1.25)
				Audio_Player.play()
				Footsteptimer = 0
