import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/finance_store.dart';
import 'security_service.dart';
import 'preferences_service.dart';

class AccountDeletionService {
  final SupabaseClient client;
  AccountDeletionService(this.client);
  Future<void> deleteCurrentUser(FinanceStore store) async {
    if (client.auth.currentUser == null)
      throw StateError('No hay una sesión autenticada.');
    final r = await client.functions.invoke('delete-account');
    if (r.status < 200 || r.status >= 300)
      throw StateError(
        'El servidor no pudo eliminar la cuenta (${r.status}). Los datos locales se conservaron para evitar pérdida parcial.',
      );
    await client.auth.signOut();
    await store.clearLocalData();
    await SecurityService().clearAllSecurityData();
    await PreferencesService().clearUserScopedPreferences();
  }
}
