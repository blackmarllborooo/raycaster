package world

import rl "vendor:raylib"

Input :: struct {
    forward, backward: bool,
    strafe_left, strafe_right: bool,

    // Keyboard fallback for rotation (mouse is the primary control)
    rotate_left, rotate_right: bool,

    // Horizontal mouse movement since the last frame, in pixels
    mouse_dx: f32,
}

ReadInput :: proc() -> Input {
    input := Input{}

    input.forward = rl.IsKeyDown(.W) || rl.IsKeyDown(.UP)
    input.backward = rl.IsKeyDown(.S) || rl.IsKeyDown(.DOWN)
    input.strafe_left = rl.IsKeyDown(.A)
    input.strafe_right = rl.IsKeyDown(.D)
    input.rotate_left = rl.IsKeyDown(.LEFT)
    input.rotate_right = rl.IsKeyDown(.RIGHT)

    input.mouse_dx = rl.GetMouseDelta().x

    return input
}
