import 'package:flutter/material.dart';
import 'package:uberdriverapp/screens/tab/earnings_screen.dart';
import 'package:uberdriverapp/screens/tab/home_screen.dart';
import 'package:uberdriverapp/screens/tab/profile_screen.dart';
import 'package:uberdriverapp/screens/tab/trips_screen.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with SingleTickerProviderStateMixin {
  TabController? tabController;
  int indexOfSelectedScreen = 0;

  void whenNavigationBarItemClicked(int index) {
    setState(() {
      indexOfSelectedScreen = index;
      tabController!.index = indexOfSelectedScreen;
    });
  }

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        controller: tabController,
        children: const [
          HomeScreen(),
          EarningScreen(),
          TripsScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Rides"),
          BottomNavigationBarItem(
            icon: Icon(Icons.monetization_on),
            label: "Earnings",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: "Trips"),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_pin_rounded),
            label: "Info",
          ),
        ],
        currentIndex: indexOfSelectedScreen,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.amberAccent,
        selectedLabelStyle: TextStyle(fontSize: 12),
        type: BottomNavigationBarType.fixed,
        onTap: whenNavigationBarItemClicked,
      ),
    );
  }
}
