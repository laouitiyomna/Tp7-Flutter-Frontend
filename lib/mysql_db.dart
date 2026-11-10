import 'package:mysql_client/mysql_client.dart';
import 'config.dart';

class MyDb {
  static MySQLConnection? _conn;

  // Connexion MySQL
  static Future<MySQLConnection> get conn async {
    try {
      if (_conn != null && _conn!.connected) {
        return _conn!;
      }

      print("========== MYSQL CONNECTION ==========");
      print("Configured Host: $dbHost, Port: $dbPort, Database: $dbName");

      final hostsToTry = {dbHost, "127.0.0.1", "10.0.2.2"}.toList();
      final credentialsToTry = [
        {'user': dbUser, 'pass': dbPass},
        {'user': 'scolarite', 'pass': 'scolarite'},
        {'user': 'root', 'pass': ''},
      ];
      Object? lastException;

      for (final host in hostsToTry) {
        for (final cred in credentialsToTry) {
          final u = cred['user']!;
          final p = cred['pass']!;
          try {
            print("Attempting MySQL connection to $host:$dbPort with user '$u'...");
            final c = await MySQLConnection.createConnection(
              host: host,
              port: dbPort,
              userName: u,
              password: p,
              databaseName: dbName,
              secure: false,
            );

            await c.connect(timeoutMs: 2500);
            print("MYSQL CONNECTION SUCCESS ON $host with user '$u'!");
            _conn = c;
            return c;
          } catch (e) {
            print("Failed MySQL connection on $host with user '$u': $e");
            lastException = e;
          }
        }
      }

      _conn = null;
      throw lastException ?? Exception("Failed to connect to MySQL on all attempted hosts");
    } catch (e, stackTrace) {
      _conn = null;
      print("MYSQL CONNECTION ERROR: $e");
      print(stackTrace);
      rethrow;
    }
  }

  // SELECT
  static Future<List<Map<String, String?>>> select(
      String sql, [
        Map<String, dynamic>? params,
      ]) async {
    try {
      final c = await conn;

      final res = await c.execute(sql, params);

      return res.rows.map((r) => r.assoc()).toList();

    } catch (e) {
      _conn = null;
      print("SELECT ERROR: $e");
      rethrow;
    }
  }

  // INSERT / UPDATE / DELETE
  static Future<void> exec(
      String sql, [
        Map<String, dynamic>? params,
      ]) async {
    try {
      final c = await conn;

      await c.execute(sql, params);

      print("SQL EXECUTION SUCCESS!");

    } catch (e) {
      _conn = null;
      print("SQL EXECUTION ERROR: $e");
      rethrow;
    }
  }

  // Fermer la connexion
  static Future<void> close() async {
    if (_conn != null) {
      await _conn!.close();
      _conn = null;
      print("MYSQL CONNECTION CLOSED");
    }
  }

  // Tester la connexion
  static Future<bool> testConnection() async {
    try {
      final c = await conn;

      final result = await c.execute("SELECT 1 AS test");

      print("MYSQL TEST: ${result.rows.first.assoc()}");

      return true;

    } catch (e) {
      print("MYSQL TEST FAILED: $e");
      return false;
    }
  }
}