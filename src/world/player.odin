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