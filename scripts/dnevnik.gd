class_name Dnevnik
extends Node3D


@export var lines = [
	"gladan sam",
	"galeb pasteta",
	"njam njam"
]
@export var next_line: int = 0


func read() -> String:
	var ret_line = lines[next_line]
	next_line += 1
	if next_line == lines.size():
		next_line = 0
	return "Dnevnik:\n" + "        \"" + ret_line + "\""
