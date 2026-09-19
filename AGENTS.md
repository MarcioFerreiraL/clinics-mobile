# 🤖 AI AGENT OPERATIONAL GUIDE & REPOSITORY CONTEXT (`AGENTS.md`)

This document is the **primary instruction manual and context guide** for AI Coding Agents working on the **Clinics** repository. Any AI agent modifying, generating, or debugging code in this workspace MUST follow the rules and guidelines detailed herein.

---

## 1. Repository Structure Overview

```
clinics-mobile/
├── AGENTS.md                   # Primary AI Agent Context & Guidelines (THIS FILE)
├── MVP_specification.md        # Full Product Requirement Document & Core Entities
├── docs/                       # Technical & Architectural Documentation
│   ├── ARCHITECTURE.md         # Detailed System Architecture (Flutter + Go)
│   ├── API_SPECIFICATION.md    # REST API Endpoints & Data Contracts
│   ├── DESIGN_SYSTEM.md       # Color tokens, typography, elevation, and UI shapes
│   └── prototype/pages/        # HTML/CSS UI prototypes and DESIGN.md spec
└── clinics/                    # Flutter Mobile Application Project Root
    ├── lib/
    │   ├── core/               # Shared utilities, theme, router, network client
    │   └── features/           # Feature-First Clean Architecture modules
    │       ├── auth/           # Login, Register, User State
    │       ├── search/         # Home search, category filters, exam list
    │       ├── exam/           # Exam details & WhatsApp redirection
    │       ├── clinic/         # Public clinic profile & management dashboard
    │       └── profile/        # Patient profile & drawer navigation
    ├── pubspec.yaml
    └── test/
```

> **Note on Backend Location:**  
> The Go backend will be developed in a `backend/` root directory at the top level of this repository.

---

## 2. Mandatory Coding Conventions & Architecture Rules

### 2.1. Code Language & Conventions
- **Code Identifiers (Variables, Functions, Classes):** 100% English.
  - Flutter: `camelCase` for variables/methods, `PascalCase` for classes/widgets, `snake_case` for filenames.
  - Golang: `camelCase` for unexported, `PascalCase` for exported, `snake_case` for JSON tags & database column names.
- **User-Facing Strings:** 100% Portuguese (pt-BR) (e.g., "Buscar exames", "Agendar via WhatsApp").

### 2.2. Frontend Architecture (Flutter)
- **Structure:** Feature-First + Clean Architecture.
- **Layers within each Feature (`lib/features/<feature_name>/`):**
  - `domain/`: Entities, Value Objects, Use Case Interfaces / Repositories.
  - `data/`: Data Sources (Remote API/Local), DTOs (Models with `fromJson`/`toJson`), Repository Implementations.
  - `presentation/`: Riverpod Providers, UI Screens, Reusable Widgets.
- **State Management:** `flutter_riverpod` (Notifier / AsyncNotifier).
- **Navigation:** `go_router` with declarative route declarations and shell routing for bottom navigation / drawer.

### 2.3. Backend Architecture (Golang)
- **Framework:** `Fiber` (v2/v3).
- **ORM:** `GORM` with PostgreSQL driver (`gorm.io/driver/postgres`).
- **Auth & JWT:** `github.com/golang-jwt/jwt/v5`.
- **Directory Layout (`backend/`):**
  - `cmd/server/main.go`: Application entrypoint.
  - `internal/api/handlers/`: Fiber HTTP route handlers.
  - `internal/api/middleware/`: JWT verification, CORS, Logging, and **IDOR Ownership Middleware**.
  - `internal/core/domain/`: Go structs for entities (`User`, `Clinic`, `Exam`).
  - `internal/core/ports/`: Interfaces for repositories and services.
  - `internal/infrastructure/repository/`: GORM database queries.

---

## 3. Strict Security & Business Rules

1. **IDOR Prevention (Ownership Validation):**
   - NEVER create a clinic exam write endpoint (`POST/PUT/DELETE /api/clinics/:id/exams/...`) without attaching the Ownership Middleware.
   - Middleware MUST check: `authenticated_user_id == clinic.owner_user_id`. Return HTTP 403 Forbidden if mismatched.
2. **Password Hashing:**
   - Always hash passwords using `golang.org/x/crypto/bcrypt` with a cost factor of at least 10.
3. **JWT Claims:**
   - Token payload MUST contain `user_id`, `role` (`patient` | `clinic_manager`), and `exp`.

---

## 4. Design System & UI Constraints

All Flutter UI implementations MUST strictly comply with tokens defined in [`docs/DESIGN_SYSTEM.md`](file:///home/ogmacin/Repositorio/clinics-mobile/docs/DESIGN_SYSTEM.md):

- **Primary Colors:**
  - `Primary`: `#0284C7` (Buttons, active tabs, main accents)
  - `Atmospheric Blue`: `#E0F2FE` (Badge backgrounds, selected containers)
  - `Action Emerald`: `#10B981` / `WhatsApp Green`: `#25D366` (Booking CTAs)
  - `Surface Canvas`: `#F8FAFC`
- **Typography:**
  - Display/Headings/Prices: `Plus Jakarta Sans`
  - Body/Metadata: `Inter`
  - Prices format: Tabular lining figures (`price-display` style)
- **Shapes & Border Radii:**
  - Cards & Clinic Containers: `16px` (`rounded-2xl`)
  - Input Fields & Buttons: `12px` (`rounded-xl`)
  - Filter Chips & Status Badges: Full Pill (`rounded-full`)

---

## 5. Helpful References & Documentation Files

Before implementing any module, review these docs in order:
1. [`MVP_specification.md`](file:///home/ogmacin/Repositorio/clinics-mobile/MVP_specification.md) — Product requirement document & entity schemas.
2. [`docs/ARCHITECTURE.md`](file:///home/ogmacin/Repositorio/clinics-mobile/docs/ARCHITECTURE.md) — System architecture diagram & layers.
3. [`docs/API_SPECIFICATION.md`](file:///home/ogmacin/Repositorio/clinics-mobile/docs/API_SPECIFICATION.md) — Full REST API documentation.
4. [`docs/DESIGN_SYSTEM.md`](file:///home/ogmacin/Repositorio/clinics-mobile/docs/DESIGN_SYSTEM.md) — Design tokens & Flutter theme implementation.
