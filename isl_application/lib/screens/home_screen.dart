// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:isl_application/screens/voice_to_ISL_screen.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onThemeToggle;

  HomeScreen({
    super.key,
    required this.onThemeToggle,
  });

  final List<MenuItem> menuItems = [
    MenuItem(
      'Audio-to-ISL',
      Icons.mic,
      Colors.blue,
      (context) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VoiceToISLScreen(),
          ),
        );
      },
    ),
    MenuItem(
      'Text-to-ISL',
      Icons.keyboard,
      Colors.green,
      (context) => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Text-to-ISL tapped')),
      ),
    ),
    MenuItem(
      'Camera-to-ISL',
      Icons.camera_alt,
      Colors.orange,
      (context) => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera-to-ISL tapped')),
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      drawer: Drawer(
        // backgroundColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/images/drawer.jpg'),
                    fit: BoxFit.fitWidth),
                color: isDarkMode ? Colors.grey[800] : Colors.blue,
              ),
              child: Center(child: Text('')),
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to About screen if needed.
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to Settings screen if needed.
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          'SIGNIFY',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        actions: [
          IconButton(
            // Toggle icon based on current theme.
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: onThemeToggle,
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode
                ? [Colors.grey[900]!, Colors.black]
                : [Colors.blue[100]!, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            itemCount: menuItems.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.8,
            ),
            itemBuilder: (context, index) {
              final item = menuItems[index];
              return Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(16),
                color: Theme.of(context).cardColor,
                child: InkWell(
                  onTap: () => item.ontap(context),
                  borderRadius: BorderRadius.circular(16),
                  splashColor: item.color.withOpacity(0.3),
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: item.color.withOpacity(0.5),
                        width: 1.5,
                      ),
                      color: item.color.withOpacity(0.1),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(item.icon, size: 50, color: item.color),
                        const SizedBox(height: 12),
                        Text(
                          item.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: item.color.darken(),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class MenuItem {
  final String title;
  final IconData icon;
  final Color color;
  final Function(BuildContext) ontap;

  const MenuItem(this.title, this.icon, this.color, this.ontap);
}

extension ColorAdjustment on Color {
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}
