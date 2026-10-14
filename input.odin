package pong

import rl "vendor:raylib"

DEAD_ZONE :: 25

Input :: enum {
  UP,
  DOWN,
  NONE,
}

create_player_input :: proc() -> Input {
  if rl.IsKeyDown(.UP) do return .UP
  if rl.IsKeyDown(.DOWN) do return .DOWN

  return .NONE
}

create_p1_input :: proc() -> Input {
  if rl.IsKeyDown(.Q) do return .UP
  if rl.IsKeyDown(.A) do return .DOWN

  return .NONE
}

create_p2_input :: proc() -> Input {
  if rl.IsKeyDown(.O) do return .UP
  if rl.IsKeyDown(.L) do return .DOWN

  return .NONE
}

create_ai_input :: proc(
  paddle: Rect,
  ball_pos: Vec2,
  direction: Vec2,
) -> Input {
  if direction.x < 0 do return .NONE

  paddle_center := paddle.y + paddle.height / 2
  diff := ball_pos.y - paddle_center

  if diff < -DEAD_ZONE do return .UP
  if diff > DEAD_ZONE do return .DOWN

  return .NONE
}
