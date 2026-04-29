import 'package:flutter/material.dart';
import 'license_entry.dart';

class LicensesSection extends StatelessWidget {
  const LicensesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Licenses',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        const Text(
          'This application uses the following open source packages:',
          style: TextStyle(fontSize: 15),
        ),
        const SizedBox(height: 12),
        const LicenseEntry(
          package: 'flutter_bloc',
          license: 'BSD-3-Clause',
          url: 'https://github.com/felangel/flutter_bloc',
        ),
        const LicenseEntry(
          package: 'Freezed',
          license: 'MIT',
          url: 'https://github.com/rrousselGit/freezed',
        ),
        const LicenseEntry(
          package: 'Dartz',
          license: 'MIT',
          url: 'https://github.com/spebbe/dartz',
        ),
        const LicenseEntry(
          package: 'GetIt',
          license: 'MIT',
          url: 'https://github.com/fluttercommunity/get_it',
        ),
        const LicenseEntry(
          package: 'File Picker',
          license: 'MIT',
          url: 'https://github.com/miguelpruivo/flutter_file_picker',
        ),
        const LicenseEntry(
          package: 'Equatable',
          license: 'MIT',
          url: 'https://github.com/felangel/equatable',
        ),
        const LicenseEntry(
          package: 'Path Provider',
          license: 'MIT',
          url: 'https://github.com/flutter/plugins',
        ),
        const LicenseEntry(
          package: 'JSON Serializable',
          license: 'MIT',
          url: 'https://github.com/google/json_serializable.dart',
        ),
      ],
    );
  }
}
