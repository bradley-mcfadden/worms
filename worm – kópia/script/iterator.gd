class_name Iterator
extends Node

var data
var idx := 0


func new_instance(dat: Array):
	self.data = dat


func next():
	if idx < len(data):
		var ret = data[idx]
		idx += 1
		return ret
	return null


func peek():
	var ret = next()
	idx -= 1
	return ret
