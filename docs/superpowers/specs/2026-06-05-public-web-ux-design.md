# Public Web UX Design Consolidation

> Date: 2026-06-05
> Status: Design consolidation for review
> Target product area: AstroAI public web MVP

## Meeting Purpose

This document consolidates design decisions already discussed across the AstroAI redevelopment, the existing Flutter demo, the current Next.js public horoscope page, and external reference sites.

The goal is not to create a decorative inspiration board. The goal is to define a practical page-level design direction that can guide the next frontend implementation PRs.

## Expert Meeting Conclusion

AstroAI should not become a traditional horoscope portal and should not become a pure experimental art site. The right direction is a daily astrology product that feels personal, luminous, chart-grounded, and calm.

The public experience should be immediately useful:

1. Choose a zodiac sign or enter a birth date.
2. Pick or land on a date.
3. Read the selected date's daily guidance, matching weekly guidance, current month, and year overview.
4. Register only when the user wants saved natal chart, AI personalization, memory, or history.

The visual system should support trust and repeat use. Immersive or experimental effects may add delight, but they must never make reading, sign selection, date selection, or focus switching harder.

## Product Role of Public Web

The public web layer has three jobs:

- Acquisition: SEO pages and shareable public horoscope/sign content.
- Utility: one-request static horoscope reading without registration.
- Conversion: invite users into saved natal chart and AI personalization only after the free static layer proves value.

The public web should feel like a real product surface, not a marketing-only landing page and not a backend tester.

## External References

### Horoscope.com

Use for:

- Clear astrology content taxonomy.
- Familiar sign entry patterns.
- Obvious daily, love, career, money, health, tarot, and birth chart pathways.

Do not copy:

- Traditional portal density.
- Generic ad-supported content feel.
- Plain directory-like page composition.

### Makemepulse

Use for:

- High craft.
- Light interactive motion.
- Immersive polish that still feels purposeful.

Do not copy:

- Full experimental navigation as the main reading path.
- Heavy animation that delays horoscope access.

### Hoverstat.es

Use for:

- Small hover and scroll interactions.
- Alternative visual treatments for focus tabs, zodiac grouping, or reading transitions.

Do not copy:

- Novel interaction as the primary interface.
- Anything that makes mobile use unclear.

### Resn, Warhol Arts, Major Lazer, Valentime

Use for:

- Strong atmosphere.
- Layered visual memory.
- Editorial confidence.
- Occasional cinematic section transitions.

Do not copy:

- Exhibition-style navigation.
- Long intro sequences.
- Full-screen effects before the user can read.

### Inflatable

Use for:

- Soft, tactile 3D inspiration for zodiac symbols, planets, or chart reveal assets.

Do not copy:

- Toy-like full-page visual language.
- 3D as the dominant UI layer.

## Legacy Flutter Decisions

Keep:

- White fixed header with AstroAI branding.
- Blue-to-pink gradient brand mark.
- Brand palette:
  - Blue `#4097FF`
  - Pink `#FF92A2`
  - Light blue `#A5E5F9`
  - Purple `#8985CF`
  - Light pink `#FFF3F8`
- Poppins/Inter-style readable typography from the current Flutter theme.
- Occasional decorative display heading for high-emotion moments, such as chart reveal or hero-level page titles.
- Daily insights information structure:
  - greeting or context
  - date
  - sign
  - guidance cards
  - lucky numbers
  - lucky colors
- Natal chart wheel and reveal direction for registered-user features.
- Rounded but not overly soft cards for repeated reading content.

Change:

- Do not keep legacy routes or legacy API calls.
- Do not keep ASMR, celebrity matching, and feature sprawl in MVP navigation.
- Do not use full-page gradients as the default surface.
- Do not rely on corrupted emoji/zodiac glyphs.
- Do not make every content section a floating card.
- Do not preserve the current rough Next.js page styling as production design.

## Current Next.js Page Assessment

Current strengths:

- It calls the canonical `/api/v1` bundle and sun-sign routes.
- It supports sign selection, birth date, view date, focus tabs, daily reading, weekly reading, month list, and year overview.
- It avoids the preview page's manual API base field and raw JSON.

Current problems:

