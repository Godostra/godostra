extends Spatial

var GSC = preload("res://scripts/gsc.gd")

const res_p = preload("res://misc/resources/resource.tscn")

const gold = preload("res://data/techtrees/megapack/resources/gold/models/gold.dae")
const stone = preload("res://data/techtrees/megapack/resources/stone/models/stone.dae")

const pyramid = preload("res://data/techtrees/megapack/factions/egypt/pyramid/pyramid.dae")
const unit = preload("res://unit.tscn")

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

func _ready():
	randomize()
	
	# Setup map data
	
	map = GSC.read_json("res://data/maps/"+global.map_name+".json")
	
	map_size = Vector2(int(map['width']),int(map['height']))
	map_area = map_size * Vector2(tile_size,tile_size)
	
	
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
	
	var splatmap = ImageTexture.new()
	splatmap.load("res://data/maps/"+global.map_name+"_splat.png")
	
	var heightmap = ImageTexture.new()
	heightmap.load("res://data/maps/"+global.map_name+"_heightmap.png")
	
	var grass = ImageTexture.new()
	grass.load("res://data/tilesets/"+global.tileset_name+"/textures/dirt.png")
	
	var rock = ImageTexture.new()
	rock.load("res://data/tilesets/"+global.tileset_name+"/textures/grass.png")
	
	var dirt = ImageTexture.new()
	dirt.load("res://data/tilesets/"+global.tileset_name+"/textures/road.png")
	
	var water = ImageTexture.new()
	water.load("res://data/tilesets/"+global.tileset_name+"/textures/water.png")
	
	$water.get_surface_material(0).set_shader_param("texturemap",water)
	
	$terrain.get_mesh().get_material().set_shader_param("source",heightmap)
	$terrain.get_mesh().get_material().set_shader_param("splatmap",splatmap)
	$terrain.get_mesh().get_material().set_shader_param("grass",grass)
	$terrain.get_mesh().get_material().set_shader_param("rock",rock)
	$terrain.get_mesh().get_material().set_shader_param("dirt",dirt)
	

	# Setup faction and resources
	
	techtree = GSC.read_json("res://data/techtrees/"+global.techtree_name+"/"+global.techtree_name+".json")
	faction = GSC.read_json("res://data/techtrees/"+global.techtree_name+"/factions/"+global.faction_name+"/"+global.faction_name+".json")

	
	i = 0
	for res in faction["faction"]["starting-resources"]["resource"]:
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
			o = int(map['objects'][i])
			if o > 0 and o != 10:
				s = float(map['heights'][i])
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
							mat.params_specular_mode = true
							m.get_mesh().surface_set_material(ss,mat)
				
				z = s*0.16
				obj.translate(Vector3(x*tile_size-map_area.x/2,z,y*tile_size-map_area.y/2))
				obj.set_scale(Vector3(obj_scale,obj_scale,obj_scale))
				obj.set_rotation_degrees(Vector3(0,randi()%359,0))
				
				$tileset.add_child(obj)
			
			i += 1
	
	# Setup initial units TMP
	for player in map['players']:
		var player_pos = map['players'][str(player)]
		var obj = pyramid.instance()
		var x = int(player_pos[0])
		var y = int(player_pos[1])
		s = float(map['heights'][y*map_size.y+x])
		z = s*0.16
		var unit_new = unit.instance()
		unit_new.translate(Vector3(x*tile_size-map_area.x/2,z,y*tile_size-map_area.y/2))
		unit_new.set_scale(Vector3(obj_scale,obj_scale,obj_scale))
		unit_new.set_rotation_degrees(Vector3(0,randi()%359,0))
		unit_new.unit_name = "pyramid"
		unit_new.add_child(obj)
		unit_new.player_id = int(player)+1
		$units.add_child(unit_new)
		add_child(obj)

func _on_main_menu_button_down():
	get_tree().change_scene("res://main_menu.tscn")


func clear_selection():
	for obj in $units.get_children():
		obj.get_node("selection").set_visible(false)