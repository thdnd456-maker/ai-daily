import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../app/rest_timer.dart';
import 'diet/diet_tab.dart';
import 'history/history_screen.dart';
import 'home/home_screen.dart';
import 'stats/stats_screen.dart';
import 'trainer/trainer_screen.dart';

/// 하단 메뉴: 홈(운동 포함) | 식단 | 기록 | 통계 | AI 트레이너
class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});
  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    Notifications.requestPermission();
    ref.read(restTimerProvider); // 저장된 휴식 타이머 복원
  }

  void go(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    final pages = [HomeScreen(onNavigate: go), const DietTab(), const HistoryScreen(), const StatsScreen(), const TrainerScreen()];
    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: go,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: '홈'),
          NavigationDestination(icon: Icon(Icons.restaurant_menu_outlined), selectedIcon: Icon(Icons.restaurant_menu), label: '식단'),
          NavigationDestination(icon: Icon(Icons.event_note_outlined), selectedIcon: Icon(Icons.event_note), label: '기록'),
          NavigationDestination(icon: Icon(Icons.insights_outlined), selectedIcon: Icon(Icons.insights), label: '통계'),
          NavigationDestination(icon: Icon(Icons.smart_toy_outlined), selectedIcon: Icon(Icons.smart_toy), label: 'AI 트레이너'),
        ],
      ),
    );
  }
}
