class User {
  int id;
  String email;

  User(this.id, this.email);

  factory User.fromMap(Map<String, dynamic> map) => User(
        map["id"] is int
            ? map["id"]
            : int.tryParse(map["id"]?.toString() ?? '0') ?? 0,
        map["email"] ?? '',
      );
}