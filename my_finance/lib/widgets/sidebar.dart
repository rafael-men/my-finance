import 'package:flutter/material.dart';
import 'package:my_finance/pages/compras_page.dart';
import 'package:my_finance/pages/homepage.dart';
import 'package:my_finance/pages/trips_page.dart';
import 'package:my_finance/services/auth_service.dart';
import 'package:my_finance/utils/SidebarItem.dart';
import 'package:my_finance/widgets/edit_profile_dialog.dart';

enum SidebarDestination { home, compras, trips }

class Sidebar extends StatelessWidget {
  final bool expanded;
  final bool showToggle;
  final VoidCallback? onToggleExpanded;
  final SidebarDestination destination;

  const Sidebar({
    super.key,
    this.expanded = true,
    this.showToggle = false,
    this.onToggleExpanded,
    this.destination = SidebarDestination.home,
  });

  Widget get _logo => Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: const Color.fromARGB(31, 255, 255, 255),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(
          Icons.account_balance_wallet_outlined,
          color: Colors.white,
        ),
      );

  Widget _buildProfileAvatar(BuildContext context) {
    final authService = AuthService.getShared();
    final user = authService.appUser;
    final displayName = user?.name ?? '';
    final initials = displayName.isNotEmpty
        ? displayName
            .trim()
            .split(' ')
            .map((w) => w[0])
            .take(2)
            .join()
            .toUpperCase()
        : '';

    return PopupMenuButton<String>(
      offset: Offset(expanded ? 0 : 10, 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user?.name ?? 'Usuário',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                user?.email ?? '',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'edit_profile',
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 20, color: Color.fromARGB(255, 47, 9, 54)),
              SizedBox(width: 8),
              Text('Editar perfil'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, size: 20, color: Colors.red),
              SizedBox(width: 8),
              Text('Sair', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        if (value == 'logout') {
          authService.signOut();
        } else if (value == 'edit_profile') {
          showEditProfileDialog(context);
        }
      },
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: initials.isNotEmpty
            ? Center(
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
            : const Icon(
                Icons.person_outline,
                color: Colors.white,
                size: 20,
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
      width: expanded ? 260 : 88,
      color: const Color.fromARGB(255, 47, 9, 54),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: expanded
                  ? Row(
                      children: [
                        _logo,
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'My Finance',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Painel financeiro',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _buildProfileAvatar(context),
                        if (showToggle) ...[
                          const SizedBox(width: 4),
                          IconButton(
                            onPressed: onToggleExpanded,
                            icon: const Icon(
                              Icons.chevron_left,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ],
                    )
                  : Column(
                      children: [
                        _logo,
                        const SizedBox(height: 12),
                        _buildProfileAvatar(context),
                        if (showToggle) ...[
                          const SizedBox(height: 8),
                          IconButton(
                            onPressed: onToggleExpanded,
                            icon: const Icon(
                              Icons.chevron_right,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ],
                    ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(color: Colors.white24, height: 1),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  SidebarItem(
                    icon: Icons.home_outlined,
                    label: 'Gastos',
                    expanded: expanded,
                    selected: destination == SidebarDestination.home,
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const Homepage()),
                    ),
                  ),
                  SidebarItem(
                    icon: Icons.shopping_bag_outlined,
                    label: 'Compras',
                    expanded: expanded,
                    selected: destination == SidebarDestination.compras,
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ComprasPage(),
                      ),
                    ),
                  ),
                  SidebarItem(
                    icon: Icons.airplane_ticket_outlined,
                    label: 'Viagens',
                    expanded: expanded,
                    selected: destination == SidebarDestination.trips,
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TripsPage(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
