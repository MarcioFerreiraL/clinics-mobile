# 🚀 MVP Product Specification Document (PRD)

**Project Name:** Medical Services Price Comparison App (Surubim - PE) — *Clinics*  
**Target Architecture:** Flutter (Mobile App) + Go (REST Backend)  
**Goal:** Deliver a lightweight, ultra-fast, and simple mobile application to aggregate and compare local medical exam/service prices in Surubim-PE, redirecting users directly to clinics via WhatsApp.

---

## 1. High-Level System Overview & Tech Stack

* **Frontend:** Flutter (Mobile - iOS/Android)
  * Location: `clinics/`
  * Architecture: Clean Architecture + Feature-First structure
  * State Management: `flutter_riverpod`
  * Routing: `go_router`
  * Integrations: `url_launcher` (WhatsApp redirect), `speech_to_text` (Voice Search), `permission_handler`
* **Backend:** Go (Golang)
  * Location: `backend/`
  * Architecture: RESTful API (Fiber framework)
  * ORM / Database: PostgreSQL via GORM (`gorm.io/driver/postgres`)
  * Authentication: JWT (`github.com/golang-jwt/jwt/v5`)
  * Local Infrastructure: `docker-compose.yml` for PostgreSQL
* **Design Guidelines:**
  * Clean, minimal, airy UI with soft medical tones (subtle blues, cyans, light grays).
  * High icon-to-text ratio (Material Symbols).
  * Variable/Code Language: 100% English (`camelCase` frontend, `snake_case` backend).
  * User-facing text: Portuguese (pt-BR).

---

## 2. Core Entities & Data Models

### 2.1. `User` (Client / Clinic Admin Account)
```json
{
  "id": "UUID (PK)",
  "phone": "String (Required, Unique)",
  "email": "String (Optional)",
  "password_hash": "String (BCrypt)",
  "full_name": "String (Required)",
  "role": "String (patient | clinic_manager)",
  "birth_date": "DateTime (Optional)",
  "profile_image_url": "String (Optional)",
  "created_at": "DateTime",
  "updated_at": "DateTime"
}
```

### 2.2. `Clinic` (Medical Entity)
```json
{
  "id": "UUID (PK)",
  "owner_user_id": "UUID (FK -> User.id, Unique per Clinic)",
  "name": "String (Required)",
  "description": "Text",
  "address": "String (Required)",
  "city": "String (Default: Surubim)",
  "state": "String (Default: PE)",
  "phone_number": "String",
  "whatsapp_number": "String (Required for booking)",
  "logo_url": "String",
  "rating": "Float (Default: 5.0)",
  "patient_count": "Integer (Default: 0)",
  "is_verified": "Boolean (Default: true)",
  "operating_hours": "String",
  "created_at": "DateTime",
  "updated_at": "DateTime"
}
```

### 2.3. `Exam` (Medical Examination / Consultation)
```json
{
  "id": "UUID (PK)",
  "clinic_id": "UUID (FK -> Clinic.id)",
  "title": "String (Required)",
  "category": "String (Sangue | Raio-X | Consultas | Cardio | Ultrassom)",
  "description": "Text",
  "preparation": "String (e.g., Jejum 8h, Resultado em 24h)",
  "price": "Decimal/Float (Required)",
  "payment_methods": "String (e.g., À vista, Cartão)",
  "available": "Boolean (Default: true)",
  "created_at": "DateTime",
  "updated_at": "DateTime"
}
```

---

## 3. Screen Inventory & Flow Mapping

| Screen ID | Name | Role Target | Core Functions |
|---|---|---|---|
| `1._login_cadastro_onboarding` | Login / Registration | All Users | Phone/password auth, JWT storage, role-based redirection. |
| `2._in_cio_busca_centralizada` | Home & Central Search | Patient | Search bar, category chips (Sangue, Raio-X, etc.), trending exams. |
| `3._menu_lateral_drawer` | Navigation Drawer | All Users | Global app drawer navigation. |
| `4._resultados_de_busca_compara_o` | Search Results & Comparison | Patient | List/compare prices across clinics, direct WhatsApp CTA. |
| `5._detalhes_do_exame` | Exam Details | Patient | Fasting requirements, preparation, price breakdown, WhatsApp CTA. |
| `6._perfil_do_usu_rio` | Patient Profile | Patient | View user info, logout. |
| `7._painel_da_cl_nica_dashboard` | Clinic Dashboard | Clinic Manager | Overview of listed exams, statistics. |
| `8._gest_o_de_exames_da_cl_nica` | Exam Management | Clinic Manager | CRUD operations for exams owned by the clinic. |
| `9._perfil_p_blico_da_cl_nica` | Public Clinic Profile | Patient | Public view of clinic (Exams, Photos, Operating Hours, WhatsApp). |

---

## 4. Key Security & Operational Business Rules

1. **IDOR Prevention (Ownership Validation):**
   - Clinic Managers can ONLY edit or delete exams (`Exam`) belonging to their own `Clinic` (`Clinic.owner_user_id == JWT.user_id`).
   - Middleware on write endpoints (`POST/PUT/DELETE /api/clinics/{id}/exams/...`) must validate this ownership before executing DB queries.
2. **Role Redirection:**
   - Patient (`role: "patient"`) -> Navigates to `Home` (`2._in_cio_busca_centralizada`).
   - Clinic Manager (`role: "clinic_manager"`) -> Navigates to `Dashboard` (`7._painel_da_cl_nica_dashboard`).
3. **WhatsApp Redirection:**
   - WhatsApp CTA generates dynamic `https://wa.me/{whatsapp_number}?text={encoded_message}`.