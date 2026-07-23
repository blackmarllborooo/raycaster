package world

import geo "../geo"

// A very large number used as delta_dist when a ray direction component is 0
// (i.e. the ray is exactly parallel to that axis and will never cross it).
InfiniteDist :: f32(1e30)

Ray :: struct {
    // Direction of the ray (unit-ish vector, not normalized to 1)
    direction: geo.Vec2,

    // Current tile in the map that the ray is in
    map_x, map_y: int,

    // Step direction in x and y (either +1 or -1)
    step_x, step_y: int,

    // Distance (in tile units) from the ray start to the first x/y grid line
    side_dist_x, side_dist_y: f32,

    // Distance (in tile units) from one x/y grid line to the next
    delta_dist_x, delta_dist_y: f32,

    // true if the DDA loop stopped because it hit a wall
    hit: bool,

    // 0 if a vertical (x-side) wall was hit, 1 if a horizontal (y-side) wall was hit
    side: int,

    // Perpendicular distance (in tile units) from the player to the wall.
    // This is fisheye-corrected and should be used for wall height, not the
    // raw euclidean distance.
    perp_wall_dist: f32,
}

// CastRay fires a single ray from the player's position in the given
// direction and runs a DDA (Digital Differential Analysis) walk through the
// grid until it hits a wall tile.
CastRay :: proc(p: ^Player, game_map: ^Map, direction: geo.Vec2) -> Ray {
    ray := Ray{}
    ray.direction = direction

    pos_x := p.position.x / TileSize
    pos_y := p.position.y / TileSize

    ray.map_x = int(pos_x)
    ray.map_y = int(pos_y)

    ray.delta_dist_x = ray.direction.x == 0 ? InfiniteDist : abs(1.0 / ray.direction.x)
    ray.delta_dist_y = ray.direction.y == 0 ? InfiniteDist : abs(1.0 / ray.direction.y)

    if ray.direction.x < 0 {
        ray.step_x = -1
        ray.side_dist_x = (pos_x - f32(ray.map_x)) * ray.delta_dist_x
    } else {
        ray.step_x = 1
        ray.side_dist_x = (f32(ray.map_x + 1) - pos_x) * ray.delta_dist_x
    }

    if ray.direction.y < 0 {
        ray.step_y = -1
        ray.side_dist_y = (pos_y - f32(ray.map_y)) * ray.delta_dist_y
    } else {
        ray.step_y = 1
        ray.side_dist_y = (f32(ray.map_y + 1) - pos_y) * ray.delta_dist_y
    }

    for !ray.hit {
        if ray.side_dist_x < ray.side_dist_y {
            ray.side_dist_x += ray.delta_dist_x
            ray.map_x += ray.step_x
            ray.side = 0
        } else {
            ray.side_dist_y += ray.delta_dist_y
            ray.map_y += ray.step_y
            ray.side = 1
        }

        // Out of bounds: treat as a hit so we never loop forever. The map is
        // walled on all borders so this should not normally happen.
        if ray.map_x < 0 || ray.map_x >= MapWidth || ray.map_y < 0 || ray.map_y >= MapHeight {
            ray.hit = true
            break
        }

        if game_map.tiles[ray.map_y][ray.map_x] == .Wall {
            ray.hit = true
        }
    }

    if ray.side == 0 {
        ray.perp_wall_dist = ray.side_dist_x - ray.delta_dist_x
    } else {
        ray.perp_wall_dist = ray.side_dist_y - ray.delta_dist_y
    }

    return ray
}
