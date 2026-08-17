import 'package:flutter/material.dart';
import '../config/app_config.dart';
import 'map_screen.dart';
import 'parts_screen.dart';
import 'vehicles_screen.dart';

class HomeScreen extends StatefulWidget {
  final AppConfig config;
  final ValueNotifier<bool> isAr;

  const HomeScreen({super.key, required this.config, required this.isAr});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      VehiclesScreen(config: widget.config),
      PartsScreen(config: widget.config),
      MapScreen(config: widget.config),
    ];

    return ValueListenableBuilder<bool>(
      valueListenable: widget.isAr,
      builder: (context, isAr, _) {
        return Directionality(
          textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: widget.config.primaryColor,
              foregroundColor: Colors.white,
              title: Text(widget.config.appName),
              actions: [
                TextButton(
                  onPressed: () => widget.isAr.value = !isAr,
                  child: Text(
                    isAr ? 'FR' : 'AR',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            body: IndexedStack(index: _index, children: screens),
            bottomNavigationBar: NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.directions_car),
                  label: isAr ? 'سياراتي' : 'Véhicules',
                ),
                NavigationDestination(
                  icon: const Icon(Icons.build),
                  label: isAr ? 'القطع' : 'Pièces',
                ),
                NavigationDestination(
                  icon: const Icon(Icons.map),
                  label: isAr ? 'الخريطة' : 'Carte',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
