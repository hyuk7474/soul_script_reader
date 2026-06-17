import 'package:mysql_client_plus/mysql_client_plus.dart';

/// MySQL 연결 설정
class DatabaseConfig {
  DatabaseConfig({
    required this.host,
    required this.port,
    required this.user,
    required this.password,
    required this.database,
  });

  final String host;
  final int port;
  final String user;
  final String password;
  final String database;

  factory DatabaseConfig.fromEnv(Map<String, String> env) {
    return DatabaseConfig(
      host: env['MYSQL_HOST'] ?? '127.0.0.1',
      port: int.tryParse(env['MYSQL_PORT'] ?? '') ?? 3306,
      user: env['MYSQL_USER'] ?? 'soul_app',
      password: env['MYSQL_PASSWORD'] ?? '',
      database: env['MYSQL_DATABASE'] ?? 'soul_script_reader',
    );
  }
}

/// MySQL 연결 헬퍼
class Database {
  Database(this._config);

  final DatabaseConfig _config;
  MySQLConnection? _connection;

  Future<MySQLConnection> get connection async {
    if (_connection == null) {
      _connection = await MySQLConnection.createConnection(
        host: _config.host,
        port: _config.port,
        userName: _config.user,
        password: _config.password,
        databaseName: _config.database,
        // caching_sha2_password(MySQL 8.4 LTS 기본)는 TLS 연결 필요
        secure: true,
        onBadCertificate: (_) => true,
      );
      await _connection!.connect();
    }
    return _connection!;
  }

  Future<void> close() async {
    await _connection?.close();
    _connection = null;
  }
}
