import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:water_tracker/screens/profile_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/theme_provider.dart';
import '../providers/water_provider.dart';
import '../services/notification_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // Helper method to determine icon color based on theme
  Color _getIconColor(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return isDarkMode ? Colors.white70 : Theme.of(context).primaryColor;
  }

  // Method to launch email client
  Future<void> _launchEmail(BuildContext context) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'abuelhassan179@gmail.com',
      query: 'subject=Support Request&body=Please describe your issue:',
    );
    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Could not launch email client'),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Error launching email client'),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return AnimatedTheme(
          data: theme,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  expandedHeight: 200.0,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      'Settings',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    background: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors:
                              isDarkMode
                                  ? [
                                    Colors.blueGrey.shade900,
                                    Colors.blueGrey.shade700,
                                  ]
                                  : [
                                    Colors.blue.shade400,
                                    Colors.blue.shade200,
                                  ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 16),
                    // Profile Card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            radius: 30,
                            backgroundColor: _getIconColor(context),
                            child: Icon(
                              Icons.person,
                              color: isDarkMode ? Colors.black : Colors.white,
                            ),
                          ),
                          title: const Text(
                            'User Profile',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: const Text('Manage your account settings'),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: _getIconColor(context),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfileScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Theme Settings
                    _buildSectionHeader(
                      context,
                      'Appearance',
                      MdiIcons.palette,
                    ),
                    _buildCard(
                      context,
                      child: Consumer<ThemeProvider>(
                        builder: (context, themeProvider, child) {
                          return SwitchListTile(
                            title: const Text(
                              'Dark Mode',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: const Text(
                              'Enable dark theme for better visibility',
                            ),
                            value: themeProvider.isDarkMode,
                            activeColor: _getIconColor(context),
                            onChanged: (value) {
                              HapticFeedback.lightImpact();
                              themeProvider.toggleTheme();
                            },
                            secondary: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              child: RotationTransition(
                                turns: Tween(begin: 0.0, end: 0.5).animate(
                                  CurvedAnimation(
                                    parent: AnimationController(
                                      vsync: Navigator.of(context),
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      value:
                                          themeProvider.isDarkMode ? 1.0 : 0.0,
                                    )..forward(),
                                    curve: Curves.easeInOut,
                                  ),
                                ),
                                child: ScaleTransition(
                                  scale: Tween(begin: 0.8, end: 1.0).animate(
                                    CurvedAnimation(
                                      parent: AnimationController(
                                        vsync: Navigator.of(context),
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        value:
                                            themeProvider.isDarkMode
                                                ? 1.0
                                                : 0.0,
                                      )..forward(),
                                      curve: Curves.easeInOut,
                                    ),
                                  ),
                                  child: Icon(
                                    themeProvider.isDarkMode
                                        ? Icons.nightlight_round
                                        : Icons.wb_sunny,
                                    color: _getIconColor(context),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    // Notification Settings
                    _buildSectionHeader(
                      context,
                      'Notifications',
                      MdiIcons.bell,
                    ),
                    _buildCard(
                      context,
                      child: Consumer<WaterProvider>(
                        builder: (context, waterProvider, child) {
                          return Column(
                            children: [
                              SwitchListTile(
                                title: const Text(
                                  'Reminder Notifications',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                subtitle: const Text(
                                  'Receive timely reminders to stay hydrated',
                                ),
                                value: waterProvider.remindersEnabled,
                                activeColor: _getIconColor(context),
                                onChanged: (value) {
                                  HapticFeedback.lightImpact();
                                  waterProvider.setRemindersEnabled(value);
                                  if (value) {
                                    NotificationService().scheduleReminders();
                                  } else {
                                    NotificationService()
                                        .cancelAllNotifications();
                                  }
                                },
                                secondary: Icon(
                                  MdiIcons.clockOutline,
                                  color: _getIconColor(context),
                                ),
                              ),
                              // Add a divider between the switch and the test button
                              // const Divider(),
                              // // Add the test notification button
                              // Padding(
                              //   padding: const EdgeInsets.symmetric(
                              //     horizontal: 16.0,
                              //     vertical: 8.0,
                              //   ),
                              //   child: Center(child: TestNotificationButton()),
                              // ),
                            ],
                          );
                        },
                      ),
                    ),
                    // Units Settings
                    _buildSectionHeader(context, 'App Settings', MdiIcons.cog),
                    
                    // About
                    _buildSectionHeader(context, 'About', MdiIcons.information),
                    _buildCard(
                      context,
                      child: Column(
                        children: [
                          ListTile(
                            title: const Text(
                              'App Version',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: const Text('1.0.0'),
                            leading: Icon(
                              MdiIcons.tag,
                              color: _getIconColor(context),
                            ),
                          ),
                          ListTile(
                            title: const Text(
                              'Privacy Policy',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: _getIconColor(context),
                            ),
                            leading: Icon(
                              MdiIcons.shieldLock,
                              color: _getIconColor(context),
                            ),
                            onTap: () {
                              HapticFeedback.lightImpact();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => const PrivacyPolicyScreen(),
                                ),
                              );
                            },
                          ),
                          ListTile(
                            title: const Text(
                              'Support',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: _getIconColor(context),
                            ),
                            leading: Icon(
                              MdiIcons.fileDocument,
                              color: _getIconColor(context),
                            ),
                            onTap: () {
                              HapticFeedback.lightImpact();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'Contact support at abuelhassan179@gmail.com',
                                  ),
                                  backgroundColor: _getIconColor(context),
                                  duration: const Duration(seconds: 4),
                                  action: SnackBarAction(
                                    label: 'Email',
                                    textColor:
                                        isDarkMode
                                            ? Colors.black
                                            : Colors.white,
                                    onPressed: () => _launchEmail(context),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ]),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Icon(icon, color: _getIconColor(context), size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, {required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Material(color: Theme.of(context).cardColor, child: child),
        ),
      ),
    );
  }
}

// Privacy Policy Screen
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Privacy Policy',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: isDark ? Colors.blueGrey.shade900 : Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'HydroMate Privacy Policy',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Last updated: May 3, 2025',
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('1. Information We Collect'),
              _buildBullet(
                'Personal Data: Gender, weight, and activity level (for hydration goal calculations).',
              ),
              _buildBullet(
                'Usage Data: Hydration logs, streaks, and daily progress.',
              ),
              _buildBullet(
                'Custom Settings: Reminder times and theme preferences.',
              ),
              _buildNote(
                'This data is used only to improve hydration tracking and is never shared without your explicit consent.',
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('2. How We Use Your Information'),
              _buildBullet('Calculate personalized hydration goals.'),
              _buildBullet('Send reminders to drink water.'),
              _buildBullet('Display progress statistics.'),
              _buildBullet(
                'Enhance user experience with customizable features.',
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('3. Data Storage and Security'),
              _buildBullet('All data is stored securely on your device.'),
              _buildBullet(
                'No sensitive data is transmitted to external servers.',
              ),
              _buildBullet('We use appropriate measures to protect your data.'),
              const SizedBox(height: 16),
              _buildSectionTitle('4. Permissions Required'),
              _buildBullet('Notifications: To send hydration reminders.'),
              _buildBullet('Storage: To save preferences and backgrounds.'),
              _buildBullet('Health Access: To read step count (if enabled).'),
              _buildNote(
                'All permissions are optional and can be managed via device settings.',
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('5. Third-Party Services'),
              Text(
                'HydroMate does not share your data with third parties. If future integrations require this, we will update the policy accordingly.',
                style: GoogleFonts.poppins(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('6. Children\'s Privacy'),
              Text(
                'We do not knowingly collect data from children under 13. Contact us if you believe your child has provided personal data.',
                style: GoogleFonts.poppins(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('7. Changes to This Policy'),
              Text(
                'We may occasionally update this policy. Continued use of HydroMate implies acceptance of the latest version.',
                style: GoogleFonts.poppins(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('8. Contact Us'),
              Text(
                'If you have any questions or concerns, feel free to reach out to us at:',
                style: GoogleFonts.poppins(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 8),
              SelectableText(
                '📧 abuelhassan179@gmail.com',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
    );
  }

  Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(fontSize: 18)),
          Expanded(child: Text(text, style: GoogleFonts.poppins(fontSize: 16))),
        ],
      ),
    );
  }

  Widget _buildNote(String note) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text(
        'Note: $note',
        style: GoogleFonts.poppins(
          fontSize: 15,
          fontStyle: FontStyle.italic,
          color: Colors.orange.shade800,
        ),
      ),
    );
  }
}
