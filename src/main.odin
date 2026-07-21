package main

import rl "vendor:raylib"

main :: proc() {
    rl.InitWindow(1280, 720, "Raycaster")
    rl.SetTargetFPS(60)
    defer rl.CloseWindow()


    player_x: f32 = 300
    player_y: f32 = 200
    player_size: f32 = 40
    player_speed: f32 = 300 // pixels per second

    for !rl.WindowShouldClose() {
        dt := rl.GetFrameTime()

        // ===== INPUT =====

        if rl.IsKeyDown(.W) || rl.IsKeyDown(.UP) {
            player_y -= player_speed * dt
        }

        if rl.IsKeyDown(.S) || rl.IsKeyDown(.DOWN) {
            player_y += player_speed * dt
        }

        if rl.IsKeyDown(.A) || rl.IsKeyDown(.LEFT) {
            player_x -= player_speed * dt
        }

        if rl.IsKeyDown(.D) || rl.IsKeyDown(.RIGHT) {
            player_x += player_speed * dt
        }

        // ===== RENDER =====

        rl.BeginDrawing()

        rl.ClearBackground(rl.BLACK)

        rl.DrawRectangle(
            i32(player_x),
            i32(player_y),
            i32(player_size),
            i32(player_size),
            rl.GREEN,
        )

        rl.EndDrawing()
    }
}