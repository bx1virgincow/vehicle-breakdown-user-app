import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:onroadapp/components/drawer_widget.dart';
import 'package:onroadapp/pages/homepage.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  //list or map of data
  List<Map<String, dynamic>> data = [
    {'title': 'Flat Tire', 'sevice': 'Tire', 'icon': Icons.tire_repair},
    {'title': 'Fuel Delivery', 'sevice': 'Fuel', 'icon': Icons.delivery_dining},
    {'title': 'Towing', 'sevice': 'Towing', 'icon': Icons.fire_truck},
    {'title': 'Lockout', 'sevice': 'Lockout', 'icon': Icons.lock},
    {'title': 'Jumpstart', 'sevice': 'Jumpstart', 'icon': Icons.start},
    {'title': 'Mechanic', 'sevice': 'Mechanic', 'icon': Icons.build},
    {'title': 'Car Rental', 'sevice': 'Rental', 'icon': Icons.car_rental},
  ];

  List<Map<String, dynamic>> accommodation = [
    {'title': 'Hotels', 'sevice': 'Hotel', 'icon': Icons.hotel},
    {'title': 'Restaurants', 'sevice': 'Restaurants', 'icon': Icons.restaurant},
  ];

  //
  // final String service;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Vehicle Assistant',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      drawer: DrawerWidget(
        email: '',
        name: '',
      ),
      body: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset('assets/icon/on_road.png'),
              const Text(
                'How can we help you?',
                style: TextStyle(
                  fontSize: 30,
                ),
              ),
              Container(
                child: Text(
                  'Car Services',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Expanded(
                child: ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      return _container(context, data.elementAt(index)['title'],
                          data.elementAt(index)['icon'], () {
                        Get.to(() => Homepage(
                            service: data.elementAt(index)['service']));
                      });
                    }),
              ),
              const SizedBox(height: 10),
              Text(
                'Accommodation',
                style: TextStyle(fontSize: 20),
              ),
              Expanded(
                child: ListView.builder(
                    itemCount: accommodation.length,
                    itemBuilder: (context, index) {
                      return _container(
                          context,
                          accommodation.elementAt(index)['title'],
                          accommodation.elementAt(index)['icon'], () {
                        Get.to(() => Homepage(
                            service:
                                accommodation.elementAt(index)['service']));
                      });
                    }),
              ),
            ],
          )),
    );
  }
}

_container(
    BuildContext context, String title, IconData icon, VoidCallback onpress) {
  return Container(
    margin: const EdgeInsets.symmetric(
      // horizontal: 12.0,
      vertical: 4.0,
    ),
    decoration: BoxDecoration(
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(12.0)),
    child: ListTile(
      onTap: onpress,
      leading: Icon(
        icon,
        color: Colors.orange,
      ),
      title: Text(title),
      trailing: Icon(Icons.chevron_right),
    ),
  );
}
