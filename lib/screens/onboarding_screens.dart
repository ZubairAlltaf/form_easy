import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'icon': Icons.dashboard_customize_outlined,
      'title': 'Design Forms with Ease',
      'description': 'Create custom forms in seconds with a beautiful, intuitive layout.',
    },
    {
      'icon': Icons.cloud_off_outlined,
      'title': 'Offline? No Problem!',
      'description': 'Collect form entries anytime—even without internet.',
    },
    {
      'icon': Icons.download_for_offline_outlined,
      'title': 'Export & Share Data',
      'description': 'Export entries as Excel or CSV with just one tap.',
    },
  ];

  final List<List<Color>> _gradients = [
    [Color(0xFF667eea), Color(0xFF764ba2)],
    [Color(0xFFff758c), Color(0xFFff7eb3)],
    [Color(0xFF43cea2), Color(0xFF185a9d)],
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    if (mounted) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _gradients[_currentPage],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: _pages.length,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) {
                final page = _pages[index];
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: size.height * 0.1),

                    // --- ICON CARD WITH GLASS EFFECT ---
                    Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            alignment: Alignment.center,
                            color: Colors.white.withOpacity(0.05),
                            child: Icon(page['icon'], size: 64, color: Colors.white),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // --- TITLE ---
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: Text(
                        page['title'],
                        key: ValueKey(page['title']),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // --- DESCRIPTION ---
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: Padding(
                        key: ValueKey(page['description']),
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Text(
                          page['description'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.6,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            // --- BOTTOM NAVIGATION ---
            Positioned(
              bottom: 40,
              left: 30,
              right: 30,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Skip
                  TextButton(
                    onPressed: _completeOnboarding,
                    child: const Text('Skip', style: TextStyle(color: Colors.white70)),
                  ),

                  // Indicators
                  Row(
                    children: List.generate(_pages.length, (index) {
                      final isActive = index == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        height: 10,
                        width: isActive ? 26 : 10,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(isActive ? 1.0 : 0.4),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      );
                    }),
                  ),

                  // Next or Done
                  TextButton(
                    onPressed: () {
                      if (_currentPage == _pages.length - 1) {
                        _completeOnboarding();
                      } else {
                        _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
                      }
                    },
                    child: Text(
                      _currentPage == _pages.length - 1 ? 'Done' : 'Next',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
