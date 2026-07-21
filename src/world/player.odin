package world

import "../geo"

Player :: struct {
    position: geo.Vec2,

    direction: geo.Vec2,
    camera_plane: geo.Vec2,
    
    size: f32,
    
    speed: f32,
    rotation_speed: f32,
}

NewPlayer :: proc() -> Player {
    return Player{
        position = geo.Vec2{300, 200},
        direction = geo.Vec2{1, 0},
        camera_plane = geo.Vec2{0, 0.66},
        size = 40,
        speed = 300, // pixels per second
        rotation_speed = 3, // radians per second
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

    rotation := f32(0)
    if i.rotate_left {
        rotation -= p.rotation_speed * dt
    }
    if i.rotate_right {
        rotation += p.rotation_speed * dt
    }
    
    p.direction = Rotate(p.direction, rotation)
    p.camera_plane = Rotate(p.camera_plane, rotation)
}