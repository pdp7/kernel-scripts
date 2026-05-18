---
name: Sashiko local setup
description: Run sashiko AI patch review locally on a branch before posting to lore — pre-built at ~/dev/sashiko, configured for claude-cli provider on /home/pdp7/dev/linux
type: reference
originSessionId: 0bbc4057-bb33-4fde-8ff5-2ed036a92313
---
Sashiko (https://github.com/sashiko-dev/sashiko) is the AI review engine behind sashiko.dev. Cloned and built at `~/dev/sashiko`.

**Configured Settings.toml:**
- `[ai] provider = "claude-cli"`, `model = "claude-sonnet-4-6"`, `max_input_tokens = 180000`, `max_interactions = 150` — uses Claude Code subscription, no API key, $0 LLM cost.
- `[git] repository_path = "/home/pdp7/dev/linux"` — points at the actual dev tree.
- Daemon listens 0.0.0.0:8080 (Settings says 127.0.0.1 but the API ignores host).

**Run a review on the current b4 branch:**
```bash
cd ~/dev/sashiko && ./target/release/sashiko          # daemon (terminal 1)
b4 prep --show-info                                    # get base..end commits
./target/release/sashiko-cli submit -r /home/pdp7/dev/linux <base>..<head> --type range
./target/release/sashiko-cli show 36 > review.md       # latest patchset id
```

**Gotcha — do NOT cat format-patch files into a single mbox:** `cat 0001-*.patch > series.mbx; sashiko-cli submit series.mbx` makes each patch its own patchset because b4's per-patch files lack `In-Reply-To` headers. They get stuck in `Incomplete` (received_parts=1, total_parts=N) forever. Use `--type range` against the local repo instead — sashiko walks the git range correctly and produces one patchset with all patches.

**Switch to Gemini (matches public sashiko.dev):** edit Settings.toml `[ai] provider = "gemini"`, `model = "gemini-3.1-pro-preview"`, set `LLM_API_KEY` env var. Pay-per-token.

**Web UI:** http://127.0.0.1:8080 once daemon is up. Kill daemon with `pkill -f target/release/sashiko`.
