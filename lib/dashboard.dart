import 'package:flutter/material.dart';
import 'students_screen.dart';
import 'classes_screen.dart';
import 'teachers_screen.dart';
import 'absences_screen.dart';
import 'moyennes_screen.dart';
import 'moyennes_classe_screen.dart';
import 'top_modules_screen.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  void open(BuildContext context, Widget page) {
    Navigator.pop(context); // ferme le menu
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard")),
      drawer: Drawer(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const DrawerHeader(
                margin: EdgeInsets.zero,
                decoration: BoxDecoration(color: Colors.purple),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    "Exercise for groups :\nDSI33 and DSI31",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.groups, color: Colors.deepOrange),
                title: const Text("Manage groups"),
                onTap: () => open(context, const ClassesScreen()),
              ),
              ListTile(
                leading: const Icon(Icons.school, color: Colors.deepOrange),
                title: const Text("Manage students"),
                onTap: () => open(context, const StudentsScreen()),
              ),
              ListTile(
                leading: const Icon(Icons.person, color: Colors.deepOrange),
                title: const Text("Manage teachers"),
                onTap: () => open(context, const TeachersScreen()),
              ),
              ListTile(
                leading: const Icon(Icons.event_busy, color: Colors.deepOrange),
                title: const Text("Gestion des absences"),
                onTap: () => open(context, const AbsencesScreen()),
              ),
              ListTile(
                leading: const Icon(Icons.edit_note, color: Colors.deepOrange),
                title: const Text("Saisie des notes"),
                onTap: () => open(context, const MoyennesScreen()),
              ),
              ListTile(
                leading: const Icon(Icons.assessment, color: Colors.deepOrange),
                title: const Text("Moyennes par classe"),
                onTap: () => open(context, const MoyennesClasseScreen()),
              ),
              ListTile(
                leading: const Icon(Icons.leaderboard, color: Colors.deepOrange),
                title: const Text("Top 3 modules absents"),
                onTap: () => open(context, const TopModulesScreen()),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.cancel, color: Colors.deepOrange),
                title: const Text("Close"),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
      body: const Center(child: Text("Open the menu ☰")),
    );
  }
}
