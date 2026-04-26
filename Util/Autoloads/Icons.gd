extends Node

var ICON_DICT : Dictionary =  {
	"ERROR": preload("uid://cci7w2e5ptmtb")
}

func get_icon_for(named_entity: String) -> Texture2D:
	return ICON_DICT[named_entity]
