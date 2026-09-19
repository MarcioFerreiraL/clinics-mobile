# 🎨 Design System Specifications & UI Tokens (`DESIGN_SYSTEM.md`)

This document defines the **visual identity, theme tokens, typography, and component specs** for Clinics Mobile. All Flutter UI widgets MUST strictly consume these tokens.

---

## 1. Color Palette Tokens

| Token Name | Hex Code | Purpose / Usage in Flutter |
|---|---|---|
| **Primary** | `#0284C7` | Primary buttons, active tab indicators, key focus highlights |
| **Primary Container / Dark** | `#006194` | Darker blue for active/pressed button states |
| **Atmospheric Blue** | `#E0F2FE` | Selected card backgrounds, soft container fills, badge backgrounds |
| **Action Emerald** | `#10B981` | Positive tags, turnaround badges |
| **WhatsApp Direct** | `#25D366` | WhatsApp conversion CTAs strictly |
| **Surface Canvas** | `#F8FAFC` | Page background (`scaffoldBackgroundColor`) |
| **Surface White** | `#FFFFFF` | Card background, bottom sheet background |
| **Slate Secondary** | `#64748B` | Subtitles, preparation metadata, inactive icons |
| **Slate Deep** | `#0F172A` | Headings, primary text, price numbers |
| **Border Outline** | `#E2E8F0` | Card borders, dividers |

---

## 2. Typography Rules

- **Display, Headings, and Prices Font:** `Plus Jakarta Sans`
- **Body, Metadata, and Preparation Text Font:** `Inter`

| Style Name | Font Family | Size | Weight | Line Height | Usage |
|---|---|---|---|---|---|
| `display-lg` | Plus Jakarta Sans | 32px | Bold (700) | 40px | Onboarding / Main banners |
| `headline-lg` | Plus Jakarta Sans | 24px | SemiBold (600) | 32px | Main screen titles |
| `headline-sm` | Plus Jakarta Sans | 18px | SemiBold (600) | 24px | Clinic names, section headers |
| `price-display` | Plus Jakarta Sans | 22px | Bold (700) | 28px | Exam price figures |
| `body-lg` | Inter | 16px | Regular (400) | 24px | Main body text |
| `body-md` | Inter | 14px | Regular (400) | 20px | Standard descriptions |
| `body-sm` | Inter | 12px | Regular (400) | 16px | Preparation instructions (e.g. Jejum 8h) |
| `label-md` | Plus Jakarta Sans | 12px | SemiBold (600) | 16px | Category chips, button labels |

---

## 3. Shape & Shadow Specifications

### Radii
- **Cards & Clinic Result Containers:** `16px` (`BorderRadius.circular(16)`)
- **Inputs & Standard Buttons:** `12px` (`BorderRadius.circular(12)`)
- **Filter Chips & Status Tags:** Pill shape (`BorderRadius.circular(999)`)

### Elevation & Shadows
- **Card Shadow (Level 1):**
  - Offset: `(0, 1)`, Blur: `3px`, Color: `Color.rgba(15, 23, 42, 0.04)`
  - Ambient: `(0, 4)`, Blur: `12px`, Color: `Color.rgba(14, 165, 233, 0.03)`
- **Sticky CTA Shadow (Level 3):**
  - Top border: `1px solid #E2E8F0`
  - Shadow: Offset `(0, -4)`, Blur `20px`, Color `Color.rgba(15, 23, 42, 0.06)`

---

## 4. Flutter Theme Code Reference (`app_theme.dart`)

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary = Color(0xFF0284C7);
  static const Color atmosphericBlue = Color(0xFFE0F2FE);
  static const Color whatsAppGreen = Color(0xFF25D366);
  static const Color actionEmerald = Color(0xFF10B981);
  static const Color surfaceCanvas = Color(0xFFF8FAFC);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color slateSecondary = Color(0xFF64748B);
  static const Color slateDeep = Color(0xFF0F172A);
  static const Color borderOutline = Color(0xFFE2E8F0);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: surfaceCanvas,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: whatsAppGreen,
        surface: surfaceWhite,
        onSurface: slateDeep,
        onSurfaceVariant: slateSecondary,
      ),
      textTheme: TextTheme(
        headlineLarge: GoogleFonts.plusJakartaSans(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: slateDeep,
        ),
        headlineSmall: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: slateDeep,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: slateDeep,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: slateSecondary,
        ),
        labelMedium: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: primary,
        ),
      ),
      cardTheme: CardTheme(
        color: surfaceWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderOutline, width: 1),
        ),
      ),
    );
  }
}
```
