import 'package:flutter/material.dart';
import 'package:onroadapp/pages/homepage.dart';
import 'package:onroadapp/pages/landing_page.dart';
import 'package:onroadapp/pages/login_page.dart';
import 'package:onroadapp/pages/profile_screen.dart';
import 'package:onroadapp/services/authservices.dart';
import 'package:get/get.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({
    super.key,
    required this.name,
    required this.email,
  });

  final String? name;
  final String? email;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(),
                ),
              );
              // getCurrentUserData(user!.uid);
            },
            child: DrawerHeader(
              padding: const EdgeInsets.all(0),
              margin: const EdgeInsets.all(0),
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage('assets/icon/myicon.png'),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 100,
                      ),
                    ),
                    Text(
                      name ?? 'User name',
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      email ?? 'phish@gmail.com',
                      style: const TextStyle(color: Colors.white),
                    )
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          ListTile(
            onTap: () => Get.to(() => LandingPage()),
            title: const Text('Landing Page'),
          ),
          ListTile(
            onTap: () => Get.to(() => Homepage(
                  service: null,
                )),
            title: const Text('Homepage'),
          ),
          ListTile(
            onTap: () => Get.to(() => ProfileScreen()),
            title: const Text('Profile Page'),
          ),
          Expanded(child: Container()),
          ListTile(
            onTap: () async {
              await AuthService().firebaseAuth.signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => LoginScreen(),
                ),
              );
            },
            title: const Text('Logout'),
            trailing: const Icon(Icons.logout_outlined),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
