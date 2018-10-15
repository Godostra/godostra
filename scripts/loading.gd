extends Node2D

func _ready():
	var tex = ImageTexture.new()
	tex.load("res://data/techtrees/megapack/factions/"+global.faction_name+"/loading_screen.jpg")
	$sprite.set_texture(tex)

func _on_sprite_texture_changed():
	$timer.start()


func _on_timer_timeout():
	get_tree().change_scene("res://game.tscn")
