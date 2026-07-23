package render

import rl "vendor:raylib"
import world "../world"

// CPU-side pixel sources for floor and ceiling. Kept as plain color arrays
// (not GPU textures) because floor casting samples them per pixel on the CPU.
FloorPixels: [TextureSize][TextureSize]rl.Color
CeilPixels: [TextureSize][TextureSize]rl.Color

// Full-screen framebuffer that the floor/ceiling are cast into each frame,
// then uploaded to FrameTexture in one go.
FrameBuffer: [ScreenHeight * ScreenWidth]rl.Color
FrameTexture: rl.Texture2D

LoadFloorTextures :: proc() {
    generateFloorPixels()
    generateCeilPixels()

    blank := rl.GenImageColor(ScreenWidth, ScreenHeight, rl.BLACK)
    FrameTexture = rl.LoadTextureFromImage(blank)
    rl.UnloadImage(blank)
}

UnloadFloorTextures :: proc() {
    rl.UnloadTexture(FrameTexture)
}

// DrawFloorCeiling casts the floor and ceiling into the framebuffer and draws
// it full-screen. Must run before the wall columns so walls paint over it.
DrawFloorCeiling :: proc(p: ^world.Player) {
    pos_x := p.position.x / world.TileSize
    pos_y := p.position.y / world.TileSize

    // Ray directions for the leftmost and rightmost columns.
    ray_dir_x0 := p.direction.x - p.camera_plane.x
    ray_dir_y0 := p.direction.y - p.camera_plane.y
    ray_dir_x1 := p.direction.x + p.camera_plane.x
    ray_dir_y1 := p.direction.y + p.camera_plane.y

    horizon :: ScreenHeight / 2

    // Vertical camera positions (in screen units). The floor is EyeHeight
    // below the camera; the ceiling is (RoomHeight - EyeHeight) above it, so
    // the two are cast independently and the ceiling can sit higher than a
    // simple mirror of the floor.
    floor_pos_z := EyeHeight * f32(ScreenHeight)
    ceil_pos_z := (RoomHeight - EyeHeight) * f32(ScreenHeight)

    // Floor fills the bottom half; ceiling the top half. Each screen row is
    // p_row pixels away from the horizon and samples the world at its own
    // distance.
    castHalf(pos_x, pos_y, ray_dir_x0, ray_dir_y0, ray_dir_x1, ray_dir_y1, floor_pos_z, false)
    castHalf(pos_x, pos_y, ray_dir_x0, ray_dir_y0, ray_dir_x1, ray_dir_y1, ceil_pos_z, true)

    rl.UpdateTexture(FrameTexture, &FrameBuffer[0])
    rl.DrawTexture(FrameTexture, 0, 0, rl.WHITE)
}

// castHalf casts either the floor (ceiling=false) or the ceiling
// (ceiling=true) into the framebuffer. horizon is the shared eye-level row.
@(private = "file")
castHalf :: proc(
    pos_x, pos_y: f32,
    ray_dir_x0, ray_dir_y0, ray_dir_x1, ray_dir_y1: f32,
    pos_z: f32,
    ceiling: bool,
) {
    horizon :: ScreenHeight / 2

    // Iterate over every row of this half so the whole framebuffer is
    // rewritten (no stale pixels left at the horizon or screen edge).
    y_start := ceiling ? 0 : horizon
    y_end := ceiling ? horizon : ScreenHeight

    for y in y_start ..< y_end {
        p_row := ceiling ? horizon - y : y - horizon
        if p_row < 1 {
            p_row = 1 // avoid divide-by-zero on the exact horizon row
        }

        row_distance := pos_z / f32(p_row)

        step_x := row_distance * (ray_dir_x1 - ray_dir_x0) / f32(ScreenWidth)
        step_y := row_distance * (ray_dir_y1 - ray_dir_y0) / f32(ScreenWidth)

        world_x := pos_x + row_distance * ray_dir_x0
        world_y := pos_y + row_distance * ray_dir_y0

        brightness := clamp(1 - row_distance / FogDistance, MinBrightness, 1)

        base := y * ScreenWidth

        for x in 0 ..< ScreenWidth {
            // Fractional part of the world position gives the texture UV;
            // TextureSize is a power of two so a mask does the wrap.
            tx := int(f32(TextureSize) * (world_x - f32(int(world_x)))) & (TextureSize - 1)
            ty := int(f32(TextureSize) * (world_y - f32(int(world_y)))) & (TextureSize - 1)
            if world_x < 0 {
                tx = (TextureSize - 1) - tx
            }
            if world_y < 0 {
                ty = (TextureSize - 1) - ty
            }

            world_x += step_x
            world_y += step_y

            texel := ceiling ? CeilPixels[ty][tx] : FloorPixels[ty][tx]
            FrameBuffer[base + x] = shade(texel, brightness)
        }
    }
}

@(private = "file")
shade :: proc(c: rl.Color, brightness: f32) -> rl.Color {
    return rl.Color{
        u8(f32(c.r) * brightness),
        u8(f32(c.g) * brightness),
        u8(f32(c.b) * brightness),
        255,
    }
}

@(private = "file")
generateFloorPixels :: proc() {
    // Checkerboard stone tiles with darker grout lines.
    light := rl.Color{92, 92, 88, 255}
    dark := rl.Color{72, 72, 70, 255}
    grout := rl.Color{48, 48, 46, 255}

    half :: TextureSize / 2
    for y in 0 ..< TextureSize {
        for x in 0 ..< TextureSize {
            checker := ((x / half) + (y / half)) % 2 == 0
            c := checker ? light : dark
            if x % half < 2 || y % half < 2 {
                c = grout
            }
            FloorPixels[y][x] = c
        }
    }
}

@(private = "file")
generateCeilPixels :: proc() {
    // Cool, flat slate with faint mortar seams so it reads as a ceiling.
    base := rl.Color{58, 60, 72, 255}
    seam := rl.Color{44, 46, 56, 255}

    for y in 0 ..< TextureSize {
        for x in 0 ..< TextureSize {
            c := base
            if x % 16 < 2 || y % 16 < 2 {
                c = seam
            }
            CeilPixels[y][x] = c
        }
    }
}
