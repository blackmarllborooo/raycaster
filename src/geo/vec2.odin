package geo

import "core:math"

Vec2 :: struct {
    x, y: f32
}


Length :: proc(v: Vec2) -> f32 {
    return math.sqrt(v.x * v.x + v.y * v.y)
}

Normalize :: proc(v: Vec2) -> Vec2 {
    len := Length(v)
    if len == 0 {
        return Vec2{0, 0}
    }
    return Vec2{
        x = v.x / len,
        y = v.y / len,
    }
}

Add :: proc(a, b: Vec2) -> Vec2 {
    return Vec2{a.x + b.x, a.y + b.y}
}

Sub :: proc(a, b: Vec2) -> Vec2 {
    return Vec2{a.x - b.x, a.y - b.y}
}

Scale :: proc(v: Vec2, s: f32) -> Vec2 {
    return Vec2{v.x * s, v.y * s}
}