package pong

import "core:math"
import "core:math/rand"
import rl "vendor:raylib"

Vec2 :: rl.Vector2
Rect :: rl.Rectangle

Game_State :: struct {
  p1_paddle:       Rect,
  p2_paddle:       Rect,
  ball_pos:        Vec2,
  velocity:        f32,
  direction:       Vec2,
  p1_points:       int,
  p2_points:       int,
  collision_count: int,
  ball_bounced:    bool,
  new_score:       bool,
}

PADDLE_MARGIN :: 20
PADDLE_WIDTH :: 25
PADDLE_HEIGHT :: 180
PADDLE_SPEED :: 13

P2_PADDLE_X :: WINDOW_W - PADDLE_WIDTH - PADDLE_MARGIN
PADDLE_Y :: (WINDOW_H - PADDLE_HEIGHT) / 2

INITIAL_VELOCITY :: 12
BALL_RADIUS :: 15

MIN_PADDLE_Y :: 0
MAX_PADDLE_Y :: WINDOW_H - PADDLE_HEIGHT

DASHED_LINE_START :: Vec2{WINDOW_W / 2, 0}
DASHED_LINE_END :: Vec2{WINDOW_W / 2, WINDOW_H}

game_init :: proc() -> Game_State {
  game_state := Game_State {
    p1_paddle = {PADDLE_MARGIN, PADDLE_Y, PADDLE_WIDTH, PADDLE_HEIGHT},
    p2_paddle = {P2_PADDLE_X, PADDLE_Y, PADDLE_WIDTH, PADDLE_HEIGHT},
  }

  reset_ball_state(&game_state, 1)

  return game_state
}

game_update :: proc(state: ^Game_State, p1: Input, p2: Input) {
  state.new_score = false
  state.ball_bounced = false
  state.p1_paddle.y = clamp(
    state.p1_paddle.y + (paddle_dir(p1) * PADDLE_SPEED),
    MIN_PADDLE_Y,
    MAX_PADDLE_Y,
  )

  state.p2_paddle.y = clamp(
    state.p2_paddle.y + (paddle_dir(p2) * PADDLE_SPEED),
    MIN_PADDLE_Y,
    MAX_PADDLE_Y,
  )

  state.ball_pos += (state.direction * state.velocity)

  if (state.ball_pos.y - BALL_RADIUS) <= 0 {
    state.direction.y = abs(state.direction.y)
    state.ball_bounced = true
  }

  if (state.ball_pos.y + BALL_RADIUS) >= WINDOW_H {
    state.direction.y = -abs(state.direction.y)
    state.ball_bounced = true
  }

  if state.direction.x < 0 {   // goes toward p1
    if ball_hits_paddle(state.ball_pos, state.p1_paddle) {
      state.collision_count += 1
      state.direction = new_direction(state.ball_pos, state.p1_paddle, 1)
      state.ball_bounced = true
    }
  } else {
    if ball_hits_paddle(state.ball_pos, state.p2_paddle) {
      state.collision_count += 1
      state.direction = new_direction(state.ball_pos, state.p2_paddle, -1)
      state.ball_bounced = true
    }
  }

  if state.ball_pos.x + BALL_RADIUS < 0 {   // ball falls on p1 side
    state.p2_points += 1
    reset_ball_state(state, 1)
    state.new_score = true
  } else if state.ball_pos.x - BALL_RADIUS > WINDOW_W {   // ball falls on p2 side
    state.p1_points += 1
    reset_ball_state(state, -1)
    state.new_score = true
  }

  if state.collision_count > 10 {
    state.collision_count = 0
    state.velocity += 2
  }
}

game_render :: proc(state: Game_State) {
  rl.DrawText(
    rl.TextFormat("%d", state.p1_points),
    WINDOW_W / 4,
    10,
    20,
    rl.WHITE,
  )
  rl.DrawText(
    rl.TextFormat("%d", state.p2_points),
    (WINDOW_W / 4) * 3,
    10,
    20,
    rl.WHITE,
  )

  rl.DrawText(
    rl.TextFormat("bounces: %d", state.collision_count),
    10,
    WINDOW_H - 20,
    20,
    rl.WHITE,
  )

  rl.DrawText(
    rl.TextFormat("velocity: %d", int(state.velocity)),
    200,
    WINDOW_H - 20,
    20,
    rl.WHITE,
  )
  rl.DrawLineDashed(DASHED_LINE_START, DASHED_LINE_END, 25, 10, rl.WHITE)
  rl.DrawRectangleRec(state.p1_paddle, rl.WHITE)
  rl.DrawRectangleRec(state.p2_paddle, rl.WHITE)
  rl.DrawCircleV(state.ball_pos, BALL_RADIUS, rl.WHITE)
}

@(private = "file")
paddle_dir :: proc(input: Input) -> f32 {
  if input == .UP do return -1
  if input == .DOWN do return 1

  return 0
}

@(private = "file")
ball_hits_paddle :: proc(ball: Vec2, paddle: Rect) -> bool {
  return rl.CheckCollisionCircleRec(ball, BALL_RADIUS, paddle)
}

@(private = "file")
new_direction :: proc(ball: Vec2, paddle: Rect, side: f32) -> Vec2 {
  p_center := paddle.y + (paddle.height / 2)
  offset := (ball.y - p_center) / (paddle.height / 2)
  offset = clamp(offset, -1, 1)
  angle := math.to_radians(offset * 60)

  return {side * math.cos(angle), math.sin(angle)}
}

@(private = "file")
reset_ball_state :: proc(state: ^Game_State, side: f32) {
  angle := math.to_radians(rand.float32_range(-30, 30))

  state.ball_pos = {(WINDOW_W / 2), (WINDOW_H / 2)}
  state.velocity = INITIAL_VELOCITY
  state.direction = {side * math.cos(angle), math.sin(angle)}
  state.collision_count = 0
}
