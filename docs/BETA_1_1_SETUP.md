# Finanzia Beta 1.1 — preparación de producto

## Qué cambia
- Edición visual de cuentas y movimientos.
- Confirmaciones antes de eliminar movimientos/cuentas.
- Validadores reutilizables para texto, dinero y correo.
- Estados vacíos con llamadas a la acción.
- Persistencia de Claro / Oscuro / Automático.
- Activos de marca iniciales para icono y splash.
- Pruebas unitarias de validadores.

## Branding
Los activos fuente están en `assets/branding/`:
- `finanzia_icon_1024.png`: fuente cuadrada de 1024 px para iconos de tienda/launcher.
- `finanzia_splash_mark.png`: marca centrada para splash.

Antes de publicar, genera los tamaños nativos Android/iOS desde estos activos y revisa el resultado en dispositivos reales. No se incluyen certificados ni firma de tienda.

## Validación antes de release
Ejecuta en un equipo con Flutter SDK:

```bash
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
flutter build web --release
flutter build appbundle --release
```

Para iOS, abre el proyecto en macOS/Xcode, configura Team/Bundle ID y ejecuta un Archive de Release.

## Pruebas manuales recomendadas
1. Crear cuenta, editar nombre/tipo/saldo y verificar que el Dashboard se actualiza.
2. Crear ingreso/gasto/transferencia, editar monto/cuenta/fecha y verificar saldos.
3. Intentar eliminar una cuenta con movimientos: debe bloquearse.
4. Eliminar un movimiento: debe pedir confirmación y recalcular saldos.
5. Cambiar entre Claro/Oscuro/Auto, cerrar y abrir: debe conservarse.
6. Probar formularios con montos 0, negativos, texto no numérico y correo inválido.
