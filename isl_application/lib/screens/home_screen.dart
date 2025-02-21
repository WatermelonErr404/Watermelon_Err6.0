import 'package:flutter/material.dart';
import 'package:isl_application/screens/camera_to_ISL_screen.dart';
import 'package:isl_application/screens/text_to_ISL_screen.dart';
import 'package:isl_application/screens/voice_to_ISL_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;

  const HomeScreen({
    super.key,
    required this.onThemeToggle,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<Animation<Offset>> _slideAnimations;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _drawerSlideAnimation;

  final List<MenuItem> menuItems = [
    MenuItem(
      'Audio to Sign Language',
      'Convert speech to Indian Sign Language',
      Icons.mic_rounded,
      const Color(0xFF3498DB),
      (context) => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VoiceToISLScreen(),
        ),
      ),
    ),
    MenuItem(
      'Text to Sign Language',
      'Convert text to Indian Sign Language',
      Icons.keyboard_rounded,
      const Color(0xFF2ECC71),
      (context) => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TextToISLScreen(),
        ),
      ),
    ),
    MenuItem(
      'Camera to Sign Language',
      'Convert images to Indian Sign Language',
      Icons.camera_alt_rounded,
      const Color(0xFFE67E22),
      (context) => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CameraToISLScreen(),
        ),
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _drawerSlideAnimation = Tween<double>(
      begin: -1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimations = List.generate(
      menuItems.length,
      (index) => Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            0.2 * index,
            0.6 + (0.2 * index),
            curve: Curves.easeOut,
          ),
        ),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Scaffold(
          drawer: _buildDrawer(context, isDarkMode),
          appBar: _buildAppBar(context, isDarkMode, textTheme),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDarkMode
                    ? [const Color(0xFF1A202C), const Color(0xFF2D3748)]
                    : [const Color(0xFFF7FAFC), const Color(0xFFEDF2F7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.0, -0.5),
                            end: Offset.zero,
                          ).animate(_fadeAnimation),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 24.0),
                            child: Text(
                              'Welcome to Signify',
                              style: textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: isDarkMode
                                    ? Colors.white
                                    : const Color(0xFF2D3748),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        itemCount: menuItems.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 16),
                        itemBuilder: (context, index) => SlideTransition(
                          position: _slideAnimations[index],
                          child: ScaleTransition(
                            scale: _scaleAnimation,
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: _buildMenuItem(
                                context,
                                menuItems[index],
                                isDarkMode,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDrawer(BuildContext context, bool isDarkMode) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(-1, 0),
        end: Offset.zero,
      ).animate(_fadeAnimation),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Drawer(
          child: Column(
            children: [
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return DrawerHeader(
                    decoration: BoxDecoration(
                      image: const DecorationImage(
                        image: AssetImage('assets/images/drawer.jpg'),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          Colors.black26,
                          BlendMode.darken,
                        ),
                      ),
                      color: isDarkMode
                          ? const Color(0xFF2D3748)
                          : const Color(0xFF3498DB),
                    ),
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Container(
                        width: double.infinity,
                        alignment: Alignment.bottomLeft,
                        child: const Text(
                          'Signify',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              _buildDrawerItem(
                icon: Icons.info_outline_rounded,
                title: 'About',
                onTap: () => Navigator.pop(context),
              ),
              _buildDrawerItem(
                icon: Icons.settings_rounded,
                title: 'Settings',
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ListTile(
          leading: Icon(icon),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 24),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    bool isDarkMode,
    TextTheme textTheme,
  ) {
    return AppBar(
      elevation: 0,
      centerTitle: true,
      leading: Builder(
        builder: (context) => ScaleTransition(
          scale: _scaleAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: IconButton(
              icon: const Icon(Icons.menu_rounded),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ),
      ),
      title: ScaleTransition(
        scale: _scaleAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Text(
            'SIGNIFY',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
      actions: [
        ScaleTransition(
          scale: _scaleAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: IconButton(
              icon: Icon(
                isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              ),
              onPressed: widget.onThemeToggle,
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildMenuItem(BuildContext context, MenuItem item, bool isDarkMode) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(16),
      color: isDarkMode ? const Color(0xFF2D3748) : Colors.white,
      child: InkWell(
        onTap: () => item.onTap(context),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: item.color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  item.icon,
                  size: 32,
                  color: item.color,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MenuItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Function(BuildContext) onTap;

  const MenuItem(
    this.title,
    this.subtitle,
    this.icon,
    this.color,
    this.onTap,
  );
}

extension ColorAdjustment on Color {
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
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
