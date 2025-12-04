import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/services.dart';
import '../../models/models.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/common/gradient_background.dart';
import '../../widgets/common/logo_section.dart';
import '../../widgets/common/custom_button.dart';

class ScreenPerfil extends StatefulWidget {
  const ScreenPerfil({super.key});

  @override
  State<ScreenPerfil> createState() => _ScreenPerfilState();
}

class _ScreenPerfilState extends State<ScreenPerfil> {
  bool _isLoading = false;
  User? _usuario;
  List<Specialty> _specialties = [];
  List<ClinicInfo> _clinics = [];

  @override
  void initState() {
    super.initState();
    _loadPerfil();
  }

  Future<void> _loadPerfil() async {
    setState(() => _isLoading = true);

    try {
      final perfilService = serviceLocator.profileService;
      final response = await perfilService.getProfile();

      setState(() {
        _usuario = response.data;

        // Load specialties from the User model (already parsed by json_serializable)
        if (_usuario?.specialties != null) {
          _specialties = List<Specialty>.from(_usuario!.specialties!);
        }

        // Load clinics from the User model
        if (_usuario?.clinics != null) {
          _clinics =
              _usuario!.clinics!.map((clinic) {
                return ClinicInfo(
                  id: clinic.id,
                  name: clinic.name,
                  address: clinic.address,
                  officeNumber: clinic.officeNumber,
                );
              }).toList();
        }

        final doctor = _usuario?.doctor;
        debugPrint('Doctor description: ${doctor?.description}');
        debugPrint('Doctor license: ${doctor?.licenseNumber}');
        debugPrint(
          'Especialidades: ${_specialties.map((s) => s.name).toList()}',
        );
        debugPrint('Clínicas: ${_clinics.map((c) => c.name).toList()}');
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar perfil: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String? formatDate(DateTime? date) {
    if (date == null) return null;
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(context),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.20,
                child: const LogoSection(),
              ),
              Expanded(child: _buildPerfilCard()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.white),
            onPressed: () => context.go('/home'),
          ),
          const Text(
            'Mi Perfil',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildPerfilCard() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.uadyBlue),
      );
    }

    if (_usuario == null) {
      return const Center(
        child: Text(
          'No se pudo cargar la información.',
          style: TextStyle(color: AppColors.white, fontSize: 16),
        ),
      );
    }

    final doctor = _usuario!.doctor;
    final patient = _usuario!.patient;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 6,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Nombre', _usuario!.name),
                _buildDetailRow('Correo', _usuario!.email),
                if (_usuario!.phone != null)
                  _buildDetailRow('Teléfono', _usuario!.phone!),
                const Divider(),

                if (patient != null) ...[
                  _buildSectionTitle('Información del Paciente'),
                  _buildDetailRow(
                    'Fecha de nacimiento',
                    formatDate(patient.birth) ?? 'No especificada',
                  ),
                  if (patient.gender != null)
                    _buildDetailRow('Género', patient.gender!),
                  if (patient.bloodType != null)
                    _buildDetailRow('Tipo de Sangre', patient.bloodType!),
                  if (patient.emergencyContactName != null)
                    _buildDetailRow(
                      'Contacto de Emergencia',
                      patient.emergencyContactName!,
                    ),
                  if (patient.emergencyContactPhone != null)
                    _buildDetailRow(
                      'Tel. de Emergencia',
                      patient.emergencyContactPhone!,
                    ),
                  if (patient.nssNumber != null)
                    _buildDetailRow('Número NSS', patient.nssNumber!),
                ],

                if (doctor != null) ...[
                  _buildSectionTitle('Descripción del Doctor'),

                  if (doctor.description != null &&
                      doctor.description!.isNotEmpty)
                    _buildDetailRow('Cédula Profesional', doctor.description!),

                  _buildDetailRow(
                    'Especialidades',
                    _specialties.isNotEmpty
                        ? _specialties.map((s) => s.name).join(', ')
                        : 'No asignadas',
                  ),

                  ..._buildClinicInfo(),
                ],

                const SizedBox(height: 20),
                CustomButton(
                  text: 'Editar Perfil',
                  onPressed: () => context.go('/perfil/edit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.uadyBlue,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.darkGray,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(color: AppColors.uadyBlue, fontSize: 16),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildClinicInfo() {
    if (_clinics.isEmpty) {
      return [_buildDetailRow('Clínicas', 'No asignadas')];
    }

    List<Widget> widgets = [];
    for (int i = 0; i < _clinics.length; i++) {
      final clinic = _clinics[i];
      widgets.add(
        _buildDetailRow(i == 0 ? 'Clínica' : 'Clínica ${i + 1}', clinic.name),
      );
      if (clinic.officeNumber != null && clinic.officeNumber!.isNotEmpty) {
        widgets.add(_buildDetailRow('Consultorio', clinic.officeNumber!));
      }
      widgets.add(_buildDetailRow('Dirección', clinic.address));
      if (i < _clinics.length - 1) {
        widgets.add(const SizedBox(height: 10));
      }
    }
    return widgets;
  }
}
