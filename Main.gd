extends Node2D

onready var background = $Background

func _ready():
	pass

func _process(delta):
	background.rect_size = get_viewport_rect().size
