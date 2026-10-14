package pong

import rl "vendor:raylib"

Menu_Option :: enum {
  Single_Player,
  Local_Versus,
  Online_Versus,
  Exit,
}

Menu_State :: struct {
  current_option: Menu_Option,
  selected:       bool,
  moved:          bool,
}

MENU_FONT_SIZE :: 32
INSTRUCTIONS_FONT_SIZE :: 24

MENU_LABELS := [Menu_Option]cstring {
  .Single_Player = "START PLAYER 1",
  .Local_Versus  = "START LOCAL VERSUS",
  .Online_Versus = "START ONLINE VERSUS",
  .Exit          = "EXIT GAME",
}

MENU_INSTRUCTIONS := [Menu_Option]cstring {
  .Single_Player = "Use UP and DOWN keys to move paddle. (press space)",
  .Local_Versus  = "Player 1 Q/A and Player 2 O/L to move (press space)",
  .Online_Versus = "coming soon...",
  .Exit          = "Are you sure? (press space)",
}

menu_update :: proc(state: ^Menu_State) {
  state.moved = false
  delta: int

  if rl.IsKeyPressed(.DOWN) do delta = 1
  if rl.IsKeyPressed(.UP) do delta = -1
  if delta != 0 do state.moved = true

  new_option := int(state.current_option) + delta
  state.current_option = Menu_Option(
    clamp(new_option, 0, len(Menu_Option) - 1),
  )
  state.selected = rl.IsKeyPressed(.SPACE)
}

menu_render :: proc(state: Menu_State, font: rl.Font) {
  color: rl.Color

  for label, option in MENU_LABELS {
    color = option == state.current_option ? rl.YELLOW : rl.WHITE
    draw_centered(font, label, 400 + i32(option) * 30, color, MENU_FONT_SIZE)
  }

  multiplier := len(MENU_LABELS)

  message := MENU_INSTRUCTIONS[state.current_option]
  draw_centered(
    font,
    message,
    500 + i32(multiplier) * 30,
    rl.WHITE,
    INSTRUCTIONS_FONT_SIZE,
  )
}

@(private = "file")
draw_centered :: proc(
  font: rl.Font,
  text: cstring,
  y: i32,
  color: rl.Color,
  size: i32,
) {
  width := rl.MeasureTextEx(font, text, f32(size), 3)
  x := (WINDOW_W - width.x) / 2

  rl.DrawTextEx(font, text, {f32(x), f32(y)}, f32(size), 3, color)
}
