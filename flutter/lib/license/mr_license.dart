import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../common.dart';
import '../models/platform_model.dart';

/// MR Acesso Remoto: módulo de licença — UM SÓ ponto de verificação.
/// A chave é validada no painel Gestão de Licenças (Aurora) pelo endpoint
/// clássico. O app autoriza SÓ pelo JSON da resposta, nunca pelo HTTP:
/// ok + valid + premium + tipo "premium" + produtos.mr_acesso_remoto +
/// expira_em no futuro. "Válido" não é "pago": chave de teste (tipo
/// "teste", premium false) é negada, mesmo com valid true.
/// Falha de rede, timeout ou JSON malformado NUNCA é validação com sucesso.
/// A chave guardada com expira_em futuro vale offline até essa data.
/// O valor da chave nunca é registado em logs.
class LicenseResult {
  final bool allowed;
  final String reason;
  final DateTime? expiraEm;

  const LicenseResult({
    required this.allowed,
    required this.reason,
    this.expiraEm,
  });
}

class LicenseService {
  static const String endpoint =
      'https://mrsemlimites.lovable.app/api/public/validar-licenca';

  static const String _keyOption = 'mr-license-key';
  static const String _expiryOption = 'mr-license-expira-em';
  static const String _deviceOption = 'mr-device-id';

  static bool hasValidStoredKey() {
    final key = bind.mainGetOptionSync(key: _keyOption);
    final expiry = bind.mainGetOptionSync(key: _expiryOption);
    if (key.isEmpty || expiry.isEmpty) return false;
    final exp = DateTime.tryParse(expiry);
    if (exp == null) return false;
    return exp.isAfter(DateTime.now().toUtc());
  }

  static DateTime? storedExpiry() {
    final expiry = bind.mainGetOptionSync(key: _expiryOption);
    if (expiry.isEmpty) return null;
    return DateTime.tryParse(expiry);
  }

  static Future<String> deviceId() async {
    var id = bind.mainGetOptionSync(key: _deviceOption);
    if (id.isEmpty) {
      id = const Uuid().v4();
      await bind.mainSetOption(key: _deviceOption, value: id);
    }
    return id;
  }

  static Future<void> save(String chave, DateTime expiraEm) async {
    await bind.mainSetOption(key: _keyOption, value: chave);
    await bind.mainSetOption(
        key: _expiryOption, value: expiraEm.toUtc().toIso8601String());
  }

  static Future<void> clear() async {
    await bind.mainSetOption(key: _keyOption, value: '');
    await bind.mainSetOption(key: _expiryOption, value: '');
  }

  static Future<LicenseResult> verify(String chave, {String? email}) async {
    final key = chave.trim();
    if (key.isEmpty) {
      return const LicenseResult(allowed: false, reason: 'invalida');
    }
    try {
      final body = <String, dynamic>{
        'chave': key,
        'device_id': await deviceId(),
      };
      if (email != null && email.trim().isNotEmpty) {
        body['email'] = email.trim();
      }
      final res = await http
          .post(
            Uri.parse(endpoint),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));
      if (res.statusCode != 200) {
        return const LicenseResult(allowed: false, reason: 'sem_ligacao');
      }
      final data = jsonDecode(res.body);
      if (data is! Map) {
        return const LicenseResult(allowed: false, reason: 'sem_ligacao');
      }
      final ok = data['ok'] == true;
      final valid = data['valid'] == true;
      final premium = data['premium'] == true;
      final tipo = data['tipo'];
      final produtos = data['produtos'];
      final hasProduct =
          produtos is Map && produtos['mr_acesso_remoto'] == true;
      final expiraRaw = data['expira_em'];
      final expiraEm =
          expiraRaw is String ? DateTime.tryParse(expiraRaw) : null;
      if (!ok || !valid) {
        return const LicenseResult(allowed: false, reason: 'invalida');
      }
      if (expiraEm == null || !expiraEm.isAfter(DateTime.now().toUtc())) {
        return LicenseResult(
            allowed: false, reason: 'expirada', expiraEm: expiraEm);
      }
      if (tipo != 'teste' && (!premium || tipo != 'premium')) {
        return LicenseResult(
            allowed: false, reason: 'trial', expiraEm: expiraEm);
      }
            if (tipo != 'teste' && !hasProduct) {
        return LicenseResult(
            allowed: false, reason: 'sem_produto', expiraEm: expiraEm);
      }
      return LicenseResult(allowed: true, reason: 'ok', expiraEm: expiraEm);
    } catch (_) {
      return const LicenseResult(allowed: false, reason: 'sem_ligacao');
    }
  }
}
