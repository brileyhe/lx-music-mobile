import 'package:flutter/material.dart';
import 'core/init/app_initializer.dart';
import 'core/init/initialization_progress_tracker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the app with necessary setup
  await AppInitializer.initialize();

  runApp(const LxMusicApp());
}

class LxMusicApp extends StatelessWidget {
  const LxMusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LX Music',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const SplashScreen(),
    );
  }
}

// Global reference to the shared progress tracker
InitializationProgressTracker? _globalTracker;

// Splash screen that shows initialization progress
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _progress = 0.0;
  String _status = 'Initializing LX Music...';
  List<String> _completedSteps = [];

  @override
  void initState() {
    super.initState();
    _setupProgressTracking();
  }

  void _setupProgressTracking() {
    // Get the tracker from the AppInitializer
    _globalTracker = AppInitializer.getProgressTracker();
    
    if (_globalTracker != null) {
      // Listen to progress updates
      _globalTracker!.progressStream.listen((progress) {
        setState(() {
          _progress = progress;
        });
      });

      // Listen to status updates
      _globalTracker!.statusStream.listen((status) {
        setState(() {
          _status = status;
        });
      });

      // Listen to step updates
      _globalTracker!.stepStream.listen((step) {
        setState(() {
          if (step.isCompleted && !_completedSteps.contains(step.name)) {
            _completedSteps.add(step.name);
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App logo or icon would go here
              const Icon(
                Icons.music_note,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 40),
              Text(
                'LX Music',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 40),
              // Progress bar
              LinearProgressIndicator(
                value: _progress,
                minHeight: 6,
              ),
              const SizedBox(height: 16),
              // Progress text
              Text(
                '${(_progress * 100).round()}% - $_status',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              // Completed steps list (limited to last few)
              SizedBox(
                height: 100,
                child: ListView.builder(
                  itemCount: _completedSteps.length,
                  itemBuilder: (context, index) {
                    // Show only the last 5 completed steps
                    int actualIndex = _completedSteps.length - 1 - index;
                    if (actualIndex < 0) return const SizedBox.shrink();
                    
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        '✓ ${_completedSteps[actualIndex]}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.green,
                            ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Don't dispose the global tracker as it's managed by AppInitializer
    super.dispose();
  }
}