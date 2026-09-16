class FinanziaValidators {
  static String? requiredText(String? value, {String label = 'Este campo'}) {
    if (value == null || value.trim().isEmpty) return '$label es obligatorio';
    return null;
  }

  static String? positiveMoney(String? value, {String label = 'Monto'}) {
    final normalized = (value ?? '').trim().replaceAll(',', '.');
    final n = double.tryParse(normalized);
    if (n == null) return 'Ingresa un número válido';
    if (n <= 0) return '$label debe ser mayor que 0';
    if (n > 999999999) return '$label es demasiado alto';
    return null;
  }

  static String? email(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'El correo es obligatorio';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v))
      return 'Ingresa un correo válido';
    return null;
  }
}