- The hero area still feels like an early scaffold.
- The UI is too plain and form-heavy.
- The "backend connection needed" state exposes implementation detail.
- The page title is too generic and single-page-test-like.
- Monthly content is a long list without a stronger hierarchy.
- The main reading does not yet feel like the emotional center of the page.
- The visual system does not yet express "chart-grounded AI companion."

## Design North Star

AstroAI public web should feel like:

- A calm daily ritual.
- A luminous personal reading room.
- A practical astrology tool.
- A bridge from free static guidance to saved natal chart and AI personalization.

Design adjectives:

- Mystical
- Calm
- Editorial
- Personal
- Luminous
- Chart-grounded
- Trustworthy

Avoid:

- Generic horoscope portal
- Marketing-only hero
- Dark sci-fi dashboard
- Purple-only mysticism
- Toy-like 3D
- Experimental navigation maze
- Backend testing surface

## Page Map

### Public MVP

- `/`
  - Public home or direct app entry.
  - Should route users quickly into sign/date reading.
- `/horoscope`
  - Primary public free horoscope experience.
  - Sign picker and birth-date-to-Sun-sign entry.
- `/horoscope/[sign]`
  - SEO daily sign page.
  - Same core experience preloaded for a sign.
- `/horoscope/[sign]/weekly`
  - SEO weekly page.
  - Date-driven weekly context; not a long week archive.
- `/horoscope/[sign]/monthly`
  - SEO monthly page.
  - Month summary and internal links.
- `/horoscope/[sign]/yearly`
  - SEO yearly page.
- `/zodiac/[sign]`
  - Public sign profile.
- `/compatibility/[signA]/[signB]`
  - Public sign-pair compatibility.

### Registered MVP

- `/signup`
- `/login`
- `/onboarding`
- `/dashboard`
- `/chart`
- `/chat`
- `/settings`

Mood and tarot remain future or later MVP unless required by product metrics.

## `/horoscope` Wireframe

### Header

Desktop:

- Left: gradient AstroAI mark + AstroAI wordmark.
- Center or right nav:
  - Horoscope
  - Zodiac
  - Compatibility
  - Sign in
  - Create chart

Mobile:

- Left brand.
- Right menu button.
- Menu opens simple route list.

Rules:

- Header surface is white or very light.
- Header should not use heavy shadows.
- Header should remain stable during reading and date changes.

### First View

Purpose: start reading immediately.

Structure:

1. Small eyebrow: "Free static guidance".
2. Title: "Your Gemini horoscope" or "Choose your sign".
3. Supporting copy: one sentence explaining free static guidance.
4. Control rail:
   - Sign selector.
   - Birth date input.
   - View date input.
   - Primary action only when needed.
5. Main reading preview:
   - Daily reading for selected focus and date.
   - Lucky numbers and lucky color.
   - Small note: "For a saved natal chart and AI personalization, create a profile."

The reading should be the visual center, not the form.

### Focus Tabs

Use a segmented control or pill tabs:

- General
- Love
- Career
- Money
- Wellness
- Social
- Family
- Study
- Mood

Rules:

- No debug labels.
- No provider names.
- Active focus should visibly change the daily, weekly, monthly, and yearly reading content.
- Tabs must wrap cleanly on mobile.

### Date-Driven Reading Area

The primary content order:

1. Daily reading.
2. Matching weekly reading.
3. Current month reading.
4. Year overview.

Daily card:

- Date.
- Sign.
- Focus.
- Title.
- Summary.
- Body.
- Lucky numbers.
- Lucky color.

Weekly card:

- Week range, not "This week" only.
- Derived from selected date and `period_end_date`.
- Visually secondary to daily.

Month/year:

- Compact summaries.
- Month can include a "browse months" affordance later, but long month lists should not dominate the first view.

### Conversion Area

Conversion prompt should be contextual:

- "Save your chart for personalized AI guidance."
- "Create your natal chart."
- "Ask the AI Astrologer with chart context."

Do not gate public horoscope reads behind registration.

## Visual System

### Color

Use the Flutter palette as brand accents:

- Primary action: `#4097FF`
- Warm accent: `#FF92A2`
- Soft atmospheric accent: `#A5E5F9`
- Secondary mystical accent: `#8985CF`
- Page blush: `#FFF3F8`

