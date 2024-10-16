import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../shared/controllers/theme_controller.dart';
import '../../../../shared/widgets/universal/list_tile_reveal.dart';
import '../../../../shared/widgets/universal/syntax_highlighter.dart';
import '../../../utils/generate_theme_dart_code.dart';
import '../../../utils/import_export_playground_settings.dart';
import 'show_code_theme_colors.dart';

/// Show the code for the currently configured FlexColorScheme theme setup.
///
/// Used by in a panel to show the code next to settings panels.
/// As theme settings are configured and changed, the generated setup code
/// is updated and can be copied to the clipboard at any point.
class ThemeCode extends StatefulWidget {
  const ThemeCode(this.controller, {super.key});

  final ThemeController controller;

  @override
  State<ThemeCode> createState() => _ThemeCodeState();
}

class _ThemeCodeState extends State<ThemeCode> {
  late TextEditingController exportPlaygroundTexteditingController;

  @override
  void initState() {
    super.initState();
    exportPlaygroundTexteditingController = TextEditingController(text: null);
  }

  Future<void> _handleCopyCode(BuildContext context, String text) async {
    final double? width = MediaQuery.sizeOf(context).width > 800 ? 700 : null;
    final ClipboardData data = ClipboardData(text: text);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        width: width,
        content:
            const Text('FlexColorScheme setup code copied to the clipboard!'),
        duration: const Duration(milliseconds: 2000),
      ),
    );
    await Clipboard.setData(data);
  }

  @override
  Widget build(BuildContext context) {
    final String code = generateThemeDartCode(widget.controller);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 8),
        ListTileReveal(
          title: const Text('Copy the theme code'),
          subtitleDense: true,
          subtitle: const Text(
              'When you are happy with your theme design, you can copy the '
              'produced API configuration code. Paste it into your Flutter app '
              'and when used together with the FlexColorScheme package, your '
              'app gets the same theme.\n'),
          trailing: FilledButton(
            onPressed: () {
              unawaited(_handleCopyCode(context, code));
            },
            child: const Text('Copy'),
          ),
          onTap: () {
            unawaited(_handleCopyCode(context, code));
          },
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(16),
          child: SelectableText.rich(
            TextSpan(
              style: GoogleFonts.firaMono(fontSize: 12),
              children: <TextSpan>[
                DartSyntaxHighlighter(
                  SyntaxHighlighterStyle.harmonized(context),
                ).format(code),
              ],
            ),
          ),
        ),
        const Divider(height: 1),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: ShowCodeThemeColors(),
        ),
        const ListTileReveal(
          dense: true,
          title: Text('CodeTheme is a ThemeData ThemeExtension'),
          subtitle: Text('The above colors have been added as a custom theme '
              'extension to ThemeData. Light and dark mode CodeTheme change '
              'with theme mode and is accessed via Theme.of(context). The '
              'extension colors are also using Material-3 color harmonization '
              'with active theme. When you change theme you can see that '
              'these semantic CodeTheme colors are often automatically '
              'slightly adjusted towards the overall theme colors. '
              'This CodeTheme is used as a ThemeExtension example in the '
              'Themes Playground app. It also demonstrates how to use '
              'Material-3 color harmonization of custom theme colors in '
              'Flutter.\n'
              '\n'
              'The used group colors for theme topic panels, are using the '
              'same theme harmonization. When you change themes you will '
              'notice that they also change color temperature to fit better '
              'with selected theme\n'),
        ),
        const Divider(),
        ListTileReveal(
          title: const Text('Export playground theme'),
          subtitleDense: true,
          subtitle: const Text(
              'Export theme settings, which can later be re-imported here.'),
          trailing: FilledButton(
            onPressed: () {
              _handleExportPlaygroundTheme(context);
            },
            child: const Text('Export'),
          ),
          onTap: () {
            _handleExportPlaygroundTheme(context);
          },
        ),
        ListTileReveal(
          title: const Text('Import playground theme'),
          subtitleDense: true,
          subtitle: const Text('Import theme settings exported above.'),
          trailing: FilledButton(
            onPressed: () {
              _handleImportPlaygroundTheme(context);
            },
            child: const Text('Import'),
          ),
          onTap: () {
            _handleImportPlaygroundTheme(context);
          },
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextFormField(
            controller: exportPlaygroundTexteditingController,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            minLines: 4,
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  void _handleExportPlaygroundTheme(BuildContext context) {
    try {
      final String data = exportPlaygroundSettings(widget.controller);
      exportPlaygroundTexteditingController.text = data;
      unawaited(_handleCopyCode(context, data));
    } on Exception catch (error, stackTrace) {
      debugPrintStack(
        label: 'Error exporting playground theme data: $error',
        stackTrace: stackTrace,
      );
      final double? width = MediaQuery.sizeOf(context).width > 800 ? 700 : null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          width: width,
          content: Text('Unable to export playground settings, $error'),
          duration: const Duration(milliseconds: 2000),
        ),
      );
    }
  }

  void _handleImportPlaygroundTheme(BuildContext context) {
    try {
      final String text = exportPlaygroundTexteditingController.text;
      if (text.isNotEmpty) {
        unawaited(importPlaygroundSettings(widget.controller, settings: text));
      }
    } on Exception catch (error, stackTrace) {
      debugPrintStack(
        label: 'Error importing playground theme data: $error',
        stackTrace: stackTrace,
      );
      final double? width = MediaQuery.sizeOf(context).width > 800 ? 700 : null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          width: width,
          content: Text('Unable to import playground settings, $error'),
          duration: const Duration(milliseconds: 2000),
        ),
      );
    }
  }
}
