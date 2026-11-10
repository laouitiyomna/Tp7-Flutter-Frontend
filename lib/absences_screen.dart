import 'package:flutter/material.dart';
import 'mysql_db.dart';

class AbsencesScreen extends StatefulWidget {
  const AbsencesScreen({super.key});

  @override
  State<AbsencesScreen> createState() => _AbsencesScreenState();
}

class _AbsencesScreenState extends State<AbsencesScreen> {
  List<Map<String, String?>> etudiants = [];
  List<Map<String, String?>> matieres = [];
  List<Map<String, String?>> absences = [];
  List<Map<String, String?>> totaux = [];
  String? nce;
  String? erreur;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    try {
      final e = await MyDb.select(
          "SELECT nce, nom, prenom FROM etudiant ORDER BY nce");
      final m = await MyDb.select(
          "SELECT cod_mat, int_mat FROM matiere ORDER BY cod_mat");
      setState(() {
        etudiants = e;
        matieres = m;
        erreur = null;
      });
    } catch (e) {
      setState(() => erreur =
      "Erreur de connexion MySQL :\n$e\n\n"
          "• MySQL est-il démarré dans XAMPP ?\n"
          "• Avez-vous lancé : adb reverse tcp:3306 tcp:3306 ?");
    }
  }

  Future<void> loadAbsences() async {
    if (nce == null) return;
    try {
      final a = await MyDb.select(
          "SELECT cod_mat, date_a, nha FROM absence "
              "WHERE nce = :nce ORDER BY date_a DESC",
          {"nce": nce});
      final t = await MyDb.select(
          "SELECT cod_mat, SUM(nha) AS total FROM absence "
              "WHERE nce = :nce GROUP BY cod_mat ORDER BY cod_mat",
          {"nce": nce});
      setState(() {
        absences = a;
        totaux = t;
      });
    } catch (e) {
      msg("Erreur de chargement", error: true);
    }
  }

  String fmtNum(String? v) {
    final n = num.tryParse(v ?? '') ?? 0;
    return n == n.roundToDouble() ? n.toInt().toString() : n.toString();
  }

  String fmtDate(String? iso) {
    final p = (iso ?? '').split(' ').first.split('-');
    return p.length == 3 ? '${p[2]}-${p[1]}-${p[0]}' : (iso ?? '');
  }

  void msg(String t, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(t),
      backgroundColor: error ? Colors.red : Colors.green,
    ));
  }

  Future<void> ajouter() async {
    if (nce == null || matieres.isEmpty) return;
    String? firstCodMat = matieres.first['cod_mat'];
    if (firstCodMat == null) return;
    String codMat = firstCodMat;
    DateTime date = DateTime.now();
    final nhaCtrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text("Nouvelle absence"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButton<String>(
                  isExpanded: true,
                  value: matieres.any((m) => m['cod_mat'] == codMat)
                      ? codMat
                      : firstCodMat,
                  items: matieres
                      .where((m) => m['cod_mat'] != null)
                      .map((m) => DropdownMenuItem<String>(
                    value: m['cod_mat'],
                    child: Text(m['cod_mat']!),
                  ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setS(() => codMat = v);
                  },
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_today),
                  label: Text(fmtDate(date.toIso8601String().substring(0, 10))),
                  onPressed: () async {
                    final d = await showDatePicker(
                      context: ctx,
                      initialDate: date,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (d != null) setS(() => date = d);
                  },
                ),
                TextField(
                  controller: nhaCtrl,
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                      labelText: "Nombre d'heures (NHA)"),
                ),
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
      ),
    );

    if (ok != true) return;
    final nha = double.tryParse(nhaCtrl.text.replaceAll(',', '.'));
    if (nha == null || nha <= 0) {
      msg("NHA invalide", error: true);
      return;
    }

    try {
      await MyDb.exec(
        "INSERT INTO absence (cod_mat, nce, date_a, nha) "
            "VALUES (:cod, :nce, :date, :nha)",
        {
          "cod": codMat,
          "nce": nce,
          "date": date.toIso8601String().substring(0, 10),
          "nha": nha,
        },
      );
      msg("Absence ajoutée");
      await loadAbsences();
    } catch (e) {
      msg("Cette absence existe déjà (même matière et même date)",
          error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (erreur != null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Gestion des absences")),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(erreur!, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: init, child: const Text("Réessayer")),
              ],
            ),
          ),
        ),
      );
    }

    const titre = TextStyle(
        fontSize: 16, fontWeight: FontWeight.bold, color: Colors.purple);

    return Scaffold(
      appBar: AppBar(title: const Text("Gestion des absences")),
      floatingActionButton: nce == null
          ? null
          : FloatingActionButton(
        onPressed: ajouter,
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButton<String>(
            isExpanded: true,
            value: etudiants.any((e) => e['nce'] == nce) ? nce : null,
            hint: const Text("Choisir un étudiant"),
            items: etudiants
                .map((e) => DropdownMenuItem<String>(
              value: e['nce'],
              child: Text("${e['nce']} - ${e['nom']} ${e['prenom']}"),
            ))
                .toList(),
            onChanged: (v) {
              setState(() {
                nce = v;
                absences = [];
                totaux = [];
              });
              loadAbsences();
            },
          ),
          const SizedBox(height: 20),
          if (nce == null)
            const Center(child: Text("Sélectionnez un étudiant"))
          else ...[
            const Text("Total des absences par matière", style: titre),
            const SizedBox(height: 8),
            if (totaux.isEmpty)
              const Text("Aucune absence")
            else
              Center(
                child: DataTable(
                  border: TableBorder.all(),
                  columns: const [
                    DataColumn(label: Text("CodMat")),
                    DataColumn(label: Text("Total NHA"), numeric: true),
                  ],
                  rows: totaux
                      .map((t) => DataRow(cells: [
                    DataCell(Text(t['cod_mat'] ?? '')),
                    DataCell(Text(fmtNum(t['total']))),
                  ]))
                      .toList(),
                ),
              ),
            const SizedBox(height: 24),
            const Text("Liste des absences", style: titre),
            const SizedBox(height: 8),
            if (absences.isNotEmpty)
              Center(
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text("DateA")),
                    DataColumn(label: Text("CodMat")),
                    DataColumn(label: Text("NHA"), numeric: true),
                  ],
                  rows: absences
                      .map((a) => DataRow(cells: [
                    DataCell(Text(fmtDate(a['date_a']))),
                    DataCell(Text(a['cod_mat'] ?? '')),
                    DataCell(Text(fmtNum(a['nha']))),
                  ]))
                      .toList(),
                ),
              ),
          ],
        ],
      ),
    );
  }
}