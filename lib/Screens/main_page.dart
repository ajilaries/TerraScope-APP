import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'home_screen2.dart';
import 'home_screen0.dart';
import '../Screens/farmer/farmer_dashboard.dart';
import '../Screens/care/care_dashboard.dart';

class MainPage extends StatefulWidget {
  final int initialPage;
  const MainPage({super.key, required this.initialPage});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late PageController _pageController;
  late int _currentIndex; // Start at HomeScreen1 (MainHomeScreen)

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialPage;
    _pageController = PageController(initialPage: widget.initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        scrollDirection: Axis.horizontal,
        children: [
          // HomeScreen0 (Leftmost)
          HomeScreen0(
            onModeSelected: (mode) {
              print("Selected mode: $mode");

              // Defer navigation to avoid build-time navigation
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mode == "farmer") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FarmerDashboard(),
                    ),
                  );
                } else if (mode == "care") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CareDashboard(),
                    ),
                  );
                }
              });
            },
          ),

          // MainHomeScreen / HomeScreen1 (Center - Initial)
          MainHomeScreen(),

          // HomeScreen2 (Rightmost)
          HomeScreen2(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Mode',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.cloud),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'More',
          ),
        ],
      ),
    );
  }
}
