# Godostra Controls Class
extends Node

func _ready():
	pass

# Get list of files
func get_file_list(path,extensions=[],include_ext=true):
	var dir = Directory.new()
	var output = []
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while (file_name != ""):
			if not dir.current_is_dir():
				var split = file_name.split(".")
				if extensions.size() == 0 or extensions.find(split[1]) != -1:
					if not include_ext:
						file_name = split[0]
					output.append(file_name)
			file_name = dir.get_next()
	output.sort()
	return output

# Get list of directories
func get_dir_list(path):
	var dir = Directory.new()
	var output = []
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while (file_name != ""):
			if dir.current_is_dir() and file_name != "." and file_name != "..":
				output.append(file_name)
			file_name = dir.get_next()
	output.sort()
	return output

# Batch add items to OptionButton
func opt_add_items(node,items,selected=""):
	var i = 0
	var sel_i = 0
	for item in items:
		if item == selected:
			sel_i = i
		node.add_item(item)
		i += 1
	node.select(sel_i)
	
# Get json
func read_json(file_path):
	var file = File.new()
	file.open(file_path, File.READ)
	var json = parse_json(file.get_as_text())
	file.close()
	return json