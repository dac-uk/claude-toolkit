# claude-toolkit

One place for the Claude plugins, MCP servers and connectors used across **every**
dac-uk repo — current and future — on the Mac, in Claude Code cloud sessions and on
claude.ai. Nothing here belongs to a single project.

It is a Claude Code **plugin marketplace** (`dac-toolkit`) of **bundles**: each bundle is
an empty plugin whose dependencies are the real plugins from the Anthropic directory, so
`claude plugin install core@dac-toolkit` brings all of them in one step, and
`claude plugin marketplace update` picks up any change made here.

## Bundles

| Bundle | Plugins | Always-on cost* | Use for |
|---|---|---|---|
| **`core`** | superpowers · frontend-design · context7 · playwright · code-review · code-simplifier · feature-dev · security-guidance · commit-commands · claude-md-management · skill-creator · pyright-lsp · typescript-lsp | ~1.7k tok | Every repo |
| `ios` | swift-lsp (SourceKit-LSP, ships with Xcode) | ~0 | curo-ios, narval-ios, lobsteer-ios, cryptoscope-ios — Mac only |
| `security` | claude-security | ~0.7k | Deep verified vulnerability scans (kyc-app, curo-backend, coherence, trading bots) |
| `agents` | agent-sdk-dev · mcp-server-dev · plugin-dev | ~3.1k | Building with Claude: claude-daemon, openclaw bridges, MCP servers |
| `web` | vercel · supabase | ~4.6k | Sites and apps on Vercel/Supabase (keryx-site, curo-landing) |
| `aws` | aws-core | ~7k | AWS infrastructure work |

\* Tokens added to every session, measured with `claude plugin details`. MCP tool schemas
load on demand and aren't counted. `core` is deliberately lean. The heavier bundles are
worth turning on where you need them, not everywhere.

**Why these.** The directory has ~3,600 plugins. `superpowers` and `frontend-design` are
the two most installed (~1M each, Sept 2026), and Context7, Playwright and code review are
the consensus core of every 2026 "best plugins/MCP servers" list. The rest of `core`
is Anthropic's own engineering set. Left out on purpose: `pr-review-toolkit` (~2k tok,
overlaps code-review), `huggingface-skills` (~5k), `expo` (~4.4k; your iOS apps are
native), `stripe` (~2.2k), `sentry` (~1.1k), `firecrawl`/`exa` (need API keys; use the
claude.ai connectors instead). Each is one `claude plugin install <name>@anthropic-plugin-directory`
away.

## Install it everywhere — once per surface

### 1. Mac Studio — every local repo and every Remote Control session

```bash
git clone https://github.com/dac-uk/claude-toolkit ~/code/claude-toolkit
~/code/claude-toolkit/setup/install.sh core ios security
```

Installs at **user scope** (`~/.claude/settings.json`), so every repo on the Mac gets it,
including the Remote Control environments (signalbox, housemaster, cryptography), which
run on the Mac. Re-run any time; it also installs the TypeScript and Python language
servers through npm.

### 2. Claude Code cloud sessions — every repo, present and future

A repo's own `.claude/settings.json` plugins are **not** installed in cloud sessions, and
neither is your Mac's `~/.claude`. What runs in every cloud session regardless of repo is
the **environment's setup script**. Open any cloud session → environment menu in the
title bar → **Default** → **Edit** → **Setup script**, and paste:

```bash
#!/bin/bash
git clone -q --depth 1 https://github.com/dac-uk/claude-toolkit /tmp/claude-toolkit \
  && TOOLKIT_SOFT=1 bash /tmp/claude-toolkit/setup/install.sh core security
exit 0
```

It runs before Claude Code starts. The result is cached for about seven days or until
you edit the script, so sessions don't pay for it each time. `TOOLKIT_SOFT=1` plus
`exit 0` mean a hiccup never stops a session from starting.

**Your global instructions.** The operating framework in your Mac's `~/.claude/CLAUDE.md`
doesn't reach cloud sessions either. To bring it, add this to the same setup script
(pasted there, it stays private to your environment):

```bash
mkdir -p ~/.claude && cat > ~/.claude/CLAUDE.md <<'MD'
…paste the contents of your Mac's ~/.claude/CLAUDE.md…
MD
```

**Network.** Plugin MCP servers run inside the container, so the environment's network
policy applies. Context7 (`mcp.context7.com`) is refused by the current policy. Either add
it under the environment's **Network access → Allowed domains**, or connect the
**Context7 connector** on claude.ai (below): connectors go through Anthropic's proxy and
work in every session.

### 3. claude.ai — connectors (all surfaces: cloud, desktop, Cowork, chat)

Connectors are account-wide and reach every surface. Connect at **claude.ai → Customize →
Connectors**:

| Already connected | Finish signing in | Recommended to add |
|---|---|---|
| Gmail · Google Calendar · Google Drive · Slack · Supabase · Vercel · Xero · CoinGecko · Sonos | Stripe · Microsoft 365 | **Context7** (docs) · **Exa** or **Parallel Search** (web/code search) · **Notion** · **Linear** · **Sentry** · **Figma** · **Hugging Face** · **Todoist** · **AWS MCP** |

### 4. claude.ai — plugins for Cowork and desktop chat (optional)

To have the same plugins in Cowork and desktop chat, add this repo as a marketplace:
**claude.ai → Customize → Plugins → Add → Add marketplace → `dac-uk/claude-toolkit`**,
then enable bundles there. Synced plugins also load in Claude Code sessions signed in
with the account. If you do this, skip steps 1–2 for the same bundles, or you'll load
them twice.

## Changing the toolkit

- **Add or drop a plugin:** edit the bundle's `plugins/<bundle>/.claude-plugin/plugin.json`
  `dependencies`, bump its `version`, push. Re-run `setup/install.sh` (it refreshes the
  marketplace and installs any new dependency). Cloud sessions pick it up when the setup
  script's cache refreshes, which happens at once if you re-save the script.
- **New bundle:** add `plugins/<name>/.claude-plugin/plugin.json`, list it in
  `.claude-plugin/marketplace.json` and in `ALL` in `setup/install.sh`.
- **Your own skills or plugins:** put them under `plugins/` like any plugin. They're
  distributed through the same marketplace.
- **Remove:** `claude plugin uninstall <bundle>@dac-toolkit && claude plugin prune`
  (prune removes the dependencies nothing else needs).
- **Check:** `claude plugin validate .` and `claude plugin details <plugin>` for costs.
