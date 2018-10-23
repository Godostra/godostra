extends Spatial

var GSC = preload("res://scripts/gsc.gd")

const res_p = preload("res://misc/resources/resource.tscn")

const gold = preload("res://data/techtrees/megapack/resources/gold/models/gold.dae")
const stone = preload("res://data/techtrees/megapack/resources/stone/models/stone.dae")

const unit = preload("res://unit.tscn")

# TMP
const pyramid = preload("res://data/techtrees/megapack/factions/egypt/units/pyramid/models/pyramid.dae")
const pslave = preload("res://data/techtrees/megapack/factions/egypt/units/slave/models/slave.dae")

var map
var map_size = Vector2(0,0)
var map_area = Vector2(0,0)

var imgs = []

const tile_size = 2
const obj_scale = 1

"""
Objects:
	
1 = tree
2 = dead tree, cactus, thornbush
3 = stone (not harvestable)
4 = bush, grass, fern
5 = water object, reed, papyrus  (walkable)
6 = big tree, old palm (not harvestable)
7 = hanged, impaled
8 = statues
9 = mountain (unwalkable)
10 = invisible blocking object
11 = gold (harvestable)
12 = stone (harvestable)

Surfaces:
1 = grass
2 = secondary grass
3 = road
4 = stone - NOT AVAILABLE
5 = ground - NOT AVAILABLE

"""
var tileset
var tileset_load = []

var faction
var techtree

var units = {}
var cells = []

func _ready():
	randomize()
	
	# Setup map data
	
	map = GSC.read_json("res://data/maps/"+global.map_name+"/map.json")
	
	map_size = Vector2(map['width'],map['height'])
	map_area = map_size * Vector2(tile_size,tile_size)
	
	printt(map["heightFactor"],map_size)
	
	# Setup camera

	# $camera.margins = map_size
	
	# Setup tileset

	tileset = GSC.read_json("res://data/tilesets/"+global.tileset_name+"/"+global.tileset_name+".json")
	
	var i = 0
	for tg in tileset:
		tileset_load.append([])
		for tt in tileset[tg]:
			tileset_load[i].append(load("res://data/tilesets/"+global.tileset_name+"/models/"+tt+"/"+tt+".dae"))
		i += 1
	
	
	# Setup terrain
	
	$water.get_mesh().set_size(map_area)
	$terrain.get_mesh().set_size(map_area)
	
	$terrain.get_mesh().set_subdivide_width(map_size.x)
	#$terrain.get_mesh().set_subdivide_depth(map_size.y)
	
	var splatmap = ImageTexture.new()
	splatmap.load("res://data/maps/"+global.map_name+"/splatmap.png")
	
	var heightmap = ImageTexture.new()
	heightmap.load("res://data/maps/"+global.map_name+"/heightmap.png")
	
	var grass = ImageTexture.new()
	grass.load("res://data/tilesets/"+global.tileset_name+"/textures/dirt.png")
	
	var rock = ImageTexture.new()
	rock.load("res://data/tilesets/"+global.tileset_name+"/textures/grass.png")
	
	var dirt = ImageTexture.new()
	dirt.load("res://data/tilesets/"+global.tileset_name+"/textures/road.png")
	
	var water = ImageTexture.new()
	water.load("res://data/tilesets/"+global.tileset_name+"/textures/water.png")
	
	$water.get_surface_material(0).set_shader_param("texturemap",water)
	$water.set_translation(Vector3(0,map["waterLevel"]*0.40,0))
	
	$terrain.get_mesh().get_material().set_shader_param("source",heightmap)
	$terrain.get_mesh().get_material().set_shader_param("splatmap",splatmap)
	$terrain.get_mesh().get_material().set_shader_param("grass",grass)
	$terrain.get_mesh().get_material().set_shader_param("rock",rock)
	$terrain.get_mesh().get_material().set_shader_param("dirt",dirt)
	

	# Setup faction and resources
	
	techtree = GSC.read_json("res://data/techtrees/"+global.techtree_name+"/"+global.techtree_name+".json")
	faction = GSC.read_json("res://data/techtrees/"+global.techtree_name+"/factions/"+global.faction_name+"/"+global.faction_name+".json")
	faction = faction["faction"]

	
	i = 0
	for res in faction["starting-resources"]["resource"]:
		var res_new = res_p.instance()
		var res_tex = ImageTexture.new()
		res_tex.load("res://data/techtrees/"+global.techtree_name+"/resources/"+res["name"]+"/images/"+res["name"]+".bmp")
		
		res_new.set_name("res_"+res["name"])
		res_new.get_node("texture").set_texture(res_tex)
		res_new.set_position(Vector2(i*150+200,32))
		res_new.res_amount += int(res["amount"])
		$hud/resources.add_child(res_new)
		i += 1

	
	# Setup objects
	
	i = 0
	var z = 0
	var s = 0
	var o = 0
	
	for y in range(map_size.y):
		for x in range(map_size.x):
			o = map['resourceMap'][i]
			s = int(map['heightMap'][i][0])
			
			if o == 0 or s > 3:
				cells.append(0)
			else:
				cells.append(1)
			
			if o > 0 and o != 10:
				var obj
				var rand
				if o <= 10:
					rand = randi() % tileset_load[o-1].size()
					obj = tileset_load[o-1][rand].instance()
				elif o == 11:
					obj = gold.instance()
				elif o == 12:
					obj = stone.instance()
				
				for m in obj.get_children()[0].get_children():
					for ss in range(m.get_mesh().get_surface_count()):
						var mat = m.get_mesh().surface_get_material(ss)
						if mat != null:
							#mat.flags_transparent = true
							mat.flags_unshaded = true
							mat.params_use_alpha_scissor = true
							#mat.params_specular_mode = true
							m.get_mesh().surface_set_material(ss,mat)
				
				z = s*0.16
				obj.translate(Vector3(x*tile_size-map_area.x/2,z,y*tile_size-map_area.y/2))
				obj.set_scale(Vector3(obj_scale,obj_scale,obj_scale))
				obj.set_rotation_degrees(Vector3(0,randi()%359,0))
				
				$tileset.add_child(obj)
			
			i += 1
	
	# Initial objects
	
	for unit_load in GSC.get_dir_list("res://data/techtrees/"+global.techtree_name+"/factions/"+global.faction_name+"/units"):
		# TODO open json and get all daes
		units[unit_load] = load("res://data/techtrees/"+global.techtree_name+"/factions/"+global.faction_name+"/units/"+unit_load+"/models/"+unit_load+".dae")
	
	var player_no = 1
	for player in map['startLocations']:
		for unit_load in faction["starting-units"]["unit"]:
			for amount in range(0,unit_load["amount"]):
				var x = player[0]
				var y = player[1]
				var obj = units[unit_load["name"]].instance()
				var unit_name = unit_load["name"]
				place_obj(x,y,obj,unit_name,player_no)
		player_no += 1

