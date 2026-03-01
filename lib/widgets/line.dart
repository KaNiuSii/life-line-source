import 'package:flutter/material.dart';
import 'package:life_line/data/models/line_data.dart';

// ============================================================
// KONFIGURACJA WYGLĄDU — edytuj tutaj
// ============================================================
class _Config {
  static const double canvasHeight = 400;
  static const double minWidthPerYear = 80.0;

  static const double lineStrokeWidth = 3;
  static final List<Color> lineGradientColors = [
    Colors.grey.shade300,
    Colors.grey.shade600,
    Colors.grey.shade300,
  ];

  static const double majorTickHeight = 5;
  static const double minorTickHeightFactor = 0.5;
  static const int majorTickEvery = 1;
  static final Color majorTickColor = Colors.grey.shade700;
  static final Color minorTickColor = Colors.grey.shade400;
  static const double majorTickStroke = 2;
  static const double minorTickStroke = 1;

  static const double yearLabelFontSize = 12;
  static final Color yearLabelColor = Colors.black;

  static const double dotOuterRadius = 6;
  static const double dotWhiteRadius = 4;
  static const double dotInnerRadius = 2.5;
  static const double dotEndRadius = 2;

  static const double eventLineLength = 50;
  static const double levelSpacing = 50;
  static const double eventLineStroke = 1.5;
  static const double eventLineOpacity = 0.3;

  static const Color positiveColor = Color(0xFF2E7D32);
  static const Color positiveLightColor = Color(0xFFA5D6A7);

  static const Color negativeColor = Color(0xFFC62828);
  static const Color negativeLightColor = Color(0xFFEF9A9A);

  static const double eventLabelFontSize = 11;
  static const double eventLabelBgOpacity = 0.3;
  static const double eventLabelMaxWidth = 130;
  static const double eventLabelPaddingH = 4;
  static const double eventLabelPaddingV = 2;
  static const double eventLabelBorderRadius = 4;
}
// ============================================================

class Line extends StatelessWidget {
  const Line({
    super.key,
    required this.ageStart,
    required this.ageEnd,
    required this.lineData,
  });

  final int ageStart;
  final int ageEnd;
  final List<LineData> lineData;

  @override
  Widget build(BuildContext context) {
    final int span = ageEnd - ageStart;
    final double totalWidth = (span * _Config.minWidthPerYear).clamp(
      MediaQuery.of(context).size.width,
      double.infinity,
    );

    return SizedBox(
      height: _Config.canvasHeight,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: totalWidth,
          height: _Config.canvasHeight,
          child: CustomPaint(
            painter: _DottedLinePainter(
              ageStart: ageStart,
              ageEnd: ageEnd,
              lineData: lineData,
            ),
          ),
        ),
      ),
    );
  }
}

class _DottedLinePainter extends CustomPainter {
  final int ageStart;
  final int ageEnd;
  final List<LineData> lineData;

  _DottedLinePainter({
    required this.ageStart,
    required this.ageEnd,
    required this.lineData,
  });

  int get _span => ageEnd - ageStart;

  double _xForAge(double age, double canvasWidth) {
    return canvasWidth * (age - ageStart) / _span;
  }

