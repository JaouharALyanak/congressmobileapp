import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'utils/responsive.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'config/app_config.dart';
import 'services/storage_service.dart';
import 'services/device_service.dart';
import 'core/api_client.dart';
import 'providers/speaker_provider.dart';
import 'providers/sponsor_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/connectivity_provider.dart';
import 'views/main_shell.dart';
import 'providers/committee_provider.dart';
import 'providers/program_provider.dart';
import 'providers/abstract_provider.dart';
import 'providers/vod_provider.dart';
import 'providers/faq_provider.dart';
import 'utils/connectivity_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await NotificationService.init();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => SpeakerProvider()),
        ChangeNotifierProvider(create: (_) => SponsorProvider()),
        ChangeNotifierProvider(create: (_) => CommitteeProvider()),
        ChangeNotifierProvider(create: (_) => ProgramProvider()),
        ChangeNotifierProvider(create: (_) => AbstractProvider()),
        ChangeNotifierProvider(create: (_) => VodProvider()),
        ChangeNotifierProvider(create: (_) => FaqProvider()),
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true),
        home: const SplashBootScreen(),
      ),
    );
  }
}

class SplashBootScreen extends StatefulWidget {
  const SplashBootScreen({super.key});

  @override
  State<SplashBootScreen> createState() => _SplashBootScreenState();
}

class _SplashBootScreenState extends State<SplashBootScreen> {
  bool _hasError = false;
  String? _splashBgUrl;

  @override
  void initState() {
    super.initState();
    _loadSplashBg();
    _initializeApp();
  }

  Future<void> _loadSplashBg() async {
    final url = await StorageService.getCachedSplashBgUrl();
    if (mounted) setState(() => _splashBgUrl = url);
  }

  Future<void> _initializeApp() async {
    setState(() => _hasError = false);

    final isOnline = await ConnectivityService.isOnline();

    // ── OFFLINE path ─────────────────────────────────────────────────────
    if (!isOnline) {
      final token = await StorageService.getToken();
      if (token != null) {
        // We have a token → load cached theme and go home
        if (mounted) {
          await context.read<ThemeProvider>().loadCachedTheme();
          if (!mounted) return;
          // If cache was empty, ThemeProvider sets errorMessage
          if (context.read<ThemeProvider>().errorMessage != null) {
            setState(() => _hasError = true);
            return;
          }
          await _checkAppVersion();
        }
      } else {
        setState(() => _hasError = true);
      }
      return;
    }

    // ── ONLINE path ──────────────────────────────────────────────────────
    final token = await StorageService.getToken();
    if (token != null) {
      final isValid = await ApiClient.verifyToken();
      if (isValid) {
        if (mounted) {
          // forceRefresh: toujours récupérer les données fraîches du serveur
          // (popup_image_url, couleurs, config…) — le cache sert uniquement en fallback hors-ligne
          await context.read<ThemeProvider>().loadTheme(forceRefresh: true);
          await _checkAppVersion();
        }
        return;
      }
    }

    await _performBoot();
  }

  Future<void> _performBoot() async {
    try {
      final deviceId = await DeviceService.getDeviceId();
      final response = await ApiClient.dio.post(
        '/boot',
        data: {
          'event_slug': AppConfig.eventSlug,
          'event_token': AppConfig.eventAccessKey,
          'device_id': deviceId,
        },
      );
      if (response.statusCode == 200) {
        await StorageService.saveToken(response.data['token']);
        if (mounted) {
          await context.read<ThemeProvider>().loadTheme(forceRefresh: true);
          await _checkAppVersion();
        }
      }
    } catch (e) {
      debugPrint("Erreur Boot : $e");
      // Boot failed even though we thought we were online
      // Try cache as last resort
      if (mounted) {
        await context.read<ThemeProvider>().loadCachedTheme();
        if (!mounted) return;
        if (context.read<ThemeProvider>().errorMessage != null) {
          setState(() => _hasError = true);
        } else {
          await _checkAppVersion();
        }
      }
    }
  }

  Future<void> _checkAppVersion() async {
    // Utilise app_version déjà chargé depuis la réponse theme (évite un appel API supplémentaire)
    final serverVersion = context.read<ThemeProvider>().requiredVersion;
    final info = await PackageInfo.fromPlatform();
    final currentBuild = int.tryParse(info.buildNumber) ?? 0;

    if (serverVersion <= 0) {
      _navigateToHome();
      return;
    }

    if (currentBuild < serverVersion && mounted) {
      final forced = AppConfig.forceUpdate;
      await showDialog(
        context: context,
        barrierDismissible: !forced,
        builder: (dialogContext) => PopScope(
          canPop: !forced,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              'Mise à jour disponible',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: const Text(
              'Une nouvelle version de l\'application est disponible. Veuillez mettre à jour pour continuer.',
            ),
            actions: [
              if (!forced)
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    _navigateToHome();
                  },
                  child: const Text('Plus tard'),
                ),
              TextButton(
                onPressed: () async {
                  if (kIsWeb) return; // No store on web.
                  final url = AppConfig.storeUrl;
                  if (url.isNotEmpty) {
                    final uri = Uri.parse(url);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  }
                },
                child: Text(
                  kIsWeb ? 'OK' : 'Mettre à jour',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      );
      if (forced) return;
    }

    _navigateToHome();
  }

  void _navigateToHome() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // ── Shared background widget ─────────────────────────────────────────
    Widget background;
    if (_splashBgUrl != null) {
      background = CachedNetworkImage(
        imageUrl: _splashBgUrl!,
        fit: BoxFit.cover,
        errorWidget: (_, _, _) =>
            Container(color: AppConfig.primaryColor),
      );
    } else {
      background = Container(color: AppConfig.primaryColor);
    }

    // ── Error screen: no internet + no cache ────────────────────────────
    if (_hasError) {
      return Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            background,
            Container(color: Colors.black.withValues(alpha: 0.5)),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wifi_off, size: 64, color: Colors.white),
                    const SizedBox(height: 24),
                    Text(
                      'Pas de connexion internet',
                      style: TextStyle(
                        fontSize: rFs(context, 20),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Connectez-vous à internet pour\nutiliser l\'application.',
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white70, fontSize: rFs(context, 15)),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: _initializeApp,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Réessayer'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // ── Splash screen: loading ───────────────────────────────────────────
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          background,
          Container(color: Colors.black.withValues(alpha: 0.3)),
          const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Powered by',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Image.asset(
                  'assets/images/logo-ascrea.png',
                  height: 20,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
