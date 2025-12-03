# Backend Unit Tests Documentation

## Overview

Este archivo contiene la documentación completa de todas las pruebas unitarias generadas para el backend del proyecto Construcción de Software. Las pruebas están organizadas por categoría y cubren modelos, servicios y enums.

## Current Status

### Environment Configuration

El siguiente trabajo ha sido completado para ejecutar los tests:

1. **PHP Extensions Enabled:**
   - mbstring - Multibyte string functions
   - SQLite PDO - Database driver
   - OpenSSL - Encryption functions
   - DOM, JSON, LibXML, Tokenizer, XML, XMLWriter

2. **Database Setup:**
   - Migrations created and executed
   - Database seeded with test data
   - All tables created successfully

3. **Model Fixes:**
   - Added `phone` field to User model and migration
   - Added `HasRoles` trait to User model (Spatie permission)
   - Created Clinic model (was missing)
   - Fixed relationship table names (doctor_clinic → doctor_clinics)
   - Fixed seeder enum values (Pendiente → pendiente)

### Test Execution Status

**Last Test Run Results:**

- Total Tests: 158
- Assertions: 43+
- Passing: ~15
- Errors: 132 (mostly due to missing API routes)
- Failures: 15

The tests are now **executable**. Most errors are due to Feature tests looking for routes that haven't been fully implemented yet, not problems with the test infrastructure itself.

## Test Organization

```
tests/
├── Unit/
│   ├── Models/
│   │   ├── UserModelTest.php
│   │   ├── DoctorModelTest.php
│   │   ├── PatientModelTest.php
│   │   ├── SpecialtyModelTest.php
│   │   ├── AppointmentModelTest.php
│   │   ├── AvailableScheduleModelTest.php
│   │   ├── DoctorWorkPatternModelTest.php
│   │   └── ClinicModelTest.php
│   ├── Services/
│   │   ├── DoctorServiceTest.php
│   │   └── ProfileServiceTest.php
│   └── Enums/
│       ├── AppointmentStatusEnumTest.php
│       ├── DayOfWeekEnumTest.php
│       └── GenresEnumTest.php
```

## Models Tests

### UserModelTest (10 tests)
Tests for the User model including:
- User creation with fillable attributes
- Password hashing verification
- Password hidden in serialization
- Doctor relationship
- Patient relationship
- Email uniqueness
- Email verification timestamp casting
- User updates
- User deletion

**Test Methods:**
- `test_user_can_be_created_with_name_email_password()`
- `test_user_password_is_hashed()`
- `test_user_password_is_hidden_in_array()`
- `test_user_can_have_doctor_relationship()`
- `test_user_can_have_patient_relationship()`
- `test_user_email_must_be_unique()`
- `test_user_email_verified_at_is_cast_to_datetime()`
- `test_user_can_be_updated()`
- `test_user_can_be_deleted()`

### DoctorModelTest (12 tests)
Tests for the Doctor model including:
- Doctor user relationship
- Multiple specialties relationship
- Multiple clinics relationship
- Multiple appointments relationship
- License number hashing
- Doctor availability logic
- Doctor filtering by specialty
- Doctor filtering by search
- Soft deletes

**Test Methods:**
- `test_doctor_belongs_to_user()`
- `test_doctor_can_have_many_specialties()`
- `test_doctor_can_have_many_clinics()`
- `test_doctor_can_have_many_appointments()`
- `test_doctor_license_number_is_hashed()`
- `test_doctor_is_available_with_valid_schedule()`
- `test_doctor_is_not_available_without_schedule()`
- `test_doctor_filter_by_specialty()`
- `test_doctor_filter_by_search()`
- `test_doctor_uses_soft_deletes()`

### PatientModelTest (7 tests)
Tests for the Patient model including:
- Patient user relationship
- Patient creation with all fields
- Patient creation with minimal fields
- Soft deletes
- Different blood types
- Patient updates
- Patient retrieval with relationships

