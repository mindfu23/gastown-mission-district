#!/bin/bash
# SPDX-License-Identifier: MIT
# WeirdChess Piece Generation Project
# Generate chess piece sets for each board variant in WeirdChess
#
# Usage:
#   imagen-batch weirdchess --test sample          # Test styles with Pawn/Queen/Knight
#   imagen-batch weirdchess --style flat standard   # Generate full standard set
#   imagen-batch weirdchess --style flat compound   # Generate compound/fairy pieces
#   imagen-batch weirdchess --style flat all        # Generate everything

PROJECT_NAME="WeirdChess Pieces"
PROJECT_DESC="Chess piece sets for WeirdChess app — quirky but recognizable"
DEFAULT_OUTPUT="./weirdchess-pieces"

# Variants map to piece groups and board-specific sets
VARIANTS=(
    "sample"
    "standard"
    "compound"
    "jetan"
    "all"
)

# Styles tuned for chess pieces at small sizes
RECOMMENDED_STYLES=(
    "flat"
    "geometric"
    "staunton"
)

# ── Style override: WeirdChess-specific style preset ──────────────────────
# The "weird" style is the primary target — organic, quirky, hand-carved feel.
# We add it as a custom style the imagen agent doesn't know about natively,
# by appending it to the prompt suffix when detected.
WEIRDCHESS_STYLE_DESC="quirky organic silhouette, slightly asymmetric, hand-carved wood feel, flat design with clean edges, warm tones, playful but recognizable"

# ── Shared design context ─────────────────────────────────────────────────
# This gets appended to EVERY piece prompt to maintain consistency.
PROJECT_PROMPT_SUFFIX="chess piece silhouette, flat design, clean edges suitable for SVG conversion, single piece centered on plain white background, square frame, piece fills approximately 80 percent of height, no text, no board, no background elements, 2px visible outline for contrast"

# ── Color support: white and black piece variants ─────────────────────────
SUPPORTS_COLORS=true
DEFINED_COLORS="white black"
DEFAULT_COLORS="both"

get_color_desc() {
    local color="$1"
    case "$color" in
        white) echo "warm cream/off-white piece (fill color #F5E6D3) with dark charcoal outline (#2D3542)" ;;
        black) echo "dark charcoal piece (fill color #1A1A1A) with warm cream outline (#F5E6D3)" ;;
        *)     echo "$color colored" ;;
    esac
}

# ── Sample set: 3 pieces for style exploration ────────────────────────────
# Pawn (simplest), Queen (most ornate), Knight (most distinctive)
SAMPLE_ITEMS=(
    "pawn|Pawn|Chess pawn piece, simple rounded top, smallest and humblest piece, organic curved base, minimal detail"
    "queen|Queen|Chess queen piece, multi-pointed crown coronet clearly visible at top, commanding regal presence, second tallest piece, expressive personality"
    "knight|Knight|Chess knight piece, horse head in profile facing left, expressive characterful eye, visible flowing mane, organic serpentine neck curves"
)

# ── Standard pieces (6) ──────────────────────────────────────────────────
STANDARD_ITEMS=(
    "king|King|Chess king piece, clear cross on top visible even at small sizes, tallest piece in the set, organic bulbous body shape with personality, slight asymmetry"
    "queen|Queen|Chess queen piece, multi-pointed crown coronet clearly visible at top, commanding regal presence, second tallest piece, expressive attitude with organic curves"
    "rook|Rook|Chess rook piece, flat top with clear rectangular crenellations castle battlements, stocky solid proportions, interesting organic body curves below the geometric battlement top"
    "bishop|Bishop|Chess bishop piece, pointed mitre top with diagonal slit or notch, slight lean suggesting diagonal movement, taller and thinner than rook, organic flowing body"
    "knight|Knight|Chess knight piece, horse head in profile facing left, expressive characterful eye, visible flowing mane, organic serpentine neck curves, most distinctive piece"
    "pawn|Pawn|Chess pawn piece, simple rounded top, smallest and humblest piece, organic curved base, minimal detail, subtle asymmetry for character"
)

