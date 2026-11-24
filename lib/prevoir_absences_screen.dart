import 'package:flutter/material.dart';

class _ClasseItem {
  final int codClass;
  final String nomClass;
  _ClasseItem(this.codClass, this.nomClass);
}

class _EtudiantItem {
  final String nce;
  final String nom;
  final String prenom;
  final int codClass;
  bool isAbsent = false;
  double nha = 1.5;

  _EtudiantItem(
    this.nce,
    this.nom,
    this.prenom,
    this.codClass,
  );

  String get nomComplet => "$nom $prenom";
}

class _AbsenceRecord {
  final String nce;
  final String nomEtudiant;
  final int codClass;
  final String codMat;
  final String dateA;
  final double nha;

  _AbsenceRecord({
    required this.nce,
    required this.nomEtudiant,
    required this.codClass,
    required this.codMat,
    required this.dateA,
    required this.nha,
  });
}

class PrevoirAbsencesScreen extends StatefulWidget {
  const PrevoirAbsencesScreen({super.key});

  @override
  State<PrevoirAbsencesScreen> createState() => _PrevoirAbsencesScreenState();
}

class _PrevoirAbsencesScreenState extends State<PrevoirAbsencesScreen> {
  // Données Frontend de démonstration
  final List<_ClasseItem> _classes = [
    _ClasseItem(1, "DSI33"),
    _ClasseItem(2, "DSI31"),
    _ClasseItem(3, "DSI21"),
  ];

  final List<String> _matieres = [
    "Framework cross-platform (AFCP)",
    "Développement mobile (MOB)",
    "Architecture orientée services (SOA)",
    "Java / Spring Boot",
    "Bases de données",
  ];

  final List<_EtudiantItem> _etudiants = [
    _EtudiantItem("E1", "Ben Foulen1", "Foulen1", 1),
    _EtudiantItem("E2", "Trabelsi", "Amira", 1),
    _EtudiantItem("E5", "Khemiri", "Salma", 1),
    _EtudiantItem("E6", "Ben Ali", "Sami", 1),
    _EtudiantItem("E3", "Gharbi", "Youssef", 2),
    _EtudiantItem("E7", "Ayari", "Ahmed", 2),
    _EtudiantItem("E4", "Mansouri", "Ines", 3),
    _EtudiantItem("E8", "Jlassi", "Sarra", 3),
  ];

  // Base d'absences Frontend existantes
  final List<_AbsenceRecord> _absencesData = [
    _AbsenceRecord(nce: "E1", nomEtudiant: "Ben Foulen1 Foulen1", codClass: 1, codMat: "AFCP", dateA: "10/11/2025", nha: 3.0),
    _AbsenceRecord(nce: "E1", nomEtudiant: "Ben Foulen1 Foulen1", codClass: 1, codMat: "SOA", dateA: "04/11/2025", nha: 1.5),
    _AbsenceRecord(nce: "E2", nomEtudiant: "Trabelsi Amira", codClass: 1, codMat: "MOB", dateA: "08/11/2025", nha: 3.0),
    _AbsenceRecord(nce: "E2", nomEtudiant: "Trabelsi Amira", codClass: 1, codMat: "AFCP", dateA: "01/11/2025", nha: 1.5),
    _AbsenceRecord(nce: "E5", nomEtudiant: "Khemiri Salma", codClass: 1, codMat: "Java", dateA: "05/11/2025", nha: 4.5),
    _AbsenceRecord(nce: "E3", nomEtudiant: "Gharbi Youssef", codClass: 2, codMat: "SOA", dateA: "02/11/2025", nha: 1.5),
    _AbsenceRecord(nce: "E7", nomEtudiant: "Ayari Ahmed", codClass: 2, codMat: "AFCP", dateA: "06/11/2025", nha: 3.0),
    _AbsenceRecord(nce: "E4", nomEtudiant: "Mansouri Ines", codClass: 3, codMat: "MOB", dateA: "03/11/2025", nha: 4.5),
  ];

