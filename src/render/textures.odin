package render

import rl "vendor:raylib"

TextureSize :: 64

WallTexture: rl.Texture2D

// LoadTextures generates the wall texture on the CPU and uploads it to the
// GPU. Procedural, so the repo doesn't need to ship binary image assets.
LoadTextures :: proc() {
    image := generateBrickImage()
    WallTexture = rl.LoadTextureFromImage(image)
    rl.UnloadImage(image)
}

UnloadTextures :: proc() {
    rl.UnloadTexture(WallTexture)
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
