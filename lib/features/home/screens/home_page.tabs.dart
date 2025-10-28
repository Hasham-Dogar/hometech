part of 'home_page.dart';

extension _HomePageTabs on _HomePageState {
  Widget _buildTabs(bool isSmallScreen) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFEDEDF7),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor:
                    _tabIndex == 0 ? Colors.white : Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              onPressed: () {
                setState(() => _tabIndex = 0);
              },
              child: Text(
                'Room',
                style: TextStyle(
                  color: _tabIndex == 0
                      ? const Color(0xFF22223B)
                      : const Color(0xFF9A9AB0),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor:
                    _tabIndex == 1 ? Colors.white : Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              onPressed: () {
                setState(() => _tabIndex = 1);
              },
              child: Text(
                'Devices',
                style: TextStyle(
                  color: _tabIndex == 1
                      ? const Color(0xFF22223B)
                      : const Color(0xFF9A9AB0),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
