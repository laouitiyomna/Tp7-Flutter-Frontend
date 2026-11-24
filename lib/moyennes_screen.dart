import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'config.dart';
import 'mysql_db.dart';

class _Eleve {
  final String id;
  final String nom;
  final String prenom;
  _Eleve(this.id, this.nom, this.prenom);
  String get complet => '$nom $prenom';
}

class MoyennesScreen extends StatefulWidget {
  const MoyennesScreen({super.key});

  @override
  State<MoyennesScreen> createState() => _MoyennesScreenState();
}

class _MoyennesScreenState extends State<MoyennesScreen> {
  static const matieres = ['Java', 'Base de données', 'Réseaux'];
  static const colonnes = ['TP1', 'TP2', 'DS', 'DC'];

  List<_Eleve> _eleves = [];
  _Eleve? _selection;
  bool _loading = true;
  String? _erreur;

  final Map<String, Map<String, List<TextEditingController>>> _ctrl = {};

  @override
  void initState() {
    super.initState();
    _chargerEtudiants();
  }

  @override
  void dispose() {
    for (final m in _ctrl.values) {
      for (final l in m.values) {
        for (final c in l) {
          c.dispose();
        }
      }
    }
    super.dispose();
  }

  Future<void> _chargerEtudiants() async {
    setState(() {
      _loading = true;
      _erreur = null;
    });
    try {
      List<_Eleve> eleves = [];

      try {
        final res = await http
            .get(Uri.parse('$baseUrl/etudiants?size=1000'))
            .timeout(const Duration(seconds: 4));
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          final List liste = data is List
              ? data
              : (data['_embedded']?['etudiants'] ?? []) as List;

          eleves = liste.map<_Eleve>((e) {
            String id = '${e['id'] ?? e['nce'] ?? ''}';
            if (id.isEmpty) {
              final href = e['_links']?['self']?['href'] as String?;
              id = href?.split('/').last ?? '';
            }
            return _Eleve(id, '${e['nom'] ?? ''}', '${e['prenom'] ?? ''}');
          }).toList();
        }
      } catch (_) {}

      if (eleves.isEmpty) {
        final rows = await MyDb.select(
            "SELECT nce AS id, nom, prenom FROM etudiant ORDER BY nce");
        eleves = rows
            .map((r) => _Eleve(
                r['id'] ?? '', r['nom'] ?? '', r['prenom'] ?? ''))
            .toList();
      }

      setState(() {
        _eleves = eleves;
        if (eleves.isNotEmpty) {
          _selection = eleves.first;
        }
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _erreur = 'Impossible de charger les étudiants : $e';
        _loading = false;
      });
    }
  }

  Map<String, List<TextEditingController>> _champsDe(_Eleve e) {
    return _ctrl.putIfAbsent(e.id, () {
      final hash = e.id.hashCode.abs();
      return {
        for (int i = 0; i < matieres.length; i++)
          matieres[i]: [
            TextEditingController(text: '${12 + ((hash + i * 3) % 7)}'),
            TextEditingController(text: '${13 + ((hash + i * 2) % 6)}'),
            TextEditingController(text: '${11 + ((hash + i * 5) % 8)}'),
            TextEditingController(text: '${14 + ((hash + i * 4) % 6)}'),
          ],
      };
    });
  }

  double? _note(TextEditingController c) {
    final v = double.tryParse(c.text.trim().replaceAll(',', '.'));
    if (v == null || v < 0 || v > 20) return null;
    return v;
  }

  double? _moyenneMatiere(List<TextEditingController> champs) {
    final notes = champs.map(_note).toList();
    if (notes.any((n) => n == null)) return null;
    return notes.fold<double>(0, (a, b) => a + b!) / 4;
  }

  double? _moyenneGenerale(Map<String, List<TextEditingController>> champs) {
    final moyennes = champs.values
        .map(_moyenneMatiere)
        .whereType<double>()
        .toList();
    if (moyennes.isEmpty) return null;
    return moyennes.reduce((a, b) => a + b) / moyennes.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestion des moyennes')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: _corps(),
        ),
      ),
    );
  }

  Widget _corps() {
    if (_loading) return const Center(child: CircularProgressIndicator());

    if (_erreur != null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(_erreur!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _chargerEtudiants,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Gestion des moyennes',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        DropdownButtonFormField<_Eleve>(
          initialValue: _selection,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Sélectionner un étudiant',
            prefixIcon: Icon(Icons.person),
            border: OutlineInputBorder(),
          ),
          items: _eleves
              .map((e) => DropdownMenuItem(value: e, child: Text(e.complet)))
              .toList(),
          onChanged: (e) => setState(() => _selection = e),
        ),
        const SizedBox(height: 16),
        if (_eleves.isEmpty)
          const _Message('Aucun étudiant disponible.')
        else if (_selection == null)
          const _Message('Sélectionne un étudiant pour saisir ses notes.')
        else
          ..._contenuEtudiant(_selection!),
      ],
    );
  }

  List<Widget> _contenuEtudiant(_Eleve e) {
    final champs = _champsDe(e);
    final general = _moyenneGenerale(champs);

    return [
      Card(
        elevation: 2,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(Colors.indigo.shade50),
            columns: [
              const DataColumn(label: Text('Matière')),
              ...colonnes.map((c) => DataColumn(label: Text(c))),
              const DataColumn(label: Text('Moyenne')),
            ],
            rows: matieres.map((m) {
              final l = champs[m]!;
              final moy = _moyenneMatiere(l);
              return DataRow(cells: [
                DataCell(Text(m, style: const TextStyle(fontWeight: FontWeight.w600))),
                ...l.map((c) => DataCell(SizedBox(
                      width: 64,
                      child: TextField(
                        controller: c,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          hintText: '—',
                          isDense: true,
                          errorText: (c.text.isNotEmpty && _note(c) == null) ? '' : null,
                          errorStyle: const TextStyle(height: 0),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ))),
                DataCell(Text(
                  moy == null ? '—' : moy.toStringAsFixed(2),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                )),
              ]);
            }).toList(),
          ),
        ),
      ),
      const SizedBox(height: 8),
      const Text('Notes sur 20. Les valeurs hors de 0 à 20 sont ignorées.',
          style: TextStyle(fontSize: 12, color: Colors.grey)),
      const SizedBox(height: 16),
      Card(
        color: Colors.indigo.shade600,
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              const CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.school, color: Colors.white)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.complet,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    const Text('Moyenne générale',
                        style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
              Text(
                general == null ? '—' : '${general.toStringAsFixed(2)} / 20',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    ];
  }
}

class _Message extends StatelessWidget {
  final String texte;
  const _Message(this.texte);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(Icons.info_outline, size: 40, color: Colors.grey.shade500),
          const SizedBox(height: 8),
          Text(texte, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
