import 'package:flutter/material.dart';

class _ClasseModel {
  final int codClass;
  final String nomClass;
  int nbreEtud;

  _ClasseModel({
    required this.codClass,
    required this.nomClass,
    required this.nbreEtud,
  });
}

class _EtudiantModel {
  final String nce;
  final String nom;
  final String prenom;
  final int codClass;

  _EtudiantModel({
    required this.nce,
    required this.nom,
    required this.prenom,
    required this.codClass,
  });
}

class StatClasseScreen extends StatefulWidget {
  const StatClasseScreen({super.key});

  @override
  State<StatClasseScreen> createState() => _StatClasseScreenState();
}

class _StatClasseScreenState extends State<StatClasseScreen> {
  // Liste Frontend de démonstration pour les classes
  final List<_ClasseModel> _classes = [
    _ClasseModel(codClass: 1, nomClass: "DSI33", nbreEtud: 15),
    _ClasseModel(codClass: 2, nomClass: "DSI31", nbreEtud: 20),
    _ClasseModel(codClass: 3, nomClass: "DSI21", nbreEtud: 18),
    _ClasseModel(codClass: 4, nomClass: "RSI31", nbreEtud: 12),
  ];

  // Liste Frontend de démonstration pour les étudiants dans la table etudiant
  final List<_EtudiantModel> _etudiants = [
    _EtudiantModel(nce: "E1", nom: "Ben Foulen1", prenom: "Foulen1", codClass: 1),
    _EtudiantModel(nce: "E2", nom: "Trabelsi", prenom: "Amira", codClass: 1),
    _EtudiantModel(nce: "E3", nom: "Khemiri", prenom: "Salma", codClass: 1),
    _EtudiantModel(nce: "E4", nom: "Ben Ali", prenom: "Sami", codClass: 1),
    _EtudiantModel(nce: "E5", nom: "Jlassi", prenom: "Mohamed", codClass: 1),
    _EtudiantModel(nce: "E6", nom: "Gharbi", prenom: "Youssef", codClass: 1),
    _EtudiantModel(nce: "E7", nom: "Ayari", prenom: "Ahmed", codClass: 1),

    _EtudiantModel(nce: "E8", nom: "Mansouri", prenom: "Ines", codClass: 2),
    _EtudiantModel(nce: "E9", nom: "Sassi", prenom: "Karim", codClass: 2),
    _EtudiantModel(nce: "E10", nom: "Bouaziz", prenom: "Meriem", codClass: 2),

    _EtudiantModel(nce: "E11", nom: "Dridi", prenom: "Omar", codClass: 3),
    _EtudiantModel(nce: "E12", nom: "Cherif", prenom: "Fatma", codClass: 3),
  ];

  // Calcul du nombre réel d'étudiants pour chaque classe
  int _compterEtudiants(int codClass) {
    return _etudiants.where((e) => e.codClass == codClass).length;
  }

  // Trouver la classe ayant le plus grand nombre d'étudiants dans la table etudiant
  _ClasseModel get _classeMax {
    _ClasseModel maxCls = _classes.first;
    int maxCount = _compterEtudiants(maxCls.codClass);

    for (var cls in _classes) {
      int currentCount = _compterEtudiants(cls.codClass);
      if (currentCount > maxCount) {
        maxCount = currentCount;
        maxCls = cls;
      }
    }
    return maxCls;
  }

  void _mettreAJourNbreEtud() {
    final maxCls = _classeMax;
    final nombreCalculer = _compterEtudiants(maxCls.codClass);

    setState(() {
      maxCls.nbreEtud = nombreCalculer;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Succès ! La colonne nbreEtud de la classe ${maxCls.nomClass} a été mise à jour à $nombreCalculer !",
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green.shade700,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxCls = _classeMax;
    final maxRealCount = _compterEtudiants(maxCls.codClass);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Classe avec le max d'étudiants"),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carte principale mettant en avant la classe maximale
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: Colors.deepOrange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.emoji_events, color: Colors.deepOrange, size: 32),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Classe avec le plus grand nombre d'étudiants",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrange,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24, thickness: 1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              maxCls.nomClass,
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepOrange.shade900,
                              ),
                            ),
                            Text("Code Classe: ${maxCls.codClass}", style: TextStyle(color: Colors.grey.shade700)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.deepOrange,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text(
                                "$maxRealCount",
                                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              const Text("Étudiants", style: TextStyle(color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.info_outline, size: 20, color: Colors.black54),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Valeur actuelle de nbreEtud enregistrée : ${maxCls.nbreEtud}",
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Bouton de mise à jour nbreEtud
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.update),
                        label: Text(
                          "Mettre à jour nbreEtud (${maxCls.nomClass}) -> $maxRealCount",
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        onPressed: _mettreAJourNbreEtud,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),
            const Text(
              "Tableau récapitulatif de toutes les classes",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Tableau de toutes les classes
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _classes.length,
                separatorBuilder: (ctx, idx) => const Divider(height: 1),
                itemBuilder: (ctx, idx) {
                  final cls = _classes[idx];
                  final count = _compterEtudiants(cls.codClass);
                  final isMax = cls.codClass == maxCls.codClass;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isMax ? Colors.deepOrange : Colors.grey.shade300,
                      foregroundColor: isMax ? Colors.white : Colors.black87,
                      child: Text("${cls.codClass}"),
                    ),
                    title: Text(
                      cls.nomClass,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isMax ? Colors.deepOrange.shade900 : Colors.black87,
                      ),
                    ),
                    subtitle: Text("nbreEtud (stocké): ${cls.nbreEtud} | Nombre réel: $count"),
                    trailing: isMax
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade100,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.amber.shade800),
                            ),
                            child: const Text("MAX ⭐", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          )
                        : null,
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
