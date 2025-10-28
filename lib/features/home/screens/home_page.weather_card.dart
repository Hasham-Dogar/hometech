part of 'home_page.dart';

extension _HomePageWeatherCard on _HomePageState {
  Widget _buildWeatherCard(bool isSmallScreen) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmallScreen ? 14 : 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFB16CEA),
            Color(0xFFFF5E69),
            Color(0xFFFF8A56),
            Color(0xFFFFC86A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_loadingWeather)
            SizedBox(
              height: isSmallScreen ? 80 : 100,
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            )
          else if (_weatherError != null)
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Weather error: $_weatherError',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmallScreen ? 12 : 14,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.refresh,
                    color: Colors.white,
                  ),
                  onPressed: () => _loadWeatherUsingGps(),
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _weather?['location']?['name'] ?? 'Unknown',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_weather?['current']?['temp_c'] ?? '--'}°',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isSmallScreen ? 28 : 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _weather?['current']?['condition']?['text'] ?? '',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isSmallScreen ? 12 : 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Feels like: ${_weather?['current']?['feelslike_c'] ?? '--'}°',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isSmallScreen ? 10 : 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Builder(
                  builder: (context) {
                    final iconPath =
                        _weather?['current']?['condition']?['icon'] as String?;
                    if (iconPath != null && iconPath.isNotEmpty) {
                      final url = iconPath.startsWith('http')
                          ? iconPath
                          : 'https:$iconPath';
                      return Image.network(
                        url,
                        width: isSmallScreen ? 40 : 56,
                        height: isSmallScreen ? 40 : 56,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.cloud,
                          color: Colors.white,
                          size: isSmallScreen ? 40 : 48,
                        ),
                      );
                    }
                    return Icon(
                      Icons.cloud,
                      color: Colors.white,
                      size: isSmallScreen ? 40 : 48,
                    );
                  },
                ),
              ],
            ),
          const SizedBox(height: 8),
          if (_forecast != null)
            SizedBox(
              height: 104,
              child: _ForecastStrip(forecastJson: _forecast!),
            ),
        ],
      ),
    );
  }
}
