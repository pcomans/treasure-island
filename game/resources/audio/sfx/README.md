# The game's sound files (not in Git)

This folder holds the takes of every sound the game plays, as
`<sound id>_<NN>.ogg`, and their manifest, `sfx.json`. Git ignores everything
here but this note: the sounds are generated with ElevenLabs, whose terms
forbid making the output available as isolated audio files, and the repository
is public (owner, 2026-11-14). The prompts and the tools that make the audio
are public; the audio stays private. `tools/sfx/README.md` explains why, with
the terms quoted, and how to make your own set ("Make your own sound set").

`tools/fetch-sfx` fills the folder from a private source given by
`TI_SFX_SOURCE` or `--source`: the `game/` folder `tools/generate-sfx --process`
writes (its `sfx.json` and `<group>/<name>_NN.ogg` takes), or a Git repository
holding one (`--subdir`, `--ref`; a token for a private repository in
`TI_SFX_GIT_TOKEN`). It copies the takes of the sounds listed in
`game/resources/audio/sounds.json` and writes this folder's `sfx.json`: each
sound's entry of the source's manifest (its playback gain, `gain_db`, which the
game applies; tools/sfx/README.md "Levels"), its takes renamed as copied here.
Run Godot's import afterwards (`tools/godot --headless --path . --import`; the
build scripts and `tools/test.sh` do) so the game can load them.

With the folder empty the game, its tests and its builds run silent: a sound
with no takes plays nothing. `tools/build-linux.sh` and `tools/build-web.sh`
call `tools/fetch-sfx`, which does nothing without a source. `tools/build-mac.sh`
calls it only when `TI_SFX_SOURCE` is set, and otherwise logs how many takes this
folder holds; the Mac build on GitHub Actions (`.github/workflows/mac-build.yml`)
takes `TI_SFX_SOURCE`, `TI_SFX_SUBDIR` and `TI_SFX_REF` from the repository's
variables and `TI_SFX_GIT_TOKEN` from its secrets, and is silent while they are
unset.
