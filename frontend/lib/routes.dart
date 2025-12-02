import 'package:frontend/screens/busqueda/busqueda_screen.dart';
import 'package:frontend/screens/patron/work_pattern_screen.dart';
import 'package:frontend/screens/historial/historial_medico_screen.dart';
import 'package:go_router/go_router.dart';
import 'services/services.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/complete_profile_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/cita/screen_citas.dart';
import 'screens/auth/screen_profile.dart';
import 'screens/auth/update_profile_screen.dart';

final router = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) async {
    final authService = serviceLocator.authService;
    final loggedIn = await authService.isAuthenticated();
    final isLoginPage = state.uri.toString() == '/login';

    if (!loggedIn && isLoginPage) {
      return '/login';
    }
    if (loggedIn && isLoginPage) {
      return '/home';
    }
    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const ScreenLogin()),
    GoRoute(path: '/home', builder: (context, state) => const ScreenHomePage()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const ScreenRegistro(),
    ),
    GoRoute(
      path: '/complete-profile',
      builder: (context, state) => const CompleteProfileScreen(),
    ),
    GoRoute(path: '/citas', builder: (context, state) => const ScreenCitas()),
    GoRoute(path: '/perfil', builder: (context, state) => const ScreenPerfil()),
    GoRoute(
      path: '/busqueda',
      builder: (context, state) => const BusquedaScreen(),
    ),
    GoRoute(
      path: '/perfil/edit',
      builder: (context, state) => const ScreenEditarPerfil(),
    ),
    GoRoute(
      path: '/patrones-trabajo',
      builder: (context, state) => const WorkPatternScreen(),
    ),
    GoRoute(
      path: '/historial-medico',
      builder: (context, state) => const HistorialMedicoScreen(),
    ),
  ],
);
