extends Control


@onready var master_bus = AudioServer.get_bus_index("Master")
@onready var h_slider: HSlider = $GridContainer/HBoxContainer/HSlider


func _ready() -> void:
	h_slider.value = db_to_linear(AudioServer.get_bus_volume_db(master_bus))


func _on_h_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(master_bus, linear_to_db(value))


func _on_btnback_pressed() -> void:
	queue_free()
