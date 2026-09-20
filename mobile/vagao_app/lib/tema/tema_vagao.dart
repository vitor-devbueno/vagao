import 'package:flutter/material.dart';

/// Identidade visual do projeto VAGÃO, traduzida da aplicação Web:
/// vermelho escuro, preto, tipografia serifada em títulos, monoespaçada
/// em labels, sombra dura (equivalente ao box-shadow duro do CSS).
class TemaVagao {
  TemaVagao._();

  static const Color vermelho = Color(0xFFA8192E);
  static const Color preto = Color(0xFF111111);
  static const Color painel = Color(0xFF1A1A1A);
  static const Color claro = Color(0xFFF2F2F2);

  /// Sombra dura de 8px, equivalente a "box-shadow: 8px 8px 0 #a8192e" da Web.
  static const List<BoxShadow> sombraDura = [
    BoxShadow(color: vermelho, offset: Offset(8, 8), blurRadius: 0),
  ];

  /// Título serifado, equivalente aos headings em Georgia da Web.
  static const TextStyle titulo = TextStyle(
    fontFamily: 'serif',
    fontWeight: FontWeight.w900,
    color: claro,
    letterSpacing: 1,
  );

  /// Label monoespaçado, equivalente aos labels em Courier New da Web.
  static const TextStyle label = TextStyle(
    fontFamily: 'monospace',
    fontSize: 12,
    letterSpacing: 2,
    color: vermelho,
  );

  static ThemeData get tema {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: preto,
      colorScheme: ColorScheme.fromSeed(
        seedColor: vermelho,
        brightness: Brightness.dark,
      ).copyWith(
        primary: vermelho,
        surface: painel,
        onPrimary: preto,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: vermelho,
        foregroundColor: preto,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: 'monospace',
          fontWeight: FontWeight.bold,
          letterSpacing: 4,
          color: preto,
          fontSize: 16,
        ),
      ),
      textTheme: const TextTheme(
        headlineMedium: titulo,
        headlineSmall: titulo,
        labelLarge: label,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: vermelho,
          foregroundColor: claro,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          textStyle: const TextStyle(
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: painel,
        labelStyle: label,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: vermelho, width: 2),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: vermelho, width: 2),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: claro, width: 2),
        ),
      ),
    );
    return base;
  }
}