Base surfaces:

- White.
- Very light blush.
- Very light blue.
- Dark ink text.

Rules:

- No full-page purple-only palette.
- Gradients should appear in the brand mark, selected accents, small panels, or chart reveal moments.
- Main text areas should have high contrast.

### Typography

Use:

- Practical sans-serif body: Inter or equivalent.
- Warm geometric headings: Poppins or equivalent.
- Optional decorative display type only for special brand moments.

Rules:

- Do not use decorative type for dense horoscope body copy.
- No negative letter spacing in compact UI.
- Do not scale font size directly with viewport width.

### Shape and Layout

- Reading cards: 8px to 12px radius.
- Controls: 8px radius.
- Brand mark can be circular or softly rounded.
- Avoid cards inside cards.
- Use full-width bands for page sections.
- Use cards only for individual readings, modals, repeated sign/focus items, and contained tools.

### Motion

Allowed:

- Subtle focus tab transitions.
- Soft reveal when changing date or focus.
- Gentle chart/star field background motion in future chart reveal.
- Hover glow on sign/focus controls.

Not allowed:

- Intro animations that block reading.
- Heavy scroll hijacking.
- Motion required to understand navigation.
- Continuous distracting background effects behind body text.

## Content and Tone

Tone:

- Warm.
- Practical.
- Reflective.
- Not alarmist.
- Not cryptic for the sake of mystery.

Public static copy should be labeled by experience, not by implementation.

Do not use:

- "Codex"
- "Gemini"
- "provider"
- "bundle"
- "backend"
- "static seed"
- "debug"

User-facing alternatives:

- "Free guidance"
- "Today's reading"
- "This week's pattern"
- "Month ahead"
- "Year overview"

## Responsive Rules

Mobile:

- Header should be one line.
- Sign, birth date, and view date controls stack vertically.
- Focus tabs wrap or become horizontally scrollable.
- Daily reading appears before weekly/month/year.
- No text overlap or clipped buttons.

Tablet:

- Controls may sit in a two-column panel.
- Reading cards can use a two-column layout after daily.

Desktop:

- First view may use a two-column layout:
  - Left: reading and context.
  - Right: controls and current sign/date state.
- Daily reading remains the largest content object.

## Implementation Acceptance Criteria

The next production public horoscope UI PR should satisfy:

- `/horoscope` does not show API base URL, manual load buttons, raw JSON, provider names, or debug language.
- Selecting a sign loads one sign/year bundle.
- Entering a birth date calls `/utils/sun-sign`, selects the sign, then uses the same bundle behavior.
- Changing view date updates daily and matching weekly from the loaded bundle.
- Focus tabs update all visible reading panels.
- Weekly content is date-driven, not a long list.
- Month/year content is available but does not bury the daily reading.
- Empty/loading/error states are polished and user-facing.
- Mobile and desktop layouts have no overlapping or clipped text.
- The page uses AstroAI brand accents without becoming a purple gradient page.

## Future Registered Design Direction

Natal chart onboarding:

- Calm multi-step flow.
- Birth date, time, birthplace, unknown-time option.
- Consent/privacy note.
- Chart reveal with wheel visual.

Dashboard:

- Today's personalized guidance.
- Natal chart summary.
- AI Astrologer entry.
- Quota state.
- Suggested prompts.

AI Astrologer:

- Chat should feel like a companion with chart context.
- Backend owns prompt construction.
- Frontend must not imply memory that is not yet stored.

## Design Decisions

- Public static horoscope comes before registered personalization in the user journey.
- Reading content is the hero.
- Experimental inspiration is used as polish, not structure.
- Flutter visual direction is input, not a constraint.
- Horoscope.com informs taxonomy, not visual identity.
- The public page must be simple enough to use daily.

## Open Questions

- Should `/` immediately show the horoscope entry experience, or a short brand gateway with the same controls above the fold?
- Should zodiac sign pages use 3D/illustrated sign assets in MVP, or simple typographic/icon treatments first?
- Should monthly browsing be included in the first redesign PR, or kept compact until sign/profile SEO pages are added?
