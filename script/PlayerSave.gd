#
# PlayerSave.gd stores player save information and read/writes it at the
# start or end of the game.
#

extends Node


const PLAYER_SAVE_FILE_NAME := "user://saved_game.json"
const INITIAL_SAVE_DATA := {
	"current_skin" : "classic",
	"highest_level_completed" : -1,
	"level_progress" : [],
	"upgrades" : [],
	"collected" : []
}
const NULL_TIME := -1

var save_data := INITIAL_SAVE_DATA


func _enter_tree() -> void:
	cload()


func _exit_tree() -> void:
	save()


func save() -> void:
#
# save records the current player save data into the save file.
#
	var save_file := File.new()
	if save_file.open(PLAYER_SAVE_FILE_NAME, File.WRITE) != OK:
		print("could not open save file for writing")
		return
	save_file.store_string(JSON.print(save_data))
	save_file.close()


func cload() -> void:
#
# cload will load the save data from the player save file, or initialize it
# to the default contents if it does not exist.
#
# In the event that the save file is not valid in format, it will be assumed to
# be corrupted, and will be copied to PLAYER_SAVE_FILE_NAME + '.bak' so the player
# can take a look at it.
#
	var save_file := File.new()
	if save_file.open(PLAYER_SAVE_FILE_NAME, File.READ) != OK:
		print("could not open save file for reading")
		return
	var file_text := save_file.get_as_text()
	save_file.close()
	
	var json_result := JSON.parse(file_text)
	if json_result.error != OK:
		# might want to copy the player's corrupted file here
		var copy_save_file := File.new()
		if copy_save_file.open(PLAYER_SAVE_FILE_NAME + '.bak', File.WRITE) == OK:
			copy_save_file.store_string(file_text)
			copy_save_file.close()
			# Initialize save data
			save_data = INITIAL_SAVE_DATA
		print("could not parse save file as JSON")
	else:
		save_data = json_result.result
	# Initialize all levels to have zero progress
	for _i in range(len(Levels.get_level_list())):
		save_data.level_progress.append({
			"time" : NULL_TIME,
			"collected" : []
		})


func delete() -> void:
	save_data = INITIAL_SAVE_DATA
	save()


func add_to_upgrades(upgrade_name: String) -> void:
#
# add_to_upgrades
# Add @upgrade_name to the list of obtained upgrades if it does not already exist.
# @upgrade_name - Unique upgrade name to record to save file.
#
# TODO - Is the upgrade valid?
	var current_upgrades: Array = save_data.upgrades
	if current_upgrades.find(upgrade_name) != -1:
		current_upgrades.append(upgrade_name) 


func update_level_progress(level_idx: int, progress: Dictionary) -> int:
#
# update_level_progress
# @level_idx - Index of level to save progress for.
# @progress - Dictionary containing time integer, and array of collectibles.
# @return - Error.OK if successfully recorded, ERR_PARAMETER_RANGE_ERROR if some error occurred.
#
	var number_of_levels :=  len(Levels.get_level_list)
	if not (level_idx >= 0 and level_idx < number_of_levels):
		print("level index %d out of range 0 to %d" % [level_idx, number_of_levels])
		return ERR_PARAMETER_RANGE_ERROR
	if not (progress.has("collected") and progress.has("time") and progress.collected is Array and progress.time is int):
		print("malformed level progress")
		return ERR_PARAMETER_RANGE_ERROR
	save_data.level_progress[level_idx] = progress
	return OK


func set_current_skin(skin_name: String) -> int:
#
# set_current_skin - Change the player's skin to @skin_name, record it.
# @skin_name - Skin identifier that player should use by default.
# @return - OK if @skin_name is a valid skin, an error otherwise.
#
	if Skins.skin_by_name(skin_name).empty():
		print("%s is not a valid skin" % skin_name)
		return ERR_PARAMETER_RANGE_ERROR
	save_data.current_skin = skin_name
	return OK


func set_highest_level_completed(level_idx: int) -> int:
#
# set_highest_level_completed
# Change the index of the highest completed level.
# @level_idx - Index of new highest level completed.
# @return - OK if everything was fine, ERR if index is not in range.
#
	var number_of_levels := len(Levels.get_level_list())
	if not (level_idx >= 0 and level_idx < number_of_levels):
		print("level index %d out of range 0 to %d" % [level_idx, number_of_levels])
		return ERR_PARAMETER_RANGE_ERROR
	save_data.highest_level_completed = level_idx
	return OK


func has_collected(collectible_name: String) -> bool:
#
# has_collected
# Check if player has collected @collectible_name.
# @return - True if player has collected @collectible_name, false otherwise.
# 
	return save_data.collected.find(collectible_name) != -1


func add_collectible(collectible_name: String) -> bool:
#
# add_collectible
# Record a collectible into the save file.
# @return - True if collectible was not already in the file.
#
	if save_data.collected.find(collectible_name) != -1:
		return false
	save_data.collected.append(collectible_name)
	return true
