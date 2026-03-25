import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ironkey/app_theme.dart';

void main() {
  runApp(const IronKeyApp());
}

class IronKeyApp extends StatelessWidget {
  const IronKeyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const IronKeyScreen(),
    );
  }
}

class IronKeyScreen extends StatefulWidget {
  const IronKeyScreen({super.key});

  @override
  State<IronKeyScreen> createState() => _IronKeyScreenState();
}

class _IronKeyScreenState extends State<IronKeyScreen> {
  final TextEditingController _passwordController = TextEditingController();

  int _maxCharacters = 12;

  bool isPin = false;

  @override
  void initState() {
    super.initState();

    _passwordController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void copyPassword(String password) {
    Clipboard.setData(ClipboardData(text: password));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Senha copiada!')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ColorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ClipOval(
                      child: SizedBox(
                        child: Image.asset("assets/images/ironman.png"),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      "Blindagem Total",
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),

                    const SizedBox(height: 24),

                    TextField(
                      controller: _passwordController,
                      maxLength: _maxCharacters,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: _passwordController.text.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  copyPassword(_passwordController.text);
                                },
                                icon: Icon(Icons.copy),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text("Tipo de senha"),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile(
                            value: true,
                            groupValue: isPin,
                            onChanged: (value) {
                              setState(() {
                                isPin = true;
                              });
                            },
                            title: Text("PIN"),
                          ),
                        ),
                        Expanded(
                          child: RadioListTile(
                            value: false,
                            groupValue: isPin,
                            onChanged: (value) {
                              setState(() {
                                isPin = false;
                              });
                            },
                            title: Text("Senha Padrão"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: FilledButton(
                onPressed: () {
                  final PasswordGenerator generator = isPin
                      ? PinPasswordGenerator()
                      : StandardPasswordGenerator(
                          includeUppercase: true,
                          includeLowercase: true,
                          includeNumbers: true,
                          includeSymbols: true,
                        );
                  final result = generator.generate(_maxCharacters);
                  setState(() {
                    _passwordController.text = result;
                  });
                },
                child: Text("Gerar senha"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

abstract interface class PasswordGenerator {
  String generate(int length);
}

class PinPasswordGenerator implements PasswordGenerator {
  @override
  String generate(int length) {
    const digits = '0123456789';
    final random = Random();

    return List.generate(
      length,
      (_) => digits[random.nextInt(digits.length)],
    ).join();
  }
}

class StandardPasswordGenerator implements PasswordGenerator {
  final bool includeUppercase;
  final bool includeLowercase;
  final bool includeNumbers;
  final bool includeSymbols;
  StandardPasswordGenerator({
    required this.includeUppercase,
    required this.includeLowercase,
    required this.includeNumbers,
    required this.includeSymbols,
  });
  @override
  String generate(int length) {
    final buffer = StringBuffer();
    if (includeUppercase) buffer.write('ABCDEFGHIJKLMNOPQRSTUVWXYZ');
    if (includeLowercase) buffer.write('abcdefghijklmnopqrstuvwxyz');
    if (includeNumbers) buffer.write('0123456789');
    if (includeSymbols) buffer.write('!@#\$%&*()_-+=<>?');
    final chars = buffer.toString();
    if (chars.isEmpty) return '';
    final random = Random();
    return List.generate(
      length,
      (_) => chars[random.nextInt(chars.length)],
    ).join();
  }
}
