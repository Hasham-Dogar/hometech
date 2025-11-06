part of 'home_page.dart';

mixin _HomePageContent on State<HomePage> {
  // Abstract declarations for state variables
  // ignore: unused_element
  int get _tabIndex;
  // ignore: unused_element
  set _tabIndex(int value);

  List<Map<String, dynamic>> get rooms;
  List<Map<String, dynamic>> get devices;

  Widget _buildContent(bool isSmallScreen) {
    if (_tabIndex == 0) {
      return GridView.builder(
        physics: const BouncingScrollPhysics(),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 250,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
        ),
        itemCount: rooms.length,
        itemBuilder: (context, index) {
          final room = rooms[index];
          return GestureDetector(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RoomDetailPage2(
                    roomName: room["title"],
                    devices: devices
                        .where((d) => d["subtitle"] == room["title"])
                        .toList(),
                  ),
                ),
              );
              if (mounted) setState(() {});
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRect(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          room["image"],
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.error, size: 50),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            room["title"],
                            style: TextStyle(
                              fontSize: isSmallScreen ? 12 : 14,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF22223B),
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            room["devices"],
                            style: TextStyle(
                              fontSize: isSmallScreen ? 8 : 10,
                              color: const Color(0xFF9A9AB0),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                room["status"] ? "ON" : "OFF",
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 8 : 10,
                                  color: room["status"]
                                      ? const Color(0xFFB16CEA)
                                      : const Color(0xFF9A9AB0),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              Switch(
                                value: room["status"],
                                onChanged: (val) {
                                  setState(() {
                                    rooms[index]["status"] = val;
                                  });
                                },
                                activeThumbColor: const Color(0xFFB16CEA),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }

    // Devices list
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: devices.length,
      separatorBuilder: (context, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final device = devices[index];
        Widget card = DeviceCard(
          title: device["title"],
          subtitle: device["subtitle"],
          icon: device["icon"],
          status: device["status"],
          onChanged: (val) {
            setState(() {
              devices[index]["status"] = val;
              final roomTitle = devices[index]["subtitle"];
              final roomIndex = rooms.indexWhere(
                (r) => r["title"] == roomTitle,
              );
              if (roomIndex != -1) {
                final anyOn = devices
                    .where((d) => d["subtitle"] == roomTitle)
                    .any((d) => d["status"] == true);
                rooms[roomIndex]["status"] = anyOn;
              }
            });
          },
        );

        switch (device["title"]) {
          case "Thermostat":
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ThermostatScreen()),
                );
              },
              child: card,
            );
          case "Smart Light":
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SmartLightPage(
                      status: device["status"],
                      onChanged: (val) {
                        setState(() {
                          devices[index]["status"] = val;
                          final roomTitle = devices[index]["subtitle"];
                          final roomIndex = rooms.indexWhere(
                            (r) => r["title"] == roomTitle,
                          );
                          if (roomIndex != -1) {
                            final anyOn = devices
                                .where((d) => d["subtitle"] == roomTitle)
                                .any((d) => d["status"] == true);
                            rooms[roomIndex]["status"] = anyOn;
                          }
                        });
                      },
                    ),
                  ),
                );
              },
              child: card,
            );
          case "Smart Plug":
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SmartPlugPage(
                      status: device["status"],
                      onChanged: (val) {
                        setState(() {
                          devices[index]["status"] = val;
                          final roomTitle = devices[index]["subtitle"];
                          final roomIndex = rooms.indexWhere(
                            (r) => r["title"] == roomTitle,
                          );
                          if (roomIndex != -1) {
                            final anyOn = devices
                                .where((d) => d["subtitle"] == roomTitle)
                                .any((d) => d["status"] == true);
                            rooms[roomIndex]["status"] = anyOn;
                          }
                        });
                      },
                    ),
                  ),
                );
              },
              child: card,
            );
          case "Smart TV":
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SmartTVPage()),
                );
              },
              child: card,
            );
          case "Air Conditioner":
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AirConditionerPage(
                      initialTemp: 24.0,
                      status: device["status"],
                      onStatusChanged: (val) {
                        setState(() {
                          devices[index]["status"] = val;
                          final roomTitle = devices[index]["subtitle"];
                          final roomIndex = rooms.indexWhere(
                            (r) => r["title"] == roomTitle,
                          );
                          if (roomIndex != -1) {
                            final anyOn = devices
                                .where((d) => d["subtitle"] == roomTitle)
                                .any((d) => d["status"] == true);
                            rooms[roomIndex]["status"] = anyOn;
                          }
                        });
                      },
                    ),
                  ),
                );
              },
              child: card,
            );
          default:
            return card;
        }
      },
    );
  }
}
