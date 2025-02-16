// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:isl_application/screens/about_screen.dart';
import 'package:isl_application/screens/camera_to_ISL_screen.dart';
import 'package:isl_application/screens/text_to_ISL_screen.dart';
import 'package:isl_application/screens/voice_to_ISL_screen.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onThemeToggle;

   HomeScreen({
    super.key,
    required this.onThemeToggle,
  });

  final List<MenuItem> menuItems = [
    MenuItem(
      'Audio to SIGN Language',
      Icons.mic,
      Colors.blue,
      (context) {
        Navigator.push(
          context,
          _createRoute(VoiceToISLScreen()),
        );
      },
    ),
    MenuItem(
      'Text to SIGN Language',
      Icons.keyboard,
      Colors.green,
      (context) {
        Navigator.push(
          context,
          _createRoute(TextToISLScreen()),
        );
      },
    ),
    MenuItem(
      'Camera to SIGN Language',
      Icons.camera_alt,
      Colors.orange,
      (context) {
        Navigator.push(
          context,
          _createRoute(CameraToISLScreen()),
        );
      },
    ),
  ];

  // Helper function that creates a slide transition route.
  static Route _createRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end)
            .chain(CurveTween(curve: Curves.easeInOut));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage('assets/images/drawer.jpg'),
                  fit: BoxFit.fill,
                ),
                color: isDarkMode ? Colors.grey[800] : Colors.blue,
              ),
              child: const Center(child: Text('')),
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: Text(
                'About',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  _createRoute(const AboutScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: Text(
                'Settings',
                style: Theme.of(context).textTheme.displaySmall,
              ),
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
                : [Colors.white, Colors.white],
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
              return AnimatedGridItem(
                index: index,
                child: Material(
                  elevation: 0,
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
                              fontSize: 18,
                              color: item.color.darken(),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
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
    final hslDark =
        hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}

class AnimatedGridItem extends StatefulWidget {
  final Widget child;
  final int index;

  const AnimatedGridItem({
    Key? key,
    required this.child,
    required this.index,
  }) : super(key: key);

  @override
  _AnimatedGridItemState createState() => _AnimatedGridItemState();
}

class _AnimatedGridItemState extends State<AnimatedGridItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    // Start the animation with a delay based on index.
    Future.delayed(Duration(milliseconds: widget.index * 100), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: SlideTransition(
         position: Tween<Offset>(
           begin: const Offset(0, 0.2),
           end: Offset.zero,
         ).animate(_animation),
         child: widget.child,
      ),
    );
  }
}
