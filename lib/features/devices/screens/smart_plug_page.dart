import 'package:flutter/material.dart';

class SmartPlugPage extends StatefulWidget {
  final bool status;
  final ValueChanged<bool> onChanged;
  const SmartPlugPage({Key? key, required this.status, required this.onChanged})
    : super(key: key);

  @override
  State<SmartPlugPage> createState() => _SmartPlugPageState();
}

class _SmartPlugPageState extends State<SmartPlugPage> {
  late bool isOn;

  @override
  void initState() {
    super.initState();
    isOn = widget.status;
  }

  @override
  void didUpdateWidget(covariant SmartPlugPage oldWidget) {
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
        title: const Text('Smart Plug'),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.power,
              color: isOn ? Colors.green : Colors.grey,
              size: 80,
            ),
            const SizedBox(height: 24),
            Switch.adaptive(
              value: isOn,
              onChanged: _handleSwitch,
              activeColor: Colors.teal,
            ),
            const SizedBox(height: 12),
            Text(
              isOn ? 'Plug is ON' : 'Plug is OFF',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
