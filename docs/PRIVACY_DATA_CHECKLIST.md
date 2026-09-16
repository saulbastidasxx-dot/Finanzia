# Checklist de privacidad y datos
Finanzia maneja datos financieros personales. Antes de producción:
- Documentar qué datos se recopilan, finalidad, retención y eliminación.
- No incluir claves de servicio de Supabase en el cliente.
- Mantener RLS activa en todas las tablas por usuario.
- Ofrecer exportación y eliminación de cuenta/datos.
- Revisar logs para que no contengan saldos, tokens ni credenciales.
- Declarar biometría/notificaciones según plataforma.
- Completar Data Safety de Google Play y App Privacy de Apple según el comportamiento real de la versión publicada.
