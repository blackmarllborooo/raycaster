package world

import "../geo"

Player :: struct {
    position: geo.Vec2,
    size: f32,
    speed: f32,
}

NewPlayer :: proc() -> Player {
    return Player{
        position = geo.Vec2{300, 200},
        size = 40,
        speed = 300, // pixels per second
    }
}

UpdatePlayer :: proc(p: ^Player, i: Input, dt: f32) {
    movement := geo.Vec2{0,0}

    if i.up {
        movement.y -= 1
    }
    if i.down {
        movement.y += 1
    }
    if i.left {
        movement.x -= 1
    }
    if i.right {
        movement.x += 1
    }

    movement = geo.Normalize(movement)

    p.position.x += movement.x * p.speed * dt
    p.position.y += movement.y * p.speed * dt
}