import 'package:flutter/material.dart';
import 'package:my_finance/services/auth_service.dart';

Future<void> showEditProfileDialog(BuildContext context) async {
  final authService = AuthService.getShared();
  final user = authService.appUser;
  final nameController = TextEditingController(text: user?.name ?? '');

  await showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Editar Perfil'),
      content: Form(
        child: TextFormField(
          controller: nameController,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: 'Nome',
            prefixIcon: const Icon(Icons.person_outline),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () async {
            final newName = nameController.text.trim();
            if (newName.isEmpty || newName.length < 2) return;

            await authService.updateProfile(name: newName);
            if (context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Perfil atualizado para $newName'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 47, 9, 54),
            foregroundColor: Colors.white,
          ),
          child: const Text('Salvar'),
        ),
      ],
    ),
  );

  nameController.dispose();
}
