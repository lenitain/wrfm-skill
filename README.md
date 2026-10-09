# wrfm-skill

An [Agent Skills](https://agentskills.io)-compatible skill that teaches coding
agents how to **create, inspect, edit, verify, and iterate on `.wrfm` 3D
wireframe models** — image-first, with a strict health-check feedback loop.

`.wrfm` is a plain-text format for 3D wireframe models (`v x y z` vertices,
`e i j` edges, optional `group` sections) used by
[wireforge](https://github.com/Vaishnav-Sabari-Girish/wireforge), a TUI-based
viewer and live-editor for braille-rendered 3D wireframes, and the
[`ratatui-wireframe`](https://crates.io/crates/ratatui-wireframe) rendering crate.

The current format is **v2**: the file opens with a `wrfm 2` magic line and a
`vertices <N>   edges <M>` counts header. The v1 files of older `wrfm` 0.4.0
have neither and are rejected; `wrfm format` prints the full spec, including
how to migrate one.

## Why this skill exists

Wireframe models are *shapes*, not strings. Terminal character art hides
occlusion, silhouette, proportion, and perspective. This skill installs one
core discipline into the agent's workflow:

> **SEE the model as an image, never as terminal art.** Render → convert to
> PNG → look at the PNG → re-shoot after every edit.

Around that loop it adds guardrails the model cannot discover on its own:
facts before edits (`wrfm info` / `wrfm geometry`), a health gate after every
edit (`wrfm check`), intent verification (`wrfm verify`), CLI-only editing
(never hand-editing coordinates), Y-up orientation conventions, and a
reference library of proven topology patterns to copy instead of re-invent.

## What's inside

```text
wrfm/
├── SKILL.md                  # The operating guide the agent loads
├── scripts/
│   ├── wrfm-shot.sh          # .wrfm → PNG (single view, group zoom, or 2x3 six-view montage)
│   └── smoke.sh              # End-to-end environment verification
└── references/
    ├── wrfm_assets/          # Finished sample models (anvil, bicycle, microwave, ...)
    └── wrfm_generator/       # The Python scripts that generated them (+ WrfmModel helper)
```

### Reference library

| Object | Sample asset | Generator script |
| :--- | :--- | :--- |
| anvil | `references/wrfm_assets/anvil.wrfm` | `references/wrfm_generator/gen_anvil.py` |
| bicycle | `references/wrfm_assets/bicycle.wrfm` | `references/wrfm_generator/gen_bicycle.py` |
| microwave | `references/wrfm_assets/microwave.wrfm` | `references/wrfm_generator/gen_microwave.py` |
| toilet | `references/wrfm_assets/toilet.wrfm` | `references/wrfm_generator/gen_toilet.py` |
| vintage TV | `references/wrfm_assets/vintage_tv.wrfm` | `references/wrfm_generator/gen_vintage_tv.py` |
| washing machine | `references/wrfm_assets/washing_machine.wrfm` | `references/wrfm_generator/gen_washing_machine.py` |

Each generator demonstrates reusable patterns — named groups per part,
Y-up construction, ground at `y=0`, ring/hub/spoke and box/connect-ring
topology — built on a small `WrfmModel` helper (`add` / `edge` / `cycle` /
`ring` / `box8` / `connect_ring`). Complex models should be scripted like
these, not hand-written.

## Requirements

| Dependency | Check | Needed for |
| :--- | :--- | :--- |
| [`wrfm` CLI](https://github.com/Vaishnav-Sabari-Girish/wireforge) (the `wrfm-cli` crate in that repo) | `wrfm format > /dev/null` | All model operations |
| ImageMagick | `magick -version` | Render → PNG conversion |
| Multimodal vision | Open a PNG with the read tool | The primary workflow |

Without vision, the skill degrades to a documented text-mode fallback
(density grids + query facts) rather than pretending to see.

## Installation

Clone and copy (or symlink) the skill folder into your agent's skills directory:

```bash
git clone https://github.com/lenitain/wrfm-skill.git
cp -r wrfm-skill/wrfm ~/.config/opencode/skills/wrfm   # opencode
# or the equivalent directory for Claude Code / other Agent Skills runtimes
```

Then verify the environment end-to-end:

```bash
~/.config/opencode/skills/wrfm/scripts/smoke.sh
```

## Usage

Just ask your agent naturally — the skill triggers on any `.wrfm`
build/fix/rotate/review request:

- *"Build a windmill as a .wrfm model"*
- *"This bicycle looks squashed — fix the proportions"*
- *"Rotate the anvil 45° and check it's still healthy"*
- *"What parts does this microwave model have?"*

The typical session follows the skill's iterate loop: facts → render →
look → edit → check → verify → diff. If you keep the model open in the
wireforge TUI, it hot-reloads the file, so you can watch every edit land live.

## Related

- [wireforge](https://github.com/Vaishnav-Sabari-Girish/wireforge) — the main
  repository: TUI viewer/live-editor for `.wrfm`, plus the `wrfm` CLI crate
- [`ratatui-wireframe`](https://crates.io/crates/ratatui-wireframe) — the
  Rust rendering widget that consumes these models
