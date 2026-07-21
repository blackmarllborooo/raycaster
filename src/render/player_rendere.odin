package render

import rl "vendor:raylib"
import world "../world"

DirectionLength :: f32(60)
PlaneLength :: f32(60)

DrawPlayer :: proc(p: ^world.Player) {
    rl.DrawRectangle(
        i32(p.position.x),
        i32(p.position.y),
        i32(p.size),
        i32(p.size),
        rl.GREEN,
    )

    cx := p.position.x + p.size / 2
    cy := p.position.y + p.size / 2
    rl.DrawLine(
        i32(cx),
        i32(cy),
        i32(cx + p.direction.x * DirectionLength),
        i32(cy + p.direction.y * DirectionLength),
        rl.BLUE,
    )

    plane_start_x := cx - p.camera_plane.x * PlaneLength
    plane_start_y := cy - p.camera_plane.y * PlaneLength
    plane_end_x := cx + p.camera_plane.x * PlaneLength
    plane_end_y := cy + p.camera_plane.y * PlaneLength
    rl.DrawLine(
        i32(plane_start_x),
        i32(plane_start_y),
        i32(plane_end_x),
        i32(plane_end_y),
        rl.RED,
    )
}