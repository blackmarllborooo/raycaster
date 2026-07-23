package render

import rl "vendor:raylib"
import world "../world"

RayLength :: f32(400)

DrawRay :: proc(p: ^world.Player) {
    cx := p.position.x + p.size / 2
    cy := p.position.y + p.size / 2
    ex := cx + p.direction.x * RayLength
    ey := cy + p.direction.y * RayLength
    rl.DrawLine(
        i32(cx),
        i32(cy),
        i32(ex),
        i32(ey),
        rl.YELLOW,
    )
}