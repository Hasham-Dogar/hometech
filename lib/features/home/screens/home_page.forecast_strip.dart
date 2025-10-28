part of 'home_page.dart';

class _ForecastStrip extends StatelessWidget {
  final Map<String, dynamic> forecastJson;

  const _ForecastStrip({required this.forecastJson});

  @override
  Widget build(BuildContext context) {
    final days =
        (forecastJson['forecast']?['forecastday'] as List<dynamic>?) ?? [];
    if (days.isEmpty) return const SizedBox.shrink();

    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      itemBuilder: (context, index) {
        final day = days[index] as Map<String, dynamic>;
        final date = day['date'] as String? ?? '';
        final dayInfo = day['day'] as Map<String, dynamic>? ?? {};
        final maxTemp = dayInfo['maxtemp_c']?.toString() ?? '--';
        final minTemp = dayInfo['mintemp_c']?.toString() ?? '--';
        final iconPath = dayInfo['condition']?['icon'] as String? ?? '';
        final iconUrl = iconPath.startsWith('http')
            ? iconPath
            : 'https:$iconPath';

        return Container(
          width: 120,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                date,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              const SizedBox(height: 6),
              Image.network(
                iconUrl,
                width: 36,
                height: 36,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.cloud, color: Colors.white),
              ),
              const SizedBox(height: 6),
              Text(
                '$maxTemp° / $minTemp°',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(width: 8),
      itemCount: days.length,
    );
  }
}