  int? _selectedCodClass = 1;
  String _selectedMatiere = "Framework cross-platform (AFCP)";
  String _filterMatiereConsult = "Toutes les matières";
  DateTime _selectedDate = DateTime.now();
  double _defaultNha = 1.5;

  List<_EtudiantItem> get _filteredEtudiants {
    return _etudiants
        .where((e) => e.codClass == _selectedCodClass)
        .toList();
  }

  List<_AbsenceRecord> get _filteredAbsencesConsult {
    return _absencesData.where((a) {
      final matchClasse = a.codClass == _selectedCodClass;
      final matchMatiere = _filterMatiereConsult == "Toutes les matières" ||
          a.codMat.contains(_filterMatiereConsult.split(' ').first) ||
          _filterMatiereConsult.contains(a.codMat);
      return matchClasse && matchMatiere;
    }).toList();
  }

  void _enregistrer() {
    final absents = _filteredEtudiants.where((e) => e.isAbsent).toList();
    final count = absents.length;
    final dateStr =
        "${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}";

    if (count > 0 && _selectedCodClass != null) {
      for (var etud in absents) {
        _absencesData.add(_AbsenceRecord(
          nce: etud.nce,
          nomEtudiant: etud.nomComplet,
          codClass: _selectedCodClass!,
          codMat: _selectedMatiere.contains("(")
              ? _selectedMatiere.split("(").last.replaceAll(")", "")
              : _selectedMatiere,
          dateA: dateStr,
          nha: etud.nha,
        ));
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          count > 0
              ? "$count absence(s) ajoutée(s) et enregistrée(s) pour la classe en $_selectedMatiere !"
              : "Aucune absence cochée.",
          style: const TextStyle(fontSize: 15),
        ),
        backgroundColor: count > 0 ? Colors.green.shade700 : Colors.orange.shade800,
        duration: const Duration(seconds: 4),
      ),
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Absences par classe"),
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: Icon(Icons.list_alt), text: "Consulter absences"),
              Tab(icon: Icon(Icons.add_task), text: "Saisir / Prévoir"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildOngletConsultation(),
            _buildOngletSaisie(),
          ],
        ),
      ),
    );
  }

  // Onglet 1 : Consultation et affichage des absences de la classe
  Widget _buildOngletConsultation() {
    final list = _filteredAbsencesConsult;
    final totalHeures = list.fold<double>(0, (sum, a) => sum + a.nha);
    final nomClasse = _classes.firstWhere((c) => c.codClass == _selectedCodClass, orElse: () => _ClasseItem(0, "")).nomClass;

    final Map<String, double> totalParEtudiant = {};
    for (var a in list) {
      totalParEtudiant[a.nomEtudiant] = (totalParEtudiant[a.nomEtudiant] ?? 0) + a.nha;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Filtres d'affichage",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.purple)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          initialValue: _selectedCodClass,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: "Classe",
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          ),
                          items: _classes
                              .map((c) => DropdownMenuItem(value: c.codClass, child: Text(c.nomClass)))
                              .toList(),
                          onChanged: (val) => setState(() => _selectedCodClass = val),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _filterMatiereConsult,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: "Matière",
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          ),
                          items: ["Toutes les matières", ..._matieres]
                              .map((m) => DropdownMenuItem(value: m, child: Text(m, overflow: TextOverflow.ellipsis)))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _filterMatiereConsult = val);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Card(
                  color: Colors.purple.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text("${list.length}", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.purple.shade900)),
                        const Text("Absences déclarées", style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Card(
                  color: Colors.deepOrange.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text("${totalHeures.toStringAsFixed(1)} h", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepOrange.shade900)),
                        const Text("Heures totales (NHA)", style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text("Absences de la classe $nomClasse",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          if (list.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: Text("Aucune absence trouvée pour ces critères.")),
            )
          else ...[
            Card(
              elevation: 2,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(Colors.purple.shade50),
                  columns: const [
                    DataColumn(label: Text("NCE")),
                    DataColumn(label: Text("Étudiant")),
                    DataColumn(label: Text("Matière")),
                    DataColumn(label: Text("Date")),
                    DataColumn(label: Text("Heures (NHA)")),
                  ],
                  rows: list
                      .map((a) => DataRow(cells: [
                            DataCell(Text(a.nce, style: const TextStyle(fontWeight: FontWeight.bold))),
                            DataCell(Text(a.nomEtudiant)),
                            DataCell(Chip(label: Text(a.codMat, style: const TextStyle(fontSize: 11)), backgroundColor: Colors.purple.shade100)),
                            DataCell(Text(a.dateA)),
                            DataCell(Text("${a.nha} h", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red))),
                          ]))
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text("Bilan cumulé par étudiant ($nomClasse)",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.purple)),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: totalParEtudiant.entries.map((entry) {
                  return ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: Text(
                      "${entry.value} h totales",
                      style: TextStyle(fontWeight: FontWeight.bold, color: entry.value >= 4.0 ? Colors.red : Colors.orange.shade800),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOngletSaisie() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Saisie des absences pour un cours",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    initialValue: _selectedCodClass,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: "Classe",
                      prefixIcon: Icon(Icons.groups, color: Colors.deepOrange),
                      border: OutlineInputBorder(),
                    ),
                    items: _classes
                        .map((c) => DropdownMenuItem<int>(
                              value: c.codClass,
                              child: Text(c.nomClass, style: const TextStyle(fontWeight: FontWeight.bold)),
                            ))
                        .toList(),
                    onChanged: (val) => setState(() => _selectedCodClass = val),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedMatiere,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: "Matière",
                      prefixIcon: Icon(Icons.book, color: Colors.purple),
                      border: OutlineInputBorder(),
                    ),
                    items: _matieres
                        .map((m) => DropdownMenuItem<String>(
                              value: m,
                              child: Text(m),
                            ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedMatiere = val);
                    },
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: const Icon(Icons.calendar_today, color: Colors.purple),
                          label: Text(
                            "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          onPressed: () async {
                            final d = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );
                            if (d != null) setState(() => _selectedDate = d);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<double>(
                          initialValue: _defaultNha,
                          decoration: const InputDecoration(
                            labelText: "Heures (NHA)",
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          ),
                          items: const [0.5, 1.0, 1.5, 2.0, 3.0, 4.0, 4.5]
                              .map((h) => DropdownMenuItem(value: h, child: Text("$h h")))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) {
                              setState(() {
                                _defaultNha = v;
                                for (var e in _filteredEtudiants) {
                                  e.nha = v;
                                }
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Étudiants (${_filteredEtudiants.length})",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    final allAbsent = _filteredEtudiants.every((e) => e.isAbsent);
                    for (var e in _filteredEtudiants) {
                      e.isAbsent = !allAbsent;
                      e.nha = _defaultNha;
                    }
                  });
                },
                icon: const Icon(Icons.select_all),
                label: const Text("Tout (dé)sélectionner"),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_filteredEtudiants.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: Center(child: Text("Aucun étudiant trouvé dans cette classe.")),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _filteredEtudiants.length,
              itemBuilder: (ctx, idx) {
                final etud = _filteredEtudiants[idx];
                return Card(
                  color: etud.isAbsent ? Colors.red.shade50 : Colors.white,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: CheckboxListTile(
                    activeColor: Colors.red,
                    title: Text(
                      etud.nomComplet,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: etud.isAbsent ? Colors.red.shade900 : Colors.black87,
                      ),
                    ),
                    subtitle: Text("NCE: ${etud.nce} • ${etud.isAbsent ? 'Absent (${etud.nha}h)' : 'Présent'}"),
                    secondary: CircleAvatar(
                      backgroundColor: etud.isAbsent ? Colors.red : Colors.green,
                      child: Icon(
                        etud.isAbsent ? Icons.person_off : Icons.person,
                        color: Colors.white,
                      ),
                    ),
                    value: etud.isAbsent,
                    onChanged: (val) {
                      setState(() {
                        etud.isAbsent = val ?? false;
                        if (etud.isAbsent) etud.nha = _defaultNha;
                      });
                    },
                  ),
                );
              },
            ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.save, size: 26),
              label: const Text("Enregistrer les absences de la classe", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              onPressed: _enregistrer,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
