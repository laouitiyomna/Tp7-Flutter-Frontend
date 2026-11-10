class Etudiant {
  int id;
  String nom;
  String prenom;
  String dateNais;

  Etudiant(this.id, this.nom, this.prenom, this.dateNais);

  factory Etudiant.fromMap(Map<String, dynamic> m) => Etudiant(
        m['id'] is int
            ? m['id']
            : int.tryParse(m['id']?.toString() ?? m['nce']?.toString() ?? '0') ?? 0,
        m['nom'] ?? '',
        m['prenom'] ?? '',
        m['dateNais'] ?? '',
      );
}