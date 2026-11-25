import 'package:flutter/material.dart';
import 'mysql_db.dart';

class TopModulesScreen extends StatefulWidget {
  const TopModulesScreen({super.key});

  @override
  State<TopModulesScreen> createState() => _TopModulesScreenState();
}

class _TopModulesScreenState extends State<TopModulesScreen> {
  bool _loading = true;
  List<Map<String, String?>> _modules = [];

  @override
  void initState() {
    super.initState();
    _chargerTop();
  }

  Future<void> _chargerTop() async {
    try {
      final res = await MyDb.select(
        "SELECT a.cod_mat, m.int_mat, SUM(a.nha) AS total "
        "FROM absence a JOIN matiere m ON m.cod_mat = a.cod_mat "
        "GROUP BY a.cod_mat, m.int_mat "
        "ORDER BY total DESC, a.cod_mat LIMIT 3;",
      );
      setState(() {
        _modules = res;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Top 3 modules absents"), backgroundColor: Colors.deepOrange, foregroundColor: Colors.white),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: _modules.length,
                itemBuilder: (context, i) {
                  final m = _modules[i];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(backgroundColor: Colors.deepOrange, child: Text("${i + 1}", style: const TextStyle(color: Colors.white))),
                      title: Text("${m['cod_mat']} - ${m['int_mat']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                      trailing: Text("${m['total']} h", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 16)),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
