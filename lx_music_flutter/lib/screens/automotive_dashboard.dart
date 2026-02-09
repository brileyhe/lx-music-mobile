import 'package:flutter/material.dart';
import '../utils/responsive_layout.dart';
import '../screens/now_playing_screen.dart';
import '../screens/music_library_view.dart';
import '../screens/playlist_view.dart';
import '../screens/search_screen.dart';

/// Automotive-optimized dashboard with large touch targets and simplified interface
class AutomotiveDashboard extends StatefulWidget {
  const AutomotiveDashboard({super.key});

  @override
  State<AutomotiveDashboard> createState() => _AutomotiveDashboardState();
}

class _AutomotiveDashboardState extends State<AutomotiveDashboard> {
  int _selectedIndex = 0;
  
  // Simplified navigation for automotive use
  final List<Widget> _pages = [
    const MusicLibraryView(),
    const PlaylistView(),
    const NowPlayingScreen(
      playlistManager: PlaylistManager(), // This would be injected in a real app
    ),
    const SearchScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Automotive interfaces often use full-screen layouts
      body: _pages[_selectedIndex],
      bottomNavigationBar: _buildAutomotiveNavigation(),
    );
  }

  /// Builds automotive-optimized navigation
  Widget _buildAutomotiveNavigation() {
    return Container(
      height: ResponsiveLayout.getResponsiveButtonHeight(context) * 1.5,
      decoration: BoxDecoration(
        color: Theme.of(context).bottomAppBarColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavButton(
              icon: Icons.library_music,
              label: 'Library',
              isSelected: _selectedIndex == 0,
              onTap: () => _selectPage(0),
            ),
            _buildNavButton(
              icon: Icons.queue_music,
              label: 'Playlist',
              isSelected: _selectedIndex == 1,
              onTap: () => _selectPage(1),
            ),
            _buildNavButton(
              icon: Icons.play_circle,
              label: 'Now Playing',
              isSelected: _selectedIndex == 2,
              onTap: () => _selectPage(2),
            ),
            _buildNavButton(
              icon: Icons.search,
              label: 'Search',
              isSelected: _selectedIndex == 3,
              onTap: () => _selectPage(3),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a large navigation button optimized for automotive use
  Widget _buildNavButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: ResponsiveLayout.getResponsiveButtonHeight(context),
          margin: EdgeInsets.symmetric(horizontal: ResponsiveLayout.getResponsiveSpacing(context) / 4),
          decoration: BoxDecoration(
            color: isSelected 
                ? Theme.of(context).primaryColor.withOpacity(0.2) 
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: ResponsiveLayout.getResponsiveIconSize(context, baseSize: 28),
                color: isSelected 
                    ? Theme.of(context).primaryColor 
                    : Theme.of(context).iconTheme.color,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: ResponsiveLayout.getResponsiveFontSize(context, baseSize: 12),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected 
                      ? Theme.of(context).primaryColor 
                      : Theme.of(context).textTheme.bodyMedium?.color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Selects a page and updates the UI
  void _selectPage(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }
}

/// Automotive-optimized now playing screen with larger controls
class AutomotiveNowPlayingScreen extends StatelessWidget {
  final PlaylistManager playlistManager;
  final AudioEffectsManager? audioEffectsManager;

  const AutomotiveNowPlayingScreen({
    super.key,
    required this.playlistManager,
    this.audioEffectsManager,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Automotive interfaces often hide the app bar for more content space
      body: SafeArea(
        child: Column(
          children: [
            // Large album art display
            Expanded(
              flex: 3,
              child: Padding(
                padding: ResponsiveLayout.getResponsivePadding(context),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      child: const Icon(
                        Icons.album,
                        size: 100,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // Track information
            Expanded(
              flex: 1,
              child: Padding(
                padding: ResponsiveLayout.getResponsivePadding(context),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Song Title',
                      style: TextStyle(
                        fontSize: ResponsiveLayout.getResponsiveFontSize(context, baseSize: 20),
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Artist Name',
                      style: TextStyle(
                        fontSize: ResponsiveLayout.getResponsiveFontSize(context, baseSize: 16),
                        color: Theme.of(context).hintColor,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            
            // Large playback controls
            Expanded(
              flex: 1,
              child: Padding(
                padding: ResponsiveLayout.getResponsivePadding(context),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildLargeControlButton(
                      icon: Icons.skip_previous,
                      size: ResponsiveLayout.getResponsiveTouchTargetSize(context),
                      onPressed: () {
                        // Previous track
                      },
                    ),
                    _buildLargeControlButton(
                      icon: Icons.play_arrow,
                      size: ResponsiveLayout.getResponsiveTouchTargetSize(context) * 1.5,
                      onPressed: () {
                        // Play/Pause
                      },
                    ),
                    _buildLargeControlButton(
                      icon: Icons.skip_next,
                      size: ResponsiveLayout.getResponsiveTouchTargetSize(context),
                      onPressed: () {
                        // Next track
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            // Additional controls row
            Expanded(
              flex: 1,
              child: Padding(
                padding: ResponsiveLayout.getResponsivePadding(context),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildLargeControlButton(
                      icon: Icons.favorite_border,
                      size: ResponsiveLayout.getResponsiveTouchTargetSize(context) * 0.8,
                      onPressed: () {
                        // Favorite
                      },
                    ),
                    _buildLargeControlButton(
                      icon: Icons.playlist_play,
                      size: ResponsiveLayout.getResponsiveTouchTargetSize(context) * 0.8,
                      onPressed: () {
                        // Add to queue
                      },
                    ),
                    _buildLargeControlButton(
                      icon: Icons.graphic_eq,
                      size: ResponsiveLayout.getResponsiveTouchTargetSize(context) * 0.8,
                      onPressed: () {
                        // Equalizer
                      },
                    ),
                    _buildLargeControlButton(
                      icon: Icons.more_vert,
                      size: ResponsiveLayout.getResponsiveTouchTargetSize(context) * 0.8,
                      onPressed: () {
                        // More options
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a large control button for automotive use
  Widget _buildLargeControlButton({
    required IconData icon,
    required double size,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(size / 2),
          onTap: onPressed,
          child: Icon(
            icon,
            size: size * 0.6,
            color: Theme.of(context).iconTheme.color,
          ),
        ),
      ),
    );
  }
}