func place_obj(x,y,obj,obj_name,player_no):
	var unit_new = unit.instance()
	unit_new.translate(near_free_cell(x,y))
	unit_new.set_scale(Vector3(obj_scale,obj_scale,obj_scale))
	unit_new.set_rotation_degrees(Vector3(0,randi()%359,0))
	unit_new.unit_name = obj_name
	unit_new.add_child(obj)
	unit_new.player_id = player_no
	$units.add_child(unit_new)
	for m in obj.get_children()[0].get_children():
		for ss in range(m.get_mesh().get_surface_count()):
			var mat = m.get_mesh().surface_get_material(ss)
			if mat != null:
				mat.flags_unshaded = true
				#mat.params_use_alpha_scissor = true
				m.get_mesh().surface_set_material(ss,mat)
	add_child(unit_new)

func near_free_cell(x,y):
	# TMP
	var cell_pos = cells[y*map_size.y+x]
	
	while cell_pos == 1:
		x += 2
		if cells[y*map_size.y+x] == 0:
			cell_pos = cells[y*map_size.y+x]
	
	cells[y*map_size.y+x] = 1
	var z = int(map['heightMap'][y*map_size.y+x][0])*0.35
	return Vector3(x*tile_size-map_area.x/2,z,y*tile_size-map_area.y/2)

func _on_main_menu_button_down():
	get_tree().change_scene("res://main_menu.tscn")


func clear_selection():
	for obj in $units.get_children():
		obj.get_node("selection").set_visible(false)