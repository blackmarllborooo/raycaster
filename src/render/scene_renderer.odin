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

// DrawScene casts one ray per screen column and draws the resulting first-
// person 3D view (floor, ceiling and shaded wall slices).
DrawScene :: proc(p: ^world.Player, game_map: ^world.Map) {
    DrawFloorCeiling(p)

    for x in 0 ..< ScreenWidth {
        camera_x := 2 * f32(x) / f32(ScreenWidth) - 1
        ray_dir := geo.Add(p.direction, geo.Scale(p.camera_plane, camera_x))

        ray := world.CastRay(p, game_map, ray_dir)

        dist := ray.perp_wall_dist
        if dist < MinWallDist {
            dist = MinWallDist
        }

        ZBuffer[x] = dist

        // The wall spans from the floor (z=0) up to the ceiling
        // (z=RoomHeight). Project both edges relative to the horizon; when
        // the wall is close these go well outside the screen.
        draw_end_f := Horizon + EyeHeight * f32(ScreenHeight) / dist
        draw_start_f := Horizon - (RoomHeight - EyeHeight) * f32(ScreenHeight) / dist
        wall_px_height := draw_end_f - draw_start_f

        draw_start := draw_start_f < 0 ? 0 : draw_start_f
        draw_end := draw_end_f > f32(ScreenHeight) ? f32(ScreenHeight) : draw_end_f

        // Only sample the slice of the texture that's actually visible on
        // screen, at its true scale — otherwise clamping draw_start/draw_end
        // above would squash the whole texture into whatever's left,
        // distorting bricks when standing close to a wall.
        // Multiply by RoomHeight so the texture tiles once per tile of wall
        // height instead of stretching across the whole (taller) wall. The
        // wall textures are loaded with REPEAT wrapping for this.
        tex_top := (draw_start - draw_start_f) / wall_px_height * f32(TextureSize) * RoomHeight
        tex_bottom := (draw_end - draw_start_f) / wall_px_height * f32(TextureSize) * RoomHeight

        // Pick the texture column, flipping it on some sides so the brick
        // pattern isn't mirrored depending on which direction you approach
        // the wall from.
        tex_x := i32(ray.wall_x * f32(TextureSize))
        flip := ray.side == 0 ? ray_dir.x > 0 : ray_dir.y < 0
        if flip {
            tex_x = TextureSize - tex_x - 1
        }
        tex_x = clamp(tex_x, 0, TextureSize - 1)

        // X-side walls are drawn full brightness, Y-side walls slightly
        // darker to fake a light direction; both fade out with distance.
        base := ray.side == 0 ? f32(1) : f32(0.7)
        brightness := clamp(base * (1 - dist / FogDistance), MinBrightness, 1)
        shade := u8(255 * brightness)
        tint := rl.Color{shade, shade, shade, 255}

        source := rl.Rectangle{f32(tex_x), tex_top, 1, tex_bottom - tex_top}
        dest := rl.Rectangle{f32(x), draw_start, 1, draw_end - draw_start}
        rl.DrawTexturePro(TextureForTile(ray.tile), source, dest, rl.Vector2{0, 0}, 0, tint)
    }
}
