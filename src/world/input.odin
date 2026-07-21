package world

import rl "vendor:raylib"

Input :: struct {
    up, down, left, right: bool,
}

ReadInput :: proc() -> Input {
    input := Input{}

    input.up = rl.IsKeyDown(.W) || rl.IsKeyDown(.UP)
    input.down = rl.IsKeyDown(.S) || rl.IsKeyDown(.DOWN)
    input.left = rl.IsKeyDown(.A) || rl.IsKeyDown(.LEFT)
    input.right = rl.IsKeyDown(.D) || rl.IsKeyDown(.RIGHT)

    return input
}