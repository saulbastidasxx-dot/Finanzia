# Eliminación de cuenta — especificación
Antes del lanzamiento público debe implementarse como operación autenticada del lado servidor.

Flujo:
1. Usuario abre Configuración > Cuenta > Eliminar cuenta.
2. Se explica qué se eliminará y que la acción es irreversible.
3. Se exige reautenticación.
4. Una función segura de backend elimina datos dependientes y el usuario de Auth.
5. Se cierra la sesión local y se limpia almacenamiento local.
6. Se muestra confirmación.

Nunca colocar una `service_role` en Flutter para eliminar usuarios de Auth.
