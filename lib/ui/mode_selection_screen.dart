import 'package:flutter/material.dart';
import 'package:scentview/admin/admin_home_screen.dart';
import 'package:scentview/ui/main_app_screen.dart';

class ModeSelectionScreen extends StatelessWidget {
  const ModeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).pushReplacementNamed(MainAppScreen.routeName);
              },
              child: const Text('User Mode'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).pushReplacementNamed(AdminHomeScreen.routeName);
              },
              child: const Text('Admin Mode'),
            ),
          ],
        ),
      ),
    );
  }
}
