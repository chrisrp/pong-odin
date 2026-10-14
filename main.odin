package pong

import rl "vendor:raylib"

WINDOW_W :: 1024
WINDOW_H :: 768

Screen :: enum {
  Menu,
  Single_Player,
  Local_Versus,
  Online_Versus,
}

main :: proc() {
  running := true
  game_state := game_init()
  current_screen := Screen.Menu

  selection_state := Menu_State {
    current_option = .Single_Player,
  }

  rl.InitWindow(WINDOW_W, WINDOW_H, "Pong")
  defer rl.CloseWindow()

  font := rl.LoadFontEx("assets/Orbitron-VariableFont_wght.ttf", 32, nil, 0)
  rl.SetTextureFilter(font.texture, .BILINEAR)
  defer rl.UnloadFont(font)

  audio := audio_init()
  defer audio_destroy(audio)

  rl.PlayMusicStream(audio.music)

  rl.SetExitKey(.KEY_NULL)
  rl.SetTargetFPS(60)

  for running && !rl.WindowShouldClose() {
    rl.UpdateMusicStream(audio.music)

    rl.BeginDrawing()
    defer rl.EndDrawing()

    rl.ClearBackground(rl.BLACK)

    switch current_screen {
    case .Menu:
      menu_update(&selection_state)
      if selection_state.moved do rl.PlaySound(audio.menu)

      if selection_state.selected {
        switch selection_state.current_option {
        case .Single_Player:
          current_screen = .Single_Player
        case .Local_Versus:
          current_screen = .Local_Versus
        case .Online_Versus:
          current_screen = .Menu // TODO: online versus
        case .Exit:
          running = false
        }
      }

      menu_render(selection_state, font)

    case .Single_Player:
      if exit_to_menu(&current_screen, &game_state) do continue

      p1_input := create_player_input()
      p2_input := create_ai_input(
        game_state.p2_paddle,
        game_state.ball_pos,
        game_state.direction,
      )

      update_and_render(&game_state, {p1_input, p2_input}, audio)

    case .Local_Versus:
      if exit_to_menu(&current_screen, &game_state) do continue

      update_and_render(
        &game_state,
        {create_p1_input(), create_p2_input()},
        audio,
      )

    case .Online_Versus:
    }

    rl.DrawFPS(10, 10)
  }
}

update_and_render :: proc(
  game_state: ^Game_State,
  inputs: [2]Input,
  a: Audio,
) {
  game_update(game_state, inputs[0], inputs[1])
  if game_state.ball_bounced do rl.PlaySound(a.bounce)
  if game_state.new_score do rl.PlaySound(a.score)

  game_render(game_state^)
}

exit_to_menu :: proc(
  current_screen: ^Screen,
  game_state: ^Game_State,
) -> bool {
  if rl.IsKeyPressed(.ESCAPE) {
    current_screen^ = .Menu
    game_state^ = game_init()
    return true
  }

  return false
}
