# State Scout

Map practice game for learning the 50 US states and the 13 colonies by location.

- Single self-contained page: [index.html](index.html) (US map path data from Wikimedia Commons, public domain).
- Mastery ladder: blocks of ten states east to west; a configurable number of perfect drag-and-drop rounds in a row unlocks the next block. Colonies use a player-chosen block size.
- Progress: localStorage per device, plus cross-device sync via "Sign in with Google" (Firebase Auth + Firestore, one doc per player at `players/{uid}`; rules in [firebase/firestore.rules](firebase/firestore.rules)).
- The `FIREBASE_CONFIG` constant in index.html holds the public Firebase web config; `null` disables sync and hides the sign-in button.

Hosted on Vercel; pushing to main redeploys.
