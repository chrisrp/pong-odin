package pong

import rl "vendor:raylib"

MUSIC_VOLUME :: 0.3

Audio :: struct {
  music:  rl.Music,
  menu:   rl.Sound,
  bounce: rl.Sound,
  score:  rl.Sound,
}

audio_init :: proc() -> Audio {
  rl.InitAudioDevice()

  audio: Audio = {
    music  = rl.LoadMusicStream("assets/music.wav"),
    menu   = rl.LoadSound("assets/menu_move.wav"),
    bounce = rl.LoadSound("assets/bounce.wav"),
    score  = rl.LoadSound("assets/score.wav"),
  }

  rl.SetMusicVolume(audio.music, MUSIC_VOLUME)

  return audio
}

audio_destroy :: proc(audio: Audio) {
  rl.UnloadMusicStream(audio.music)
  rl.UnloadSound(audio.menu)
  rl.UnloadSound(audio.bounce)
  rl.UnloadSound(audio.score)

  rl.CloseAudioDevice()
}
