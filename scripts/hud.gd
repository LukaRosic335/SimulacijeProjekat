extends Control

@onready var interaction_ray: RayCast3D = $"../head/Camera3D/InteractionRay"
@onready var crosshair: TextureRect = $crosshair
@onready var camera_3d: Camera3D = $"../head/Camera3D"
@onready var framerate: Label = $framerate
@onready var text: Label = $text

@onready var general = preload("res://assets/crosshairs/general.png")
@onready var interact = preload("res://assets/crosshairs/interact.png")
@onready var screen = preload("res://assets/crosshairs/screen.png")
@onready var service = preload("res://assets/crosshairs/service.png")

var text_timer: float = 0.0

@export var ne_plivanje_voicelines = [
	"Voleo bih da znam da plivam",
	"Udavicu se",
	"Plaism se riba",
	"Necu da ukvasim carape",
	"Mrzim sol",
]
var last_np_voiceline: int = 0


func _ready() -> void:
	text.hide()


func _process(delta: float) -> void:
	if text_timer <= 0:
		text.hide()
	text_timer -= delta
	
	framerate.text = str(Engine.get_frames_per_second())
	var target = interaction_ray.__find_target()
	if target == null:
		crosshair.texture = general
		return
	if target.is_in_group("Pickable"):
		crosshair.texture = interact
	elif target.is_in_group("Interactable"):
		crosshair.texture = interact
	else:
		crosshair.texture = general


func show_text(tex: String) -> void:
	text.text = tex
	text_timer = 3
	text.show()

func show_ne_znam_da_plivam() -> void:
	var index = randi_range(0, ne_plivanje_voicelines.size()-1)
	while index == last_np_voiceline:
		index = randi_range(0, ne_plivanje_voicelines.size()-1)
	show_text(ne_plivanje_voicelines[index])
