package world

Player :: struct {
    x, y: f32,
    size: f32,
    speed: f32,
}

NewPlayer :: proc() -> Player {
    return Player{
        x = 300,
        y = 200,
        size = 40,
        speed = 300, // pixels per second
    }
}