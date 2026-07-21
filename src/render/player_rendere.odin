package render

import rl "vendor:raylib"
import world "../world"

DrawPlayer :: proc(p: ^world.Player) {
    rl.DrawRectangle(
        i32(p.position.x),
        i32(p.position.y),
        i32(p.size),
        i32(p.size),
        rl.GREEN,
    )
}