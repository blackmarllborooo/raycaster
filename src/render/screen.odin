package render

ScreenWidth :: 1280
ScreenHeight :: 720

// Screen row of the horizon (eye level). Walls, floor and ceiling are all
// projected relative to this line.
Horizon :: f32(ScreenHeight) / 2

// Vertical layout of the room, in tile units (1 tile = 1.0).
//   - EyeHeight:  how high the camera sits above the floor.
//   - RoomHeight: distance from floor to ceiling.
// Walls span z=0..RoomHeight and the floor/ceiling casters derive their
// vertical camera position from these, so raising RoomHeight lifts the
// ceiling while keeping everything consistent. A future jump would animate
// the eye height instead of these constants.
EyeHeight :: f32(0.5)
RoomHeight :: f32(2.0)
