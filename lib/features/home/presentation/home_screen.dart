import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const actions = <({String title, String subtitle, IconData icon, String route})>[
      (title: 'Unicode Explorer', subtitle: 'Find any character', icon: Icons.search_rounded, route: '/explorer'),
      (title: 'Name Studio', subtitle: 'Style your name', icon: Icons.auto_awesome_rounded, route: '/studio'),
      (title: 'Decorative Composer', subtitle: 'Build decorated text', icon: Icons.edit_rounded, route: '/composer'),
      (title: 'Emoji & Symbols', subtitle: 'Browse and copy symbols', icon: Icons.emoji_emotions_outlined, route: '/symbols'),
      (title: 'Combining Marks Lab', subtitle: 'Experiment with marks', icon: Icons.science_outlined, route: '/combining'),
    ];

    return Scaffold(
      appBar: const GlassAppBar(title: Text('Unicode Master Library')),
      body: ListView(
        // Extra bottom padding keeps the last card clear of the floating
        // glass navigation bar.
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
        children: [
          GlassSurface(
            padding: const EdgeInsets.all(20),
            radius: 24,
            blurSigma: 26,
            tint: AppColors.primary.withValues(alpha: 0.38),
            borderColor: const Color(0x73FFFFFF),
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
          ...actions.map((action) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GlassSurface(
                  padding: EdgeInsets.zero,
                  child: ListTile(
                    onTap: () => context.go(action.route),
                    leading: CircleAvatar(
                      backgroundColor: const Color(0x33FFFFFF),
                      child: Icon(action.icon, color: Colors.white),
                    ),
                    title: Text(action.title),
                    subtitle: Text(action.subtitle),
                    trailing: const Icon(Icons.chevron_right_rounded),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
