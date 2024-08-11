import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:password/PasswordListScreen.dart'; 
import 'package:password/db.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
  return MaterialApp(
  title: 'Random Password Generator',
  theme: ThemeData(
    primarySwatch: Colors.blue,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    scaffoldBackgroundColor: Colors.white,
  ),
  home: const RandomPasswordGenerator(),
);

   
  }
}

class RandomPasswordGenerator extends StatefulWidget {
  const RandomPasswordGenerator({super.key});

  @override
  State<RandomPasswordGenerator> createState() => _RandomPasswordGeneratorState();
}

class _RandomPasswordGeneratorState extends State<RandomPasswordGenerator> {
  List<String> char = [];
  var symbols = "!@#\$%^&*()";
  List<String> password = [];
  bool? hasNumbers = true;
  bool? hasSymbols = true;
  bool? hasUppercase = true;
  bool? hasLowercase = true;
  double length = 8;

  final DatabaseHelper _dbHelper = DatabaseHelper(); 

  void generatePassword() {
    char = [];

    if (hasNumbers!) {
      List.generate(10, (index) => char.add(String.fromCharCode(index + 48)));
    }
    if (hasSymbols!) {
      List.generate(8, (index) => char.add(symbols[index]));
    }
    if (hasUppercase!) {
      List.generate(26, (index) => char.add(String.fromCharCode(index + 65)));
    }
    if (hasLowercase!) {
      List.generate(26, (index) => char.add(String.fromCharCode(index + 97)));
    }
    if (char.isNotEmpty) {
      char.shuffle();

      password = [];
      final random = math.Random();
      for (int i = 0; i < length; i++) {
        password.add(char[random.nextInt(char.length)]);
      }
      password.shuffle();

      setState(() {});
    } else {
      password = [];
      setState(() {});
    }
  }

  void savePassword(String name, String password) {
    _dbHelper.insertPassword(name, password);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('Password Saved'),
      ),
    );
  }

  void showSaveDialog() {
    String name = '';
    TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Save Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Enter a name for this password:'),
              TextField(
                controller: nameController,
                onChanged: (value) {
                  name = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (name.isNotEmpty) {
                  savePassword(name, password.join());
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                iconColor: Colors.blue,
              ),
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void navigateToPasswordListScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PasswordListScreen()),
    );
  }

  @override
  void initState() {
    generatePassword();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Password Generator'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              showSaveDialog();
            },
          ),
          IconButton(
            icon: Icon(Icons.list),
            onPressed: () {
              navigateToPasswordListScreen();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Generated Password:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
                const SizedBox(height: 10),
                password.isEmpty
                    ? const Text(
                        'Please select at least one option',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              password.join(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy),
                            tooltip: 'Copy Password',
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: password.join()));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  behavior: SnackBarBehavior.floating,
                                  content: Text('Password Copied'),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CheckBoxs(
                          checkBoxText: 'A-Z',
                          value: hasUppercase,
                          onChanged: (value) {
                            setState(() {
                              hasUppercase = value;
                            });
                            generatePassword();
                          },
                        ),
                        CheckBoxs(
                          checkBoxText: 'a-z',
                          value: hasLowercase,
                          onChanged: (value) {
                            setState(() {
                              hasLowercase = value;
                            });
                            generatePassword();
                          },
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CheckBoxs(
                          checkBoxText: '0-9',
                          value: hasNumbers,
                          onChanged: (value) {
                            setState(() {
                              hasNumbers = value;
                            });
                            generatePassword();
                          },
                        ),
                        CheckBoxs(
                          checkBoxText: 'Special Characters',
                          value: hasSymbols,
                          onChanged: (value) {
                            setState(() {
                              hasSymbols = value;
                            });
                            generatePassword();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Password Length: ', style: TextStyle(fontSize: 16)),
                    Text('${length.toInt()}', style: const TextStyle(fontSize: 16)),
                  ],
                ),
                Slider(
                  label: length.toString(),
                  value: length,
                  min: 8,
                  max: 20,
                  divisions: 12,
                  onChanged: (value) {
                    setState(() {
                      length = value;
                    });
                    generatePassword();
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                   style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                  onPressed: () => generatePassword(),
                  child: const Text('Generate Password'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CheckBoxs extends StatelessWidget {
  final String checkBoxText;
  final bool? value;
  final Function(bool?)? onChanged;

  const CheckBoxs({
    required this.checkBoxText,
    required this.value,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.blue,
        ),
        const SizedBox(width: 5),
        Text(checkBoxText),
      ],
    );
  }
}
