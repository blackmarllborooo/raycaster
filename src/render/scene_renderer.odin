package render

import rl "vendor:raylib"
import geo "../geo"
import world "../world"

CeilingColor :: rl.Color{40, 40, 60, 255}
FloorColor :: rl.Color{55, 55, 55, 255}

WallColorX :: rl.Color{180, 30, 30, 255}
WallColorY :: rl.Color{130, 20, 20, 255}

MinWallDist :: f32(0.0001)

// DrawScene casts one ray per screen column and draws the resulting first-
// person 3D view (floor, ceiling and shaded wall slices).
DrawScene :: proc(p: ^world.Player, game_map: ^world.Map) {
    rl.DrawRectangle(0, 0, ScreenWidth, ScreenHeight / 2, CeilingColor)
    rl.DrawRectangle(0, ScreenHeight / 2, ScreenWidth, ScreenHeight / 2, FloorColor)

    for x in 0 ..< ScreenWidth {
        camera_x := 2 * f32(x) / f32(ScreenWidth) - 1
        ray_dir := geo.Add(p.direction, geo.Scale(p.camera_plane, camera_x))

        ray := world.CastRay(p, game_map, ray_dir)

        dist := ray.perp_wall_dist
        if dist < MinWallDist {
            dist = MinWallDist
        }

        line_height := i32(f32(ScreenHeight) / dist)

        draw_start := -line_height / 2 + ScreenHeight / 2
        draw_end := line_height / 2 + ScreenHeight / 2
        if draw_start < 0 {
            draw_start = 0
        }
        if draw_end >= ScreenHeight {
            draw_end = ScreenHeight - 1
        }

        color := ray.side == 0 ? WallColorX : WallColorY

        rl.DrawLine(i32(x), draw_start, i32(x), draw_end, color)
    }
}