# ── Compound / Fairy pieces (7) ──────────────────────────────────────────
# These combine standard piece move sets — silhouettes should hint at the combination
COMPOUND_ITEMS=(
    "amazon|Amazon|Chess amazon fairy piece, combines queen and knight, crown with horse-ear elements, powerful commanding silhouette, ornate but clear"
    "cardinal|Cardinal|Chess cardinal fairy piece, combines bishop and knight, pointed mitre top merging with horse-head profile elements, elegant diagonal energy"
    "marshal|Marshal|Chess marshal fairy piece, combines rook and knight, crenellated battlement top with horse-head profile elements, military authority"
    "champion|Champion|Chess champion fairy piece, king-like single-step movement plus long leaps, shield or medallion shape, sturdy defensive silhouette"
    "wizard|Wizard|Chess wizard fairy piece, diagonal one-step plus three-square leaps, pointed wizard hat or star-topped silhouette, mystical character"
    "falcon|Falcon|Chess falcon fairy piece, forward diagonal slider, wing or bird silhouette in profile, sleek aerodynamic shape suggesting swift diagonal movement"
    "hunter|Hunter|Chess hunter fairy piece, forward rook plus backward bishop movement, arrow or directional shape, asymmetric front-back design suggesting dual nature"
)

# ── Jetan / Barsoomian pieces (8) ────────────────────────────────────────
# Martian chess from Edgar Rice Burroughs — alien sci-fi aesthetic
JETAN_ITEMS=(
    "chief|Chief|Jetan Barsoomian chess chief piece, alien warrior king, helmet or command insignia, most important piece, sci-fi Martian aesthetic, angular alien authority"
    "princess|Princess|Jetan Barsoomian chess princess piece, alien royalty, tiara or Barsoomian ornamental headpiece, elegant but otherworldly, most powerful piece"
    "flier|Flier|Jetan Barsoomian chess flier piece, Martian airship or alien wing shape, suggests aerial movement, sleek futuristic flying vessel silhouette"
    "dwar|Dwar|Jetan Barsoomian chess dwar piece, warrior captain with alien weapon, strong military bearing, angular aggressive silhouette"
    "padwar|Padwar|Jetan Barsoomian chess padwar piece, officer rank insignia, lieutenant grade, smaller than dwar but still authoritative, alien military rank marking"
    "warrior|Warrior|Jetan Barsoomian chess warrior piece, alien foot soldier with Martian sword or spear silhouette, functional combat-ready shape"
    "thoat|Thoat|Jetan Barsoomian chess thoat piece, alien cavalry mount, eight-legged Martian beast of burden, distinctive multi-limbed creature silhouette"
    "panthan|Panthan|Jetan Barsoomian chess panthan piece, Martian mercenary pawn, simplest piece, humble wandering soldier, minimal alien detail"
)

# ── Item routing ─────────────────────────────────────────────────────────
get_items_for_variant() {
    local variant="$1"

    case "$variant" in
        sample)
            printf '%s\n' "${SAMPLE_ITEMS[@]}"
            ;;
        standard)
            printf '%s\n' "${STANDARD_ITEMS[@]}"
            ;;
        compound)
            printf '%s\n' "${COMPOUND_ITEMS[@]}"
            ;;
        jetan)
            printf '%s\n' "${JETAN_ITEMS[@]}"
            ;;
        all)
            printf '%s\n' "${STANDARD_ITEMS[@]}" "${COMPOUND_ITEMS[@]}" "${JETAN_ITEMS[@]}"
            ;;
        *)
            return 1
            ;;
    esac
}

# ── Per-variant style recommendations ────────────────────────────────────
get_variant_styles() {
    local variant="$1"

    case "$variant" in
        sample)
            # Test the core styles that matter most
            echo "flat geometric staunton"
            ;;
        standard)
            echo "flat geometric staunton"
            ;;
        compound)
            # Fairy pieces benefit from slightly more expressive styles
            echo "flat geometric watercolor"
            ;;
        jetan)
            # Sci-fi aesthetic
            echo "flat geometric neon"
            ;;
        *)
            echo "${RECOMMENDED_STYLES[*]}"
            ;;
    esac
}
