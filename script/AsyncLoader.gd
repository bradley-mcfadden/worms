
# 
# async_loader.gd
# Allows for loading a resource from another node without entirely blocking.
#
extends Node

# Emitted when a resource has finished loading.
signal resource_loaded(path, resource) # String, Resource

onready var loader: ResourceInteractiveLoader
onready var wait_frames: int = 1
onready var time_max: int = 100 # msec
onready var current_scene: Node
onready var resource_path: String
onready var thread: Thread = null


func _ready() -> void:
	var root: Node = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)


func load_resource(path: String) -> void:
#
# load_resource
# Loads the resource at path interactively. The "resource_loaded"
# signal is emitted when it finished, with path as an argument.
# path - Resource to load
#
	resource_path = path
	loader = ResourceLoader.load_interactive(path)
	if loader == null:
		# show an error
		return
	if not thread == null:
		thread.wait_to_finish()
	thread = Thread.new()
	var err: int = thread.start(self, "_load_resource", null)
	if err == OK:
		print("Thread started")
	else:
		print("Thread not started")
	
	# start "loading..." animation
	# not yet implemented
	wait_frames = 1


func _load_resource(_userdata) -> void:
	if loader == null:
		print("Loader is null")
		return
	
	# Wait for frames to let the "loading" animation show up
	# if wait_frames > 0:
	# 	wait_frames -= 1
	# 	return
	
	# Use "time_max" to control for how long we block this thread
	while true:
		# Poll the loader
		var err: int = loader.poll()

		if err == ERR_FILE_EOF: # Finished loading
			var resource: Resource = loader.get_resource()
			loader = null
			emit_signal("resource_loaded", resource_path, resource)
			resource_path = ""
			print("Done loading")
			break
		elif err == OK:
			pass
			#print("OK")
		else:
			loader = null
			resource_path = ""
			# print("Not OK")
			break


func change_scene_to(scene: PackedScene) -> void:
#
# change_scene_to
# Synchronously change the active scene to the scene
# resource by instancing it and replacing the root child.
#
	var root: Node = get_tree().get_root()
	var previous_scene: Node = root.get_child(root.get_child_count() - 1)
	# previous_scene.queue_free()
	print("Freeing ", previous_scene)
	current_scene = scene.instance()
	get_node("/root").add_child(current_scene)
	previous_scene.call_deferred("queue_free")


func _exit_tree():
	if not thread == null:
		thread.wait_to_finish()
