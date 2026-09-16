/// Configuración de backend. En producción usa --dart-define para no fijar
/// valores por ambiente en el código fuente.
class SupabaseConfig {
  static const url = String.fromEnvironment('SUPABASE_URL');
  static const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static bool get configured => url.isNotEmpty && anonKey.isNotEmpty;
}
