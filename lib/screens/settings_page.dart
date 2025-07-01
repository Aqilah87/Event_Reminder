import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reminder_test/theme_provider.dart';
import '../models/auth_data.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final auth = Provider.of<AuthData>(context);
    final theme = Theme.of(context);
    final currentUser = auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildSectionHeader("Preferences"),
            Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Dark Mode'),
                    value: themeProvider.isDarkMode,
                    onChanged: (bool value) {
                      themeProvider.toggleTheme();
                    },
                    secondary:
                        Icon(Icons.dark_mode, color: theme.iconTheme.color),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Enable Notifications'),
                    value: _notificationsEnabled,
                    onChanged: (bool value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                    },
                    secondary:
                        Icon(Icons.notifications, color: theme.iconTheme.color),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSectionHeader("User Info"),
            Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: const Icon(Icons.person),
                title: Text(currentUser?.username ?? 'Guest User'),
                trailing: const Icon(Icons.info_outline),
              ),
            ),
            const SizedBox(height: 16),
            _buildSectionHeader("About"),
            Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                ),
                title: const Text('About This App'),
                subtitle:
                    const Text('Event Reminder v1.0\nCreated by Team 3A1I'),
              ),
            ),
            const SizedBox(height: 16),
            _buildSectionHeader("Account"),
            Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Log Out'),
                onTap: () {
                  _showLogoutDialog(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, left: 4.0, bottom: 4.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text("Log Out"),
          content: const Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.pop(ctx); // Close dialog
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (route) => false);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("You have been logged out.")),
                );
              },
              child: const Text("Log Out"),
            ),
          ],
        );
      },
    );
  }
}
