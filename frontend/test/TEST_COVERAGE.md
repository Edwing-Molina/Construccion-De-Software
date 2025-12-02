# Flutter Unit Tests - Frontend Project

## Descripción General
Este conjunto de pruebas unitarias y de widgets cubre las clases principales del proyecto frontend, incluyendo modelos, servicios, widgets y pantallas.

## Estructura de Pruebas

### 1. Tests de Modelos (`test/models/`)

#### `specialty_model_test.dart`
- Creación de instancias de Specialty
- Serialización/deserialización JSON (fromJson/toJson)
- Validación de campos
- Round-trip serialization

#### `clinic_info_model_test.dart`
- Creación con todos los campos
- Creación con campos requeridos solamente
- Serialización JSON con office_number nullable
- Round-trip serialization

#### `doctor_model_test.dart`
- Creación con especialidades
- Creación con campos mínimos
- Serialización JSON compleja
- Manejo de relaciones (specialties, clinics via DoctorClinicPivot)
- Round-trip serialization

#### `api_response_test.dart`
- Respuestas exitosas con datos
- Respuestas con errores
- Genéricos (List, Map, primitivos)
- Valores nulos

### 2. Tests de Utilidades (`test/utils/`)

#### `form_validators_test.dart`
- Validación de email (formato con @ y .)
- Validación de contraseña (mínimo 8 caracteres)
- Validación de teléfono (mínimo 10 dígitos)
- Validación de nombres (no vacío, no solo espacios)

#### `date_formatter_test.dart`
- Extracción de componentes de fecha (año, mes, día)
- Comparación de fechas
- Validación de fecha de nacimiento (no futura)
- Cálculo de edad

### 3. Tests de Servicios (`test/services/`)

#### `services_test.dart`
- Estructura de tests para AuthService
- Estructura de tests para ProfileService
- Estructura de tests para DoctorService
- Patrones de mocking y testing

### 4. Tests de Widgets (`test/widgets/`)

#### `custom_text_field_test.dart`
- Renderizado del TextField
- Entrada de texto
- Mostrar mensajes de error
- Campo de contraseña (obscureText)

#### `custom_button_test.dart`
- Renderizado del botón
- Evento de click
- Estado deshabilitado
- Estado de carga (con CircularProgressIndicator)

#### `loading_indicator_test.dart`
- Mostrar spinner de carga
- Mostrar con mensaje
- Estados de visibilidad

#### `appointment_card_test.dart`
- Mostrar información de cita
- Mostrar estado de cita (Confirmed, Pending, etc.)

### 5. Tests de Pantallas (`test/screens/`)

#### `login_screen_test.dart`
- Mostrar campos de formulario (Email, Password)
- Botón de login clickeable
- Campo de contraseña oculta el texto

#### `busqueda_screen_test.dart`
- Filtro por especialidad
- Lista de doctores
- Funcionalidad de filtro

#### `profile_screen_test.dart`
- Mostrar información del usuario
- Botón para editar perfil
- Información de doctor (especialidades, clínicas)
- Información de paciente (fecha nacimiento, tipo sangre)

## Cómo Ejecutar las Pruebas

### Ejecutar todos los tests
```bash
cd frontend
flutter test
```

### Ejecutar tests de una categoría específica
```bash
# Tests de modelos
flutter test test/models/

# Tests de utilidades
flutter test test/utils/

# Tests de widgets
flutter test test/widgets/

# Tests de pantallas
flutter test test/screens/

# Tests de servicios
flutter test test/services/
```

### Ejecutar un archivo de test específico
```bash
flutter test test/models/specialty_model_test.dart
```

### Ejecutar tests con cobertura
```bash
flutter test --coverage
```

### Ver reporte de cobertura
```bash
# Generar reporte HTML (requiere lcov)
genhtml coverage/lcov.info -o coverage/html
```

## Estructura de Archivos de Test

```
test/
├── models/
│   ├── specialty_model_test.dart
│   ├── clinic_info_model_test.dart
│   ├── doctor_model_test.dart
│   └── api_response_test.dart
├── utils/
│   ├── form_validators_test.dart
│   └── date_formatter_test.dart
├── services/
│   └── services_test.dart
├── widgets/
│   ├── custom_text_field_test.dart
│   ├── custom_button_test.dart
│   ├── loading_indicator_test.dart
│   └── appointment_card_test.dart
├── screens/
│   ├── login_screen_test.dart
│   ├── busqueda_screen_test.dart
│   └── profile_screen_test.dart
└── widget_test.dart
```

## Mejores Prácticas Implementadas

1. **Nombres descriptivos**: Los nombres de tests describen exactamente qué se está probando
2. **Arrange-Act-Assert**: Estructura clara de preparación, ejecución y validación
3. **Pruebas independientes**: Cada test es independiente y no depende de otros
4. **Setup y TearDown**: Se usan cuando es necesario limpiar recursos
5. **Cobertura de casos límite**: Se prueban casos normales, vacíos y nulos
6. **Comentarios claros**: Se proporcionan comentarios cuando la prueba no es evidente

## Relaciones Entre Clases Testeadas

### Modelo User
- Relación uno-a-uno con Doctor
- Relación uno-a-uno con Patient
- Relación muchos-a-muchos con Specialty (vía doctor)
- Relación muchos-a-muchos con DoctorClinic (vía doctor)

### Modelo Doctor
- Relación uno-a-muchos con Appointment
- Relación muchos-a-muchos con Specialty
- Relación muchos-a-muchos con Clinic (vía DoctorClinicPivot)

### Modelo Specialty
- Relación muchos-a-muchos con Doctor

### Modelo ClinicInfo
- Usado en composición dentro de Doctor
- Relación con DoctorClinicPivot

## Notas Importantes

1. Los tests de modelos validan la serialización JSON correcta
2. Los tests de servicios demuestran patrones de mocking para futuras implementaciones
3. Los tests de widgets utilizan `testWidgets` del framework Flutter
4. Los tests de pantallas validan el flujo de UI y la interacción del usuario
5. Las pruebas están diseñadas para ser ejecutadas sin dependencias externas complejas

## Cobertura de Tests

| Categoría | Archivos | Tests |
|-----------|----------|-------|
| Modelos | 4 | 24+ |
| Utilidades | 2 | 15+ |
| Servicios | 1 | 5+ |
| Widgets | 4 | 12+ |
| Pantallas | 3 | 15+ |
| **Total** | **14** | **71+** |

## Próximos Pasos para Mejoras

1. Agregar tests de integración con mocking HTTP
2. Implementar tests de estado (BLoC/Provider si se usa)
3. Agregar tests de performance
4. Mejorar cobertura a 80%+
5. Agregar tests para manejo de errores en servicios

---

**Última actualización**: 2025-12-02
**Versión Flutter**: ^3.7.2
**Versión Dart**: ^3.7.2
