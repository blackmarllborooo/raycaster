package render

import rl "vendor:raylib"
import geo "../geo"
import world "../world"



DrawMap :: proc(game_map: ^world.Map, scale: f32 = 1, offset: geo.Vec2 = geo.Vec2{0, 0}) {
    tile_size := world.TileSize * scale

    for y in 0..<world.MapHeight {
        for x in 0..<world.MapWidth {
            title := game_map.tiles[y][x]

            color := title == .Wall ? rl.GRAY : rl.DARKGRAY

            // +1 to avoid rounding gaps between adjacent tiles
            rl.DrawRectangle(
                i32(offset.x + f32(x) * tile_size),
                i32(offset.y + f32(y) * tile_size),
                i32(tile_size) + 1,
                i32(tile_size) + 1,
                color,
            )
        }
    }
}
