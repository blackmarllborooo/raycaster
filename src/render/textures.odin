package render

import "core:math/rand"
import rl "vendor:raylib"
import world "../world"

TextureSize :: 64

WallTextures: [world.Tile]rl.Texture2D

// LoadTextures generates the wall textures on the CPU and uploads them to
// the GPU. Procedural, so the repo doesn't need to ship binary image assets.
LoadTextures :: proc() {
    brick := generateBrickImage()
    stone := generateStoneImage()
    wood := generateWoodImage()

    WallTextures[.WallBrick] = rl.LoadTextureFromImage(brick)
    WallTextures[.WallStone] = rl.LoadTextureFromImage(stone)
    WallTextures[.WallWood] = rl.LoadTextureFromImage(wood)

    rl.UnloadImage(brick)
    rl.UnloadImage(stone)
    rl.UnloadImage(wood)
}

UnloadTextures :: proc() {
    rl.UnloadTexture(WallTextures[.WallBrick])
    rl.UnloadTexture(WallTextures[.WallStone])
    rl.UnloadTexture(WallTextures[.WallWood])
}

TextureForTile :: proc(t: world.Tile) -> rl.Texture2D {
    return WallTextures[t]
}

@(private = "file")
generateBrickImage :: proc() -> rl.Image {
    mortar := rl.Color{62, 56, 52, 255}
    brick := rl.Color{150, 68, 48, 255}
    brick_dark := rl.Color{128, 56, 40, 255}

    image := rl.GenImageColor(TextureSize, TextureSize, mortar)

    brick_h :: 16
    brick_w :: 32
    gap :: 2

    row := 0
    for y := 0; y < TextureSize; y += brick_h {
        offset := row % 2 == 0 ? 0 : brick_w / 2
        x := -offset
        col := 0
        for x < TextureSize {
            color := col % 2 == 0 ? brick : brick_dark
            rl.ImageDrawRectangle(
                &image,
                i32(x + gap / 2), i32(y + gap / 2),
                i32(brick_w - gap), i32(brick_h - gap),
                color,
            )
            x += brick_w
            col += 1
        }
        row += 1
    }

    return image
}

@(private = "file")
generateStoneImage :: proc() -> rl.Image {
    base := rl.Color{112, 110, 102, 255}
    image := rl.GenImageColor(TextureSize, TextureSize, base)

    // Per-pixel mottling so blocks don't look like a flat fill.
    for y in 0 ..< TextureSize {
        for x in 0 ..< TextureSize {
            n := (rand.float32() * 2 - 1) * 14
            v := u8(clamp(f32(base.r) + n, 70, 165))
            b := u8(clamp(i32(v) - 6, 0, 255))
            rl.ImageDrawPixel(&image, i32(x), i32(y), rl.Color{v, v, b, 255})
        }
    }

    mortar := rl.Color{48, 46, 42, 255}
    step :: 16
    for y := 0; y < TextureSize; y += step {
        rl.ImageDrawLine(&image, 0, i32(y), TextureSize, i32(y), mortar)
    }
    for x := 0; x < TextureSize; x += step {
        rl.ImageDrawLine(&image, i32(x), 0, i32(x), TextureSize, mortar)
    }

    return image
}

@(private = "file")
generateWoodImage :: proc() -> rl.Image {
    plank := rl.Color{118, 78, 44, 255}
    image := rl.GenImageColor(TextureSize, TextureSize, plank)

    plank_h :: 10
    band := 0
    for y := 0; y < TextureSize; y += plank_h {
        shift: i32 = band % 3 == 0 ? 0 : (band % 3 == 1 ? -16 : 12)
        col := rl.Color{
            u8(clamp(i32(plank.r) + shift, 0, 255)),
            u8(clamp(i32(plank.g) + shift, 0, 255)),
            u8(clamp(i32(plank.b) + shift, 0, 255)),
            255,
        }
        rl.ImageDrawRectangle(&image, 0, i32(y), TextureSize, plank_h - 1, col)
        band += 1
    }

    seam := rl.Color{42, 27, 15, 255}
    rl.ImageDrawLine(&image, TextureSize / 2, 0, TextureSize / 2, TextureSize, seam)

    return image
}
