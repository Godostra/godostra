extends Node2D

var file = File.new()

var tile_size = 3

var map_size = Vector2(0,0)

func _ready():
	pass

func _draw():
	file.open("res://data/maps/"+global.map_name+"/map.json", File.READ)
	var map = parse_json(file.get_as_text())
	file.close()
	
	map_size = Vector2(map['width'],map['height'])
	
	if map_size.x >= 256 or map_size.y >= 256:
		tile_size = 2
	
	#print(map['players'])
	
	var i = 0
	var color = "#ffffff"
	
	for y in range(map_size.y):
				for x in range(map_size.x):
					var h = int(map['heightMap'][i][0])
					var o = int(map['resourceMap'][i])
					var s = int(map['surfaceMap'][i])
					if o == 1:
						color = "#bc460d" # tree
					elif o == 11:
						color = "#babc0d" # tree
					elif o == 12:
						color = "#707070" # tree
					else:
						if h < 2:
							color = "#1f50cd" # water
						else:
							if s == 3:
								color = "#a67962" # road
							else:
								color = "#26722d" # grass
					draw_rect(Rect2(Vector2(x*tile_size,y*tile_size),Vector2(tile_size,tile_size)),Color(color),true)
					i += 1
