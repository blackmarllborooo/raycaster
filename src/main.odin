package main

import rl "vendor:raylib"
import world "world"
import geo "geo"
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
        movement := geo.Vec2{0, 0}

        if input.up {
            movement.y -= 1
        }

        if input.down {
            movement.y += 1
        }

        if input.left {
            movement.x -= 1
        }

        if input.right {
            movement.x += 1
        }

        movement = geo.Normalize(movement)
        player.position.x += movement.x * player.speed * dt
        player.position.y += movement.y * player.speed * dt

        rl.BeginDrawing()

        rl.ClearBackground(rl.BLACK)

        render.DrawMap(&game_map)

        rl.DrawRectangle(
            i32(player.position.x),
            i32(player.position.y),
            i32(player.size),
            i32(player.size),
            rl.GREEN,
        )

        rl.EndDrawing()
    }
}