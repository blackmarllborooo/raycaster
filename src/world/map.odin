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

// IsBlocked reports whether a circle of the given radius centered at pos
// overlaps a wall tile or the outside of the map.
IsBlocked :: proc(game_map: ^Map, pos: geo.Vec2, radius: f32) -> bool {
    min_tx := int((pos.x - radius) / TileSize)
    max_tx := int((pos.x + radius) / TileSize)
    min_ty := int((pos.y - radius) / TileSize)
    max_ty := int((pos.y + radius) / TileSize)

    for ty in min_ty..=max_ty {
        for tx in min_tx..=max_tx {
            if tx < 0 || tx >= MapWidth || ty < 0 || ty >= MapHeight {
                return true
            }
            if game_map.tiles[ty][tx] == .Wall {
                return true
            }
        }
    }

    return false
}