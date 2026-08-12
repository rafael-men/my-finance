import 'package:flutter/material.dart';
import 'package:my_finance/pages/compras_page.dart';
import 'package:my_finance/pages/homepage.dart';
import 'package:my_finance/pages/trips_page.dart';
import 'package:my_finance/utils/SidebarItem.dart';

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
              child: Row(
                children: [
                  Container(
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
                  ),
                  if (expanded) ...[
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
                  ],
                  if (showToggle)
                    IconButton(
                      onPressed: onToggleExpanded,
                      icon: Icon(
                        expanded ? Icons.chevron_left : Icons.chevron_right,
                        color: Colors.white,
                      ),
                    ),
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
