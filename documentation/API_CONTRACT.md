# Contrato de API

## Autenticación

### Login de un usuario
- **POST** `/mobile/login`
- **Middleware:** `auth:sanctum`
  **Formato JSON:**
```json
{
    "email": "testDoctor@example.com",
    "password": "password",
    "device_name": "MyPhone"
}
```

### Logout de un usuario
- **POST** `/mobile/logout`
- **Middleware:** `auth:sanctum`
- **Headers:** `Authorization: Bearer token`

### Registro de un usuario (solo rol paciente)
- **POST** `/register`
- **Middleware:** `auth:sanctum`
  **Formato JSON:**
```json
{
    "name": "nombre",
    "phone": "1234567891",
    "email": "otroUser@example.com",
    "password": "password",
    "password_confirmation": "password"
}
```

---

## Endpoints para Usuarios Autenticados

### Perfil del Usuario
- **GET** `/me`  
  **Descripción:** Obtiene la información del perfil del usuario autenticado.  
  **Middleware:** `auth:sanctum`

- **PUT** `/me`  
  **Descripción:** Actualiza la información del perfil del usuario autenticado.  
  **Middleware:** `auth:sanctum`

  **Formato JSON para Paciente:**

```json
{
    "name": "Nuevo nombre del paciente",
    "phone": "1234567890",
    "patient": {
        "description": "Nueva descripción del paciente",
        "birth": "1990-01-01",
        "gender": "masculino",
        "blood_type": "A+",
        "emergency_contact_name": "Contacto Emergencia",
        "emergency_contact_phone": "0987654321",
        "nss_number": "987654321"
    }
}
```

  **Formato JSON para Doctor:**

```json
{
    "name": "Nuevo Nombre del Doctor",
    "phone": "1234567890",
    "doctor": {
        "description": "Nueva descripción del doctor"
    },
    "specialty_ids": [1, 2, 3],
    "clinics": [
        {
            "clinic_id": 1,
            "office_number": "15"
        }
    ]
}
```

  **Notas importantes:**

- `specialty_ids`: Array de IDs de especialidades (requerido para doctores, debe enviarse en el nivel raíz del JSON)
- `clinics`: Array con información de clínicas y número de consultorio
- Los campos `name` y `phone` se actualizan directamente en el usuario
- Para `gender` usar valores: "masculino", "femenino", "prefiero no decirlo"

### Ver otros perfiles
- **GET** `show/{id}/profile`  
  **Descripción:** Obtiene la información de un usuario registrado.  
  **Middleware:** `auth:sanctum`

### Especialidades

- **GET** `/specialtys`  
  **Descripción:** Lista todas las especialidades disponibles.  
  **Middleware:** `auth:sanctum`
  **Notas:** Endpoint accesible tanto para pacientes como doctores. Usado para cargar las opciones de especialidades en formularios de edición de perfil.

### Doctores
- **GET** `/doctors`  
  **Descripción:** Lista todos los doctores disponibles.  
  **Middleware:** `auth:sanctum`, `role:patient`
  **Query parameters:** id, specialty_id, clinic_id, per_page
---

## Endpoints para Pacientes

### Citas
- **GET** `/patient-appointments`  
  **Descripción:** Lista las citas del paciente autenticado.  
  **Middleware:** `auth:sanctum`, `role:patient`  
  **Query parameters:** status, doctor_id, from_date, to_date, specialty_id

- **POST** `/patient-appointments`  
  **Descripción:** Crea una nueva cita para el paciente autenticado.  
  **Middleware:** `auth:sanctum`, `role:patient`  
  **Formato del JSON:**
  ```json
  {
      "available_schedule_id": 15
  }
  ```

- **GET** `/patient-appointments/{id}`  
  **Descripción:** Muestra los detalles de una cita específica.  
  **Middleware:** `auth:sanctum`, `role:patient`

- **PUT** `/patient-appointments/{id}`  
  **Descripción:** Cancela una cita específica.  
  **Middleware:** `auth:sanctum`, `role:patient`

### Horarios Disponibles
- **GET** `/patient-available-schedules`  
  **Descripción:** Lista los horarios disponibles con diferentes filtros aplicables 
  **Middleware:** `auth:sanctum`, `role:patient`
  **Query parameters:** doctor_id, specialty_id, clinic_id,schedule_id,start_date,end_date

---

## Endpoints para Doctores

### Citas
- **GET** `/doctor-appointments`  
  **Descripción:** Lista las citas del doctor autenticado.  
  **Middleware:** `auth:sanctum`, `role:doctor`.  
  **Query parameters:** status, from_date, to_date, specialty_id

- **PUT** `doctor-appointments/{appointment_id}/complete`  
  **Descripción:** Marca una cita como completada.  
  **Middleware:** `auth:sanctum`, `role:doctor`

### Horarios Disponibles
- **GET** `/doctor-available-schedules`  
  **Descripción:** Lista los horarios disponibles del doctor autenticado.  
  **Middleware:** `auth:sanctum`, `role:doctor`
  **Query parameters:** doctor_id, specialty_id, clinic_id,schedule_id,start_date,end_date


### Generar Horarios Disponibles
- **POST** `/available-schedules/generate`  
  **Descripción:** Genera los horarios disponibles basándose en la información de los patrones de trabajo del doctor autenticado.  
  **Middleware:** `auth:sanctum`, `role:doctor`  
  **Formato JSON:**
  ```json
  {
    "start_date": "YYYY-MM_DD",
    "end_date": "YYYY-MM_DD"
  }
  ```

### Patrones de Trabajo
- **GET** `/work-patterns`  
  **Descripción:** Lista los patrones de trabajo del doctor autenticado.  
  **Middleware:** `auth:sanctum`, `role:doctor`

- **POST** `/work-patterns`  
  **Descripción:** Crea un nuevo patrón de trabajo.  
  **Middleware:** `auth:sanctum`, `role:doctor`  
  **Formato del JSON:**
  ```json
  {
      "clinic_id": 1,
      "day_of_week": "Saturday",
      "start_time_pattern": "08:00",
      "end_time_pattern": "12:00",
      "slot_duration_minutes": 30,
      "is_active": true,
      "start_date_effective": "2025-07-01",
      "end_date_effective": "2025-07-31"
  }
  ```

- **GET** `/work-patterns/{id}`  
  **Descripción:** Muestra los detalles de un patrón de trabajo específico.  
  **Middleware:** `auth:sanctum`, `role:doctor`

- **PUT** `/work-patterns/{id}`  
  **Descripción:** Desactiva un patrón de trabajo específico.  
  **Middleware:** `auth:sanctum`, `role:doctor`
