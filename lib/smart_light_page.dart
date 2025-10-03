import 'package:flutter/material.dart';

class SmartLightPage extends StatefulWidget {
  final bool status;
  final ValueChanged<bool> onChanged;
  const SmartLightPage({
    Key? key,
    required this.status,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<SmartLightPage> createState() => _SmartLightPageState();
}

class _SmartLightPageState extends State<SmartLightPage> {
  late bool isOn;

  @override
  void initState() {
    super.initState();
    isOn = widget.status;
  }

  @override
  void didUpdateWidget(covariant SmartLightPage oldWidget) {
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
    widget.onChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Light'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lightbulb,
              color: isOn ? Colors.yellow : Colors.grey,
              size: 80,
            ),
            const SizedBox(height: 24),
            Switch.adaptive(
              value: isOn,
              onChanged: _handleSwitch,
              activeColor: Colors.deepPurple,
            ),
            const SizedBox(height: 12),
            Text(
              isOn ? 'Light is ON' : 'Light is OFF',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
