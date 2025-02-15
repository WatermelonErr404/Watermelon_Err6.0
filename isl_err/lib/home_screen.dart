import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onThemeToggle;
  final bool isDarkMode;

  const HomeScreen({Key? key, required this.onThemeToggle, required this.isDarkMode})
      : super(key: key);

  // List of menu items for our grid.
  final List<MenuItem> menuItems = const [
    MenuItem('Audio-to-ISL', Icons.mic, Colors.blue),
    MenuItem('Text-to-ISL', Icons.keyboard, Colors.green),
    MenuItem('Camera-to-ISL', Icons.camera_alt, Colors.orange),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ISL Bridge'),
        actions: [
          // Theme toggle button
          IconButton(
            tooltip: isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: onThemeToggle,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: menuItems.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Two columns (you can adjust this as needed)
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemBuilder: (context, index) {
            final item = menuItems[index];
            return GestureDetector(
              onTap: () {
                // TODO: Navigate to respective screen.
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content:  Text('${item.title} tapped')),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: item.color, width: 1.5),
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
                        color: item.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// A simple model for our menu items.
class MenuItem {
  final String title;
  final IconData icon;
  final Color color;

  const MenuItem(this.title, this.icon, this.color);
}
