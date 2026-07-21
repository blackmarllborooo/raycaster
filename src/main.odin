package main

import rl "vendor:raylib"
import world "world"
import render "render"

main :: proc() {
    rl.InitWindow(1280, 720, "Raycaster")
    rl.SetTargetFPS(60)
    defer rl.CloseWindow()


    player := world.NewPlayer()
    game_map := world.NewMap()

    for !rl.WindowShouldClose() {
        dt := rl.GetFrameTime()

        input := world.ReadInput()

        world.UpdatePlayer(&player, input, dt)

        rl.BeginDrawing()

        rl.ClearBackground(rl.BLACK)

        render.DrawMap(&game_map)
        render.DrawPlayer(&player)

        rl.EndDrawing()
    }
}