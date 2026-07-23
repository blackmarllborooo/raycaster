package render

import rl "vendor:raylib"
import geo "../geo"
import world "../world"

MinimapScale :: f32(0.25)
MinimapPadding :: f32(15)
MinimapBorder :: f32(4)

// DrawMinimap draws a small top-down overview of the map and player in the
// corner of the screen, on top of the 3D scene.
DrawMinimap :: proc(p: ^world.Player, game_map: ^world.Map, sprites: []world.Sprite) {
    offset := geo.Vec2{MinimapPadding, MinimapPadding}
    map_w := f32(world.MapWidth) * world.TileSize * MinimapScale
    map_h := f32(world.MapHeight) * world.TileSize * MinimapScale

    rl.DrawRectangle(
        i32(offset.x - MinimapBorder),
        i32(offset.y - MinimapBorder),
        i32(map_w + MinimapBorder * 2),
        i32(map_h + MinimapBorder * 2),
        rl.Color{0, 0, 0, 180},
    )

    DrawMap(game_map, MinimapScale, offset)
    DrawSpriteMarkers(sprites, MinimapScale, offset)
    DrawPlayer(p, MinimapScale, offset)

    rl.DrawRectangleLines(
        i32(offset.x - MinimapBorder),
        i32(offset.y - MinimapBorder),
        i32(map_w + MinimapBorder * 2),
        i32(map_h + MinimapBorder * 2),
        rl.RAYWHITE,
    )
}
