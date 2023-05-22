# Logger is a node that handles global logging.
# It allows basically to set log levels and log with tags,
# which should make the process of searching and managing
# log files easier.
extends Node

# LogLevel
# FATAL - Should be used for messages about what crashed the system
# ERROR - Significant errors that are recoverable but should be reported
# WARNING - Suspicious conditions worth reporting
# DEBUG - Information to aid with debugging
# INFO - Info about normal program flow
# VERBOSE - Highly detailed messages about common happenings
enum LogLevel { FATAL, ERROR, WARNING, DEBUG, INFO, VERBOSE }

const DEFAULT_FORMAT := "{time} {tag}:{level} {text}"

onready var _log_level_text: String 
onready var log_level: int = LogLevel.WARNING setget set_log_level
onready var include_time_format := true
onready var log_format := DEFAULT_FORMAT


func set_log_level(new_log_level: int) -> void:
# set_log_level
# new_log_level - Log level to replace current level with. Should be
#                 one of the LogLevel enums.
	match new_log_level:
		LogLevel.FATAL:
			_log_level_text = "F"
		LogLevel.ERROR:
			_log_level_text = "E"
		LogLevel.WARNING:
			_log_level_text = "W"
		LogLevel.DEBUG:
			_log_level_text = "D"
		LogLevel.INFO:
			_log_level_text = "I"
		LogLevel.VERBOSE:
			_log_level_text = "V"
	
	log_level = new_log_level


func f(tag: String, text: String) -> void:
# f - Log a fatal message.
# tag - Tag to use.
# text - Message body.
	if log_level >= LogLevel.FATAL:
		var time_str := Time.get_datetime_string_from_system(false, true)
		print(log_format.format({"time" : time_str, "tag" : tag, "level" : _log_level_text, "text" : text}))


func e(tag: String, text: String) -> void:
# e - Log an error message.
# tag - Tag to use.
# text - Message body.
	if log_level >= LogLevel.ERROR:
		var time_str := Time.get_datetime_string_from_system(false, true)
		print(log_format.format({"time" : time_str, "tag" : tag, "level" : _log_level_text, "text" : text}))


func d(tag: String, text: String) -> void:
# d - Log a debug message.
# tag - Tag to use.
# text - Message body.
	if log_level >= LogLevel.DEBUG:
		var time_str := Time.get_datetime_string_from_system(false, true)
		print(log_format.format({"time" : time_str, "tag" : tag, "level" : _log_level_text, "text" : text}))


func w(tag: String, text: String) -> void:
# w - Log a warning message.
# tag - Tag to use.
# text - Message body.
	if log_level >= LogLevel.WARNING:
		var time_str := Time.get_datetime_string_from_system(false, true)
		print(log_format.format({"time" : time_str, "tag" : tag, "level" : _log_level_text, "text" : text}))


func i(tag: String, text: String) -> void:
# i - Log an info message.
# tag - Tag to use.
# text - Message body.
	if log_level >= LogLevel.INFO:
		var time_str := Time.get_datetime_string_from_system(false, true)
		print(log_format.format({"time" : time_str, "tag" : tag, "level" : _log_level_text, "text" : text}))


func v(tag: String, text: String) -> void:
# v - Log a verbose message.
# tag - Tag to use.
# body - Message body.
	if log_level >= LogLevel.VERBOSE:
		var time_str := Time.get_datetime_string_from_system(false, true)
		print(log_format.format({"time" : time_str, "tag" : tag, "level" : _log_level_text, "text" : text}))