import 'package:flutter/material.dart';

import '../core/theme.dart';
import 'app_menu_glyph.dart';
import 'brand_logo.dart';

/// Compact SOC-style header shared by the tool screens.
class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon,
  });

  final String title;
  final String subtitle;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final scaffold = Scaffold.maybeOf(context);
    final hasMenu = scaffold?.hasDrawer ?? false;
    final badge = icon == null
        ? const LinkScannerLogo(size: 42, glowing: false)
        : Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: alpha(C.accent, 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: alpha(C.accent, 0.45)),
            ),
            child: Icon(icon, color: C.accent, size: 21),
          );

    return Padding(
      padding: EdgeInsets.fromLTRB(14, top + 9, 14, 13),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 11, 10, 11),
        decoration: BoxDecoration(
          color: C.surface,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: C.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(width: 6, height: 6, decoration: const BoxDecoration(color: C.green, shape: BoxShape.circle)),
                const SizedBox(width: 7),
                const Text(
                  'LINK SCANNER  /  SECURITY CONSOLE',
                  style: TextStyle(
                    color: C.secondary,
                    fontSize: 9,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.65,
                  ),
                ),
                const Spacer(),
                const Text('READY', style: TextStyle(color: C.green, fontSize: 9, fontFamily: 'monospace', fontWeight: FontWeight.w900)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                badge,
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: C.text, fontSize: 17, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: C.muted, fontSize: 10.5, height: 1.3),
                      ),
                    ],
                  ),
                ),
                if (hasMenu) ...[
                  const SizedBox(width: 8),
                  Material(
                    color: C.bg,
                    borderRadius: BorderRadius.circular(7),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(7),
                      onTap: () => scaffold?.openDrawer(),
                      child: Tooltip(
                        message: 'فتح القائمة الجانبية',
                        child: Semantics(
                          button: true,
                          label: 'فتح القائمة الجانبية',
                          child: const SizedBox(
                            width: 40,
                            height: 40,
                            child: Center(child: AppMenuGlyph(size: 22)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
