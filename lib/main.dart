import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:footer/footer.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

import 'package:hooks_riverpod/hooks_riverpod.dart';

final scanStateProvider = StateNotifierProvider<ScanNotifier, ScanState>((ref) {
  return ScanNotifier();
});

class ScanState {
  final bool scanning;
  final int progress;
  final int filesScanned;
  final int threatsFound;
  final String scanStatus;
  final List<String> notifications;

  ScanState({
    this.scanning = false,
    this.progress = 0,
    this.filesScanned = 0,
    this.threatsFound = 0,
    this.scanStatus = 'System Ready',
    this.notifications = const [],
  });

  ScanState copyWith({
    bool? scanning,
    int? progress,
    int? filesScanned,
    int? threatsFound,
    String? scanStatus,
    List<String>? notifications,
  }) {
    return ScanState(
      scanning: scanning ?? this.scanning,
      progress: progress ?? this.progress,
      filesScanned: filesScanned ?? this.filesScanned,
      threatsFound: threatsFound ?? this.threatsFound,
      scanStatus: scanStatus ?? this.scanStatus,
      notifications: notifications ?? this.notifications,
    );
  }
}

class ScanNotifier extends StateNotifier<ScanState> {
  Timer? _scanTimer;
  Timer? _tipTimer;

  ScanNotifier() : super(ScanState()) {
    _startTipTimer();
  }

  void initiateScan() {
    if (state.scanning) return;

    state = state.copyWith(
      scanning: true,
      progress: 0,
      filesScanned: 0,
      threatsFound: 0,
      scanStatus: '>> SCANNING SYSTEM <<',
    );

    _scanTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      final newProgress = state.progress + 1;
      final newFilesScanned = state.filesScanned + Random().nextInt(15);

      if (Random().nextDouble() < 0.1 && state.progress < 95) {
        state = state.copyWith(
          threatsFound: state.threatsFound + 1,
        );
        addNotification('🚨 Potential threat detected!');
      }

      if (newProgress >= 100) {
        timer.cancel();
        state = state.copyWith(
          scanning: false,
          progress: 100,
          scanStatus: 'SCAN COMPLETE',
        );
        addNotification('✅ System scan completed successfully');
      } else {
        state = state.copyWith(
          progress: newProgress,
          filesScanned: newFilesScanned,
        );
      }
    });
  }

  void addNotification(String message) {
    state = state.copyWith(
      notifications: [...state.notifications, message],
    );
    Future.delayed(Duration(seconds: 3), () {
      if (mounted) {
        state = state.copyWith(
          notifications:
              state.notifications.where((n) => n != message).toList(),
        );
      }
    });
  }

  void _startTipTimer() {
    const tips = [
      "Keep your apps updated for better security",
      "Avoid installing apps from unknown sources",
      "Regular scans help maintain device security",
      "Monitor app permissions carefully"
    ];

    _tipTimer = Timer.periodic(Duration(seconds: 15), (_) {
      if (!state.scanning) {
        final tip = tips[Random().nextInt(tips.length)];
        addNotification('💡 Tip: $tip');
      }
    });
  }

  @override
  void dispose() {
    _scanTimer?.cancel();
    _tipTimer?.cancel();
    super.dispose();
  }
}

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
  ],
);

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      title: 'GetSecure',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Color(0xFF0A0A0F),
        textTheme: GoogleFonts.shareTechMonoTextTheme(
          Theme.of(context).textTheme.apply(bodyColor: Colors.white),
        ),
      ),
    );
  }
}

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scanState = ref.watch(scanStateProvider);

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 80),
                HomeHeader(),
                ScannerSection(),
                FeaturesSection(),
                Footer(),
              ],
            ),
          ),
          NavBar(),
          NotificationOverlay(),
        ],
      ),
    );
  }
}

class NavBar extends ConsumerWidget {
  const NavBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          color: Colors.black.withOpacity(0.7),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.network(
                      'https://firebasestorage.googleapis.com/v0/b/widecanvas-d0dd4.appspot.com/o/logos%2Fcover12.png?alt=media&token=05577b7c-abc0-4bcd-b928-a49e0ee1d07b',
                      height: 40,
                    ),
                    SizedBox(width: 8),
                    CyberGlitchText('GetSecure',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
                CyberButton(
                  onPressed: () =>
                      ref.read(scanStateProvider.notifier).initiateScan(),
                  child: Text('Start Scan'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CyberGlitchText extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const CyberGlitchText(this.text, {this.style, super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Text(
          text,
          style: style?.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2
              ..color = Colors.cyan,
          ),
        ),
        Text(
          text,
          style: style?.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2
              ..color = Colors.pink,
          ),
        ),
        Text(text, style: style),
      ],
    );
  }
}

class CyberButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;

  const CyberButton({
    required this.onPressed,
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.cyan, width: 2),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.cyan.withOpacity(0.5),
            blurRadius: 10,
          ),
        ],
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        child: child,
      ),
    );
  }
}

// Add remaining widget implementations (HomeHeader, ScannerSection, FeaturesSection, Footer, NotificationOverlay)
// following the same pattern and cyber aesthetic...
