import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/services.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/widgets.dart';

class ScreenHomePage extends StatefulWidget {
  const ScreenHomePage({super.key});

  @override
  State<ScreenHomePage> createState() => _ScreenHomePageState();
}

class _ScreenHomePageState extends State<ScreenHomePage> {
  String? userRole;
  String? userName;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final profileService = serviceLocator.get<ProfileService>();
      final authService = serviceLocator.authService;

      final profileResponse = await profileService.getProfile();
      final role = await authService.getUserRole();

      if (profileResponse.success && profileResponse.data != null) {
        setState(() {
          userName = profileResponse.data!.name;
          userRole = role;
          isLoading = false;
        });
      } else {
        _loadUserDataFromCache();
      }
    } catch (e) {
      _loadUserDataFromCache();
    }
  }

  Future<void> _loadUserDataFromCache() async {
    try {
      final authService = serviceLocator.authService;
      final user = await authService.getCurrentUser(forceRefresh: false);
      final role = await authService.getUserRole();

      setState(() {
        userName = user?.name ?? 'Usuario';
        userRole = role;
        isLoading = false;
      });
    } catch (cacheError) {
      setState(() {
        userName = 'Usuario';
        userRole = null;
        isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    try {
      final authService = serviceLocator.authService;
      await authService.logout();

      if (mounted) {
        context.go('/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cerrar sesión: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: AppColors.lightBackground,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (userRole != 'patient' && userRole != 'doctor') {
      return Scaffold(
        backgroundColor: AppColors.lightBackground,
        body: const Center(child: Text('Acceso denegado :(')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: CustomAppBar(title: 'Servicio Médico UADY', onLogout: _logout),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 800),
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.only(top: 20, bottom: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UserInfoCard(
                userName: userName ?? 'Usuario',
                userRole: userRole ?? 'No definido',
              ),
              const SizedBox(height: 25),

              const Text(
                'Menú Principal',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.uadyBlue,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 15),

              GridMenu(userRole: userRole ?? '', onNavigate: _navigateToRoute),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToRoute(String route) {
    context.go(route);
  }
}
