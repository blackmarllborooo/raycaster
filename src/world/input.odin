package world

import rl "vendor:raylib"

Input :: struct {
    up, down, left, right: bool,
    rotate_left, rotate_right: bool,
}

ReadInput :: proc() -> Input {
    input := Input{}

    input.up = rl.IsKeyDown(.W) || rl.IsKeyDown(.UP)
    input.down = rl.IsKeyDown(.S) || rl.IsKeyDown(.DOWN)
    input.left = rl.IsKeyDown(.A) || rl.IsKeyDown(.LEFT)
    input.right = rl.IsKeyDown(.D) || rl.IsKeyDown(.RIGHT)
    input.rotate_left = rl.IsKeyDown(.Q)
    input.rotate_right = rl.IsKeyDown(.E)

    return input
}