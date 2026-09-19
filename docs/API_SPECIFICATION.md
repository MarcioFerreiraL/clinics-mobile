# 🔌 REST API Specification Document (`API_SPECIFICATION.md`)

**Base URL:** `http://localhost:8080/api/v1`  
**Authentication:** HTTP Bearer Token (`Authorization: Bearer <JWT>`)

---

## 1. Authentication Endpoints

### 1.1. `POST /auth/register`
Creates a new user account (Patient or Clinic Manager).

- **Request Body:**
```json
{
  "phone": "(81) 99876-5432",
  "password": "Password123!",
  "full_name": "Maria Silva",
  "role": "patient"
}
```
- **Response (201 Created):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "a3b8e912-3456-7890-abcd-ef1234567890",
    "phone": "(81) 99876-5432",
    "full_name": "Maria Silva",
    "role": "patient"
  }
}
```

---

### 1.2. `POST /auth/login`
Authenticates a user by phone and password.

- **Request Body:**
```json
{
  "phone": "(81) 99876-5432",
  "password": "Password123!"
}
```
- **Response (200 OK):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "a3b8e912-3456-7890-abcd-ef1234567890",
    "phone": "(81) 99876-5432",
    "full_name": "Maria Silva",
    "role": "patient"
  }
}
```

---

## 2. Exams & Search Endpoints (Public)

### 2.1. `GET /exams/search`
Search exams by query string, category filter, and sorting.

- **Query Parameters:**
  - `query` (optional, string): e.g. `Hemograma`
  - `category` (optional, string): `Sangue` | `Raio-X` | `Consultas` | `Cardio` | `Ultrassom`
  - `sort_by` (optional, default `price`): `price` | `rating` | `name`
- **Response (200 OK):**
```json
{
  "total": 1,
  "data": [
    {
      "id": "e1f2a3b4-5678-9012-3456-789012345678",
      "clinic_id": "c1d2e3f4-5678-9012-3456-789012345678",
      "clinic_name": "Clínica Santa Maria",
      "clinic_whatsapp": "5581999999999",
      "clinic_rating": 4.9,
      "title": "Hemograma Completo",
      "category": "Sangue",
      "description": "Análise completa de hemácias, leucócitos e plaquetas.",
      "preparation": "Jejum 8h • Coleta até 11:00",
      "price": 18.00,
      "payment_methods": "À vista",
      "available": true
    }
  ]
}
```

---

### 2.2. `GET /exams/:id`
Retrieves detailed information for a specific exam.

- **Response (200 OK):**
```json
{
  "id": "e1f2a3b4-5678-9012-3456-789012345678",
  "clinic_id": "c1d2e3f4-5678-9012-3456-789012345678",
  "clinic_name": "Clínica Santa Maria",
  "clinic_address": "Rua João Alfredo, 142 • Centro, Surubim - PE",
  "clinic_whatsapp": "5581999999999",
  "title": "Hemograma Completo",
  "category": "Sangue",
  "description": "Análise de sangue presencial.",
  "preparation": "Jejum 8h • Resultado em 24h",
  "price": 18.00,
  "payment_methods": "À vista ou Cartão",
  "available": true
}
```

---

## 3. Clinics Endpoints (Public)

### 3.1. `GET /clinics/:id`
Retrieves public profile info for Screen 9 (`9._perfil_p_blico_da_cl_nica`).

- **Response (200 OK):**
```json
{
  "id": "c1d2e3f4-5678-9012-3456-789012345678",
  "name": "Clínica Santa Maria",
  "description": "Diagnósticos por imagem e análises clínicas em Surubim.",
  "address": "Rua João Alfredo, 142 • Centro, Surubim - PE",
  "whatsapp_number": "5581999999999",
  "logo_url": "https://...",
  "rating": 4.9,
  "patient_count": 1200,
  "is_verified": true,
  "operating_hours": "Seg a Sex: 06:30 às 18:00 • Sáb até 12:00",
  "exams_count": 18
}
```

---

## 4. Clinic Management Endpoints (Protected - `clinic_manager` + IDOR check)

### 4.1. `POST /clinics/:id/exams`
Adds a new exam for the owned clinic.

- **Headers:** `Authorization: Bearer <JWT>`
- **Request Body:**
```json
{
  "title": "Ultrassom Abdominal Total",
  "category": "Ultrassom",
  "description": "Exame completo de abdômen.",
  "preparation": "Jejum 8h",
  "price": 95.00,
  "payment_methods": "À vista",
  "available": true
}
```
- **Response (201 Created)**

---

### 4.2. `PUT /clinics/:id/exams/:exam_id`
Updates an existing exam.

- **Headers:** `Authorization: Bearer <JWT>`
- **Response (200 OK)**

---

### 4.3. `DELETE /clinics/:id/exams/:exam_id`
Deletes an exam.

- **Headers:** `Authorization: Bearer <JWT>`
- **Response (204 No Content)**
