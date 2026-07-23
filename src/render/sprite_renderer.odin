package render

import rl "vendor:raylib"
import geo "../geo"
import world "../world"

MaxSprites :: 32

// How tall a sprite is drawn, as a fraction of a full tile height.
SpriteHeightScale :: f32(0.7)

SpriteTexture: rl.Texture2D

LoadSpriteTextures :: proc() {
    image := generateBarrelImage()
    SpriteTexture = rl.LoadTextureFromImage(image)
    rl.UnloadImage(image)
}

UnloadSpriteTextures :: proc() {
    rl.UnloadTexture(SpriteTexture)
}

// DrawSprites billboards every sprite towards the camera and depth-tests it
// against the wall Z-buffer built by the last DrawScene call.
DrawSprites :: proc(p: ^world.Player, sprites: []world.Sprite) {
    n := len(sprites)
    if n > MaxSprites {
        n = MaxSprites
    }

    dists: [MaxSprites]f32
    order: [MaxSprites]int
    for i in 0 ..< n {
        d := geo.Sub(sprites[i].position, p.position)
        dists[i] = d.x * d.x + d.y * d.y
        order[i] = i
    }

    // Selection sort, farthest first (painter's algorithm). Sprite counts
    // are small here so an O(n^2) sort isn't worth avoiding.
    for i in 0 ..< n {
        max_idx := i
        for j in i + 1 ..< n {
            if dists[order[j]] > dists[order[max_idx]] {
                max_idx = j
            }
        }
        order[i], order[max_idx] = order[max_idx], order[i]
    }

    for i in 0 ..< n {
        drawSprite(p, sprites[order[i]])
    }
}

@(private = "file")
drawSprite :: proc(p: ^world.Player, sprite: world.Sprite) {
    // Sprite position relative to the player, in the same tile-space units
    // CastRay works in.
    rel := geo.Vec2{
        (sprite.position.x - p.position.x) / world.TileSize,
        (sprite.position.y - p.position.y) / world.TileSize,
    }

    dir := p.direction
    plane := p.camera_plane

    // Inverse of the camera's [direction, plane] basis, to move the sprite
    // into camera space (x = across the view, y = depth).
    inv_det := 1 / (plane.x * dir.y - dir.x * plane.y)

    transform_x := inv_det * (dir.y * rel.x - dir.x * rel.y)
    transform_y := inv_det * (-plane.y * rel.x + plane.x * rel.y)

    if transform_y <= 0.1 {
        return // behind the camera, or too close to project sanely
    }

    screen_x := (f32(ScreenWidth) / 2) * (1 + transform_x / transform_y)

    full_line_height := f32(ScreenHeight) / transform_y
    sprite_h := full_line_height * SpriteHeightScale
    sprite_w := sprite_h

    // Anchor to the floor at the sprite's distance rather than centering on
    // screen like a wall column would.
    floor_y := f32(ScreenHeight) / 2 + full_line_height / 2
    draw_start_y_f := floor_y - sprite_h
    draw_end_y_f := floor_y

    draw_start_x_f := screen_x - sprite_w / 2
    draw_end_x_f := screen_x + sprite_w / 2

    start_x := i32(draw_start_x_f)
    end_x := i32(draw_end_x_f)
    if start_x < 0 {
        start_x = 0
    }
    if end_x > ScreenWidth {
        end_x = ScreenWidth
    }

    draw_top := draw_start_y_f < 0 ? 0 : draw_start_y_f
    draw_bottom := draw_end_y_f > f32(ScreenHeight) ? f32(ScreenHeight) : draw_end_y_f
    if draw_bottom <= draw_top {
        return
    }

    // Same trick as the wall renderer: sample only the visible slice of the
    // texture instead of squashing the whole thing into the clamped rect,
    // so close-up sprites don't distort vertically.
    tex_v_top := (draw_top - draw_start_y_f) / sprite_h * f32(TextureSize)
    tex_v_bottom := (draw_bottom - draw_start_y_f) / sprite_h * f32(TextureSize)

    brightness := clamp(1 - transform_y / FogDistance, MinBrightness, 1)
    shade := u8(255 * brightness)
    tint := rl.Color{shade, shade, shade, 255}

    for x := start_x; x < end_x; x += 1 {
        if transform_y >= ZBuffer[x] {
            continue // a solid wall is closer on this column
        }

        // If a fence is closer than the sprite, it hides the sprite from its
        // top edge down to the floor. Clip this column to whatever pokes up
        // above the fence.
        col_bottom := draw_bottom
        if FenceDist[x] < transform_y && FenceTopY[x] < col_bottom {
            col_bottom = FenceTopY[x]
        }
        if col_bottom <= draw_top {
            continue // fully hidden behind the fence
        }

        tex_x := i32((f32(x) - draw_start_x_f) / sprite_w * f32(TextureSize))
        tex_x = clamp(tex_x, 0, TextureSize - 1)

        col_tex_v_bottom := (col_bottom - draw_start_y_f) / sprite_h * f32(TextureSize)

        source := rl.Rectangle{f32(tex_x), tex_v_top, 1, col_tex_v_bottom - tex_v_top}
        dest := rl.Rectangle{f32(x), draw_top, 1, col_bottom - draw_top}
        rl.DrawTexturePro(SpriteTexture, source, dest, rl.Vector2{0, 0}, 0, tint)
    }
}

@(private = "file")
generateBarrelImage :: proc() -> rl.Image {
    image := rl.GenImageColor(TextureSize, TextureSize, rl.BLANK)

    cx := f32(TextureSize) / 2
    cy := f32(TextureSize) / 2 + 4
    rx := f32(TextureSize) / 2 - 6
    ry := f32(TextureSize) / 2 - 4

    body := rl.Color{112, 66, 34, 255}
    shade := rl.Color{80, 46, 22, 255}
    band := rl.Color{54, 36, 18, 255}

    for y in 0 ..< TextureSize {
        for x in 0 ..< TextureSize {
            dx := (f32(x) - cx) / rx
            dy := (f32(y) - cy) / ry
            if dx * dx + dy * dy > 1 {
                continue
            }

            col := body
            if dx < -0.4 {
                col = shade
            }
            if y % 18 < 3 {
                col = band
            }

            rl.ImageDrawPixel(&image, i32(x), i32(y), col)
        }
    }

    return image
}
