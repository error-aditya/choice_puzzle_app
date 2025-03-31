import 'package:audioplayers/audioplayers.dart';
import 'package:choice_puzzle_app/local_selection/dashboard/premium_screen.dart';
import 'package:choice_puzzle_app/local_selection/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:get/get.dart';

class DashboardScreen extends StatefulWidget {
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final List<Widget> _navigation = [HomeScreen(), PremiumScreen()];
  bool isPlaying = false;
  int completedPuzzles = 0;
  final int requiredPuzzles = 10;
  int _currentIndex = 1;
  bool showImages = false;

  @override
  void dispose() {
    _audioPlayer.dispose(); // Stop music when screen is closed
    super.dispose();
  }

  Future<void> _playBackgroundMusic() async {
    await _audioPlayer.play(
      AssetSource('music/Mr_Smith-Azul.mp3'),
    ); // Play loop
    _audioPlayer.setReleaseMode(ReleaseMode.loop); // Loop music
  }

  Future<void> _stopMusic() async {
    await _audioPlayer.stop(); // Stop music if needed
  }

  void nav(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentIndex == 1 ? null : AppBar(
        actions: [
          IconButton(
            icon: Icon(
              isPlaying ? Icons.music_note : Icons.music_off,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                isPlaying = !isPlaying;
              });
              isPlaying ? _playBackgroundMusic() : _stopMusic();
            },
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF24C6DC), Color(0xFF514A9D)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Shimmer.fromColors(
          baseColor: Colors.white,
          highlightColor: Colors.blue[200]!,
          child: Text(
            'PUZZLE GAME',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
        centerTitle: true,
      ),
      // bottomNavigationBar: Container(
      //   decoration: BoxDecoration(
      //     gradient: LinearGradient(
      //       colors: [Color(0xFF24C6DC), Color(0xFF514A9D)],
      //       begin: Alignment.topLeft,
      //       end: Alignment.bottomRight,
      //     ),
      //   ),
      //   child: BottomNavigationBar(
      //     backgroundColor:
      //         Colors.transparent, // Set to transparent to show the gradient
      //     currentIndex: _currentIndex,
      //     landscapeLayout: BottomNavigationBarLandscapeLayout.linear,
      //     onTap: (value) {
      //       setState(() {
      //         nav(value);
      //       });
      //     },
      //     selectedItemColor: Colors.white,
      //     unselectedItemColor: Colors.grey,
      //     items: [
      //       BottomNavigationBarItem(
      //         icon: Icon(Icons.dashboard),
      //         label: 'Dashboard',
      //       ),
      //       BottomNavigationBarItem(
      //         icon: Icon(Icons.stars_rounded),
      //         label: 'Premium',
      //       ),
      //     ],
      //   ),
      // ),
      
      body: PremiumScreen(),
    );
  }
}
