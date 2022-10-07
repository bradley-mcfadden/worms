#
# Iterator provides a way to iterator through an Array
# without knowing anything about it.
#

class_name Iterator
extends Node

var data: Array
var idx := 0


func new_instance(dat: Array) -> void:
# new_instance of Iterator backed by dat
# dat - Array to back Iterator with
	self.data = dat


func next(): # Returns some generic type.
# next increments the iterator's position and returns the next element.
# return next element or null if reached end.
	if idx < len(data):
		var ret = data[idx]
		idx += 1
		return ret
	return null


func peek(): # Returns some generic type.
# look at the next element without incrementing the index.
# return - Next element or null if we're at the last position.
	var ret = next()
	idx -= 1
	return ret
