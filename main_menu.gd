extends Control

var GSC = preload("res://scripts/gsc.gd")
var DEV = preload("res://scripts/developer.gd").new()

onready var cnt = $panel/TabContainer
onready var file = File.new()

func _ready():
	#OS.set_window_maximized(true)
	DEV._ready()
	if DEV.val("autostart_game",false):
		get_tree().change_scene("res://loading.tscn")
	
	GSC.opt_add_items(cnt.get_node("Game/opt_map"),GSC.get_file_list("res://data/maps",["json"],false),global.map_name)
	GSC.opt_add_items(cnt.get_node("Game/opt_tileset"),GSC.get_dir_list("res://data/tilesets"),global.tileset_name)
	GSC.opt_add_items(cnt.get_node("Game/opt_techtree"),GSC.get_dir_list("res://data/techtrees"),global.techtree_name)
	_on_opt_techtree_item_selected(0) # TODO make it from defaults
	
	# DEVELOPER CONTENT
	file.open("user://developer.ini", File.READ)
	cnt.get_node("Developer/developer").set_text(file.get_as_text().substr(12,len(file.get_as_text())))
	file.close()

func _on_save_button_down():
	file.open("user://developer.ini", File.WRITE)
	file.store_string("[DEVELOPER]\n"+cnt.get_node("Developer/developer").get_text())
	file.close()
	
func _on_start_button_down():
	get_tree().change_scene("res://loading.tscn")


func _on_opt_map_item_selected(id):
	global.map_name = cnt.get_node("Game/opt_map").get_item_text(id)
	cnt.get_node("Game/map_preview").update()

func _on_opt_tileset_item_selected(id):
	global.tileset_name = cnt.get_node("Game/opt_tileset").get_item_text(id)

func _on_opt_techtree_item_selected(id):
	global.techtree_name = cnt.get_node("Game/opt_techtree").get_item_text(id)
	GSC.opt_add_items(cnt.get_node("Game/opt_faction"),GSC.get_dir_list("res://data/techtrees/"+global.techtree_name+"/factions"),global.techtree_name)

func _on_opt_faction_item_selected(id):
	global.faction_name = cnt.get_node("Game/opt_faction").get_item_text(id)
