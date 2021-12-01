tool
extends Node2D

# TODO you can't use child nodes because I don't want the tileset to appear in the world, but it should be in memory somewhere only once
# T0 prevent leaking, use a singleton so it only loads once

var tilemaps = {}
var level_amount = 9

func _ready():
	
	for i in level_amount:
		var lvl_num = i+1
		tilemaps[lvl_num] = load("res://Levels/Level%sTilemap.tmx" % lvl_num).instance()

# TODO you can't do "Level%dTilemap.tmx" here because the instanced scenes need to be kept in memory ONLY ONCE
# if you keep calling instance() you WILL leak memory
# You can only do this if you know exactly how many levels your game has...

func get_level_tilemap_base(level: int):
	
	if level in tilemaps:
		return tilemaps[level]
	else:
		print("warning: unknown level ", level)
		return null
