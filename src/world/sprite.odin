package world

import geo "../geo"

Sprite :: struct {
    position: geo.Vec2,
}

SpriteCount :: 4

// Collision radius of a sprite in world units. A barrel is roughly a third
// of a tile wide.
SpriteRadius :: f32(16)

// SpriteBlocks reports whether a circle of the given radius centered at pos
// overlaps any sprite.
SpriteBlocks :: proc(sprites: []Sprite, pos: geo.Vec2, radius: f32) -> bool {
    reach := radius + SpriteRadius
    for s in sprites {
        d := geo.Sub(pos, s.position)
        if d.x * d.x + d.y * d.y < reach * reach {
            return true
        }
    }
    return false
}

NewSprites :: proc() -> [SpriteCount]Sprite {
    return [SpriteCount]Sprite{
        {position = geo.Vec2{4.5 * TileSize, 3.5 * TileSize}},
        {position = geo.Vec2{7.5 * TileSize, 7.5 * TileSize}},
        {position = geo.Vec2{6.5 * TileSize, 2.5 * TileSize}},
        {position = geo.Vec2{2.5 * TileSize, 6.5 * TileSize}},
    }
}
