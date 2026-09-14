class_name GalebSfxPlayer
extends AudioStreamPlayer3D


const GALEB_1 = preload("uid://dn5j0bxi0n1q8")
const GALEB_2 = preload("uid://ds4li6ujldnby")
const GALEB_3 = preload("uid://bvwe5nwa5ttha")
const GALEB_4 = preload("uid://5vdgmkcgot3h")
const GALEB_5 = preload("uid://dhe8dweedet0e")
const GALEB_6 = preload("uid://bkln543rqxqvx")
const GALEB_SMRT_1 = preload("uid://dlki3jf33ytkw")
const GALEB_SMRT_2 = preload("uid://bpupuwxs3wd8r")

const GALEB_SFX = [GALEB_1, GALEB_2, GALEB_3, GALEB_4, GALEB_5, GALEB_6]
const GALEB_SMRT_SFX = [GALEB_SMRT_1, GALEB_SMRT_2]

@onready var sfx_player: AudioStreamPlayer3D = $"."


func play_sfx() -> void:
	sfx_player.stream = GALEB_SFX[randi_range(0, GALEB_SFX.size() - 1)]
	sfx_player.play()


func play_death_sfx() -> void:
	sfx_player.stream = GALEB_SFX[randi_range(0, GALEB_SFX.size() - 1)]
	sfx_player.play()
