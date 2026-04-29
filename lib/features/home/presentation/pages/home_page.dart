import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vmaf/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:flutter_vmaf/features/settings/presentation/bloc/settings_event.dart';
import 'package:flutter_vmaf/features/settings/presentation/pages/settings_page.dart';
import 'package:flutter_vmaf/features/vmaf_calculation/presentation/pages/vmaf_page.dart';
import 'console_page.dart';
import 'about_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static const _pages = [
    VmafPage(),
    SettingsPage(),
    ConsolePage(),
    AboutPage(),
  ];

  @override
  void initState() {
    super.initState();
    context.read<SettingsBloc>().add(const LoadSettings());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.calculate_outlined),
                selectedIcon: Icon(Icons.calculate),
                label: Text('Calculate'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.terminal_outlined),
                selectedIcon: Icon(Icons.terminal),
                label: Text('Console'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.info_outline),
                selectedIcon: Icon(Icons.info),
                label: Text('About'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: _pages,
            ),
          ),
        ],
      ),
    );
  }
}