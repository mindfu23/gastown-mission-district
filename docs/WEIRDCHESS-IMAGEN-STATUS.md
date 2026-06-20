# WeirdChess Imagen Pipeline — Status

Last updated: 2026-04-12

## Overview

Custom image generation pipeline added to gastown-mission-district fork for
producing chess piece art for the WeirdChess app. Uses Gemini 2.5 Flash via
the `imagen` and `imagen-batch` agents.

## Changes Made to Fork

### Imagen Agent (`agents/imagen`)

- **Model updated**: Changed from `gemini-2.0-flash-exp-image-generation` (retired)
  to `gemini-2.5-flash-image`
- **Temp file for request body**: API calls now write the JSON request to a temp
  file and use `curl -d @file` instead of `-d "$REQUEST_BODY"` inline. This fixes
  "Argument list too long" errors when base64 reference images exceed shell arg limits.

### Imagen-Batch Agent (`agents/imagen-batch`)

- **`--take <n>` flag**: Prefixes all generated filenames with `take{n}_` to prevent
  overwriting between iterations. Essential for A/B comparison across takes.
- **`--reference, -r <file>` flag**: Passes reference image(s) through to the
  underlying `imagen` agent. Supports multiple references. References are shown
  in dry-run output for traceability.
- Updated help text and info output to show take number and references.

### WeirdChess Project File (`agents/lib/imagen-projects/weirdchess.sh`)

New batch generation project with:

**Variants:**
- `sample` — 3-piece style test (Pawn, Queen, Knight)
- `standard` — 6 standard pieces
- `compound` — 7 fairy pieces (Amazon, Cardinal, Marshal, etc.)
- `jetan` — 8 Barsoomian pieces (Chief, Princess, Flier, etc.)
- `all` — everything

**Features:**
- Per-piece prompt descriptions with sacred recognition cues
- White/black color variants with app-palette-matched color descriptions
  (`#F5E6D3` cream for white, `#1A1A1A` charcoal for black)
- Recommended styles per variant (flat, geometric, staunton for standard;
  neon for jetan, etc.)
- Project prompt suffix ensures consistent framing (white background, no text,
  SVG-ready edges)

**Usage:**
```bash
# Style exploration
imagen-batch weirdchess --test sample

# Full set generation
imagen-batch weirdchess --take 1 --style flat standard

# With reference image
imagen-batch weirdchess --take 2 --reference ./seed.png --style flat standard

# Dry run
imagen-batch weirdchess --take 3 --dry-run --style flat all
```

## Generated Assets

All output in `weirdchess-pieces/`:

```
weirdchess-pieces/
├── seed_images/                    # Midjourney reference images
│   ├── knight1.png                 # Cropped silhouette — horse head
│   ├── queen1.png                  # Cropped — geometric stacked
│   ├── bishop1.png                 # Cropped — wavy with crown
│   ├── pawn1.png                   # Cropped — orb with spirals
│   ├── generic1.png                # Cropped — checkered hourglass
│   ├── king_round2.png             # Round 2 — carved wood face
│   ├── knight_round2.png           # Round 2 — cubist geometric
│   ├── pawn_round2.png             # Round 2 — polished gourd
│   └── anideasmith_*.png           # 3 full Midjourney compositions
└── sample/
    └── test_styles/
        ├── take1_sample_*.png      # Take 1: no reference, 3 styles × pawn
        ├── sample_*take2_*.png     # Take 2: full silhouette sheet as ref
        ├── sample_take3_*.png      # Take 3: per-piece cropped refs
        ├── sample_take4_*.png      # Take 4: stronger weirdness prompts
        ├── sample_take5_*.png      # Take 5: S-curve bishop, checkered pattern, wild knight
        ├── sample_take6_*.png      # Take 6: 3D sculptural (carved wood, cubist)
        ├── sample_take7_*.png      # Take 7: flat vector conversion of round 2
        ├── sample_take8_*.png      # Take 8: consistent notched bases, face details
        ├── sample_take9_*.png      # Take 9: gourd bases, S-curve bishop, clean rook
        ├── sample_take10_*.png     # Take 10: uniform height, pedestal bases
        ├── sample_take11_*.png     # Take 11: larger fill, detailed crowns, spiky knight
        ├── sample_take12_*.png     # Take 12: crown-only king/queen attempt
        └── *.prompt.txt            # Saved prompts for each generated image
```

## Fork Sync Status

- **Upstream**: `steveyegge/gastown`
- **Last synced**: 2026-02-28
- **Commits behind**: ~1,715 (upstream hit v1.0.0)
- **Commits ahead**: ~10 (personal additions)
- **Conflict risk**: Low — imagen agents and router are personal additions, not upstream
- **Notable upstream additions**: Formula overlay/compose system (83 commits to `internal/formula/`)
  which would be useful for chaining generate→review→iterate workflows

## API Configuration

- **API key**: `GEMINI_API_KEY` set in `~/.zshrc`
- **Key format**: Google AI Studio key (starts with `AIza...`)
- **Cost**: Covered by Google AI Studio Pro subscription
- **Model**: `gemini-2.5-flash-image` (as of 2026-04-12; may change)

## Lessons Learned

1. **Cropped single-piece references >> full composite images** for style transfer
2. **Per-piece reference routing** produces best results but requires individual calls
3. **Using previous take output as reference** for next iteration is very effective
4. **Flat vector constraint** must be explicit and emphatic or Gemini defaults to 3D
5. **Structural removal** (e.g., "no shaft") is hard — Gemini resists removing elements
   from reference images. Better to use programmatic cropping or different references.
6. **Generated PNGs always have white backgrounds** — must post-process with Pillow
7. **Model names expire** — check ListModels endpoint if generation fails
