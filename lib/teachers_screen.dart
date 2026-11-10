import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'config.dart';

class TeachersScreen extends StatefulWidget {
  const TeachersScreen({super.key});

  @override
  State<TeachersScreen> createState() => _TeachersScreenState();
}

class _TeachersScreenState extends State<TeachersScreen> {
  List<dynamic> teachers = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  void msg(String text, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(text),
      backgroundColor: error ? Colors.red : Colors.green,
    ));
  }

  Future<void> load() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/enseignants"));
      if (res.statusCode == 200) {
        setState(() => teachers = jsonDecode(res.body));
      }
    } catch (e) {
      msg("Impossible de charger les enseignants", error: true);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> showForm({Map<String, dynamic>? t}) async {
    final nomCtrl = TextEditingController(text: t?['nom'] ?? '');
    final prenomCtrl = TextEditingController(text: t?['prenom'] ?? '');
    final matiereCtrl = TextEditingController(text: t?['matiere'] ?? '');

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t == null ? "Nouvel enseignant" : "Modifier l'enseignant"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: nomCtrl,
                  decoration: const InputDecoration(labelText: "Nom")),
              TextField(
                  controller: prenomCtrl,
                  decoration: const InputDecoration(labelText: "Prénom")),
              TextField(
                  controller: matiereCtrl,
                  decoration: const InputDecoration(labelText: "Matière")),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Annuler")),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text("Enregistrer")),
        ],
      ),
    );

    if (ok != true || nomCtrl.text.trim().isEmpty) return;

    final body = json.encode({
      'nom': nomCtrl.text.trim(),
      'prenom': prenomCtrl.text.trim(),
      'matiere': matiereCtrl.text.trim(),
    });

    try {
      final res = t == null
          ? await http.post(Uri.parse("$baseUrl/enseignants"),
          headers: {'Content-Type': 'application/json'}, body: body)
          : await http.put(Uri.parse("$baseUrl/enseignants/${t['id']}"),
          headers: {'Content-Type': 'application/json'}, body: body);
      if (res.statusCode == 200 || res.statusCode == 201) {
        msg("Enseignant enregistré");
        load();
      } else {
        msg("Erreur ${res.statusCode}", error: true);
      }
    } catch (e) {
      msg("Erreur de connexion", error: true);
    }
  }

  Future<void> delete(int id) async {
    try {
      final res = await http.delete(Uri.parse("$baseUrl/enseignants/$id"));
      if (res.statusCode == 200 || res.statusCode == 204) {
        msg("Enseignant supprimé");
        load();
      } else {
        msg("Suppression impossible", error: true);
      }
    } catch (e) {
      msg("Erreur de connexion", error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage teachers")),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showForm(),
        child: const Icon(Icons.add),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : teachers.isEmpty
          ? const Center(child: Text("Aucun enseignant"))
          : ListView.builder(
        itemCount: teachers.length,
        itemBuilder: (context, i) {
          final t = teachers[i] as Map<String, dynamic>;
          return ListTile(
            leading: const Icon(Icons.person, color: Colors.deepOrange),
            title: Text("${t['nom'] ?? ''} ${t['prenom'] ?? ''}"),
            subtitle: Text(t['matiere'] ?? ''),
            onTap: () => showForm(t: t),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => delete(t['id']),
            ),
          );
        },
      ),
    );
  }
}