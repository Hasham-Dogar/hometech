import 'package:flutter/material.dart';
import 'add_profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:collection';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static const List<Color> _buttonGradient = [
    Color(0xFFB16CEA),
    Color(0xFFFF5E69),
  ];

  Widget _gradientButton({
    required String text,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style:
            ElevatedButton.styleFrom(
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 2,
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
            ).copyWith(
              backgroundColor: MaterialStateProperty.all(Colors.transparent),
              elevation: MaterialStateProperty.all(0),
            ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _buttonGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            alignment: Alignment.center,
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Map<String, String>> get profiles {
    final base = [
      {'image': 'assets/1.jpeg', 'name': 'dev', 'email': 'dev@gmail.com'},
      {'image': 'assets/2.jpg', 'name': 'User One', 'email': 'user1@gmail.com'},
      {
        'image': 'assets/3.jpeg',
        'name': 'User Two',
        'email': 'user2@gmail.com',
      },
    ];

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return base;

    final userProfile = <String, String>{
      'image': user.photoURL ?? 'assets/1.jpeg',
      'name': user.displayName ?? (user.email ?? 'Account'),
      'email': user.email ?? '',
    };

    // Ensure user's profile appears first and avoid duplicates by email
    final merged = LinkedHashSet<Map<String, String>>.from([]);
    merged.add(userProfile);
    for (final p in base) {
      if (p['email'] != userProfile['email']) merged.add(p);
    }

    return merged.toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profiles'),
        backgroundColor: const Color(0xFF252A4A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF5F6FA),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: ListView.separated(
                itemCount: profiles.length,
                separatorBuilder: (_, __) => const SizedBox(height: 20),
                itemBuilder: (context, index) {
                  final profile = profiles[index];
                  final currentUser = FirebaseAuth.instance.currentUser;
                  final isCurrent =
                      currentUser != null &&
                      profile['email'] == currentUser.email;
                  final image = profile['image'] ?? '';
                  final ImageProvider avatarImage =
                      image.startsWith('http') || image.startsWith('https')
                      ? NetworkImage(image)
                      : AssetImage(image) as ImageProvider;

                  return InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      if (isCurrent) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Profile: ${profile['name']}'),
                            content: const Text('Choose an action'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const AddProfilePage(),
                                    ),
                                  );
                                },
                                child: const Text('Edit'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFB16CEA),
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () async {
                                  await FirebaseAuth.instance.signOut();
                                  if (context.mounted) {
                                    Navigator.of(
                                      context,
                                    ).pushNamedAndRemoveUntil(
                                      '/login',
                                      (route) => false,
                                    );
                                  }
                                },
                                child: const Text('Logout'),
                              ),
                            ],
                          ),
                        );
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Profile: ${profile['name']}'),
                            content: const Text('Do you want to logout?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFB16CEA),
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () async {
                                  await FirebaseAuth.instance.signOut();
                                  if (context.mounted) {
                                    Navigator.of(
                                      context,
                                    ).pushNamedAndRemoveUntil(
                                      '/login',
                                      (route) => false,
                                    );
                                  }
                                },
                                child: const Text('Logout'),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    child: Row(
                      children: [
                        CircleAvatar(radius: 32, backgroundImage: avatarImage),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profile['name']!,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF22223B),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                profile['email']!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF9A9AB0),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isCurrent)
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AddProfilePage(),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.edit,
                              color: Color(0xFFB16CEA),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddProfilePage()),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Another Profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB16CEA),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            const SizedBox(height: 8),
            _gradientButton(
              text: 'Logout',
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/login', (route) => false);
                }
              },
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFFB16CEA),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                side: const BorderSide(color: Color(0xFFB16CEA)),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}

//brah
