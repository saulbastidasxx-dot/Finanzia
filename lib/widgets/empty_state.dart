import 'package:flutter/material.dart';
class EmptyState extends StatelessWidget {
  final IconData icon; final String title,description; final String? actionLabel; final VoidCallback? onAction;
  const EmptyState({super.key,required this.icon,required this.title,required this.description,this.actionLabel,this.onAction});
  @override Widget build(BuildContext context)=>Card(child:Padding(padding:const EdgeInsets.all(28),child:Column(children:[Icon(icon,size:52,color:Theme.of(context).colorScheme.primary),const SizedBox(height:14),Text(title,textAlign:TextAlign.center,style:Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight:FontWeight.w800)),const SizedBox(height:8),Text(description,textAlign:TextAlign.center,style:Theme.of(context).textTheme.bodyMedium),if(actionLabel!=null&&onAction!=null)...[const SizedBox(height:18),FilledButton.icon(onPressed:onAction,icon:const Icon(Icons.add),label:Text(actionLabel!))]])));
}
