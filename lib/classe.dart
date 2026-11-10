class Classe {
  int codClass;
  String nomClass;
  int nbreEtud;

  Classe(this.codClass, this.nomClass, this.nbreEtud);

  factory Classe.fromMap(Map<String, dynamic> m) => Classe(
        m['codClass'] is int
            ? m['codClass']
            : int.tryParse(m['codClass']?.toString() ?? '0') ?? 0,
        m['nomClass'] ?? '',
        m['nbreEtud'] is int
            ? m['nbreEtud']
            : int.tryParse(m['nbreEtud']?.toString() ?? '0') ?? 0,
      );
}