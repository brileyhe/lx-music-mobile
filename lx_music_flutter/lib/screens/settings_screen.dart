import 'package:flutter/material.dart';
import '../utils/responsive_layout.dart';

/// Settings screen that allows users to configure app preferences
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // App settings
  bool _notificationsEnabled = true;
  bool _autoDownloadEnabled = false;
  bool _highQualityAudio = true;
  String _themeMode = 'system'; // 'light', 'dark', 'system'
  double _volumeBoost = 0.0;
  bool _enableEqualizer = false;
  String _sleepTimer = 'off'; // 'off', '15min', '30min', '45min', '60min'
  bool _showLockScreenControls = true;
  bool _autoPlayOnConnect = true;
  bool _hideExplicitContent = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SafeArea(
        child: ResponsiveBuilder(
          builder: (context, screenSize, constraints) {
            return ListView(
              padding: ResponsiveLayout.getResponsivePadding(context),
              children: [
                // Account Section
                _buildSectionHeader('Account'),
                _buildSettingsCard([
                  _buildListTile(
                    icon: Icons.account_circle,
                    title: 'Account',
                    subtitle: 'Manage your account',
                    onTap: () {},
                  ),
                  _buildListTile(
                    icon: Icons.sync,
                    title: 'Sync Settings',
                    subtitle: 'Backup and restore',
                    onTap: () {},
                  ),
                ]),
                
                const SizedBox(height: 16),
                
                // Playback Section
                _buildSectionHeader('Playback'),
                _buildSettingsCard([
                  _buildSwitchListTile(
                    icon: Icons.notifications,
                    title: 'Notifications',
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                    },
                  ),
                  _buildSwitchListTile(
                    icon: Icons.volume_up,
                    title: 'High Quality Audio',
                    subtitle: 'Better sound, larger files',
                    value: _highQualityAudio,
                    onChanged: (value) {
                      setState(() {
                        _highQualityAudio = value;
                      });
                    },
                  ),
                  _buildSliderListTile(
                    icon: Icons.volume_up,
                    title: 'Volume Boost',
                    value: _volumeBoost,
                    min: 0.0,
                    max: 20.0,
                    divisions: 20,
                    label: '${_volumeBoost.round()} dB',
                    onChanged: (value) {
                      setState(() {
                        _volumeBoost = value;
                      });
                    },
                  ),
                  _buildSwitchListTile(
                    icon: Icons.graphic_eq,
                    title: 'Enable Equalizer',
                    value: _enableEqualizer,
                    onChanged: (value) {
                      setState(() {
                        _enableEqualizer = value;
                      });
                    },
                  ),
                  _buildDropdownListTile(
                    icon: Icons.timer,
                    title: 'Sleep Timer',
                    value: _sleepTimer,
                    items: const [
                      DropdownMenuItem(value: 'off', child: Text('Off')),
                      DropdownMenuItem(value: '15min', child: Text('15 minutes')),
                      DropdownMenuItem(value: '30min', child: Text('30 minutes')),
                      DropdownMenuItem(value: '45min', child: Text('45 minutes')),
                      DropdownMenuItem(value: '60min', child: Text('60 minutes')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _sleepTimer = value!;
                      });
                    },
                  ),
                ]),
                
                const SizedBox(height: 16),
                
                // Downloads Section
                _buildSectionHeader('Downloads'),
                _buildSettingsCard([
                  _buildSwitchListTile(
                    icon: Icons.download,
                    title: 'Auto Download',
                    subtitle: 'Download songs for offline listening',
                    value: _autoDownloadEnabled,
                    onChanged: (value) {
                      setState(() {
                        _autoDownloadEnabled = value;
                      });
                    },
                  ),
                  _buildListTile(
                    icon: Icons.storage,
                    title: 'Storage Location',
                    subtitle: '/storage/emulated/0/Music',
                    onTap: () {},
                  ),
                  _buildListTile(
                    icon: Icons.data_usage,
                    title: 'Storage Used',
                    subtitle: '1.2 GB',
                    onTap: () {},
                  ),
                ]),
                
                const SizedBox(height: 16),
                
                // Display Section
                _buildSectionHeader('Display'),
                _buildSettingsCard([
                  _buildDropdownListTile(
                    icon: Icons.brightness_medium,
                    title: 'Theme Mode',
                    value: _themeMode,
                    items: const [
                      DropdownMenuItem(value: 'system', child: Text('System Default')),
                      DropdownMenuItem(value: 'light', child: Text('Light')),
                      DropdownMenuItem(value: 'dark', child: Text('Dark')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _themeMode = value!;
                      });
                    },
                  ),
                  _buildSwitchListTile(
                    icon: Icons.lock,
                    title: 'Show Lock Screen Controls',
                    value: _showLockScreenControls,
                    onChanged: (value) {
                      setState(() {
                        _showLockScreenControls = value;
                      });
                    },
                  ),
                ]),
                
                const SizedBox(height: 16),
                
                // Automotive Section
                _buildSectionHeader('Automotive'),
                _buildSettingsCard([
                  _buildSwitchListTile(
                    icon: Icons.bluetooth_connected,
                    title: 'Auto Play on Connect',
                    subtitle: 'Start playing when device connects to car',
                    value: _autoPlayOnConnect,
                    onChanged: (value) {
                      setState(() {
                        _autoPlayOnConnect = value;
                      });
                    },
                  ),
                  _buildSwitchListTile(
                    icon: Icons.visibility_off,
                    title: 'Hide Explicit Content',
                    value: _hideExplicitContent,
                    onChanged: (value) {
                      setState(() {
                        _hideExplicitContent = value;
                      });
                    },
                  ),
                ]),
                
                const SizedBox(height: 16),
                
                // About Section
                _buildSectionHeader('About'),
                _buildSettingsCard([
                  _buildListTile(
                    icon: Icons.info,
                    title: 'About LX Music',
                    subtitle: 'Version 1.8.0',
                    onTap: () {},
                  ),
                  _buildListTile(
                    icon: Icons.privacy_tip,
                    title: 'Privacy Policy',
                    onTap: () {},
                  ),
                  _buildListTile(
                    icon: Icons.article,
                    title: 'Terms of Service',
                    onTap: () {},
                  ),
                ]),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Builds a section header
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(
        left: ResponsiveLayout.getResponsiveSpacing(context),
        bottom: ResponsiveLayout.getResponsiveSpacing(context) / 2,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: ResponsiveLayout.getResponsiveFontSize(context, baseSize: 16),
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  /// Builds a card containing settings items
  Widget _buildSettingsCard(List<Widget> children) {
    return Card(
      elevation: 2,
      child: Column(
        children: children,
      ),
    );
  }

  /// Builds a list tile for settings
  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).primaryColor,
        size: ResponsiveLayout.getResponsiveIconSize(context),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: ResponsiveLayout.getResponsiveFontSize(context),
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                fontSize: ResponsiveLayout.getResponsiveFontSize(context, baseSize: 14),
              ),
            )
          : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  /// Builds a switch list tile for settings
  Widget _buildSwitchListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(
        icon,
        color: Theme.of(context).primaryColor,
        size: ResponsiveLayout.getResponsiveIconSize(context),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: ResponsiveLayout.getResponsiveFontSize(context),
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                fontSize: ResponsiveLayout.getResponsiveFontSize(context, baseSize: 14),
              ),
            )
          : null,
      value: value,
      onChanged: onChanged,
    );
  }

  /// Builds a slider list tile for settings
  Widget _buildSliderListTile({
    required IconData icon,
    required String title,
    required double value,
    required double min,
    required double max,
    int? divisions,
    required String label,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(
            icon,
            color: Theme.of(context).primaryColor,
            size: ResponsiveLayout.getResponsiveIconSize(context),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: ResponsiveLayout.getResponsiveFontSize(context),
            ),
          ),
          trailing: Text(
            label,
            style: TextStyle(
              fontSize: ResponsiveLayout.getResponsiveFontSize(context, baseSize: 14),
            ),
          ),
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          label: label,
          onChanged: onChanged,
        ),
      ],
    );
  }

  /// Builds a dropdown list tile for settings
  Widget _buildDropdownListTile<T>({
    required IconData icon,
    required String title,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?>? onChanged,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).primaryColor,
        size: ResponsiveLayout.getResponsiveIconSize(context),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: ResponsiveLayout.getResponsiveFontSize(context),
        ),
      ),
      trailing: DropdownButton<T>(
        value: value,
        items: items,
        onChanged: onChanged,
        underline: Container(),
      ),
      onTap: () {
        // Trigger the dropdown when tapped on the entire tile
        FocusScope.of(context).requestFocus(FocusNode());
      },
    );
  }
}