---
name: Clínics
colors:
  surface: '#f8f9ff'
  surface-dim: '#cbdbf5'
  surface-bright: '#f8f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#eff4ff'
  surface-container: '#e5eeff'
  surface-container-high: '#dce9ff'
  surface-container-highest: '#d3e4fe'
  on-surface: '#0b1c30'
  on-surface-variant: '#3f4850'
  inverse-surface: '#213145'
  inverse-on-surface: '#eaf1ff'
  outline: '#707881'
  outline-variant: '#bfc7d2'
  surface-tint: '#006398'
  primary: '#006194'
  on-primary: '#ffffff'
  primary-container: '#007bb9'
  on-primary-container: '#fdfcff'
  inverse-primary: '#93ccff'
  secondary: '#006c49'
  on-secondary: '#ffffff'
  secondary-container: '#6cf8bb'
  on-secondary-container: '#00714d'
  tertiary: '#00628d'
  on-tertiary: '#ffffff'
  tertiary-container: '#007cb1'
  on-tertiary-container: '#fcfcff'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#cce5ff'
  primary-fixed-dim: '#93ccff'
  on-primary-fixed: '#001d31'
  on-primary-fixed-variant: '#004b73'
  secondary-fixed: '#6ffbbe'
  secondary-fixed-dim: '#4edea3'
  on-secondary-fixed: '#002113'
  on-secondary-fixed-variant: '#005236'
  tertiary-fixed: '#c9e6ff'
  tertiary-fixed-dim: '#89ceff'
  on-tertiary-fixed: '#001e2f'
  on-tertiary-fixed-variant: '#004c6e'
  background: '#f8f9ff'
  on-background: '#0b1c30'
  surface-variant: '#d3e4fe'
typography:
  display-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: -0.015em
  headline-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
    letterSpacing: -0.01em
  headline-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  body-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
  price-display:
    fontFamily: Plus Jakarta Sans
    fontSize: 22px
    fontWeight: '700'
    lineHeight: 28px
    letterSpacing: -0.02em
  label-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
  label-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.01em
  label-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 11px
    fontWeight: '600'
    lineHeight: 14px
    letterSpacing: 0.02em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 0.75rem
  gutter-tablet: 1rem
  gutter-desktop: 1.5rem
  margin: 1rem
  margin-tablet: 1.5rem
  margin-desktop: 2rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 0.75rem
  space-lg: 1rem
  space-xl: 1.5rem
---

## Brand & Style

This design system delivers a clinical, reassuring, and effortless price-comparison experience tailored for everyday residents seeking medical exams, lab work, and specialty consultations in Surubim. The interface balances high utility with compassionate clarity, mitigating the stress and opacity traditionally associated with healthcare costs.

The design movement is **Modern Minimalist with Soft Humanist Utility**. It avoids sterile hospital austerity by pairing structural precision with pillowy, protective rounded containers, generous touch targets, and high-legibility typographic hierarchies. Whitespace functions as a cognitive decompression buffer, guiding patients directly to transparent pricing, exam availability, and direct clinic scheduling via WhatsApp.

## Colors

The color system is rooted in high-trust clinical blues, softened by clean atmospheric tints and grounded by an actionable communication green.

- **Primary (`#0284C7`) & Sky Accent (`#0EA5E9`)**: Anchors critical navigation, active filters, informational badges, and authoritative healthcare data points.
- **Atmospheric Blue (`#E0F2FE`)**: Used exclusively for soft container fills, selected states, and badge backgrounds to eliminate stark contrast while retaining structure.
- **Action Emerald (`#10B981`) & WhatsApp Direct (`#25D366`)**: Reserved strictly for high-conversion booking workflows, immediate contact triggers, and real-time clinic confirmation statuses.
- **Neutrals**:
  - **Canvas / Off-White (`#F8FAFC`)**: Base surface background, reducing eye strain in direct daylight.
  - **Surface White (`#FFFFFF`)**: Card surfaces, bottom sheets, and elevated comparison blocks.
  - **Slate Secondary (`#64748B`)**: Body text, exam prerequisites, metadata, and inactive states.
  - **Slate Deep (`#0F172A`)**: Primary headings, numerical price totals, and maximum-contrast focal elements.

## Typography

The typographic hierarchy pairs **Plus Jakarta Sans** for display, structural titles, and numerical prices with **Inter** for descriptions, exam preparation guidelines, and metadata.

- Plus Jakarta Sans infuses warmth and modern geometric authority, preventing financial and medical figures from feeling intimidating.
- Inter guarantees ultra-clear legibility at small scale, particularly for dense health directives (e.g., fasting hours, preparation details, clinic address specs).
- Numeric figures in prices (`price-display`) must always render with tabular lining figures (`font-variant-numeric: tabular-nums`) to ensure fast scanning and clean vertical alignment across comparison cards.

## Layout & Spacing

