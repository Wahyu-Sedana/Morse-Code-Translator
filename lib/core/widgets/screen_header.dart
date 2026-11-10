import 'package:flutter/material.dart';

import '../theme/app_text.dart';

class ScreenHeader extends StatelessWidget {
  const ScreenHeader({super.key, required this.eyebrow, required this.title, this.trailing});

  final String eyebrow;
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ExcludeSemantics(child: Text(eyebrow, style: AppText.eyebrow)),
                const SizedBox(height: 2),
                Semantics(header: true, child: Text(title, style: AppText.screenTitle)),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
