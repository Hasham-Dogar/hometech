part of 'home_page.dart';

extension _HomePageHeader on _HomePageState {
  Widget _buildHeader(bool isSmallScreen) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Home",
              style: TextStyle(
                fontSize: isSmallScreen ? 24 : 28,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF22223B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Family members",
              style: TextStyle(
                fontSize: isSmallScreen ? 12 : 14,
                color: const Color(0xFF9A9AB0),
              ),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.map,
                color: Color(0xFFB16CEA),
              ),
              tooltip: 'Pick location on map',
              onPressed: () async {
                final picked = await Navigator.pushNamed(
                  context,
                  '/pick-location',
                );
                if (!mounted) return;
                if (picked != null && picked is LatLng) {
                  final latlon = '${picked.latitude},${picked.longitude}';
                  setState(() {
                    _loadingWeather = true;
                    _weatherError = null;
                  });
                  try {
                    final data = await WeatherApi()
                        .fetchCurrentWeather(latlon)
                        .timeout(const Duration(seconds: 10));
                    if (!mounted) return;
                    setState(() => _weather = data);
                    try {
                      final fc = await WeatherApi()
                          .fetchForecast(latlon, days: 3)
                          .timeout(const Duration(seconds: 10));
                      if (mounted) setState(() => _forecast = fc);
                    } catch (_) {}
                  } catch (e) {
                    if (!mounted) return;
                    setState(() => _weatherError = e.toString());
                  } finally {
                    if (mounted) setState(() => _loadingWeather = false);
                  }
                }
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.play_circle_fill,
                color: Colors.redAccent,
                size: 28,
              ),
              tooltip: 'Open videos',
              onPressed: () {
                Navigator.pushNamed(context, '/videos');
              },
            ),
            Row(
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProfilePage(),
                      ),
                    );
                  },
                  child: const CircleAvatar(
                    radius: 16,
                    backgroundImage: AssetImage("assets/1.jpeg"),
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProfilePage(),
                      ),
                    );
                  },
                  child: const CircleAvatar(
                    radius: 16,
                    backgroundImage: AssetImage("assets/2.jpg"),
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProfilePage(),
                      ),
                    );
                  },
                  child: const CircleAvatar(
                    radius: 16,
                    backgroundImage: AssetImage("assets/3.jpeg"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
