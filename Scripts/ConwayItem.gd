class_name ConwayItem
extends Resource

var item_type: GlobalInventory.ItemType = GlobalInventory.ItemType.None
var time_on_belt: float
var associated_sprite: Sprite2D
var conway_path_index: int
var world_tile: Vector2i

static func ctor(type: GlobalInventory.ItemType):
	var result = ConwayItem.new()
	result.item_type = type
	result.time_on_belt = 0
	return result
