import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../services/services.dart';
import '../../models/models.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/common/gradient_background.dart';
import '../../widgets/common/logo_section.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';

/// Screen to edit the current user's profile.
class ScreenEditarPerfil extends StatefulWidget {
  const ScreenEditarPerfil({super.key});

  @override
  State<ScreenEditarPerfil> createState() => _ScreenEditarPerfilState();
}

class _ScreenEditarPerfilState extends State<ScreenEditarPerfil> {
  // Form key and controllers.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _officeNumberController = TextEditingController();
  final TextEditingController _emergencyNameController =
      TextEditingController();
  final TextEditingController _emergencyPhoneController =
      TextEditingController();
  final TextEditingController _nssController = TextEditingController();

  // State fields.
  final List<int> _selectedSpecialtyIds = <int>[];
  String? _selectedClinicId;
  String? _selectedBloodType;
  String? _selectedGender;
  DateTime? _selectedBirthDate;

  bool _isLoading = false;
  User? _usuario;
  final List<Specialty> _specialties = <Specialty>[];
  final List<Specialty> _allSpecialties = <Specialty>[];
  final List<ClinicInfo> _clinics = <ClinicInfo>[];

  // Static lists.
  static const List<String> _bloodTypes = <String>[
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  static const List<String> _genders = <String>[
    'masculino',
    'femenino',
    'prefiero no decirlo',
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks.
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    _officeNumberController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    _nssController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    _setLoading(true);
    try {
      final perfilService = serviceLocator.profileService;
      final specialtyService = serviceLocator.specialtyService;

      final allSpecialtiesResponse = await specialtyService.getAllSpecialties();
      if (allSpecialtiesResponse.success) {
        _allSpecialties
          ..clear()
          ..addAll(allSpecialtiesResponse.data ?? <Specialty>[]);
      }

      final response = await perfilService.getProfile();
      final user = response.data;
      if (user == null) {
        _showSnackBar('No profile data available', color: Colors.red);
        return;
      }

      _usuario = user;
      _nameController.text = user.name;
      _emailController.text = user.email;
      _phoneController.text = user.phone ?? '';

      if (user.doctor != null) {
        final doctor = user.doctor!;
        _descriptionController.text = doctor.description ?? '';

        if (kDebugMode) {
          debugPrint('User object: ${user.toJson()}');
          debugPrint('User specialties: ${user.specialties}');
          debugPrint('User clinics: ${user.clinics}');
        }

        // Las especialidades ya están cargadas en el objeto user
        if (user.specialties != null) {
          _specialties
            ..clear()
            ..addAll(user.specialties!);
          _selectedSpecialtyIds
            ..clear()
            ..addAll(_specialties.map((s) => s.id));
        }

        // Las clínicas ya están cargadas en el objeto user
        if (user.clinics != null && user.clinics!.isNotEmpty) {
          _clinics
            ..clear()
            ..addAll(
              user.clinics!.map(
                (dc) => ClinicInfo(
                  id: dc.id,
                  name: dc.name,
                  address: dc.address,
                  officeNumber: dc.officeNumber,
                ),
              ),
            );
        }

        if (_clinics.isNotEmpty) {
          _selectedClinicId = _clinics.first.id.toString();
          _officeNumberController.text = _clinics.first.officeNumber ?? '';
        }

        if (kDebugMode) {
          debugPrint(
            'Doctor specialties: ${_specialties.map((s) => s.name).toList()}',
          );
          debugPrint('Selected specialty ids: $_selectedSpecialtyIds');
          debugPrint('Clinics loaded: ${_clinics.map((c) => c.name).toList()}');
        }
      }

      if (user.patient != null) {
        final patient = user.patient!;
        _selectedGender =
            _genders.contains(patient.gender) ? patient.gender : null;
        _selectedBloodType =
            _bloodTypes.contains(patient.bloodType) ? patient.bloodType : null;
        _selectedBirthDate = patient.birth;
        _emergencyNameController.text = patient.emergencyContactName ?? '';
        _emergencyPhoneController.text = patient.emergencyContactPhone ?? '';
        _nssController.text = patient.nssNumber ?? '';
      }
    } catch (e) {
      _showSnackBar('Error loading data: $e', color: Colors.red);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    if (_usuario?.doctor == null && _usuario?.patient == null) {
      _showSnackBar('Unsupported user type', color: Colors.red);
      return;
    }

    // If patient, ensure birth date is present.
    if (_usuario?.patient != null && _selectedBirthDate == null) {
      _showSnackBar('Please select a birth date', color: Colors.red);
      return;
    }

    _setLoading(true);
    try {
      final perfilService = serviceLocator.profileService;
      late final Map<String, dynamic> profileData;

      if (_usuario?.doctor != null) {
        final List<Map<String, dynamic>> clinicsData = <Map<String, dynamic>>[];
        if (_selectedClinicId != null) {
          clinicsData.add(<String, dynamic>{
            'clinic_id': int.parse(_selectedClinicId!),
            'office_number': _officeNumberController.text.trim(),
          });
        }

        profileData = perfilService.prepareDoctorProfileData(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          description: _descriptionController.text.trim(),
          specialtyIds: List<int>.from(_selectedSpecialtyIds),
          clinics: clinicsData,
        );
      } else {
        profileData = perfilService.preparePatientProfileData(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          description: null,
          birthDate: _selectedBirthDate!,
          gender: _selectedGender ?? '',
          bloodType: _selectedBloodType ?? '',
          emergencyContactName: _emergencyNameController.text.trim(),
          emergencyContactPhone: _emergencyPhoneController.text.trim(),
          nssNumber: _nssController.text.trim(),
        );
      }

      final response = await perfilService.updateProfile(profileData);
      if (response.success) {
        _showSnackBar(response.message, color: Colors.green);
        if (!mounted) return;
        context.go('/perfil');
      } else {
        _showSnackBar(response.message, color: Colors.red);
      }
    } catch (e) {
      _showSnackBar('Error updating profile: $e', color: Colors.red);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final result = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (result != null && mounted) {
      setState(() => _selectedBirthDate = result);
    }
  }

  Widget _buildSpecialtySelector() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: <Widget>[
          if (_selectedSpecialtyIds.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    _selectedSpecialtyIds.map<Widget>((specialtyId) {
                      final specialty = _allSpecialties.firstWhere(
                        (s) => s.id == specialtyId,
                        orElse:
                            () => Specialty(id: specialtyId, name: 'Unknown'),
                      );
                      return Chip(
                        label: Text(specialty.name),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () {
                          setState(
                            () => _selectedSpecialtyIds.remove(specialtyId),
                          );
                        },
                        backgroundColor: AppColors.uadyBlue.withOpacity(0.1),
                        deleteIconColor: AppColors.uadyBlue,
                        labelStyle: const TextStyle(color: AppColors.uadyBlue),
                      );
                    }).toList(),
              ),
            ),
          ExpansionTile(
            title: Text(
              _selectedSpecialtyIds.isEmpty
                  ? 'Seleccionar especialidades'
                  : 'Agregar más especialidades',
              style: TextStyle(
                color:
                    _selectedSpecialtyIds.isEmpty
                        ? Colors.grey[600]
                        : AppColors.uadyBlue,
              ),
            ),
            children: <Widget>[
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _allSpecialties.length,
                  itemBuilder: (context, index) {
                    final specialty = _allSpecialties[index];
                    final isSelected = _selectedSpecialtyIds.contains(
                      specialty.id,
                    );

                    return CheckboxListTile(
                      title: Text(specialty.name),
                      value: isSelected,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            if (!_selectedSpecialtyIds.contains(specialty.id)) {
                              _selectedSpecialtyIds.add(specialty.id);
                            }
                          } else {
                            _selectedSpecialtyIds.remove(specialty.id);
                          }
                        });
                      },
                      activeColor: AppColors.uadyBlue,
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _setLoading(bool value) {
    if (!mounted) return;
    setState(() => _isLoading = value);
  }

  void _showSnackBar(String message, {Color color = Colors.red}) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.25,
                    child: const LogoSection(),
                  ),
                  _buildFormContainer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormContainer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Editar Perfil',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.uadyBlue,
              ),
            ),
            const SizedBox(height: 20),
            CustomTextField(
              hintText: 'Nombre',
              icon: Icons.person_outline,
              controller: _nameController,
              validator:
                  (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              hintText: 'Correo Electrónico',
              icon: Icons.email_outlined,
              controller: _emailController,
              readOnly: true,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              hintText: 'Teléfono',
              icon: Icons.phone_outlined,
              controller: _phoneController,
              readOnly: true,
            ),
            if (_usuario?.doctor != null) ...<Widget>[
              const SizedBox(height: 20),
              CustomTextField(
                hintText: 'Descripción',
                icon: Icons.info_outline,
                controller: _descriptionController,
              ),
              const SizedBox(height: 20),
              const Text(
                'Especialidades',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              _buildSpecialtySelector(),
              const SizedBox(height: 20),
              const Text(
                'Clínica',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedClinicId,
                items:
                    _clinics
                        .map(
                          (c) => DropdownMenuItem<String>(
                            value: c.id.toString(),
                            child: Text(c.name),
                          ),
                        )
                        .toList(),
                onChanged: (v) => setState(() => _selectedClinicId = v),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.lightGray,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              CustomTextField(
                hintText: 'Número de Consultorio',
                icon: Icons.door_front_door_outlined,
                controller: _officeNumberController,
                validator:
                    (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
              ),
            ],
            if (_usuario?.patient != null) ...<Widget>[
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                items:
                    _genders
                        .map(
                          (g) => DropdownMenuItem<String>(
                            value: g,
                            child: Text(g),
                          ),
                        )
                        .toList(),
                onChanged: (v) => setState(() => _selectedGender = v),
                decoration: const InputDecoration(
                  labelText: 'Género',
                  filled: true,
                  fillColor: AppColors.lightGray,
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedBloodType,
                items:
                    _bloodTypes
                        .map(
                          (b) => DropdownMenuItem<String>(
                            value: b,
                            child: Text(b),
                          ),
                        )
                        .toList(),
                onChanged: (v) => setState(() => _selectedBloodType = v),
                decoration: const InputDecoration(
                  labelText: 'Tipo de Sangre',
                  filled: true,
                  fillColor: AppColors.lightGray,
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _pickBirthDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Fecha de nacimiento',
                    filled: true,
                    fillColor: AppColors.lightGray,
                  ),
                  child: Text(
                    _selectedBirthDate != null
                        ? DateFormat('dd/MM/yyyy').format(_selectedBirthDate!)
                        : 'Selecciona una fecha',
                  ),
                ),
              ),
              const SizedBox(height: 20),
              CustomTextField(
                hintText: 'Contacto de Emergencia',
                icon: Icons.contact_phone,
                controller: _emergencyNameController,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                hintText: 'Teléfono de Emergencia',
                icon: Icons.phone_callback,
                controller: _emergencyPhoneController,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                hintText: 'Número de Seguro Social',
                icon: Icons.health_and_safety,
                controller: _nssController,
              ),
            ],
            const SizedBox(height: 30),
            CustomButton(
              text: 'Guardar Cambios',
              onPressed: _updateProfile,
              isLoading: _isLoading,
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: () => context.go('/perfil'),
              icon: const Icon(Icons.arrow_back, color: AppColors.uadyBlue),
              label: const Text(
                'Regresar al Perfil',
                style: TextStyle(color: AppColors.uadyBlue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
