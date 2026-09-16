# Finanzia RC14

Versión `2.7.0-rc.14+27`.

RC14 rehace las correcciones de RC13 desde la base RC12 para evitar las corrupciones sintácticas introducidas por la transformación automática de llaves. Los cambios son puntuales: API de inicialización Supabase, `initialValue` en DropdownButtonFormField, imports sin uso, llaves explícitas en los puntos reportados, UUID namespace, API PDF y archivos condicionales Web.

El paso de formato de CI formatea el checkout antes de analizar; no modifica el repositorio remoto. La validación real sigue siendo `flutter analyze`, `flutter test` y builds posteriores.
