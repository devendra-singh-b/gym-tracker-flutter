import 'package:flutter/material.dart';
import 'add_workout_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

        drawer: Drawer(
  child: ListView(
    padding: EdgeInsets.zero,
    children: [

      const UserAccountsDrawerHeader(
        accountName: Text(
          "Devendra",
          style: TextStyle(fontSize: 20),
        ),
        accountEmail: Text("Gym Tracker"),
        currentAccountPicture: CircleAvatar(
          child: Icon(Icons.person, size: 40),
        ),
      ),

      ListTile(
        leading: const Icon(Icons.home),
        title: const Text("Dashboard"),
        onTap: () {
          Navigator.pop(context);
        },
      ),

      ListTile(
        leading: const Icon(Icons.add_circle),
        title: const Text("Add Workout"),
        onTap: () {

  Navigator.pop(context);

  Navigator.push(

    context,

    MaterialPageRoute(

      builder: (context) => const AddWorkoutScreen(),

    ),

  );

},
      ),

      ListTile(
        leading: const Icon(Icons.history),
        title: const Text("Workout History"),
        onTap: () {},
      ),

      ListTile(
        leading: const Icon(Icons.bar_chart),
        title: const Text("Progress"),
        onTap: () {},
      ),

      const Divider(),

      ListTile(
        leading: const Icon(Icons.settings),
        title: const Text("Settings"),
        onTap: () {},
      ),
    ],
  ),
),
      appBar: AppBar(
        
        title: const Text("Welcome Devendra"),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            const SizedBox(height: 10),

            const Text(
              "Today's Workout",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            Card(
              child: ListTile(
                leading: const Icon(Icons.fitness_center),
                title: const Text("No workout added today"),
                subtitle: const Text("Click Add Workout"),
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              "Recent Workouts",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            Expanded(
              child: ListView(
                children: const [

                  ListTile(
                    leading: Icon(Icons.history),
                    title: Text("Chest Workout"),
                    subtitle: Text("31 Jul"),
                  ),

                  ListTile(
                    leading: Icon(Icons.history),
                    title: Text("Back Workout"),
                    subtitle: Text("30 Jul"),
                  ),

                  ListTile(
                    leading: Icon(Icons.history),
                    title: Text("Leg Workout"),
                    subtitle: Text("29 Jul"),
                  ),

                ],
              ),
            )

          ],
        ),
      ),
    );
  }
}