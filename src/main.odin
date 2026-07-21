package main

import rl "vendor:raylib"
import world "world"

main :: proc() {
    rl.InitWindow(1280, 720, "Raycaster")
    rl.SetTargetFPS(60)
    defer rl.CloseWindow()


    player := world.NewPlayer()

    for !rl.WindowShouldClose() {
        dt := rl.GetFrameTime()

        // ===== INPUT =====

        if rl.IsKeyDown(.W) || rl.IsKeyDown(.UP) {
            player.y -= player.speed * dt
        }

        if rl.IsKeyDown(.S) || rl.IsKeyDown(.DOWN) {
            player.y += player.speed * dt
        }

        if rl.IsKeyDown(.A) || rl.IsKeyDown(.LEFT) {
            player.x -= player.speed * dt
        }

        if rl.IsKeyDown(.D) || rl.IsKeyDown(.RIGHT) {
            player.x += player.speed * dt
        }

        // ===== RENDER =====

        rl.BeginDrawing()

        rl.ClearBackground(rl.BLACK)

        rl.DrawRectangle(
            i32(player.x),
            i32(player.y),
            i32(player.size),
            i32(player.size),
            rl.GREEN,
        )

        rl.EndDrawing()
    }
}