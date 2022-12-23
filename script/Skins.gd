#
# Skins.gd
# AutoLoad that loads the skin data, and allows scripts to access
# it.
#

extends Node

const SKINS_FILE_PATH = "res://data/skins.json"

var _skins := {}

func _enter_tree() -> void:
    pass


func _load_from_data_file() -> void:
    var file := File.new()
    if file.open(SKINS_FILE_PATH, File.READ) == OK:
        var json_data := file.get_as_text()
        var result := JSON.parse(json_data)
        if result.error == OK:
            _skins = result.result["skins"]


func skins() -> Array:
    if _skins.has("skins"):
        return _skins["skins"]
    else:
        return []
    