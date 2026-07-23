package world

import "core:math"
import geo "../geo"

// A very large number used as delta_dist when a ray direction component is 0
// (i.e. the ray is exactly parallel to that axis and will never cross it).
InfiniteDist :: f32(1e30)

// Maximum number of fence tiles a single ray will render before it reaches a
// solid wall. Anything past this is dropped (it would be tiny and occluded).
MaxFences :: 8

// Hit describes where a ray crossed into one wall or fence tile.
Hit :: struct {
    // 0 if a vertical (x-side) face was hit, 1 if a horizontal (y-side) face.
    side: int,

    // Perpendicular (fisheye-corrected) distance to the face, in tile units.
    perp_wall_dist: f32,

    // Where the ray crossed the face, as a fraction (0..1) along it. Used as
    // the texture U coordinate.
    wall_x: f32,

    // The tile that was hit, used to pick the texture.
    tile: Tile,
}

// RayResult is the outcome of one cast: every fence passed through (nearest
// first) plus the solid wall that finally stopped the ray.
RayResult :: struct {
    fences: [MaxFences]Hit,
    fence_count: int,
    solid: Hit,
}

// CastRay fires a single ray from the player's position and runs a DDA walk
// through the grid. It records each waist-high fence it passes over and keeps
// going until it reaches a full-height wall (or the map edge), so the caller
// can draw the scene behind fences.
CastRay :: proc(p: ^Player, game_map: ^Map, direction: geo.Vec2) -> RayResult {
    result := RayResult{}

    pos_x := p.position.x / TileSize
    pos_y := p.position.y / TileSize

    map_x := int(pos_x)
    map_y := int(pos_y)

    delta_dist_x := direction.x == 0 ? InfiniteDist : abs(1.0 / direction.x)
    delta_dist_y := direction.y == 0 ? InfiniteDist : abs(1.0 / direction.y)

    step_x, step_y: int
    side_dist_x, side_dist_y: f32

    if direction.x < 0 {
        step_x = -1
        side_dist_x = (pos_x - f32(map_x)) * delta_dist_x
    } else {
        step_x = 1
        side_dist_x = (f32(map_x + 1) - pos_x) * delta_dist_x
    }

    if direction.y < 0 {
        step_y = -1
        side_dist_y = (pos_y - f32(map_y)) * delta_dist_y
    } else {
        step_y = 1
        side_dist_y = (f32(map_y + 1) - pos_y) * delta_dist_y
    }

    for {
        side: int
        if side_dist_x < side_dist_y {
            side_dist_x += delta_dist_x
            map_x += step_x
            side = 0
        } else {
            side_dist_y += delta_dist_y
            map_y += step_y
            side = 1
        }

        // Out of bounds: treat as a solid wall so the loop always terminates.
        // The map is walled on all borders so this should not normally happen.
        oob := map_x < 0 || map_x >= MapWidth || map_y < 0 || map_y >= MapHeight
        tile := oob ? Tile.WallStone : game_map.tiles[map_y][map_x]

        if oob || IsSolid(tile) {
            result.solid = makeHit(
                side, side_dist_x, side_dist_y, delta_dist_x, delta_dist_y,
                pos_x, pos_y, direction, tile,
            )
            break
        }

        if IsFence(tile) && result.fence_count < MaxFences {
            result.fences[result.fence_count] = makeHit(
                side, side_dist_x, side_dist_y, delta_dist_x, delta_dist_y,
                pos_x, pos_y, direction, tile,
            )
            result.fence_count += 1
        }
    }

    return result
}

// makeHit computes the perpendicular distance and texture U for the tile the
// DDA just stepped into.
@(private)
makeHit :: proc(
    side: int,
    side_dist_x, side_dist_y, delta_dist_x, delta_dist_y: f32,
    pos_x, pos_y: f32,
    direction: geo.Vec2,
    tile: Tile,
) -> Hit {
    hit := Hit{side = side, tile = tile}

    if side == 0 {
        hit.perp_wall_dist = side_dist_x - delta_dist_x
        hit.wall_x = pos_y + hit.perp_wall_dist * direction.y
    } else {
        hit.perp_wall_dist = side_dist_y - delta_dist_y
        hit.wall_x = pos_x + hit.perp_wall_dist * direction.x
    }

    hit.wall_x -= math.floor(hit.wall_x)
    return hit
}
