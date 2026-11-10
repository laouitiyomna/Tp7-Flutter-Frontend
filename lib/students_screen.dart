import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'config.dart';
import 'classe.dart';
import 'etudiant.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  List<Classe> classes = [];
  List<Etudiant> etudiants = [];
  int? selectedClasse; // on garde le code de la classe choisie
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadClasses();
  }

  Future<void> loadClasses() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/classes"));
      if (res.statusCode == 200) {
        final list = (jsonDecode(res.body) as List)
            .map((e) => Classe.fromMap(e))
            .toList();
        setState(() {
          classes = list;
          if (list.isNotEmpty) selectedClasse = list.first.codClass;
        });
        if (selectedClasse != null) await loadEtudiants(selectedClasse!);
      }
    } catch (e) {
      showError("Impossible de charger les classes");
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> loadEtudiants(int codClass) async {
    try {
      final res =
      await http.get(Uri.parse("$baseUrl/etudiants/classe/$codClass"));
      if (res.statusCode == 200) {
        setState(() {
          etudiants = (jsonDecode(res.body) as List)
              .map((e) => Etudiant.fromMap(e))
              .toList();
        });
      }
    } catch (e) {
      showError("Impossible de charger les étudiants");
    }
  }

  void showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage students")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text("Classe : ",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButton<int>(
                    isExpanded: true,
                    value: classes.any((c) => c.codClass == selectedClasse)
                        ? selectedClasse
                        : null,
                    hint: const Text("Code Classe"),
                    items: classes
                        .map((c) => DropdownMenuItem<int>(
                      value: c.codClass,
                      child: Text(c.nomClass),
                    ))
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => selectedClasse = value);
                      loadEtudiants(value);
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: etudiants.isEmpty
                ? const Center(child: Text("Aucun étudiant"))
                : ListView.builder(
              itemCount: etudiants.length,
              itemBuilder: (context, i) {
                final e = etudiants[i];
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text("${e.nom} ${e.prenom}"),
                  subtitle: Text(e.dateNais.isNotEmpty ? "Né(e) le ${e.dateNais}" : ""),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}