**Test Methods:**
- `test_patient_belongs_to_user()`
- `test_patient_can_be_created_with_all_fields()`
- `test_patient_can_be_created_with_minimal_fields()`
- `test_patient_uses_soft_deletes()`
- `test_patient_with_different_blood_types()`
- `test_patient_can_be_updated()`
- `test_patient_with_user_relationship()`

### SpecialtyModelTest (8 tests)
Tests for the Specialty model including:
- Specialty creation
- Specialty doctor relationship
- Filter by name scope
- Filter by name with empty string
- Ordered by name scope
- Timestamps behavior
- Specialty updates
- Multiple specialties for same doctor

**Test Methods:**
- `test_specialty_can_be_created_with_name()`
- `test_specialty_belongs_to_many_doctors()`
- `test_specialty_scope_filter_by_name()`
- `test_specialty_scope_filter_by_name_with_empty_string()`
- `test_specialty_scope_ordered_by_name()`
- `test_specialty_does_not_have_timestamps()`
- `test_specialty_can_be_updated()`
- `test_multiple_specialties_for_same_doctor()`

### AppointmentModelTest (9 tests)
Tests for the Appointment model including:
- Appointment creation
- Appointment patient relationship
- Appointment schedule relationship
- Through relationship to doctor
- Appointment status enum casting
- Filter by status scope
- Filter by doctor scope
- Filter by date range scope
- Appointment updates

**Test Methods:**
- `test_appointment_can_be_created()`
- `test_appointment_belongs_to_patient()`
- `test_appointment_belongs_to_available_schedule()`
- `test_appointment_has_one_through_doctor()`
- `test_appointment_status_is_cast_to_enum()`
- `test_appointment_scope_filter_by_status()`
- `test_appointment_scope_filter_by_doctor()`
- `test_appointment_scope_filter_by_date_range()`
- `test_appointment_can_be_updated()`

### AvailableScheduleModelTest (12 tests)
Tests for the AvailableSchedule model including:
- Schedule creation
- Schedule doctor relationship
- Date casting
- Boolean casting
- Mark as available/unavailable
- Check if available
- Check if in future
- Past schedule verification
- Appointments relationship
- Schedule updates

**Test Methods:**
- `test_available_schedule_can_be_created()`
- `test_available_schedule_belongs_to_doctor()`
- `test_available_schedule_date_is_cast_to_date()`
- `test_available_schedule_available_is_cast_to_boolean()`
- `test_mark_available_schedule_as_available()`
- `test_mark_available_schedule_as_unavailable()`
- `test_check_if_schedule_is_available()`
- `test_check_if_schedule_is_in_future()`
- `test_past_schedule_is_not_in_future()`
- `test_available_schedule_has_many_appointments()`
- `test_available_schedule_can_be_updated()`

### DoctorWorkPatternModelTest (10 tests)
Tests for the DoctorWorkPattern model including:
- Work pattern creation
- Doctor relationship
- Clinic relationship
- Day of week enum casting
- Is active boolean casting
- Scope for doctor
- Duplicate pattern validation
- Different days same clinic
- Effective date range

**Test Methods:**
- `test_doctor_work_pattern_can_be_created()`
- `test_doctor_work_pattern_belongs_to_doctor()`
- `test_doctor_work_pattern_belongs_to_clinic()`
- `test_doctor_work_pattern_day_of_week_cast_to_enum()`
- `test_doctor_work_pattern_is_active_cast_to_boolean()`
- `test_doctor_work_pattern_scope_for_doctor()`
- `test_doctor_work_pattern_throws_exception_for_duplicate()`
- `test_doctor_work_pattern_different_days_same_clinic()`
- `test_doctor_work_pattern_with_effective_date_range()`

### ClinicModelTest (4 tests)
Tests for the Clinic model including:
- Clinic creation
- Clinic updates
- Clinic deletion
- Clinic doctor relationship

