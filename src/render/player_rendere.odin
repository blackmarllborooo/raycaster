package render

import rl "vendor:raylib"
import geo "../geo"
import world "../world"

DirectionLength :: f32(60)
PlaneLength :: f32(60)

DrawPlayer :: proc(p: ^world.Player, scale: f32 = 1, offset: geo.Vec2 = geo.Vec2{0, 0}) {
    px := offset.x + p.position.x * scale
    py := offset.y + p.position.y * scale
    size := p.size * scale

    rl.DrawRectangle(
        i32(px),
        i32(py),
        i32(size),
        i32(size),
        rl.GREEN,
    )

    cx := px + size / 2
    cy := py + size / 2

    dir_len := DirectionLength * scale
    plane_len := PlaneLength * scale

    rl.DrawLine(
        i32(cx),
        i32(cy),
        i32(cx + p.direction.x * dir_len),
        i32(cy + p.direction.y * dir_len),
        rl.BLUE,
    )

    plane_start_x := cx - p.camera_plane.x * plane_len
    plane_start_y := cy - p.camera_plane.y * plane_len
    plane_end_x := cx + p.camera_plane.x * plane_len
    plane_end_y := cy + p.camera_plane.y * plane_len
    rl.DrawLine(
        i32(plane_start_x),
        i32(plane_start_y),
        i32(plane_end_x),
        i32(plane_end_y),
        rl.RED,
    )
}