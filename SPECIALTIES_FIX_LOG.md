# Specialties & Clinics Display Fix

## Problem Identified
The specialties and clinics were not displaying in the profile edit screen even though:
1. The backend was returning the data correctly
2. The frontend User model had @JsonKey annotations for these fields
3. The json_serializable .g.dart files were properly generated

## Root Cause
The `ProfileController.php` was returning a complex data structure where specialties and clinics were merged at different levels, causing inconsistent JSON serialization.

## Solution Applied

### Backend Changes (ProfileController.php)

#### 1. **show() method** - Fixed response format
**Before:** Merging arrays inconsistently
```php
$relations = [];
// ... complex merging logic
$userData = array_merge($user->toArray(), $relations);
```

**After:** Consistent formatting with specialties/clinics at top level
```php
$user->load('patient', 'doctor.specialties', 'doctor.clinics');
$userData = $user->toArray();

if ($user->doctor) {
    $userData['specialties'] = $user->doctor->specialties()->get()->map(...);
    $userData['clinics'] = $user->doctor->clinics()->get()->map(...);
}
```

#### 2. **update() method** - Consistent response format
**Before:** Returning loaded model directly
```php
'data' => $user->load('patient', 'doctor.specialties', 'doctor.clinics'),
```

**After:** Same format as show()
```php
$user->load('patient', 'doctor.specialties', 'doctor.clinics');
$userData = $user->toArray();

if ($user->doctor) {
    $userData['specialties'] = ...;
    $userData['clinics'] = ...;
}
```

#### 3. **showOtherUser() method** - Consistent response format
Unified to use same structure as show() and update()

### Frontend Changes (update_profile_screen.dart)

Added debug logging to help diagnose issues:
```dart
if (kDebugMode) {
  debugPrint('User object: ${user.toJson()}');
  debugPrint('User specialties: ${user.specialties}');
  debugPrint('User clinics: ${user.clinics}');
}
```

## Expected JSON Response Format

### After fix, the API response should look like:
```json
{
  "message": "Perfil de usuario recuperado exitosamente.",
  "data": {
    "id": 1,
    "name": "Dr. Example",
    "email": "doctor@example.com",
    "phone": "1234567890",
    "doctor": {
      "id": 1,
      "user_id": 1,
      "description": "a123456789",
      "is_active": 1
    },
    "patient": null,
    "specialties": [
      {
        "id": 1,
        "name": "Dermatologia"
      }
    ],
    "clinics": [
      {
        "id": 1,
        "name": "Clinic Name",
        "address": "Address",
        "office_number": "15"
      }
    ]
  }
}
```

## How Specialties Now Load

1. API returns specialties array at top level of data object
2. User.fromJson() deserializes it using user.g.dart
3. Frontend accesses via `user.specialties` property
4. Debug logs confirm data is present in User object
5. UI displays specialties as chips in edit profile screen

## Files Modified

- ✅ `backend/app/Http/Controllers/Api/ProfileController.php` - All 3 methods (show, update, showOtherUser)
- ✅ `frontend/lib/screens/auth/update_profile_screen.dart` - Added debug logging

## Testing Checklist

- [ ] Login as a doctor with assigned specialties
- [ ] Navigate to edit profile
- [ ] Verify specialties display as chips
- [ ] Verify clinics display correctly
- [ ] Add/remove specialties and save
- [ ] Reload profile to confirm changes persisted
- [ ] Check debug logs show non-empty specialties list

## Notes

The issue was not with json_serializable or the model definitions - those were correct. The issue was that the backend was returning inconsistent JSON structures across different endpoints, making it impossible for the frontend to reliably parse the data.
