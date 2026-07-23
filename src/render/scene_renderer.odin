package render

import rl "vendor:raylib"
import geo "../geo"
import world "../world"

MinWallDist :: f32(0.0001)

// Walls beyond this distance (in tiles) are rendered at minimum brightness.
FogDistance :: f32(8)
MinBrightness :: f32(0.2)

// Per-column wall distance (in tiles) from the last DrawScene call, used by
// the sprite renderer to occlude sprites standing behind walls.
ZBuffer: [ScreenWidth]f32

// Per-column nearest-fence distance and the screen row of that fence's top
// edge. The sprite renderer uses these to hide the lower part of a sprite
// standing behind a waist-high fence (the fence doesn't write ZBuffer because
// it only occludes the bottom half of the column).
FenceDist: [ScreenWidth]f32
FenceTopY: [ScreenWidth]f32

// DrawScene casts one ray per screen column and draws the resulting first-
// person 3D view (floor, ceiling and shaded wall slices).
DrawScene :: proc(p: ^world.Player, game_map: ^world.Map) {
    DrawFloorCeiling(p)

    for x in 0 ..< ScreenWidth {
        camera_x := 2 * f32(x) / f32(ScreenWidth) - 1
        ray_dir := geo.Add(p.direction, geo.Scale(p.camera_plane, camera_x))

        result := world.CastRay(p, game_map, ray_dir)

        // The solid wall is the backdrop for this column: draw it full height
        // first and record its distance for sprite occlusion.
        solid_dist := result.solid.perp_wall_dist
        if solid_dist < MinWallDist {
            solid_dist = MinWallDist
        }
        ZBuffer[x] = solid_dist
        drawHitSlice(x, ray_dir, result.solid, 0, RoomHeight)

        // Then the waist-high fences on top, farthest first so nearer fences
        // (and the wall behind) layer correctly. Track the nearest fence in
        // this column so sprites behind it get clipped.
        FenceDist[x] = 1e30
        FenceTopY[x] = 0
        for i := result.fence_count - 1; i >= 0; i -= 1 {
            fence := result.fences[i]
            drawHitSlice(x, ray_dir, fence, 0, RoomHeight / 2)

            fd := fence.perp_wall_dist
            if fd < MinWallDist {
                fd = MinWallDist
            }
            if fd < FenceDist[x] {
                FenceDist[x] = fd
                FenceTopY[x] = Horizon + (EyeHeight - RoomHeight / 2) * f32(ScreenHeight) / fd
            }
        }
    }
}

// drawHitSlice renders one wall/fence hit as a vertical slice spanning world
// heights z0..z1, handling texture selection, mirroring and distance shading.
@(private = "file")
drawHitSlice :: proc(x: int, ray_dir: geo.Vec2, hit: world.Hit, z0, z1: f32) {
    dist := hit.perp_wall_dist
    if dist < MinWallDist {
        dist = MinWallDist
    }

    // Pick the texture column, flipping it on some sides so the pattern isn't
    // mirrored depending on which direction you approach the wall.
    tex_x := i32(hit.wall_x * f32(TextureSize))
    flip := hit.side == 0 ? ray_dir.x > 0 : ray_dir.y < 0
    if flip {
        tex_x = TextureSize - tex_x - 1
    }
    tex_x = clamp(tex_x, 0, TextureSize - 1)

    // X-side faces are drawn full brightness, Y-side faces slightly darker to
    // fake a light direction; both fade out with distance.
    base := hit.side == 0 ? f32(1) : f32(0.7)
    brightness := clamp(base * (1 - dist / FogDistance), MinBrightness, 1)
    shade := u8(255 * brightness)
    tint := rl.Color{shade, shade, shade, 255}

    drawWallSlice(x, dist, z0, z1, TextureForTile(hit.tile), tex_x, tint)
}

// drawWallSlice paints one vertical texture slice of a wall column spanning
// world heights z0 (lower) to z1 (upper), in tile units. The texture repeats
// once per tile of height (REPEAT wrapping) and stays upright; only the part
// actually on screen is sampled so close walls don't distort.
@(private = "file")
drawWallSlice :: proc(x: int, dist, z0, z1: f32, tex: rl.Texture2D, tex_x: i32, tint: rl.Color) {
    // Higher z projects higher on screen (smaller y).
    top_f := Horizon + (EyeHeight - z1) * f32(ScreenHeight) / dist
    bottom_f := Horizon + (EyeHeight - z0) * f32(ScreenHeight) / dist
    slice_px := bottom_f - top_f

    top := top_f < 0 ? 0 : top_f
    bottom := bottom_f > f32(ScreenHeight) ? f32(ScreenHeight) : bottom_f
    if bottom <= top {
        return
    }

    // Texture v runs 0 at the slice top to (z1-z0)*TextureSize at the bottom,
    // then is narrowed to just the on-screen portion.
    full_v := (z1 - z0) * f32(TextureSize)
    tex_top := (top - top_f) / slice_px * full_v
    tex_bottom := (bottom - top_f) / slice_px * full_v

    source := rl.Rectangle{f32(tex_x), tex_top, 1, tex_bottom - tex_top}
    dest := rl.Rectangle{f32(x), top, 1, bottom - top}
    rl.DrawTexturePro(tex, source, dest, rl.Vector2{0, 0}, 0, tint)
}
