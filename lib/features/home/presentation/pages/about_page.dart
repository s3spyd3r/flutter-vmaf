import 'package:flutter/material.dart';
import '../widgets/about_info_section.dart';
import '../widgets/score_interpretation_card.dart';
import '../widgets/licenses_section.dart';
import '../widgets/ffmpeg_license_info.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AboutInfoSection(
              title: 'What is VMAF?',
              content: 'VMAF (Video Multimethod Assessment Fusion) is a '
                  'objective video quality metric developed by Netflix that '
                  'predicts how humans perceive video quality. It uses a '
                  'machine-learning model to combine multiple metrics and '
                  'produce a score from 0-100.\n\n'
                  'VMAF compares a "distorted" (encoded) video against a '
                  '"reference" (original) video to measure how much quality '
                  'was lost during encoding.',
            ),
            const SizedBox(height: 24),
            const ScoreInterpretationCard(),
            const SizedBox(height: 24),
            const AboutInfoSection(
              title: 'How This App Works',
              content: 'This app uses FFmpeg with the libvmaf filter to calculate '
                  'VMAF scores. You select an original (reference) video and '
                  'an encoded (distorted) video, and the app runs the VMAF '
                  'computation using FFmpeg.',
            ),
            const SizedBox(height: 24),
            const AboutInfoSection(
              title: 'App Version',
              content: 'Flutter VMAF v1.0.0',
              titleFontSize: 20,
              contentFontSize: 15,
            ),
            const SizedBox(height: 24),
            const LicensesSection(),
            const SizedBox(height: 24),
            const FfmpegLicenseInfo(),
          ],
        ),
      ),
    );
  }
}
