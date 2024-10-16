// ignore_for_file: lines_longer_than_80_chars
import 'dart:convert';

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

import '../../shared/controllers/theme_controller.dart';

/// A function that exports the theme playground settings to JSON
String exportPlaygroundSettings(ThemeController controller) {
  final String data = JsonEncoder.withIndent(
    '    ',
    (dynamic object) {
      /// Custom converter for types that can't be serialised

      if (object is Color) {
        return <String, String>{
          'dart_type': 'color',
          'value': object.hex,
        };
      }

      if (object is Enum) {
        return <String, String>{
          'dart_type': 'enum',
          'enum_type': object.runtimeType.toString(),
          'value': object.name,
        };
      }

      return object;
    },
  ).convert(controller.exportSavedThemeData());

  return data;
}

/// A function that imports the saved theme playground settings from JSON
Future<void> importPlaygroundSettings(
  ThemeController controller, {
  required String settings,
}) {
  final Map<String, dynamic> json =
      jsonDecode(settings) as Map<String, dynamic>;

  final Map<String, dynamic> data = <String, dynamic>{};

  for (final MapEntry<String, dynamic> item in json.entries) {
    if (item.value is Map) {
      final dynamic dartType = item.value['dart_type'];
      final dynamic value = item.value['value'];

      final Object mapped = switch (dartType) {
        'color' => Color(int.parse("0x${value.replaceAll("#", "")}")),
        'enum' => switch (item.value['enum_type']) {
            'SchemeColor' => SchemeColor.values.firstWhere((element) =>
                element.name.toLowerCase() == (value as String).toLowerCase()),
            'ThemeMode' => ThemeMode.values.firstWhere((element) =>
                element.name.toLowerCase() == (value as String).toLowerCase()),
            _ => UnimplementedError(
                'TODO: handle enum type ${item.value['enum_type']}'),
          },
        _ => UnimplementedError('TODO: handle type $dartType'),
      };

      data[item.key] = mapped;
    } else {
      data[item.key] = item.value;
    }
  }

  return controller
      .importSavedThemeData(data)
      .then((value) => controller.loadAll());
}
