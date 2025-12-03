import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/form_constants.dart';
import '../../core/utils/form_validators.dart';
import '../../widgets/widgets.dart';
import '../../services/services.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _birthController = TextEditingController();
  final _emergencyContactNameController = TextEditingController();
  final _emergencyContactPhoneController = TextEditingController();
  final _nssNumberController = TextEditingController();

  String? _selectedGender;
  String? _selectedBloodType;
  DateTime? _selectedBirthDate;
  bool _isLoading = false;

  // Constantes movidas a FormConstants

  @override
  void dispose() {
    _birthController.dispose();
    _emergencyContactNameController.dispose();
    _emergencyContactPhoneController.dispose();
    _nssNumberController.dispose();
    super.dispose();
  }

  Future<void> _completeProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final profileService = serviceLocator.profileService;
      final profileData = profileService.preparePatientProfileData(
        birthDate: _selectedBirthDate!,
        gender: _selectedGender!,
        bloodType: _selectedBloodType!,
        emergencyContactName: _emergencyContactNameController.text.trim(),
        emergencyContactPhone: _emergencyContactPhoneController.text.trim(),
        nssNumber: _nssNumberController.text.trim(),
      );

      final response = await profileService.updateProfile(profileData);

      if (mounted && response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: $message'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: constraints.maxWidth > 600 ? 40 : 16,
                  vertical: 12,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 24,
                  ),
                  child: Stack(
                    children: [
                      const LogoSection(),
                      Padding(
                        padding: EdgeInsets.only(
                          top: constraints.maxHeight > 700 ? 200 : 160,
                        ),
                        child: Column(
                          children: [
                            _buildFormContainer(),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFormContainer() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return FormContainer(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              SizedBox(height: constraints.maxWidth > 600 ? 24 : 16),
              _buildCompleteProfileForm(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return ProfileFormHeader(
      title: FormConstants.screenTitle,
      subtitle: FormConstants.screenSubtitle,
    );
  }

  Widget _buildCompleteProfileForm() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = constraints.maxWidth > 600 ? 16.0 : 12.0;

        return Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(height: spacing),
              _buildBirthDateField(),
              SizedBox(height: spacing),
              _buildGenderField(),
              SizedBox(height: spacing),
              _buildBloodTypeField(),
              SizedBox(height: spacing),
              _buildEmergencyContactNameField(),
              SizedBox(height: spacing),
              _buildEmergencyContactPhoneField(),
              SizedBox(height: spacing),
              _buildNssNumberField(),
              SizedBox(height: spacing * 1.5),
              _buildContinueButton(),
              SizedBox(height: spacing * 0.75),
              _buildSkipForNowButton(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBirthDateField() {
    return BirthDateField(
      controller: _birthController,
      selectedDate: _selectedBirthDate,
      onDateSelected: (date) {
        setState(() {
          _selectedBirthDate = date;
        });
      },
      hintText: FormConstants.birthDatePlaceholder,
      validator:
          (value) => FormValidators.validateBirthDate(_selectedBirthDate),
    );
  }

  Widget _buildGenderField() {
    return CustomDropdownField(
      value: _selectedGender,
      items: FormConstants.genderOptions,
      hintText: FormConstants.genderPlaceholder,
      icon: Icons.person_outline,
      onChanged: (String? newValue) {
        setState(() {
          _selectedGender = newValue;
        });
      },
      validator:
          (value) => FormValidators.validateDropdown(
            value,
            customMessage: FormConstants.genderRequiredMessage,
          ),
    );
  }

  Widget _buildBloodTypeField() {
    return CustomDropdownField(
      value: _selectedBloodType,
      items: FormConstants.bloodTypeOptions,
      hintText: FormConstants.bloodTypePlaceholder,
      icon: Icons.bloodtype_outlined,
      onChanged: (String? newValue) {
        setState(() {
          _selectedBloodType = newValue;
        });
      },
      validator:
          (value) => FormValidators.validateDropdown(
            value,
            customMessage: FormConstants.bloodTypeRequiredMessage,
          ),
    );
  }

  Widget _buildEmergencyContactNameField() {
    return CustomTextField(
      controller: _emergencyContactNameController,
      hintText: FormConstants.emergencyContactNamePlaceholder,
      icon: Icons.person_outline,
      validator:
          (value) => FormValidators.validateRequired(
            value,
            customMessage: FormConstants.emergencyContactNameRequiredMessage,
          ),
    );
  }

  Widget _buildEmergencyContactPhoneField() {
    return CustomTextField(
      controller: _emergencyContactPhoneController,
      hintText: FormConstants.emergencyContactPhonePlaceholder,
      icon: Icons.phone_outlined,
      keyboardType: TextInputType.phone,
      validator: FormValidators.validatePhone,
    );
  }

  Widget _buildNssNumberField() {
    return CustomTextField(
      controller: _nssNumberController,
      hintText: FormConstants.nssPlaceholder,
      icon: Icons.badge_outlined,
      keyboardType: TextInputType.number,
      validator:
          (value) => FormValidators.validateRequired(
            value,
            customMessage: FormConstants.nssRequiredMessage,
          ),
    );
  }

  Widget _buildContinueButton() {
    return CustomButton(
      text: FormConstants.continueButtonText,
      onPressed: _isLoading ? null : _completeProfile,
      isLoading: _isLoading,
    );
  }

  Widget _buildSkipForNowButton() {
    return TextButton(
      onPressed: _isLoading ? null : () => context.go('/home'),
      child: const Text(
        FormConstants.skipButtonText,
        style: TextStyle(
          color: AppColors.darkGray,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
    );
  }
}
