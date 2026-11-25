import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'config.dart';
import 'mysql_db.dart';

class MoyennesClasseScreen extends StatefulWidget {
  const MoyennesClasseScreen({super.key});

  @override
  State<MoyennesClasseScreen> createState() => _MoyennesClasseScreenState();
}

class _MoyennesClasseScreenState extends State<MoyennesClasseScreen> {
  bool _loading = true;
  List _classes = [];
  int? _codClass;
  List<Map<String, dynamic>> _etudiants = [];

  @override
  void initState() {
    super.initState();
    _chargerClasses();
  }

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
          _loading = false;
        });
      }
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _chargerEtudiants(int codClass) async {
    setState(() => _loading = true);
    try {
      final res = await http.get(Uri.parse('$baseUrl/etudiants/classe/$codClass'));
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        List<Map<String, dynamic>> liste = [];

        for (var e in data) {
          int id = e['id'] ?? 0;
          String nom = e['nom'] ?? '';
          String prenom = e['prenom'] ?? '';

          final rows = await MyDb.select("SELECT tp1, tp2, ds, dc FROM note WHERE etudiant_id = :id", {"id": id});
          double? moy;
          if (rows.isNotEmpty && rows[0]['tp1'] != null) {
            double t1 = double.tryParse(rows[0]['tp1'] ?? '0') ?? 0;
            double t2 = double.tryParse(rows[0]['tp2'] ?? '0') ?? 0;
            double ds = double.tryParse(rows[0]['ds'] ?? '0') ?? 0;
            double dc = double.tryParse(rows[0]['dc'] ?? '0') ?? 0;
            moy = (t1 + t2 + ds + dc) / 4;
          }
          liste.add({"nom": nom, "prenom": prenom, "moy": moy});
        }

        setState(() {
          _etudiants = liste;
          _loading = false;
        });
      }
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Moyennes par classe"), backgroundColor: Colors.indigo, foregroundColor: Colors.white),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  DropdownButtonFormField<int>(
                    initialValue: _codClass,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: "Classe", border: OutlineInputBorder()),
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
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _etudiants.length,
                      itemBuilder: (context, i) {
                        final e = _etudiants[i];
                        double? m = e['moy'];
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.person, color: Colors.indigo),
                            title: Text("${e['nom']} ${e['prenom']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                            trailing: Text(m == null ? "Pas de note" : "${m.toStringAsFixed(2)} / 20",
                                style: TextStyle(fontWeight: FontWeight.bold, color: m != null && m >= 10 ? Colors.green : Colors.red)),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
