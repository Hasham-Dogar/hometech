part of 'home_page.dart';

class _MicButton extends StatelessWidget {
  final double fabSize;
  const _MicButton({required this.fabSize});

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      width: fabSize * 0.7,
      height: fabSize * 0.7,
      borderRadius: fabSize,
      blur: 100,
      alignment: Alignment.center,
      border: 1,
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color.fromARGB(255, 248, 167, 215).withOpacity(0.2),
          const Color.fromARGB(255, 248, 167, 215).withOpacity(0.05),
        ],
      ),
      borderGradient: LinearGradient(
        colors: [
          Colors.white.withOpacity(0.5),
          Colors.white.withOpacity(0.5),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(6),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
        child: ShaderMask(
          shaderCallback: (Rect bounds) {
            return const LinearGradient(
              colors: [Color(0xFF9C27B0), Color(0xFFE91E63)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcIn,
          child: Icon(
            Icons.mic_none_outlined,
            color: Colors.white,
            size: fabSize * 0.3,
          ),
        ),
      ),
    );
  }
}
