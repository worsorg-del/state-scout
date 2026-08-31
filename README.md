# State Scout

Map practice game for learning the 50 US states and the 13 colonies by location.

- **Live site:** https://bwsnwl.github.io/state-scout/
- Single self-contained page: [index.html](index.html) (US map path data from Wikimedia Commons, public domain).
- Mastery ladder: blocks of ten states east to west; a configurable number of perfect drag-and-drop rounds in a row unlocks the next block. Colonies use a player-chosen block size.
- Progress: localStorage per device, plus optional cross-device sync via player name + PIN (Supabase RPC; config constants `SYNC.url` / `SYNC.key` in index.html — empty disables sync and hides the player button).

To edit: change index.html and push to main; GitHub Pages redeploys automatically.
