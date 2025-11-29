import 'package:akdeniz_cep/pages/main_page.dart';
import 'package:flutter/material.dart';
import 'package:akdeniz_cep/pages/note_page.dart';
import 'package:akdeniz_cep/pages/yemekhane_page.dart';
import 'package:akdeniz_cep/services/auth_service.dart';
import 'package:akdeniz_cep/pages/login_page.dart';
import 'package:akdeniz_cep/pages/profile_page.dart';
import 'package:akdeniz_cep/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:akdeniz_cep/pages/transportation_page.dart';
import 'package:akdeniz_cep/pages/campus_page.dart';
import 'package:akdeniz_cep/pages/event_society_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();

  static final List<Widget> _widgetOptions = <Widget>[
    const MainPage(),          
    const YemekhanePage(),     
    const UlasimPage(),       
    const EventSocietyPage(),  
    const NotesPage(),         
    const CampusPage(),        
  ];

  int _selectedIndex = 0;
  final BottomNavigationBarType _bottomNavType =
      BottomNavigationBarType.shifting;

  Future<void> _signOut() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SignInScreen()),
      );
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text('Çıkış yapmak istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _signOut();
            },
            child: const Text(
              'Çıkış Yap',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Akdeniz Cep',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          StreamBuilder<User?>(
            stream: _authService.authStateChanges,
            builder: (context, snapshot) {
              final user = snapshot.data;

              if (user != null) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    StreamBuilder<UserModel?>(
                      stream: _authService.getUserDataStream(user.uid),
                      builder: (context, userSnapshot) {
                        final userData = userSnapshot.data;
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ProfilePage(),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.grey.shade300,
                              backgroundImage: userData?.ppUrl != null &&
                                      userData!.ppUrl!.isNotEmpty
                                  ? NetworkImage(userData.ppUrl!)
                                  : null,
                              child: userData?.ppUrl == null ||
                                      userData!.ppUrl!.isEmpty
                                  ? Icon(
                                      Icons.person,
                                      size: 20,
                                      color: Colors.grey.shade600,
                                    )
                                  : null,
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout),
                      tooltip: 'Çıkış Yap',
                      onPressed: _showLogoutDialog,
                    ),
                  ],
                );
              } else {
                return IconButton(
                  icon: const Icon(Icons.login),
                  tooltip: 'Giriş Yap',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignInScreen(),
                      ),
                    );
                  },
                );
              }
            },
          ),
        ],
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xff6200ee),
        unselectedItemColor: const Color(0xff757575),
        type: _bottomNavType,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: _navBarItems,
      ),
    );
  }
}

const _navBarItems = [
  BottomNavigationBarItem(
    icon: Icon(Icons.home_outlined),
    activeIcon: Icon(Icons.home_rounded),
    label: 'Ana Sayfa',
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.restaurant_menu_outlined),
    activeIcon: Icon(Icons.restaurant_menu),
    label: 'Yemekhane',
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.directions_bus_filled_outlined),
    activeIcon: Icon(Icons.directions_bus_filled),
    label: 'Ulaşım',
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.event_outlined),
    activeIcon: Icon(Icons.event_rounded),
    label: 'Etkinlikler',
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.dashboard_outlined),
    activeIcon: Icon(Icons.dashboard),
    label: 'Pano',
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.map_outlined),
    activeIcon: Icon(Icons.map_rounded),
    label: 'Harita',
  ),
];