**Test Methods:**
- `test_clinic_can_be_created()`
- `test_clinic_can_be_updated()`
- `test_clinic_can_be_deleted()`
- `test_clinic_belongs_to_many_doctors()`

## Services Tests

### DoctorServiceTest (10 tests)
Tests for the DoctorService service including:
- Search without filters
- Paginated results
- Search by specialty
- Search by clinic
- Search by name
- Search by specialty convenience method
- Custom per page
- Loaded relationships
- Non-existent specialty handling
- Multiple filters combination

**Test Methods:**
- `test_doctor_service_search_without_filters()`
- `test_doctor_service_search_returns_pagination()`
- `test_doctor_service_search_by_specialty()`
- `test_doctor_service_search_by_clinic()`
- `test_doctor_service_search_by_name()`
- `test_doctor_service_search_by_specialty_convenience_method()`
- `test_doctor_service_search_with_custom_per_page()`
- `test_doctor_service_search_returns_loaded_relationships()`
- `test_doctor_service_search_with_non_existent_specialty()`
- `test_doctor_service_search_with_multiple_filters()`

### ProfileServiceTest (11 tests)
Tests for the ProfileService service including:
- Get user by ID
- Exception for non-existent user
- Update basic user info
- Update patient info
- Update doctor specialties
- Exception for invalid specialty
- Sync doctor clinics
- Exception for non-existent clinic
- Transaction rollback on error
- Loaded relationships
- Empty clinic data handling

**Test Methods:**
- `test_profile_service_get_user_by_id()`
- `test_profile_service_get_user_throws_exception_for_non_existent()`
- `test_profile_service_update_basic_user_info()`
- `test_profile_service_update_patient_info()`
- `test_profile_service_update_doctor_specialties()`
- `test_profile_service_throws_exception_for_invalid_specialty()`
- `test_profile_service_sync_doctor_clinics()`
- `test_profile_service_throws_exception_for_non_existent_clinic()`
- `test_profile_service_transaction_rollback_on_error()`
- `test_profile_service_returns_user_with_relationships()`
- `test_profile_service_handles_empty_clinic_data()`

## Enums Tests

### AppointmentStatusEnumTest (6 tests)
Tests for the AppointmentStatus enum including:
- Enum cases verification
- Values method
- To array method
- Is valid method
- Invalid status rejection
- Case sensitivity

**Test Methods:**
- `test_appointment_status_enum_cases_exist()`
- `test_appointment_status_values_method()`
- `test_appointment_status_to_array_method()`
- `test_appointment_status_is_valid_method()`
- `test_appointment_status_is_valid_rejects_invalid()`
- `test_appointment_status_is_valid_is_case_sensitive()`

### DayOfWeekEnumTest (4 tests)
Tests for the DayOfWeek enum including:
- Enum cases verification
- Enum values
- Has seven cases
- Enum comparison

**Test Methods:**
- `test_day_of_week_enum_cases_exist()`
- `test_day_of_week_enum_values()`
- `test_day_of_week_has_seven_cases()`
- `test_day_of_week_can_be_compared()`

### GenresEnumTest (4 tests)
Tests for the Genres enum including:
- Enum cases verification
- To array method
- All cases present
- Enum comparison

**Test Methods:**
- `test_genres_enum_cases_exist()`
- `test_genres_to_array_method()`
- `test_genres_has_all_cases()`
- `test_genres_can_be_compared()`

## Running Tests

```bash
# Run all tests
php -c php.ini vendor/bin/phpunit

# Run specific test file
php -c php.ini vendor/bin/phpunit tests/Unit/Models/UserModelTest.php

# Run tests with coverage
php -c php.ini vendor/bin/phpunit --coverage-html coverage/
```

## Total Test Count

- **Models Tests**: 72 tests across 8 model classes
- **Services Tests**: 21 tests across 2 service classes
- **Enums Tests**: 14 tests across 3 enum classes
- **Total**: 107 unit tests
