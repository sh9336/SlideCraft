import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'screens/home_screen.dart';
import 'providers/editor_provider.dart';
import 'constants/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
  
  // Delay background tasks to ensure the UI paints before the system dialog fights for resources
  Future.delayed(const Duration(milliseconds: 1000), () {
    _requestPermission();
  });
}

Future<void> _requestPermission() async {
  try {
    PermissionStatus status = await Permission.storage.status;

    if (!status.isGranted) {
      status = await Permission.storage.request();

      if (!status.isGranted) {
        status = await Permission.camera.request();
      }

      print('Storage permission status: $status');
    }
  } catch (e) {
    print('Error requesting permissions: $e');
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => EditorProvider(),
      child: MaterialApp(
        title: 'SlideCraft',
        theme: AppTheme.lightTheme(),
        darkTheme: AppTheme.darkTheme(),
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        home: HomeScreen(),
      ),
    );
  }
}

