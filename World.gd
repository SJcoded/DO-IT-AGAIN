extends Node2D


onready var camera_scene = preload('res://Scenes/Character/MainCamera.tscn')
onready var character_scene = preload('res://Scenes/Character/Character.tscn')
onready var scene_transition = preload('res://Scenes/Transition/SceneTransition.tscn')

var bottom_location = Vector2(32, -170)
var brick_location = Vector2(32, -600)
var clouds_location = Vector2(32, -900)
var court_location = Vector2(160, -1020)
var at_bottom = Vector2(160,90)
var camera_follows_player = false
var current_character : KinematicBody2D

onready var win_screen_scene = preload('res://Scenes/Court/YouWin/YouWin.tscn')

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	new_camera()
	spawn_in_court()
	Player.connect("respawn", self, 'spawn_at_bottom')
	Player.connect("lifted", self, '_camera_on_court')
	Player.connect('start_bg_music', self, 'start_bg_music')
	Player.connect('end_bg_music', self, 'stop_bg_music')
	Player.connect("beat_the_game", self, '_trigger_win_screen')
	Player.connect('follow', self, '_follow_player')


func spawn_at_bottom():
	camera_follows_player = false
	var transition: SceneTransition = scene_transition.instance()
	add_child(transition)
	transition.clouds()
	# Reset character
	Player.dead = false
	var character: KinematicBody2D = spawn_new_player()
	character.position = bottom_location
	# Set camera position
	yield(get_tree().create_timer(0.5),"timeout")
	Player.camera.queue_free()
	new_camera().position = at_bottom
	Player.camera.current = true
	# Gain new ability
	Player.roll_the_dice()



func spawn_in_court()->void:
	# Set character
	var character: KinematicBody2D = spawn_new_player()
	character.position = clouds_location
	Player.camera.position = court_location
	# Set camera
#	_camera_on_court()

func spawn_below_court()->void:
	# Set character
	var character: KinematicBody2D = spawn_new_player()
	character.position = clouds_location


func spawn_new_player()->KinematicBody2D:
	var character = character_scene.instance()
	current_character = character
	$YSort.add_child(character)
	$YSort.move_child(character, 0)
	return character

func new_camera()->MainCamera:
	var camera = camera_scene.instance()
	add_child(camera)
	Player.camera = camera
	return camera


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed('ui_restart'):
		Player.death()
	
	# Follow player
	if camera_follows_player:
		Player.camera.position = current_character.position

func _follow_player(yes:bool = true)->void:
	if yes:
		camera_follows_player = true
	else:
		camera_follows_player = false

#func _camera_on_court()->void:
#	var starting_camera: MainCamera = camera_scene.instance()
#	add_child(starting_camera)
#	starting_camera.position = court_location
#	starting_camera.current = true
#	Player.camera = starting_camera


func start_bg_music()->void:
	$AudioStreamPlayer.play()
	$AnimationPlayer.play("fade_in_music")

func stop_bg_music()->void:
	$AnimationPlayer.play("fade_out_music")
	yield($AnimationPlayer, "animation_finished")
	$AudioStreamPlayer.stop()

func _trigger_win_screen()->void:
	var win_screen = win_screen_scene.instance()
	add_child(win_screen)
