import 'package:material_ui/material_ui.dart';

import '../../../shared/widgets/surface_card.dart';

class SectionEmptyState extends StatelessWidget {
  const SectionEmptyState({required this.icon, required this.text, super.key});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            Icon(icon, size: 60, color: Colors.white30),
            const SizedBox(height: 16),
            Text(
              text,
              style: const TextStyle(fontSize: 16, color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }
}
