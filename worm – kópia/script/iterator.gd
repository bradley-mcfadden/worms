extends Node

class_name Iterator

var data
var idx := 0

func new_instance(data:Array):
	self.data = data

func next():
	if idx < len(data):
		var ret = data[idx]
		idx += 1
		return ret
	else:
		return null

func peek():
	var ret = next()
	idx -= 1
	return ret