The layout is built for a thumb-first, vertically scrolling mobile application, with responsive scaling across tablet breakpoints.

- **Mobile (Default, up to 640px)**: Single-column flow with a strict `1rem` outer safe margin. Bottom sheets and anchored conversion actions take priority. Search bars and category filter rails remain docked or sticky below the primary top bar.
- **Tablet (641px - 1024px)**: 2-column comparison layout with `1.5rem` margins and gutters, enabling direct side-by-side clinic evaluation without modal context switching.
- **Desktop / Web Preview (1025px+)**: Max-width container restricted to 720px for dedicated mobile-app preview parity or centered 3-column table view for deep administrative comparison.

Vertical rhythms prioritize scan speed: tightly bind related metadata with `space-xs` and `space-sm`, reserve `space-md` for internal card padding, and demarcate distinct clinic entities with `space-lg`.

## Elevation & Depth

Visual hierarchy is communicated through **ambient cyan-slate tinted shadows** and **subtle surface borders**, completely avoiding heavy drop shadows.

- **Level 0 (Flat Canvas)**: Hex `#F8FAFC`. Background surfaces with zero elevation.
- **Level 1 (Card & List Tier)**: Hex `#FFFFFF` with a 1px solid border in `#E2E8F0` and an ambient shadow: `0 1px 3px rgba(15, 23, 42, 0.04), 0 4px 12px rgba(14, 165, 233, 0.03)`.
- **Level 2 (Interactive Floating / Active Selection)**: Hex `#FFFFFF` with a 1px solid border in `#BAE6FD` and an elevated shadow: `0 8px 24px rgba(2, 132, 199, 0.08)`.
- **Level 3 (Sticky CTAs & Bottom Sheets)**: Hex `#FFFFFF` with top border `1px solid rgba(226, 232, 240, 0.8)` and directional upward shadow: `0 -4px 20px rgba(15, 23, 42, 0.06)`.

## Shapes

The design uses an inviting, modern geometric shape hierarchy that centers around `rounded-2xl` for primary containers.

- **Cards & Clinic Result Containers**: Fixed at `rounded-2xl` (1rem / 16px) to soften density and make medical data approachable.
- **Input Fields & Search Surfaces**: Standardized at `rounded-xl` (0.75rem / 12px) for a balanced, tactile field presence.
- **Filter Chips & Status Tags**: Fully pill-shaped (`rounded-full`) to clearly signal micro-actions and non-card interaction patterns.
- **Buttons (Action & Primary)**: `rounded-xl` (0.75rem / 12px) for structured buttons; full pill (`rounded-full`) exclusively for floating quick-action WhatsApp booking triggers.

## Components

### Buttons
- **Primary CTA**: `#0284C7` background, white text (`label-lg`), height 48px, `rounded-xl`. Active state shifts to `#0369A1`.
- **WhatsApp Action Button**: `#25D366` background, `#FFFFFF` text (`label-lg`), paired with an unbordered WhatsApp / Message icon. Used as primary conversion on clinic cards. Includes a subtle hover/press state `#1EA952`.
- **Secondary / Ghost**: Outline `#BAE6FD`, text `#0284C7`, background `#E0F2FE` at 40% opacity.

### Clinic & Exam Comparison Cards
- **Base Style**: `#FFFFFF` background, `rounded-2xl`, 1px border in `#E2E8F0`, padding `1rem`.
- **Header**: Clinic name in `headline-sm` with verified checkmark badge (`#0EA5E9`), location proximity badge (`space-xs` gap).
- **Price Block**: Accentuated container in `#F0F9FF` with `price-display` in `#0F172A`, highlighting payment method (e.g., "À vista" or "Cartão").
- **Footer**: Side-by-side layout featuring exam availability tag and high-prominence WhatsApp direct schedule trigger.

### Filter & Category Chips
- **Inactive**: `#F1F5F9` background, `#64748B` text (`label-md`), `rounded-full`, padding `6px 14px`.
- **Active**: `#E0F2FE` background, `#0284C7` text, 1px solid `#0EA5E9`, `label-md` font weight.

### Search & Form Fields
- **Search Header**: Height 52px, `#FFFFFF` background, 1px solid `#CBD5E1`, `rounded-xl`, left-aligned search icon in `#64748B`. Placeholder text in `#94A3B8`. Active focus triggers 2px ring in `#0EA5E9` with zero offset blur.

### Lists & Comparison Items
- Clean divided rows using `1px solid #F1F5F9`. Exam item titles in `body-md` bold, sub-requirements (e.g., "Jejum 8h", "Resultado em 24h") in `body-sm` (`#64748B`).

### Status Badges
- **Fast Turnaround / Immediate**: `#ECFDF5` background, `#059669` text, `rounded-md`, padding `2px 8px`.
- **Requires Preparation**: `#FFFBEB` background, `#D97706` text.
