import 'package:flutter/material.dart';

import '../../../core/text_design/combining_marks.dart';
import '../../../core/text_design/design_themes.dart';
import '../../../core/text_design/design_types.dart';
import '../../../core/text_design/text_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/export_formats.dart';
import '../../../shared/widgets/glass_widgets.dart';

/// One generated design or font style with one-tap copy.
///
/// Tapping anywhere on the card copies the text; the buttons add favorite and
/// details. The card is deliberately blur-free: a hundred backdrop filters in
/// one scrolling list would be slow.
class DesignCard extends StatelessWidget {
  const DesignCard({
    required this.text,
    required this.caption,
    required this.isFavorite,
    required this.onCopy,
    required this.onFavorite,
    super.key,
    this.onDetails,
    this.hasCaution = false,
  });

  final String text;
  final String caption;
  final bool isFavorite;
  final bool hasCaution;
  final VoidCallback onCopy;
  final VoidCallback onFavorite;
  final VoidCallback? onDetails;

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      blurEnabled: false,
      padding: EdgeInsets.zero,
      radius: 16,
      child: InkWell(
        onTap: onCopy,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 6, 4),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    height: 1.6,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  if (hasCaution)
                    const Tooltip(
                      message: 'Some marks may render differently in other apps',
                      child: Icon(
                        Icons.info_outline_rounded,
                        size: 18,
                        color: Colors.amber,
                      ),
                    ),
                  IconButton(
                    tooltip: 'Copy',
                    visualDensity: VisualDensity.compact,
                    iconSize: 20,
                    onPressed: onCopy,
                    icon: const Icon(Icons.copy_rounded),
                  ),
                  IconButton(
                    tooltip: isFavorite ? 'Remove favorite' : 'Add favorite',
                    visualDensity: VisualDensity.compact,
                    iconSize: 20,
                    onPressed: onFavorite,
                    icon: Icon(
                      isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: isFavorite ? Colors.pinkAccent : null,
                    ),
                  ),
                  if (onDetails != null)
                    IconButton(
                      tooltip: 'Details',
                      visualDensity: VisualDensity.compact,
                      iconSize: 20,
                      onPressed: onDetails,
                      icon: const Icon(Icons.more_horiz_rounded),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Caption such as `Cute · Mathematical Bold + Script`.
String designCaption(GeneratedDesign design) {
  final theme = DesignThemes.byId(design.themeId)?.label ?? design.themeId;
  final fonts = [
    for (final id in design.fontIds) TextFonts.byId(id)?.label ?? id,
  ];
  return fonts.isEmpty ? theme : '$theme · ${fonts.join(' + ')}';
}

/// Result of the details sheet.
enum DesignAction { copy, copyCodePoints, share }

/// Shows code points, compatibility advice and actions for [design].
Future<DesignAction?> showDesignDetails(
  BuildContext context,
  GeneratedDesign design,
) {
  return showModalBottomSheet<DesignAction>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.65,
        maxChildSize: 0.92,
        minChildSize: 0.4,
        builder: (context, controller) {
          return ListView(
            controller: controller,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            children: [
              Center(
                child: SelectableText(
                  design.text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 26, height: 1.6),
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: Text(
                  '${designCaption(design)} · ${design.graphemeCount} characters '
                  '· ${design.codePoints.length} code points',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: GlassButton(
                      label: 'Copy',
                      icon: Icons.copy_rounded,
                      filled: true,
                      onPressed: () =>
                          Navigator.of(sheetContext).pop(DesignAction.copy),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GlassButton(
                      label: 'Share',
                      icon: Icons.share_rounded,
                      onPressed: () =>
                          Navigator.of(sheetContext).pop(DesignAction.share),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Text(
                'CODE POINTS',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.textSecondary,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              SelectableText(
                ExportFormats.codePointsOf(design.text),
                style: const TextStyle(
                  color: AppColors.secondary,
                  fontFamily: 'monospace',
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () => Navigator.of(sheetContext)
                    .pop(DesignAction.copyCodePoints),
                icon: const Icon(Icons.copy_all_rounded, size: 18),
                label: const Text('Copy code points'),
              ),
              const SizedBox(height: 14),
              Text(
                'COMPATIBILITY',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.textSecondary,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              for (final warning in design.warnings)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        warning.level == WarningLevel.caution
                            ? Icons.warning_amber_rounded
                            : Icons.info_outline_rounded,
                        size: 18,
                        color: warning.level == WarningLevel.caution
                            ? Colors.amber
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(warning.message)),
                    ],
                  ),
                ),
              const Text(
                renderingDisclaimer,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          );
        },
      );
    },
  );
}
