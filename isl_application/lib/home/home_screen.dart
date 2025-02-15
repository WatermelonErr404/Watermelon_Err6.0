import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  String selectedLanguage = 'English';
  final List<String> languages = ['English', 'Hindi', 'Bengali', 'Tamil'];

  // List of home screen menu items.
  final List<MenuItem> menuItems = [
    MenuItem('Audio-to-ISL', Icons.mic, Colors.blue),
    MenuItem('Text-to-ISL', Icons.keyboard, Colors.green),
    MenuItem('Camera ISL Recognition', Icons.camera_alt, Colors.orange),
    MenuItem('Public Announcements', Icons.announcement, Colors.purple),
    MenuItem('Offline Mode', Icons.offline_pin, Colors.red),
    MenuItem('Settings', Icons.settings, Colors.grey),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ISL Bridge'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedLanguage,
                icon: Icon(
                  Icons.language,
                  color: Colors.white,
                ),
                dropdownColor: Colors.blue,
                style: TextStyle(color: Colors.white, fontSize: 16),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedLanguage = newValue;
                    });
                  }
                },
                items: languages
                    .map<DropdownMenuItem<String>>(
                      (String value) => DropdownMenuItem<String>(
                        value: value,
                        child:
                            Text(value, style: TextStyle(color: Colors.white)),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: menuItems.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Two columns
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemBuilder: (context, index) {
            final item = menuItems[index];
            return GestureDetector(
              onTap: () {
                // TODO: Navigate to corresponding screen based on item.title
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${item.title} tapped')),
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
                    SizedBox(height: 12),
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

class MenuItem {
  final String title;
  final IconData icon;
  final Color color;

  MenuItem(this.title, this.icon, this.color);
}
