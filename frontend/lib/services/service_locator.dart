import 'auth/auth_service.dart';
import 'profile/profile_service.dart';
import 'cita/service_citas.dart';
import 'specialty/specialty_service.dart';
import 'app_environment.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  final Map<Type, dynamic> _services = {};

  get busquedaService => null;

  get specialtyService => get<SpecialtyService>();

  void registerSingleton<T>(T service) {
    _services[T] = service;
  }

  T get<T>() {
    final service = _services[T];
    if (service == null) {
      throw Exception(
        'Service of type $T not found. Did you forget to register it?',
      );
    }
    return service as T;
  }

  bool isRegistered<T>() {
    return _services.containsKey(T);
  }

  void reset() {
    _services.clear();
  }
}

final ServiceLocator serviceLocator = ServiceLocator();

/// Aquí se inicializan todos los servicios de la aplicación para que puedan ser utilizados en cualquier parte de la app.
Future<void> setupServices() async {
  if (AppEnvironment.useMockServices) {
    AppEnvironment.printDebug('Usando servicios mock para testing');
  } else {
    AppEnvironment.printDebug('Usando servicios reales desde API');
    serviceLocator.registerSingleton<AuthService>(AuthService());
  }

  final authService = serviceLocator.get<AuthService>();
  AppEnvironment.printDebug('AuthService registrado correctamente');

  serviceLocator.registerSingleton<ProfileService>(ProfileService());
  serviceLocator.registerSingleton<ServiceCitas>(ServiceCitas());
  serviceLocator.registerSingleton<SpecialtyService>(
    SpecialtyService(authService),
  );
  
  AppEnvironment.printDebug('Todos los servicios inicializados correctamente');
}

extension ServiceLocatorExtensions on ServiceLocator {
  AuthService get authService => get<AuthService>();
  ProfileService get profileService => get<ProfileService>();
  ServiceCitas get serviceCitas => get<ServiceCitas>();
  SpecialtyService get specialtyService => get<SpecialtyService>();
}
