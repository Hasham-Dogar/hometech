import 'package:flutter/material.dart';

class SmartTVPage extends StatelessWidget {
  const SmartTVPage({super.key});

  Widget _remoteButton(IconData icon, {VoidCallback? onTap, double size = 36}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(32),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: size, color: Colors.deepPurple),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart TV Remote'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Power button
            _remoteButton(Icons.power_settings_new, onTap: () {}, size: 40),
            const SizedBox(height: 32),
            // D-pad
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 56),
                _remoteButton(Icons.keyboard_arrow_up, onTap: () {}),
                const SizedBox(width: 56),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _remoteButton(Icons.keyboard_arrow_left, onTap: () {}),
                const SizedBox(width: 16),
                _remoteButton(
                  Icons.radio_button_checked,
                  onTap: () {},
                  size: 32,
                ), // OK
                const SizedBox(width: 16),
                _remoteButton(Icons.keyboard_arrow_right, onTap: () {}),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 56),
                _remoteButton(Icons.keyboard_arrow_down, onTap: () {}),
                const SizedBox(width: 56),
              ],
            ),
            const SizedBox(height: 32),
            // Volume and channel
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    _remoteButton(Icons.volume_up, onTap: () {}),
                    const SizedBox(height: 8),
                    _remoteButton(Icons.volume_off, onTap: () {}),
                  ],
                ),
                const SizedBox(width: 32),
                Column(
                  children: [
                    _remoteButton(Icons.arrow_drop_up, onTap: () {}),
                    const SizedBox(height: 8),
                    _remoteButton(Icons.arrow_drop_down, onTap: () {}),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Home and Back
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _remoteButton(Icons.home, onTap: () {}),
                const SizedBox(width: 32),
                _remoteButton(Icons.arrow_back, onTap: () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
