import 'package:flutter/material.dart';
import '../config/api_config.dart';
import '../controllers/range_controller.dart';
import '../services/api_service.dart';
import '../views/home_screen.dart';
import '../main.dart';

class App {
  static RangeController initializeController() {
    final apiService = ApiService(
      url: ApiConfig.getRangesEndpoint,
      bearerToken: ApiConfig.token,
    );
    
    final controller = RangeController(apiService: apiService);
    controller.fetchRanges();
    return controller;
  }
}

class MyApp extends StatelessWidget {
  final RangeController controller;
  const MyApp({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return RangeProvider(
      controller: controller,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Range Bar Assignment',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.blue,
          ).copyWith(
            secondary: Colors.blueAccent,
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
