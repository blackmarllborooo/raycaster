package world

import "core:math"
import "../geo"

Player :: struct {
    position: geo.Vec2,

    direction: geo.Vec2,
    camera_plane: geo.Vec2,

    size: f32,

    speed: f32,
    rotation_speed: f32,    // radians/sec, keyboard fallback (arrow keys)
    mouse_sensitivity: f32, // radians per pixel of mouse movement
}

NewPlayer :: proc() -> Player {
    return Player{
        position = geo.Vec2{300, 200},
        direction = geo.Vec2{1, 0},
        camera_plane = geo.Vec2{0, 0.66},
        size = 40,
        speed = 300, // pixels per second
        rotation_speed = 3, // radians per second
        mouse_sensitivity = 0.0025,
    }
}

CollisionRadius :: proc(p: ^Player) -> f32 {
    return p.size / 2
}

UpdatePlayer :: proc(p: ^Player, i: Input, game_map: ^Map, sprites: []Sprite, dt: f32) {
    // Movement is relative to where the player is facing, not world axes,
    // so strafing always moves sideways from the player's own point of view.
    right := Rotate(p.direction, math.PI / 2)

    movement := geo.Vec2{0, 0}
    if i.forward {
        movement = geo.Add(movement, p.direction)
    }
    if i.backward {
        movement = geo.Sub(movement, p.direction)
    }
    if i.strafe_right {
        movement = geo.Add(movement, right)
    }
    if i.strafe_left {
        movement = geo.Sub(movement, right)
    }

    movement = geo.Normalize(movement)
    radius := CollisionRadius(p)

    // Move along each axis independently so the player slides along walls
    // instead of stopping dead on diagonal movement into a corner.
    next_x := p.position.x + movement.x * p.speed * dt
    try_x := geo.Vec2{next_x, p.position.y}
    if !IsBlocked(game_map, try_x, radius) && !SpriteBlocks(sprites, try_x, radius) {
        p.position.x = next_x
    }

    next_y := p.position.y + movement.y * p.speed * dt
    try_y := geo.Vec2{p.position.x, next_y}
    if !IsBlocked(game_map, try_y, radius) && !SpriteBlocks(sprites, try_y, radius) {
        p.position.y = next_y
    }

    rotation := i.mouse_dx * p.mouse_sensitivity
    if i.rotate_left {
        rotation -= p.rotation_speed * dt
    }
    if i.rotate_right {
        rotation += p.rotation_speed * dt
    }

    p.direction = Rotate(p.direction, rotation)
    p.camera_plane = Rotate(p.camera_plane, rotation)
}