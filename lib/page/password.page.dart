import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_line/page/controller.dart';
import 'package:life_line/page/page.dart';

class PasswordPage extends StatefulWidget {
  const PasswordPage({super.key});

  @override
  State<PasswordPage> createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> {
  final TextEditingController _ctrl = TextEditingController();
  bool _obscure = true;

  void _confirm() {
    final password = _ctrl.text.trim();
    if (password.isEmpty) return;

    final controller = Get.find<MainPageController>();
    controller.init(password);

    Get.off(() => const MainPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Podaj hasło', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 20),
              TextField(
                controller: _ctrl,
                obscureText: _obscure,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: 'Hasło',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                onSubmitted: (_) => _confirm(),
              ),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _confirm, child: const Text('Wejdź')),
            ],
          ),
        ),
      ),
    );
  }
}
