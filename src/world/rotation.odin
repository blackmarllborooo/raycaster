package world

import "core:math"
import "../geo"

Rotate :: proc(v: geo.Vec2, angle: f32) -> geo.Vec2 {
    cos_angle := math.cos(angle)
    sin_angle := math.sin(angle)
    return geo.Vec2{
        x = v.x * cos_angle - v.y * sin_angle,
        y = v.x * sin_angle + v.y * cos_angle,
    }
}