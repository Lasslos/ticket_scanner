import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ticket_scanner/core/models/user.dart';
import 'package:ticket_scanner/core/provider/session_provider.dart';
import 'package:ticket_scanner/util/logger.dart';
import 'package:ticket_scanner/screens/home_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState createState() => LoginScreenState();
}

class LoginScreenState extends ConsumerState<LoginScreen> {
  late TextEditingController _usernameFieldController;
  late TextEditingController _passwordFieldController;
  var showPassword = false;
  List<FocusNode> focusNodes = [];

  @override
  void initState() {
    super.initState();
    _usernameFieldController = TextEditingController();
    _passwordFieldController = TextEditingController();
    for (var i = 0; i < 3; i++) {
      focusNodes.add(FocusNode());
    }
    focusNodes[0].requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    AsyncValue<Token?> session = ref.watch(sessionProvider);
    String message = "";
    if (session.hasError) {
      message = session.error.toString();
    }
    bool isLoading = false;
    if (session.isLoading) {
      isLoading = true;
    }

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Login",
                    style: Theme.of(context)
                        .textTheme
                        .displaySmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Melde dich mit deinem TicketScanner-Konto an",
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    autofocus: true,
                    focusNode: focusNodes[0],
                    autocorrect: false,
                    autofillHints: const [AutofillHints.username],
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    controller: _usernameFieldController,
                    onEditingComplete: () {
                      FocusScope.of(context).requestFocus(focusNodes[0]);
                    },
                    decoration: const InputDecoration(
                      labelText: "Benutzername",
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    focusNode: focusNodes[1],
                    autocorrect: false,
                    enableSuggestions: false,
                    obscureText: !showPassword,
                    keyboardType: TextInputType.visiblePassword,
                    autofillHints: const [AutofillHints.password],
                    textInputAction: TextInputAction.next,
                    controller: _passwordFieldController,
                    onEditingComplete: () {
                      FocusScope.of(context).requestFocus(focusNodes[1]);
                    },
                    decoration: InputDecoration(
                      labelText: "Passwort",
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: showPassword
                            ? const Icon(Icons.visibility)
                            : const Icon(Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            showPassword = !showPassword;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    style: Theme.of(context)
                        .textTheme
                        .labelMedium
                        ?.copyWith(color: Colors.red),
                  ),
                  const SizedBox(height: 8),
                  isLoading
                      ? const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: SizedBox(
                            height: 48,
                            child: Center(
                              child: LinearProgressIndicator(),
                            ),
                          ),
                        )
                      : ElevatedButton(
                          focusNode: focusNodes[2],
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                              Theme.of(context).colorScheme.primary,
                            ),
                            foregroundColor: MaterialStateProperty.all(
                              Theme.of(context).colorScheme.onPrimary,
                            ),
                            textStyle: MaterialStateProperty.all(
                              Theme.of(context).textTheme.labelLarge,
                            ),
                          ),
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            _login();
                          },
                          child: const Text("Log In"),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _login() async {
    User user = User(
      username: _usernameFieldController.text,
      password: _passwordFieldController.text,
    );

    await ref.read(sessionProvider.notifier).save(user);
    ref.read(sessionProvider).when(
      data: (token) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
      },
      error: (e, s) {
        getLogger().e("Failed to login user", error: e, stackTrace: s);
      },
      loading: () {
        getLogger().f("Loading cannot happen due to await save");
        throw Exception("Loading cannot happen due to await save");
      },
    );
  }
}
