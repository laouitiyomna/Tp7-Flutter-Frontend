import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'config.dart';
import 'mysql_db.dart';

class MoyennesScreen extends StatefulWidget {
  const MoyennesScreen({super.key});

  @override
  State<MoyennesScreen> createState() => _MoyennesScreenState();
}

class _MoyennesScreenState extends State<MoyennesScreen> {
  bool _loadingClasses = true;
  bool _loadingEtudiants = false;

  List _classes = [];
  int? _codClass;

  List _eleves = [];
  dynamic _selection;

  final _tp1 = TextEditingController();
  final _tp2 = TextEditingController();
  final _ds = TextEditingController();
  final _dc = TextEditingController();

  @override
  void initState() {
    super.initState();
    _chargerClasses();
  }

  // 1. Charger la liste des classes
  Future<void> _chargerClasses() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/classes'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _classes = data;
          if (_classes.isNotEmpty) {
            _codClass = _classes[0]['codClass'];
            _chargerEtudiants(_codClass!);
          }
          _loadingClasses = false;
        });
      }
    } catch (_) {
      setState(() => _loadingClasses = false);
    }
  }

  // 2. Charger les étudiants de la classe choisie
  Future<void> _chargerEtudiants(int codClass) async {
    setState(() => _loadingEtudiants = true);
    try {
      final res = await http.get(Uri.parse('$baseUrl/etudiants/classe/$codClass'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _eleves = data;
          if (_eleves.isNotEmpty) {
            _selection = _eleves[0];
            _chargerNotes(_selection['id']);
          } else {
            _selection = null;
            _viderNotes();
          }
          _loadingEtudiants = false;
        });
      }
    } catch (_) {
      setState(() => _loadingEtudiants = false);
    }
  }

  // 3. Charger les notes existantes depuis MySQL pour l'étudiant
  Future<void> _chargerNotes(int id) async {
    _viderNotes();
    try {
      final rows = await MyDb.select(
        "SELECT tp1, tp2, ds, dc FROM note WHERE etudiant_id = :id AND matiere = 'Java'",
        {"id": id},
      );
      if (rows.isNotEmpty) {
        _tp1.text = rows[0]['tp1'] ?? '';
        _tp2.text = rows[0]['tp2'] ?? '';
        _ds.text = rows[0]['ds'] ?? '';
        _dc.text = rows[0]['dc'] ?? '';
      }
      setState(() {});
    } catch (_) {}
  }

  void _viderNotes() {
    _tp1.text = '';
    _tp2.text = '';
    _ds.text = '';
    _dc.text = '';
  }

  // 4. Enregistrer les notes dans MySQL
  Future<void> _enregistrer() async {
    if (_selection == null) return;
    try {
      await MyDb.exec(
        "INSERT INTO note (etudiant_id, matiere, tp1, tp2, ds, dc) VALUES (:id, 'Java', :t1, :t2, :ds, :dc) "
        "ON DUPLICATE KEY UPDATE tp1=VALUES(tp1), tp2=VALUES(tp2), ds=VALUES(ds), dc=VALUES(dc)",
        {
          "id": (_selection as Map)['id'],
          "t1": double.tryParse(_tp1.text) ?? 0,
          "t2": double.tryParse(_tp2.text) ?? 0,
          "ds": double.tryParse(_ds.text) ?? 0,
          "dc": double.tryParse(_dc.text) ?? 0,
        },
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Notes enregistrées avec succès !"), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Saisie des notes par classe"),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: _loadingClasses
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  // 1. Sélection de la classe
                  DropdownButtonFormField<int>(
                    initialValue: _codClass,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: "Sélectionner une classe",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.groups, color: Colors.deepOrange),
                    ),
                    items: _classes.map<DropdownMenuItem<int>>((c) {
                      return DropdownMenuItem<int>(
                        value: c['codClass'],
                        child: Text(c['nomClass'] ?? ''),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _codClass = val);
                        _chargerEtudiants(val);
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // 2. Sélection de l'étudiant de la classe
                  _loadingEtudiants
                      ? const Center(child: CircularProgressIndicator())
                      : DropdownButtonFormField<Map<String, dynamic>>(
                          initialValue: _selection as Map<String, dynamic>?,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: "Sélectionner un étudiant",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person, color: Colors.purple),
                          ),
                          items: _eleves.map<DropdownMenuItem<Map<String, dynamic>>>((e) {
                            return DropdownMenuItem(
                              value: e as Map<String, dynamic>,
                              child: Text("${e['nom']} ${e['prenom']}"),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selection = val);
                              _chargerNotes(val['id']);
                            }
                          },
                        ),

                  const SizedBox(height: 20),
                  const Text("Matière : Java", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.purple)),
                  const SizedBox(height: 10),

                  // 3. Champs de saisie des notes
                  TextField(controller: _tp1, decoration: const InputDecoration(labelText: "TP1 (sur 20)", border: OutlineInputBorder()), keyboardType: TextInputType.number),
                  const SizedBox(height: 10),
                  TextField(controller: _tp2, decoration: const InputDecoration(labelText: "TP2 (sur 20)", border: OutlineInputBorder()), keyboardType: TextInputType.number),
                  const SizedBox(height: 10),
                  TextField(controller: _ds, decoration: const InputDecoration(labelText: "DS (sur 20)", border: OutlineInputBorder()), keyboardType: TextInputType.number),
                  const SizedBox(height: 10),
                  TextField(controller: _dc, decoration: const InputDecoration(labelText: "DC (sur 20)", border: OutlineInputBorder()), keyboardType: TextInputType.number),
                  const SizedBox(height: 20),

                  // 4. Bouton Enregistrer
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _enregistrer,
                    icon: const Icon(Icons.save),
                    label: const Text("Enregistrer les notes", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
    );
  }
}
