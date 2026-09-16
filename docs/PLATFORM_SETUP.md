# Configuración de plataformas

## Generar runners
Si el proyecto no tiene runners nativos:

```bash
flutter create . --platforms=android,ios,web
flutter pub get
```

## Android · biometría
En `android/app/src/main/kotlin/.../MainActivity.kt`:

```kotlin
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity: FlutterFragmentActivity()
```

## iOS · Face ID
En `ios/Runner/Info.plist` agrega:

```xml
<key>NSFaceIDUsageDescription</key>
<string>Finanzia usa Face ID para desbloquear tu información financiera.</string>
```

## Web
No necesita configuración biométrica. El modo web usa PIN y descarga CSV con el navegador.
