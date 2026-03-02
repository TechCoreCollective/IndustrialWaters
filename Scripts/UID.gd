extends Node

const SCN_UI_SLOT = preload("uid://b66ronir3bmmc")

const IMG_SOLID_DRILL_ICON = preload("uid://c4iw125v170hr")
const IMG_OIL_DRILL_ICON = preload("uid://c3q46mgoxrgmh")
const IMG_SMELTER_ICON = preload("uid://ctd42onjtutii")
const IMG_COLLECTOR_ICON = preload("uid://djrwdqkjlhkcw")
const IMG_MANUFACTOR_ICON = preload("uid://bvpgcdbjnw04p")
const IMG_WARNING = preload("uid://ca1bn4wh1gtfm")

const IMG_CONVEYOR_GRID = preload("uid://dhyrb1wb65lqn")
const IMG_SOLID_DRILL_GRID = preload("uid://l3s3c06ehvmb")
const IMG_OIL_DRILL_GRID = preload("uid://cb0j65eeq4kf8")
const IMG_SMELTER_GRID = preload("uid://05yiexs357d2")
const IMG_COLLECTOR_GRID = preload("uid://c8asfcgpqdcdk")
const IMG_MANUFACTOR_GRID := preload("uid://bjyo536rxqj0")

const ITEM_TEXTURES : Dictionary[GlobalInventory.ItemType, Texture] = {
	GlobalInventory.ItemType.CopperOre: preload("uid://bxwaeqnk6y1tx"),
	GlobalInventory.ItemType.Diamond: preload("uid://celevn4rd7eh"),
	GlobalInventory.ItemType.IronOre: preload("uid://r2bwasf0ddpb"),
	GlobalInventory.ItemType.CopperIngot: preload("uid://cvy826krpwoe8"),
	GlobalInventory.ItemType.IronIngot: preload("uid://b8ycg4hj3jeal"),
	GlobalInventory.ItemType.Kelp: preload("uid://dfs4ctmcm7kb0"),
	GlobalInventory.ItemType.Mezholium: preload("uid://ntvel3qu5rl5"),
	GlobalInventory.ItemType.MezholiumStick: preload("uid://brrd52jgijcgn"),
	GlobalInventory.ItemType.Glue: preload("res://icons/Glue.png"),
	GlobalInventory.ItemType.CopperPlate: preload("uid://cnrtaol4r1dli"),
	GlobalInventory.ItemType.IronPlate: preload("uid://byahnre76jvu5")
}

const SCN_WELDING = preload("uid://jntm2ufk6b6s")
const SCN_PIPES = preload("uid://8lh0b6fdq8wh")

const JSON_TASKS = preload("uid://byvqdbn00o6dy")
const JSON_PIPES = preload("uid://g8t4fs6pgsgb")
const JSON_MACHINES = preload("uid://dt1nr0e0pecf8")
