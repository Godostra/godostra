extends Node2D

var res_max = 0 setget res_max
var res_amount = 0 setget res_amount

func _ready():
	pass

func res_max(val):
	res_max = val
	res_update()

func res_amount(val):
	res_amount = val
	res_update()

func res_update():
	$label.set_text(str(res_amount)+"/"+str(res_max))