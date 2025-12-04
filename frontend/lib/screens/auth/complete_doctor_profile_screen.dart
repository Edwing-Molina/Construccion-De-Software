import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../models/specialty.dart';
import '../../widgets/widgets.dart';
import '../../services/services.dart';

class CompleteDoctorProfileScreen extends StatefulWidget {
  const CompleteDoctorProfileScreen({super.key});

  @override
  State<CompleteDoctorProfileScreen> createState() =>
      _CompleteDoctorProfileScreenState();
}

class _CompleteDoctorProfileScreenState
    extends State<CompleteDoctorProfileScreen> {
  late List<Specialty> _specialties;
  Set<int> _selectedSpecialtyIds = {};
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _specialties = [];
    _loadSpecialties();
  }

  Future<void> _loadSpecialties() async {
    try {
      final specialtyService = serviceLocator.specialtyService;
      final specialties = await specialtyService.getSpecialties();

      if (mounted) {
        setState(() {
          _specialties = specialties;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error al cargar especialidades: $e');
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _completeProfile() async {
    if (_selectedSpecialtyIds.isEmpty) {
      _showErrorSnackBar('Por favor selecciona al menos una especialidad');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final profileService = serviceLocator.profileService;

      final profileData = {'specialty_ids': _selectedSpecialtyIds.toList()};

      await profileService.updateProfile(profileData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil actualizado exitosamente'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error al actualizar perfil: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
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
          child:
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : LayoutBuilder(
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
              const ProfileFormHeader(
                title: 'Especialidades',
                subtitle: 'Selecciona tus especialidades médicas',
              ),
              const SizedBox(height: 24),
              _buildSpecialtiesGrid(),
              const SizedBox(height: 24),
              _buildContinueButton(),
              const SizedBox(height: 12),
              _buildSkipButton(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSpecialtiesGrid() {
    if (_specialties.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('No hay especialidades disponibles'),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _specialties.length,
      itemBuilder: (context, index) {
        final specialty = _specialties[index];
        final isSelected = _selectedSpecialtyIds.contains(specialty.id);

        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedSpecialtyIds.remove(specialty.id);
              } else {
                _selectedSpecialtyIds.add(specialty.id);
              }
            });
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.uadyBlue : AppColors.lightGray,
                width: isSelected ? 2 : 1,
              ),
              color:
                  isSelected
                      ? AppColors.uadyBlue.withOpacity(0.1)
                      : Colors.white,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.medical_services_outlined,
                  color: isSelected ? AppColors.uadyBlue : AppColors.darkGray,
                  size: 28,
                ),
                const SizedBox(height: 8),
                Text(
                  specialty.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? AppColors.uadyBlue : AppColors.darkGray,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContinueButton() {
    return CustomButton(
      text: 'Continuar',
      onPressed: _isSaving ? null : _completeProfile,
      isLoading: _isSaving,
    );
  }

  Widget _buildSkipButton() {
    return TextButton(
      onPressed: _isSaving ? null : () => context.go('/home'),
      child: const Text(
        'Completar después',
        style: TextStyle(
          color: AppColors.darkGray,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
    );
  }
}
