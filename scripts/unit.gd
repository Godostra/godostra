extends Spatial

onready var GAME = get_node("/root/game")
var GSC = preload("res://scripts/gsc.gd")

var player_id = 0
var unit_name = ""
var unit_dir = ""
var size = 0
var height = 0
var aab
var def

var hp = 0

func _ready():
	#aab = get_node("Scene Root/Empty").get_children()[0].get_aabb()
	unit_dir = "res://data/techtrees/"+global.techtree_name+"/factions/"+global.faction_name+"/units/"+unit_name
	
	var file = File.new()
	file.open(unit_dir+"/"+unit_name+".json", File.READ)
	def = parse_json(file.get_as_text())
	file.close()
	def = def["unit"]["parameters"]
	
	size = def["size"]["value"]
	height = def["height"]["value"]
	hp = def["max-hp"]["value"]
	
	if player_id == global.player_id:
		for res in GSC.has_keys(def,["resources-stored","resource"]):
			GAME.get_node("hud/resources/res_"+res["name"]).res_max += res['amount']
		

	var sel = $selection.get_mesh().duplicate(true)
	var mat = SpatialMaterial.new()
	mat.albedo_color = Color(0,1,0)
	sel.set_material(mat)
	
	$selection.get_mesh().set_top_radius(size/2+1)
	$selection.set_mesh(sel)
	
	var envelope = Vector3(size-1.5,height,size-1.5)
	var envelope_t = Vector3(0,height/2-0.5,0)
	
	#var col = $collision.get_shape().duplicate(true)
	#col.set_extents(envelope) #/Vector3(2,2,2)
	#$collision.translate(envelope_t)
	#$collision.set_shape(col)
	
	$cube.translate(envelope_t)
	$cube.get_mesh().set_size(envelope)


func _input_event(camera, event, pos, normal, shape):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.is_pressed():
			get_node("/root/game").clear_selection()
			$selection.set_visible(true)
			var tex = ImageTexture.new()
			tex.load(unit_dir+"/images/"+unit_name+".bmp")
			GAME.get_node("hud/prop/icon").set_texture(tex)
			var info = "HP: "+str(hp)+"/"+str(def["max-hp"]["value"])+"\n"
			info += "Armor: "+str(def["armor"]["value"])+" ["+def["armor-type"]["value"]+"]\n"
			info += "Sight: "+str(def["sight"]["value"])+"\n"
			
			for res in GSC.has_keys(def,["resources-stored","resource"]):
				info += "Store: "+str(res['amount'])+" "+res["name"]+"\n"
			
			for res in GSC.has_keys(def,["resource-requirements","resource"]):
				if res["name"] == "food":
					info += "Consumes: "+str(res["amount"])+" food \n"

			GAME.get_node("hud/prop/info").set_text(info)