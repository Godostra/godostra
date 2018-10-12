extends Node

var config = ConfigFile.new()

func _ready():
	config.load("user://developer.ini")
	if not config.has_section("DEVELOPER"):
		config.set_value("DEVELOPER","foo_bar",false)
		config.save("user://developer.ini")

func val(attr,default=0):
	return config.get_value("DEVELOPER",attr,default)