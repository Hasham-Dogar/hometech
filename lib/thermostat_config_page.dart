import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<Color>? gradient;
  final bool selected;
  final VoidCallback? onTap;
  final double size;

  const _NavButton({
    required this.icon,
    required this.label,
    this.gradient,
    this.selected = false,
    this.onTap,
    this.size = 52,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        NeumorphicButton(
          style: NeumorphicStyle(
            depth: selected ? -4 : 4,
            intensity: 0.8,
            lightSource: LightSource.bottom,
            color: const Color.fromARGB(255, 255, 255, 255),
            boxShape: NeumorphicBoxShape.circle(),
          ),
          onPressed: onTap,
          child: SizedBox(
            width: size,
            height: size,
            child: Center(
              child: ShaderMask(
                blendMode: BlendMode.srcATop,
                shaderCallback: (Rect bounds) {
                  return gradient != null && selected
                      ? LinearGradient(
                          colors: gradient!,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds)
                      : const LinearGradient(
                          colors: [Colors.grey, Colors.grey],
                        ).createShader(bounds); // Use grey if not selected
                },
                child: Icon(icon, size: size * 0.5, color: Colors.white),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected
                ? const Color(0xFFB16CEA) // Purple color for selected label
                : Colors.grey.shade600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

void main() {
  runApp(
    NeumorphicApp(
      debugShowCheckedModeBanner: false,
      theme: NeumorphicThemeData(
        baseColor: const Color.fromARGB(255, 167, 167, 167),
        lightSource: LightSource.bottom,
        depth: 4,
        intensity: 0.8,
      ),
      home: ThermostatScreen(),
    ),
  );
}

class ThermostatDial extends StatefulWidget {
  final double temperature;
  final ValueChanged<double> onChanged;
  final bool showEcoIcon;
  final double width;
  final double height;

  const ThermostatDial({
    Key? key,
    required this.temperature,
    required this.onChanged,
    this.showEcoIcon = true,
    this.width = 300,
    this.height = 240,
  }) : super(key: key);

  @override
  State<ThermostatDial> createState() => _ThermostatDialState();
}

class _ThermostatDialState extends State<ThermostatDial> {
  final GlobalKey _gestureKey = GlobalKey();

  double tempToAngle(double temp) {
    return ((temp - 10) / (30 - 10)) * pi;
  }

  double angleToTemp(double angle) {
    return 10 + (angle / pi) * (30 - 10);
  }

  void _onPanUpdate(Offset localPosition, Size size) {
    final center = size.center(Offset.zero);
    final dx = localPosition.dx - center.dx;
    final dy = localPosition.dy - center.dy;
    double angle = atan2(dy, dx);

    if (angle < 0) angle += 2 * pi;
    if (angle >= pi && angle <= 2 * pi) {
      final newTemp = angleToTemp(angle - pi);
      widget.onChanged(newTemp.clamp(10, 30));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: _gestureKey,
      onPanUpdate: (details) {
        final RenderBox box =
            _gestureKey.currentContext!.findRenderObject() as RenderBox;
        _onPanUpdate(box.globalToLocal(details.globalPosition), box.size);
      },
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            CustomPaint(
              size: Size(widget.width, widget.height),
              painter: ThermostatPainter(widget.temperature),
            ),
            Positioned(
              bottom: 0,
              child: Neumorphic(
                style: NeumorphicStyle(
                  depth: 8,
                  intensity: 0.8,
                  boxShape: NeumorphicBoxShape.circle(),
                  color: Colors.white,
                ),
                child: Container(
                  width: 140,
                  height: 140,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.temperature.toStringAsFixed(0),
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF22223B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (widget.showEcoIcon)
                          const Icon(Icons.eco, color: Colors.green),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ThermostatScreen extends StatefulWidget {
  const ThermostatScreen({super.key});

  @override
  State<ThermostatScreen> createState() => _ThermostatScreenState();
}

class _ThermostatScreenState extends State<ThermostatScreen> {
  double _temperature = 20;
  String _selectedDevice = "device 1";
  int _selectedIndex = 0;
  // 0: Cooling, 1: Heating, 2: Fan, 3: Dry ("cry"/dry)
  int _modeIndex = 1; // default to Heating
  bool _ecoEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeumorphicTheme.baseColor(context),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    NeumorphicButton(
                      style: const NeumorphicStyle(
                        depth: 2,
                        boxShape: NeumorphicBoxShape.circle(),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Color(0xFF9A9AB0),
                      ),
                    ),
                    const Text(
                      "Thermostat",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF22223B),
                      ),
                    ),
                    NeumorphicButton(
                      style: const NeumorphicStyle(
                        depth: 2,
                        boxShape: NeumorphicBoxShape.circle(),
                      ),
                      onPressed: () {},
                      child: const Icon(
                        Icons.settings,
                        color: Color(0xFF9A9AB0),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ThermostatDial(
                temperature: _temperature,
                showEcoIcon: _ecoEnabled,
                onChanged: (val) {
                  setState(() {
                    _temperature = val;
                  });
                },
              ),
              const SizedBox(height: 20),
              // Display current mode (cycles when MODE button is tapped)
              Builder(
                builder: (context) {
                  final modeLabels = ['COOLING', 'HEATING', 'FAN', 'DRY'];
                  final modeColors = [
                    Color(0xFF4FC3F7), // blue for cooling
                    Color(0xFFE74C3C), // red for heating
                    Colors.black, // black for fan
                    Colors.grey, // grey for dry/cry
                  ];
                  final label = modeLabels[_modeIndex % modeLabels.length];
                  final color = modeColors[_modeIndex % modeColors.length];
                  return Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                      letterSpacing: 2,
                    ),
                  );
                },
              ),
              const SizedBox(height: 28),
              Neumorphic(
                style: NeumorphicStyle(
                  depth: 4,
                  intensity: 0.8,
                  boxShape: NeumorphicBoxShape.roundRect(
                    BorderRadius.circular(12),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedDevice,
                      items: const [
                        DropdownMenuItem(
                          value: "device 1",
                          child: Text("device 1"),
                        ),
                        DropdownMenuItem(
                          value: "device 2",
                          child: Text("device 2"),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedDevice = value!;
                        });
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 64.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    _InfoBox(
                      icon: Icons.water_drop,
                      iconColor: Color(0xFF4FC3F7),
                      label: "Inside humidity",
                      value: "49 %",
                    ),
                    SizedBox(width: 16),
                    _InfoBox(
                      icon: Icons.thermostat,
                      iconColor: Color(0xFFFFB74D),
                      label: "Outside temps.",
                      value: "-10°",
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 8.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _NavButton(
                      icon: Icons.hot_tub,
                      label: "MODE",
                      size: 52,
                      gradient: [Color(0xFFB16CEA), Color(0xFFFF5E69)],
                      selected: _selectedIndex == 0,
                      onTap: () => setState(() {
                        // cycle through modes: 0->1->2->3->0
                        _modeIndex = (_modeIndex + 1) % 4;
                        _selectedIndex = 0;
                      }),
                    ),
                    _NavButton(
                      icon: Icons.eco,
                      label: "ECO",
                      size: 52,
                      gradient: [Color(0xFFB16CEA), Color(0xFFFF5E69)],
                      selected: _selectedIndex == 1,
                      onTap: () => setState(() {
                        // toggle eco icon visibility
                        _ecoEnabled = !_ecoEnabled;
                        _selectedIndex = 1;
                      }),
                    ),
                    _NavButton(
                      icon: Icons.schedule,
                      label: "SCHEDULE",
                      size: 52,
                      gradient: [Color(0xFFB16CEA), Color(0xFFFF5E69)],
                      selected: _selectedIndex == 2,
                      onTap: () => setState(() => _selectedIndex = 2),
                    ),
                    _NavButton(
                      icon: Icons.history,
                      label: "HISTORY",
                      size: 52,
                      gradient: [Color(0xFFB16CEA), Color(0xFFFF5E69)],
                      selected: _selectedIndex == 3,
                      onTap: () => setState(() => _selectedIndex = 3),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ThermostatPainter extends CustomPainter {
  final double temperature;
  ThermostatPainter(this.temperature);

  Color lerpGradient(List<Color> colors, List<double> stops, double t) {
    for (int i = 0; i < stops.length - 1; i++) {
      if (t >= stops[i] && t <= stops[i + 1]) {
        final localT = (t - stops[i]) / (stops[i + 1] - stops[i]);
        return Color.lerp(colors[i], colors[i + 1], localT)!;
      }
    }
    return colors.last;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height - 40);
    final radius = size.width / 2 - 20;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Gradient colors
    const gradientColors = [
      Color(0xFFB16CEA), // purple
      Color(0xFFFF5E69), // pink
      Color(0xFFFF8A56), // orange
      Color(0xFFFFC86A), // yellow
    ];
    const gradientStops = [0.0, 0.33, 0.66, 1.0];

    // Background arc
    final bgPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14;
    canvas.drawArc(rect, pi, pi, false, bgPaint);

    // Active arc
    final sweep = ((temperature - 10) / (30 - 10)) * pi;
    if (sweep > 0) {
      final activeGradient = SweepGradient(
        startAngle: pi,
        endAngle: pi + sweep,
        colors: gradientColors,
        stops: gradientStops,
      );
      final activePaint = Paint()
        ..shader = activeGradient.createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round; // 👈 rounded ends
      canvas.drawArc(rect, pi, sweep, false, activePaint);
    }

    // Tick marks (lighter + further away)
    final tickPaint = Paint()
      ..color = Colors.grey.withOpacity(0.35)
      ..strokeWidth = 1.5;
    for (int i = 0; i <= 20; i++) {
      double tickOuter = radius + 40; // further out
      double tickInner = (i % 2 == 0) ? radius + 28 : radius + 32;

      final tickAngle = pi + (i / 20) * pi;
      final tickStart = Offset(
        center.dx + tickInner * cos(tickAngle),
        center.dy + tickInner * sin(tickAngle),
      );
      final tickEnd = Offset(
        center.dx + tickOuter * cos(tickAngle),
        center.dy + tickOuter * sin(tickAngle),
      );
      canvas.drawLine(tickStart, tickEnd, tickPaint);
    }

    // Glossy highlight dot (instead of knob dot)
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(
      Offset(center.dx + radius * 0.5, center.dy - radius * 0.5),
      8,
      highlightPaint,
    );

    // Labels (keep your 10°, 20°, 30° exactly)
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    final labels = {10: pi, 20: 1.5 * pi, 30: 2 * pi};
    labels.forEach((value, angle) {
      final offset = Offset(
        center.dx + (radius + 50) * cos(angle), // a little further
        center.dy + (radius + 50) * sin(angle),
      );
      textPainter.text = TextSpan(
        text: "$value°",
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        offset - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    });
  }

  @override
  bool shouldRepaint(ThermostatPainter oldDelegate) =>
      oldDelegate.temperature != temperature;
}

class _InfoBox extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _InfoBox({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Neumorphic(
      style: NeumorphicStyle(
        depth: 4,
        intensity: 0.8,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 32),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 14, color: const Color(0xFF86878D)),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF86878D),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
