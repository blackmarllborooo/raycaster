package render

import rl "vendor:raylib"
import world "../world"

TileSize :: 50

DrawMap :: proc(game_map: ^world.Map) {
    for y in 0..<world.MapHeight {
        for x in 0..<world.MapWidth {
            title := game_map.tiles[y][x]

            switch title {
                case .Wall:
                    rl.DrawRectangle(
                        i32(x * TileSize),
                        i32(y * TileSize),
                        i32(TileSize),
                        i32(TileSize),
                        rl.GRAY,
                    )
                case .Empty:
                    rl.DrawRectangle(
                        i32(x * TileSize),
                        i32(y * TileSize),
                        i32(TileSize),
                        i32(TileSize),
                        rl.DARKGRAY,
                    )
            }
        }
    }
}