package world

import geo "../geo"

TileSize :: 50

MapWidth :: 10
MapHeight :: 10

Tile :: enum u8 {
	Empty,
	Wall,
}


Map :: struct {
	tiles: [MapHeight][MapWidth]Tile,
}

NewMap :: proc() -> Map {
	game_map := Map{}

	for y in 0..<MapHeight {
		for x in 0..<MapWidth {

			// if the tile is on the border of the map, make it a wall
			if x == 0 || 
			   x == MapWidth-1 ||
			   y == 0 || 
			   y == MapHeight-1 {
				game_map.tiles[y][x] = .Wall
			} else {
				game_map.tiles[y][x] = .Empty
			}
		}
	}

	// Add some walls in the middle of the map
	game_map.tiles[5][4] = .Wall
	game_map.tiles[5][5] = .Wall
	game_map.tiles[5][6] = .Wall

	return game_map
}

WorldToTile :: proc(pos: geo.Vec2) -> (tx, ty: int) {
    return int(pos.x / TileSize), int(pos.y / TileSize)
}