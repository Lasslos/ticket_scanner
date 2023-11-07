import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ticket_scanner/core/models/user.dart';
import 'package:ticket_scanner/core/provider/session_provider.dart';
import 'package:ticket_scanner/screens/home_screen.dart';
import 'package:ticket_scanner/screens/login_screen.dart';
import 'package:ticket_scanner/util/logger.dart';

class LoadingScreen extends ConsumerStatefulWidget {
  const LoadingScreen({super.key});

  @override
  ConsumerState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends ConsumerState<LoadingScreen> {
  String _message = "Loading session";
  bool allowGoToLoginScreen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      login();
    });
  }

  // Try login with saved data
  Future<void> login() async {
    getLogger().i("Login screen started");
    Token? sessionToken;
    try {
      sessionToken = await ref.read(sessionProvider.future);
    } catch (e, s) {
      getLogger().e("Failed to load session token", error: e, stackTrace: s);
      setState(() {
        _message = e.toString();
        allowGoToLoginScreen = true;
      });
      return;
    }
    if (sessionToken == null) {
      //ignore: use_build_context_synchronously
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) {
            return const LoginScreen();
          },
        ),
      );
      return;
    }
    getLogger().i("Session token loaded");
    //ignore: use_build_context_synchronously
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) {
          return const HomeScreen();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),
            const SizedBox(
              height: 200,
              child: AspectRatio(
                aspectRatio: 1,
                child: Placeholder(),
              ),
            ),
            const Spacer(flex: 1),
            const CircularProgressIndicator(),
            const SizedBox(height: 25),
            Text(
              _message,
              style: GoogleFonts.lato(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            if (allowGoToLoginScreen) const SizedBox(height: 25),
            if (allowGoToLoginScreen) TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return const LoginScreen();
                    },
                  ),
                );
              },
              child: const Text("Go to Login Screen"),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
