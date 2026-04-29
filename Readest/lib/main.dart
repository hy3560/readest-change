import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 导入业务界面
import 'presentation/screens/dual_reader_screen.dart';
import 'presentation/screens/settings_api_screen.dart';
import 'presentation/screens/stats_dashboard_screen.dart';

void main() async {
  // 1. 确保 Flutter 引擎与插件初始化
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Windows 平台特定的窗口优化（如支持窗口拖拽、最小尺寸限制等）
  // 生产环境下可配合 window_manager 插件使用

  // 3. 设置状态栏透明（Android）
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  runApp(const ReadestApp());
}

class ReadestApp extends StatelessWidget {
  const ReadestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Readest Professional',
      debugShowCheckedModeBanner: false,
      
      // 主题配置：采用 Material 3 标准，配色方案：深海蓝灰
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF2C3E50),
        brightness: Brightness.light,
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
      ),
      
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF2C3E50),
        brightness: Brightness.dark,
      ),
      
      themeMode: ThemeMode.system, // 自动跟随系统深色模式
      
      home: const MainNavigationWrapper(),
    );
  }
}

/// 全局导航包装器：处理多端适配与页面状态保持
class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _currentIndex = 0;

  // 使用列表存储页面，配合 IndexedStack 保持页面内存状态
  final List<Widget> _pages = [
    const DualReaderScreen(),      // 双书并行阅读器
    const StatsDashboardScreen(),  // 阅读统计仪表盘
    const SettingsApiScreen(),     // API 与云端嗅探配置
  ];

  @override
  Widget build(BuildContext context) {
    // 获取屏幕宽度，判断是否为宽屏（Windows/平板）
    final bool isWideScreen = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      // 使用 Row 实现大屏幕侧边导航或小屏幕底部导航的切换
      body: Row(
        children: [
          // Windows 端专用的侧边导航栏
          if (isWideScreen)
            NavigationRail(
              extended: MediaQuery.of(context).size.width > 1200,
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) => setState(() => _currentIndex = index),
              labelType: NavigationRailLabelType.all,
              leading: const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: CircleAvatar(child: Icon(Icons.menu_book)),
              ),
              destinations: const [
                NavigationRailDestination(icon: Icon(Icons.auto_stories), label: Text('阅读')),
                NavigationRailDestination(icon: Icon(Icons.insights), label: Text('统计')),
                NavigationRailDestination(icon: Icon(Icons.settings_input_component), label: Text('配置')),
              ],
            ),
          
          // 主内容区域
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: _pages,
            ),
          ),
        ],
      ),

      // Android 端专用的底部导航栏
      bottomNavigationBar: isWideScreen
          ? null
          : NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) => setState(() => _currentIndex = index),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.auto_stories_outlined),
                  selectedIcon: Icon(Icons.auto_stories),
                  label: '阅读',
                ),
                NavigationDestination(
                  icon: Icon(Icons.insights_outlined),
                  selectedIcon: Icon(Icons.insights),
                  label: '统计',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings),
                  label: '配置',
                ),
              ],
            ),
    );
  }
}