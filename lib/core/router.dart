import 'package:flutter/material.dart';
import '../game_screen.dart';
import '../player_setup_screen.dart';
import '../role_check_screen.dart';
import '../voting_screen.dart';
import '../results_screen.dart';
import '../main.dart'; // HomeScreen 임포트

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return _fadeRoute(const HomeScreen(), settings);
      case '/player_setup':
        return _fadeRoute(const PlayerSetupScreen(), settings);
      case '/role_check':
        return _fadeRoute(const RoleCheckScreen(), settings);
      case '/game':
        return _fadeRoute(const GameScreen(), settings);
      case '/voting':
        return _fadeRoute(const VotingScreen(), settings);
      case '/results':
        return _fadeRoute(const ResultsScreen(), settings);
      default:
        return _fadeRoute(
          Scaffold(
            body: Center(child: Text('${settings.name} 경로는 존재하지 않습니다.')),
          ),
          settings,
        );
    }
  }

  // 페이드 전환 효과를 위한 헬퍼 함수
  static PageRouteBuilder _fadeRoute(Widget child, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 300), // 전환 속도 조절
    );
  }
}
