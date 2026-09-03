import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:my_finance/services/auth_service.dart';
import 'package:my_finance/utils/photo_utils.dart';
import 'package:my_finance/widgets/responsive_sidebar_scaffold.dart';
import 'package:my_finance/widgets/sidebar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  bool _isSaving = false;
  bool _isPickingPhoto = false;

  AuthService get _authService => AuthService.getShared();

  @override
  void initState() {
    super.initState();
    final user = _authService.appUser;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  String _initials(String name) {
    if (name.trim().isEmpty) return '';
    return name
        .trim()
        .split(' ')
        .map((w) => w[0])
        .take(2)
        .join()
        .toUpperCase();
  }

  Future<void> _pickPhoto() async {
    setState(() {
      _isPickingPhoto = true;
    });

    final base64 = await pickProfilePhotoBase64();

    if (!mounted) return;
    setState(() {
      _isPickingPhoto = false;
    });

    if (base64 == null) return;

    await _authService.updateProfilePhoto(base64);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Foto de perfil atualizada'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _save() async {
    final newName = _nameController.text.trim();
    if (newName.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('O nome deve ter pelo menos 2 letras'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    await _authService.updateProfile(name: newName);

    if (!mounted) return;
    setState(() {
      _isSaving = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Perfil atualizado para $newName'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _authService,
      builder: (context, _) {
        final user = _authService.appUser;
        final name = user?.name ?? '';
        final email = user?.email ?? '';
        final initials = _initials(name);
        final photo = user?.photoBase64 ?? '';
        final hasPhoto = photo.isNotEmpty;

        return ResponsiveSidebarScaffold(
          title: 'Meu Perfil',
          destination: SidebarDestination.home,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _isPickingPhoto ? null : _pickPhoto,
                        child: Stack(
                          children: [
                            Container(
                              width: 96,
                              height: 96,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color.fromARGB(255, 47, 9, 54),
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 2,
                                ),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: hasPhoto
                                  ? Image.memory(
                                      base64Decode(photo),
                                      fit: BoxFit.cover,
                                      width: 96,
                                      height: 96,
                                    )
                                  : (initials.isNotEmpty
                                      ? Center(
                                          child: Text(
                                            initials,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 32,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        )
                                      : const Icon(
                                          Icons.person_outline,
                                          color: Colors.white,
                                          size: 44,
                                        )),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color.fromARGB(255, 47, 9, 54),
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: _isPickingPhoto
                                    ? const Padding(
                                        padding: EdgeInsets.all(6),
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                        size: 15,
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Toque na foto para alterar',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        name.isEmpty ? 'Usuário' : name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Informações pessoais',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextField(
                          controller: _nameController,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: 'Nome',
                            prefixIcon: Icon(Icons.person_outline),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          enabled: false,
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'E-mail',
                            prefixIcon: Icon(Icons.email_outlined),
                            border: OutlineInputBorder(),
                            helperText: 'O e-mail não pode ser alterado',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: _isSaving ? null : _save,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 47, 9, 54),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save_outlined),
                    label: Text(_isSaving ? 'Salvando...' : 'Salvar alterações'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
