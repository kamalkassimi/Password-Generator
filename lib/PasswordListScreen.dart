import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:password/db.dart';

class PasswordListScreen extends StatefulWidget {
  const PasswordListScreen({Key? key}) : super(key: key);

  @override
  State<PasswordListScreen> createState() => _PasswordListScreenState();
}

class _PasswordListScreenState extends State<PasswordListScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _passwords = [];

  @override
  void initState() {
    super.initState();
    _fetchPasswords();
  }

  Future<void> _fetchPasswords() async {
    final passwords = await _dbHelper.getPasswords();
    setState(() {
      _passwords = passwords;
    });
  }

  void _copyPassword(String password) {
    Clipboard.setData(ClipboardData(text: password));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('Password Copied'),
      ),
    );
  }

  void _deletePassword(int id) async {
    await _dbHelper.deletePassword(id);
    _fetchPasswords(); // Refresh the list after deletion
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('Password Deleted'),
      ),
    );
  }

  void _updatePassword(int id, String newPassword) async {
    await _dbHelper.updatePassword(id, newPassword);
    _fetchPasswords(); // Refresh the list after update
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('Password Updated'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Passwords'),
        backgroundColor: Colors.blue, // Change app bar color
      ),
      body: _passwords.isEmpty
          ? const Center(
              child: Text('No saved passwords'),
            )
          : ListView.builder(
              itemCount: _passwords.length,
              itemBuilder: (context, index) {
                final password = _passwords[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  elevation: 2,
                  child: ListTile(
                    title: Text(
                      password['name'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(password['password']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.copy),
                          tooltip: 'Copy Password',
                          onPressed: () {
                            _copyPassword(password['password']);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          tooltip: 'Delete Password',
                          onPressed: () {
                            _deletePassword(password['id']);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          tooltip: 'Update Password',
                          onPressed: () {
                            _showUpdateDialog(password);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showUpdateDialog(Map<String, dynamic> password) {
    String newPassword = password['password'];
    TextEditingController passwordController =
        TextEditingController(text: newPassword);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Current password: ${password['password']}'),
              TextField(
                controller: passwordController,
                onChanged: (value) {
                  newPassword = value;
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
                _updatePassword(password['id'], newPassword);
                Navigator.pop(context);
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }
}
