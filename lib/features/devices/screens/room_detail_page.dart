import 'package:flutter/material.dart';
import '../widgets/device_card.dart';

class RoomDetailPage2 extends StatefulWidget {
  final String roomName;
  final List<Map<String, dynamic>> devices;

  const RoomDetailPage2({
    super.key,
    required this.roomName,
    required this.devices,
  });

  @override
  State<RoomDetailPage2> createState() => _RoomDetailPage2State();
}

class _RoomDetailPage2State extends State<RoomDetailPage2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.roomName),
        backgroundColor: const Color(0xFF1C1C27),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.separated(
          itemCount: widget.devices.length,
          separatorBuilder: (context, _) => const SizedBox(height: 6),
          itemBuilder: (context, index) {
            return DeviceCard(
              title: widget.devices[index]["title"],
              subtitle: widget.devices[index]["subtitle"],
              icon: widget.devices[index]["icon"],
              status: widget.devices[index]["status"],
              onChanged: (val) {
                setState(() {
                  widget.devices[index]["status"] = val;
                });
              },
            );
          },
        ),
      ),
    );
  }
}