  double _measureTextWidth(String text) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: _Config.eventLabelFontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: _Config.eventLabelMaxWidth);
    return tp.width;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double cy = size.height / 2;

    // Linia główna
    canvas.drawLine(
      Offset(0, cy),
      Offset(size.width, cy),
      Paint()
        ..shader = LinearGradient(
          colors: _Config.lineGradientColors,
        ).createShader(Rect.fromLTWH(0, cy - 2, size.width, 4))
        ..strokeWidth = _Config.lineStrokeWidth
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );

    // Ticki i etykiety lat
    for (int i = ageStart; i <= ageEnd; i++) {
      final double x = _xForAge(i.toDouble(), size.width);
      final bool isMajor = i % _Config.majorTickEvery == 0;
      final double tH = isMajor
          ? _Config.majorTickHeight
          : _Config.majorTickHeight * _Config.minorTickHeightFactor;

      canvas.drawLine(
        Offset(x, cy - tH),
        Offset(x, cy + tH),
        Paint()
          ..color = isMajor ? _Config.majorTickColor : _Config.minorTickColor
          ..strokeWidth = isMajor
              ? _Config.majorTickStroke
              : _Config.minorTickStroke,
      );

      if (isMajor) {
        _drawLabel(
          canvas,
          '$i',
          x,
          cy + _Config.majorTickHeight + 4,
          fontSize: _Config.yearLabelFontSize,
          color: _Config.yearLabelColor,
          above: false,
          bold: false,
        );
      }
    }

    // Rozkład eventów na poziomy
    final List<_EventLayout> aboveEvents = [];
    final List<_EventLayout> belowEvents = [];

    for (final event in lineData) {
      final double x = _xForAge(event.age.toDouble(), size.width);
      final list = event.positive ? aboveEvents : belowEvents;

      final double myHalfWidth =
          _measureTextWidth(event.title) / 2 + _Config.eventLabelPaddingH;

      int level = 0;
      bool found = false;
      while (!found) {
        found = true;
        for (final placed in list) {
          final double placedHalfWidth =
              _measureTextWidth(placed.event.title) / 2 +
              _Config.eventLabelPaddingH;
          if (placed.level == level &&
              (placed.x - x).abs() < myHalfWidth + placedHalfWidth + 4) {
            level++;
            found = false;
            break;
          }
        }
      }
      list.add(_EventLayout(x: x, level: level, event: event));
    }

    // Rysuj eventy
    for (final layout in [...aboveEvents, ...belowEvents]) {
      final bool above = layout.event.positive;
      final Color color = above ? _Config.positiveColor : _Config.negativeColor;
      final Color colorLight = above
          ? _Config.positiveLightColor
          : _Config.negativeLightColor;
      final double x = layout.x;
      final double lineLen =
          _Config.eventLineLength + layout.level * _Config.levelSpacing;
      final double lineEnd = above ? cy - lineLen : cy + lineLen;

      canvas.drawLine(
        Offset(x, cy),
        Offset(x, lineEnd),
        Paint()
          ..color = color.withOpacity(_Config.eventLineOpacity)
          ..strokeWidth = _Config.eventLineStroke
          ..strokeCap = StrokeCap.round,
      );

      canvas.drawCircle(
        Offset(x, cy),
        _Config.dotOuterRadius,
        Paint()..color = color,
      );
      canvas.drawCircle(
        Offset(x, cy),
        _Config.dotWhiteRadius,
        Paint()..color = Colors.white,
      );
      canvas.drawCircle(
        Offset(x, cy),
        _Config.dotInnerRadius,
        Paint()..color = color,
      );
      canvas.drawCircle(
        Offset(x, lineEnd),
        _Config.dotEndRadius,
        Paint()..color = color,
      );

      _drawLabel(
        canvas,
        layout.event.title,
        x,
        above ? lineEnd - 6 : lineEnd + 6,
        fontSize: _Config.eventLabelFontSize,
        color: color,
        above: above,
        bold: true,
        bgColor: colorLight.withOpacity(_Config.eventLabelBgOpacity),
      );
    }
  }

  void _drawLabel(
    Canvas canvas,
    String text,
    double x,
    double y, {
    required double fontSize,
    required Color color,
    required bool above,
    required bool bold,
    Color? bgColor,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: _Config.eventLabelMaxWidth);

    final double dx = (x - textPainter.width / 2).clamp(0.0, double.infinity);
    final double dy = above ? y - textPainter.height - 2 : y + 2;

    if (bgColor != null) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            dx - _Config.eventLabelPaddingH,
            dy - _Config.eventLabelPaddingV,
            textPainter.width + _Config.eventLabelPaddingH * 2,
            textPainter.height + _Config.eventLabelPaddingV * 2,
          ),
          const Radius.circular(_Config.eventLabelBorderRadius),
        ),
        Paint()..color = bgColor,
      );
    }

    textPainter.paint(canvas, Offset(dx, dy));
  }

  @override
  bool shouldRepaint(_DottedLinePainter old) =>
      old.ageStart != ageStart ||
      old.ageEnd != ageEnd ||
      old.lineData != lineData;
}

class _EventLayout {
  final double x;
  final int level;
  final LineData event;

  _EventLayout({required this.x, required this.level, required this.event});
}
