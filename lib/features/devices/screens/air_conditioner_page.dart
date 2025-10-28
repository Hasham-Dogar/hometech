import 'package:flutter/material.dart';
import 'thermostat_config_page.dart';

class AirConditionerPage extends StatefulWidget {
  final double initialTemp;
  final bool status;
  final ValueChanged<bool> onStatusChanged;

  const AirConditionerPage({
    Key? key,
    this.initialTemp = 24.0,
    required this.status,
    required this.onStatusChanged,
  }) : super(key: key);

  @override
  State<AirConditionerPage> createState() => _AirConditionerPageState();
}

class _AirConditionerPageState extends State<AirConditionerPage> {
  late bool isOn;

  @override
  void initState() {
    super.initState();
    isOn = widget.status;
  }

  @override
  void didUpdateWidget(covariant AirConditionerPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.status != widget.status) {
      setState(() {
        isOn = widget.status;
      });
    }
  }

  void _handleSwitch(bool value) {
    setState(() {
      isOn = value;
    });
    widget.onStatusChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Air Conditioner'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.ac_unit,
              color: isOn ? Colors.blueAccent : Colors.grey,
              size: 60,
            ),
            const SizedBox(height: 16),
            Switch.adaptive(
              value: isOn,
              onChanged: _handleSwitch,
              activeColor: Colors.blueAccent,
            ),
            const SizedBox(height: 8),
            Text(
              isOn ? 'AC is ON' : 'AC is OFF',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _DialSection(initialTemp: widget.initialTemp),
          ],
        ),
      ),
    );
  }
}

class _DialSection extends StatefulWidget {
  final double initialTemp;
  const _DialSection({Key? key, required this.initialTemp}) : super(key: key);

  @override
  State<_DialSection> createState() => _DialSectionState();
}

class _DialSectionState extends State<_DialSection> {
  double temp = 24.0;

  @override
  void initState() {
    super.initState();
    temp = widget.initialTemp;
  }

  @override
  Widget build(BuildContext context) {
    return ThermostatDial(
      temperature: temp,
      onChanged: (val) {
        setState(() {
          temp = val;
        });
      },
      showEcoIcon: false,
    );
  }
}
