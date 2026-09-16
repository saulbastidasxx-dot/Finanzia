import 'package:flutter/material.dart';
class LegalScreen extends StatelessWidget{
 const LegalScreen({super.key});
 @override Widget build(BuildContext c)=>Scaffold(appBar:AppBar(title:const Text('Privacidad y términos')),body:ListView(padding:const EdgeInsets.all(24),children:[
  Text('Privacidad',style:Theme.of(c).textTheme.headlineSmall?.copyWith(fontWeight:FontWeight.w800)),const SizedBox(height:12),
  const Text('Finanzia organiza información financiera que tú proporcionas o sincronizas. La versión de producción debe publicar una política de privacidad definitiva que describa datos recopilados, finalidad, conservación, proveedores y mecanismos de eliminación.'),
  const SizedBox(height:24),Text('Seguridad',style:Theme.of(c).textTheme.titleLarge?.copyWith(fontWeight:FontWeight.w700)),const SizedBox(height:8),
  const Text('La arquitectura usa aislamiento de datos por usuario en Supabase y puede proteger el acceso local con PIN o biometría. Nunca compartas contraseñas, códigos de acceso o claves privadas.'),
  const SizedBox(height:24),Text('Tus controles',style:Theme.of(c).textTheme.titleLarge?.copyWith(fontWeight:FontWeight.w700)),const SizedBox(height:8),
  const Text('Finanzia incluye exportación de información. Antes de publicación debe habilitarse además un flujo verificable de eliminación de cuenta y datos asociados.'),
  const SizedBox(height:24),Text('Términos',style:Theme.of(c).textTheme.titleLarge?.copyWith(fontWeight:FontWeight.w700)),const SizedBox(height:8),
  const Text('Finanzia es una herramienta de organización financiera y no sustituye asesoramiento financiero, fiscal, legal o de inversión. Los términos definitivos deberán revisarse antes de distribuir la aplicación.')
 ]));
}