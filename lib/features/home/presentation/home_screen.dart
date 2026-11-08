import 'package:flutter/material.dart';

import '../../../shared/widgets/glass_widgets.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = <({String title, String subtitle, IconData icon, String route})>[
      (title: 'Unicode Explorer', subtitle: 'Find any character', icon: Icons.search_rounded, route: '/explorer'),
      (title: 'Name Studio', subtitle: 'Style your name', icon: Icons.auto_awesome_rounded, route: '/studio'),
      (title: 'Decorative Composer', subtitle: 'Build decorated text', icon: Icons.edit_rounded, route: '/composer'),
      (title: 'Emoji & Symbols', subtitle: 'Browse and copy symbols', icon: Icons.emoji_emotions_outlined, route: '/symbols'),
      (title: 'Combining Marks Lab', subtitle: 'Experiment with marks', icon: Icons.science_outlined, route: '/combining'),
    ];

    return Scaffold(
      appBar: GlassAppBar(title: const Text('Unicode Master Library')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.accentGradient,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.text_fields_rounded, color: Colors.white, size: 30),
                SizedBox(height: 14),
                Text('Explore. Create. Express.',
                    style: TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w800)),
                SizedBox(height: 6),
                Text('Your offline workspace for Unicode characters and creative text.',
                    style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('QUICK ACCESS',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                  )),
          const SizedBox(height: 10),
          ...actions.map((action) => Card(
                color: AppColors.surface,
                margin: const EdgeInsets.only(bottom: 9),
                child: ListTile(
                  onTap: () => context.go(action.route),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.surfaceHigh,
                    child: Icon(action.icon, color: AppColors.primary),
                  ),
                  title: Text(action.title),
                  subtitle: Text(action.subtitle),
                  trailing: const Icon(Icons.chevron_right_rounded),
                ),
              )),
        ],
      ),
    );
  }
}
