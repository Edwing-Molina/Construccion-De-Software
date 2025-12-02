import '../constants/form_constants.dart';

class FormValidators {
  static String? validateRequired(String? value, {String? customMessage}) {
    if (value == null || value.trim().isEmpty) {
      return customMessage ?? FormConstants.requiredFieldMessage;
    }
    return null;
  }

  static String? validateBirthDate(DateTime? date) {
    if (date == null) {
      return FormConstants.birthDateRequiredMessage;
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return FormConstants.emergencyContactPhoneRequiredMessage;
    }
    if (value.length < FormConstants.minPhoneLength) {
      return FormConstants.invalidPhoneMessage;
    }
    return null;
  }

  static String? validateDropdown(String? value, {String? customMessage}) {
    if (value == null || value.isEmpty) {
      return customMessage ?? FormConstants.requiredFieldMessage;
    }
    return null;
  }
}
