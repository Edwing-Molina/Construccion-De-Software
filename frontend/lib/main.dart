import 'package:flutter/material.dart';
import 'app.dart';

import 'services/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setupServices();

  runApp(const MyApp());
}
