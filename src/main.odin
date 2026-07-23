package main

import rl "vendor:raylib"
import world "world"
import render "render"

main :: proc() {
    rl.InitWindow(render.ScreenWidth, render.ScreenHeight, "Raycaster")
    rl.SetTargetFPS(60)
    rl.DisableCursor() // lock and hide the cursor for FPS-style mouse look
    defer rl.CloseWindow()

    render.LoadTextures()
    defer render.UnloadTextures()
    render.LoadSpriteTextures()
    defer render.UnloadSpriteTextures()

    player := world.NewPlayer()
    game_map := world.NewMap()
    sprites := world.NewSprites()

    show_map := false

    for !rl.WindowShouldClose() {
        dt := rl.GetFrameTime()

        input := world.ReadInput()

        world.UpdatePlayer(&player, input, &game_map, sprites[:], dt)

        if rl.IsKeyPressed(.TAB) {
            show_map = !show_map
        }

        rl.BeginDrawing()

        rl.ClearBackground(rl.BLACK)

        if show_map {
            render.DrawMap(&game_map)
            render.DrawSpriteMarkers(sprites[:])
            render.DrawPlayer(&player)
            render.DrawRay(&player)
        } else {
            render.DrawScene(&player, &game_map)
            render.DrawSprites(&player, sprites[:])
            render.DrawMinimap(&player, &game_map, sprites[:])
        }

        rl.DrawFPS(10, render.ScreenHeight - 30)

        rl.EndDrawing()
    }
}