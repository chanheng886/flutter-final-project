import 'package:flutter/material.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/storage/token_storage.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/theme/theme_provider.dart';
import 'package:frontend/features/auth/providers/auth_provider.dart';
import 'package:frontend/features/auth/views/login_page.dart';
import 'package:frontend/features/home/providers/workspace_provider.dart';
import 'package:frontend/shell/main_shell.dart';
import 'package:provider/provider.dart';

void main() {
  final tokenStorage = TokenStorage();
  final apiClient = ApiClient(tokenStorage);

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: tokenStorage),
        Provider.value(value: apiClient),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(apiClient, tokenStorage)..tryAutoLogin(),
        ),
        ChangeNotifierProvider(
          create: (_) => WorkspaceProvider(apiClient),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeProvider.themeMode,
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          switch (auth.status) {
            case AuthStatus.unknown:
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            case AuthStatus.authenticated:
              return ChangeNotifierProvider(
                create: (ctx) =>
                    WorkspaceProvider(ctx.read<ApiClient>())..loadDashboard(),
                child: const MainShell(),
              );
            case AuthStatus.unauthenticated:
              return const LoginPage();
          }
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
