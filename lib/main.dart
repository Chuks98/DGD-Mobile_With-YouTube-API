import 'package:flutter/material.dart';
import './screens/display.dart';
import './screens/general-list.dart';
import './screens/login.dart';
import './screens/logout.dart';
import './screens/update-list.dart';
import 'env.dart';
import 'notification.dart';
import 'package:daily_grace_devotional/cache-service.dart';
import './screens/admin-login.dart'; // Import AdminLogin

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EnvironmentVariables.load();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainApp(),
    );
  }
}

class MainApp extends StatefulWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late NotificationService _notificationService;
  bool _isUserLoggedIn = false;
  bool _isAdminLoggedIn = false;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _notificationService = NotificationService();
    _notificationService.startRepeatingNotifications();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final user = await CacheService().getUser();
    final admin = await CacheService().getAdmin();

    setState(() {
      _isUserLoggedIn = user != null;
      _isAdminLoggedIn = admin != null;
    });
  }

  void _updateAdminLoginStatus() {
    setState(() {
      _isAdminLoggedIn = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: IndexedStack(
        index: _currentIndex,
        children: _buildScreens(),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        isUserLoggedIn: _isUserLoggedIn,
        isAdminLoggedIn: _isAdminLoggedIn,
      ),
    );
  }

  List<Widget> _buildScreens() {
    List<Widget> screens = [
      Display(),
      GeneralList(),
    ];

    if (_isAdminLoggedIn) {
      screens.add(UpdateList());
    }

    screens.add(_isUserLoggedIn
        ? Logout(onLogout: _checkLoginStatus)
        : Login(onLogin: _checkLoginStatus));

    return screens;
  }
}

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool isUserLoggedIn;
  final bool isAdminLoggedIn;

  CustomBottomNavigationBar({
    required this.currentIndex,
    required this.onTap,
    required this.isUserLoggedIn,
    required this.isAdminLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 4,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.today, color: Colors.orange, size: 30),
            onPressed: () => onTap(0),
          ),
          IconButton(
            icon: Icon(Icons.list, color: Colors.orange, size: 30),
            onPressed: () => onTap(1),
          ),
          if (isAdminLoggedIn)
            IconButton(
              icon: Icon(Icons.edit, color: Colors.orange, size: 30),
              onPressed: () => onTap(2),
            ),
          IconButton(
            icon: Icon(
              isUserLoggedIn ? Icons.logout : Icons.login,
              color: Colors.orange,
              size: 30,
            ),
            onPressed: () => onTap(isAdminLoggedIn ? 3 : 2),
          ),
        ],
      ),
    );
  }
}
