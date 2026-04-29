import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/injection.dart' as di;
import 'core/utils/logger.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/presentation/bloc/settings_bloc.dart';
import 'features/vmaf_calculation/presentation/bloc/vmaf_bloc.dart';
import 'features/home/presentation/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Logger.init();
  await di.initDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SettingsBloc>(
          create: (_) => di.sl<SettingsBloc>(),
        ),
        BlocProvider<VmafBloc>(
          create: (_) => di.sl<VmafBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'VMAF Calculator',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const HomePage(),
      ),
    );
  }
}