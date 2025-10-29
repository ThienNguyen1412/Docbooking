import 'package:flutter/material.dart';
import 'screens/login_screen.dart'; // Màn hình Đăng nhập
import 'screens/dashboard_screen.dart'; // Màn hình chính
import 'screens/screens.dart';
import 'screens/profile/update_profile_screen.dart';
import 'services/auth.dart';
import 'models/user.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const DoctorApp());
}

class DoctorApp extends StatelessWidget {
  const DoctorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ứng dụng Đặt lịch Khám bệnh',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Colors.blue,
          elevation: 0,
        ),
      ),

      // Khởi tạo bằng LandingPage: kiểm tra xem user đã đăng nhập hay chưa
      // và điều hướng tương ứng.
      home: const LandingPage(),

      // Các routes ứng dụng (đã loại bỏ route admin)
      routes: {
        '/dashboard': (context) => const DashboardScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        // '/update_profile' now resolves to a widget that first loads the current user.
        '/update_profile': (context) => FutureBuilder<User?>(
              future: AuthService.instance.getUser(),
              builder: (ctx, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                // If there's an error or no user, send user to login
                if (snap.hasError || snap.data == null) {
                  return const LoginScreen();
                }
                // Pass the loaded user into UpdateProfileScreen
                return UpdateProfileScreen(user: snap.data!);
              },
            ),
        '/change_password': (context) => const ChangePasswordScreen(),
        '/support': (context) => const SupportScreen(),
      },
    );
  }
}

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    try {
      // Lấy user đã lưu (AuthService sẽ trả null nếu token/expiry đã hết hạn)
      final User? user = await AuthService.instance.tryAutoLogin();

      // Thêm delay nhỏ để UX mượt hơn (không bắt buộc)
      await Future.delayed(const Duration(milliseconds: 300));

      if (!mounted) return;

      if (user != null) {
        Navigator.of(context).pushReplacementNamed('/dashboard');
      } else {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      // Nếu có lỗi khi đọc/parse dữ liệu, đưa về màn hình login an toàn
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Hiển thị giao diện đơn giản trong khi kiểm tra trạng thái đăng nhập
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.book_online_outlined, size: 80, color: Colors.blue),
            const SizedBox(height: 12),
            const Text(
              'DocBooking',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}