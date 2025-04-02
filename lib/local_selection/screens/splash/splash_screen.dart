import 'dart:async';
import 'package:choice_puzzle_app/local_selection/dashboard/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    // Initialize animation controller but don't start it yet
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3), // 1-second expansion effect
    );

    // Scale Animation (expands after 1 second)
    _animation = Tween<double>(
      begin: 3.80,
      end: 0.80,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.ease));

    // Start animation after 1 second delay
    Future.delayed(Duration(seconds: 1), () {
      _controller.forward(); // Start expanding animation

      // Fade out while expanding
      setState(() {
        _opacity = 1.0;
      });

      // Navigate to DashboardScreen after animation completes
      _controller.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          Get.off(() => DashboardScreen());
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF24C6DC), Color.fromARGB(255, 9, 69, 142)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Container(
            padding: EdgeInsets.all(25),
            child: AnimatedOpacity(
              duration: Duration(milliseconds: 2000), // 2-second fade-out
              opacity: _opacity,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _animation.value,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'assets/logo/app_logo_crop.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
