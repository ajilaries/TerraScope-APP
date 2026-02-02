import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:terra_scope_apk/Screens/farmer/farmer_result_screen.dart';
import 'package:terra_scope_apk/popups/farmer_intro_popup.dart';
import 'package:terra_scope_apk/Screens/traveler/traveler_dashboard.dart';
import 'package:terra_scope_apk/Screens/care/care_dashboard.dart';
import 'package:terra_scope_apk/Screens/daily_planner/daily_planner_dashboard.dart';
import 'package:terra_scope_apk/providers/mode_provider.dart';
import 'package:terra_scope_apk/Services/auth_service.dart';
import 'package:terra_scope_apk/Screens/signup_screen.dart';
import 'Saftey/saftey_mode_screen.dart';

class HomeScreen0 extends StatefulWidget {
  final Function(String) onModeSelected;

  const HomeScreen0({super.key, required this.onModeSelected});

  @override
  State<HomeScreen0> createState() => _HomeScreen0State();
}

class _HomeScreen0State extends State<HomeScreen0> {
  String selectedMode = "";

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ModeProvider>(context).isDarkMode;
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey.shade100,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Terrascope",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Your Weather. Your Safety.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Recent Modes Section
            Consumer<ModeProvider>(
              builder: (context, modeProvider, child) {
                if (modeProvider.recentModes.isNotEmpty) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          "Recent Modes",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 98,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: modeProvider.recentModes.length,
                          itemBuilder: (context, index) {
                            final mode = modeProvider.recentModes[index];
                            return recentModeButton(mode, isDark);
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Choose Your Experience",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  modeCard(
                    title: "Default",
                    icon: Icons.dashboard,
                    color: Colors.blue,
                    mode: "default",
                  ),
                  modeCard(
                    title: "Traveller",
                    icon: Icons.travel_explore,
                    color: Colors.green,
                    mode: "traveller",
                  ),
                  modeCard(
                    title: "Farmer",
                    icon: Icons.agriculture,
                    color: Colors.brown,
                    mode: "farmer",
                  ),
                  modeCard(
                    title: "Safety",
                    icon: Icons.shield,
                    color: Colors.red,
                    mode: "safety",
                  ),
                  modeCard(
                    title: "Kids / Senior",
                    icon: Icons.family_restroom,
                    color: Colors.deepPurple,
                    mode: "care",
                  ),
                  modeCard(
                    title: "Daily Planner",
                    icon: Icons.calendar_today,
                    color: Colors.teal,
                    mode: "daily_planner",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  // RECENT MODE BUTTON
  Widget recentModeButton(String mode, bool isDark) {
    String title;
    IconData icon;
    Color color;

    switch (mode) {
      case "default":
        title = "Default";
        icon = Icons.dashboard;
        color = Colors.blue;
        break;
      case "traveller":
        title = "Traveller";
        icon = Icons.travel_explore;
        color = Colors.green;
        break;
      case "farmer":
        title = "Farmer";
        icon = Icons.agriculture;
        color = Colors.brown;
        break;
      case "safety":
        title = "Safety";
        icon = Icons.shield;
        color = Colors.red;
        break;
      case "care":
        title = "Kids / Senior";
        icon = Icons.family_restroom;
        color = Colors.deepPurple;
        break;
      case "daily_planner":
        title = "Daily Planner";
        icon = Icons.calendar_today;
        color = Colors.teal;
        break;
      default:
        title = mode;
        icon = Icons.help;
        color = Colors.grey;
    }

    return GestureDetector(
      onTap: () {
        // Schedule navigation for next frame to avoid build-time navigation
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _navigateToMode(mode);
          }
        });
      },
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? Colors.white10 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToMode(String mode) {
    if (!mounted) return;

    // For default mode, no login required
    if (mode == "default") {
      Provider.of<ModeProvider>(context, listen: false).setMode(mode);
      widget.onModeSelected(mode);
      return;
    }

    // Check login status and signup completion asynchronously and navigate after current frame
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      // Check if user is logged in for other modes
      final authService = AuthService();
      final isLoggedIn = await authService.isLoggedIn();

      if (!isLoggedIn) {
        // User not logged in, redirect to signup for this mode
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SignupScreen(),
          ),
        );
        return;
      }

      // Check if user has completed signup
      final prefs = await SharedPreferences.getInstance();
      final hasCompletedSignup = prefs.getBool('has_completed_signup') ?? false;

      if (!hasCompletedSignup) {
        // User logged in but hasn't completed signup, redirect to signup
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SignupScreen(),
          ),
        );
        return;
      }

      // User is logged in and has completed signup, proceed with mode selection
      if (!mounted) return;
      Provider.of<ModeProvider>(context, listen: false).setMode(mode);

      // Navigate to the appropriate screen
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        switch (mode) {
          case "farmer":
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => FarmerIntroPopup(
                onSubmit: (double lat, double lon, String soilType) {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FarmerResultScreen(
                        lat: lat,
                        lon: lon,
                        soilType: soilType,
                      ),
                    ),
                  );
                },
              ),
            );
            break;
          case "traveller":
            Navigator.pushNamed(context, '/traveler-dashboard');
            break;
          case "safety":
            Navigator.pushNamed(context, '/safety-mode');
            break;
          case "care":
            Navigator.pushNamed(context, '/care-dashboard');
            break;
          case "daily_planner":
            Navigator.pushNamed(context, '/daily-planner-dashboard');
            break;
          default:
            widget.onModeSelected(mode);
        }
      });
    });
  }

  // MODE CARD
  Widget modeCard({
    required String title,
    required IconData icon,
    required Color color,
    required String mode,
  }) {
    final bool isSelected = selectedMode == mode;
    final isDark = Provider.of<ModeProvider>(context).isDarkMode;

    return GestureDetector(
      onTap: () {
        // Update selection state
        setState(() {
          selectedMode = mode;
        });

        // Schedule navigation for next frame to avoid build-time navigation
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _navigateToMode(mode);
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isDark ? Colors.white10 : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2.5,
          ),
          boxShadow: isDark
              ? null
              : const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
