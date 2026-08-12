import 'package:flutter/material.dart';
import 'package:my_finance/widgets/sidebar.dart';

class ResponsiveSidebarScaffold extends StatefulWidget {
  final String title;
  final Widget body;
  final List<Widget> actions;
  final Widget? floatingActionButton;
  final SidebarDestination destination;
  final Color backgroundColor;

  const ResponsiveSidebarScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions = const [],
    this.floatingActionButton,
    required this.destination,
    this.backgroundColor = const Color(0xFFF5F4F8),
  });

  @override
  State<ResponsiveSidebarScaffold> createState() =>
      _ResponsiveSidebarScaffoldState();
}

class _ResponsiveSidebarScaffoldState extends State<ResponsiveSidebarScaffold> {
  bool _sidebarExpanded = true;

  static const double _desktopBreakpoint = 980;

  bool get _isDesktop => MediaQuery.sizeOf(context).width >= _desktopBreakpoint;

  @override
  Widget build(BuildContext context) {
    if (_isDesktop) {
      return Scaffold(
        backgroundColor: widget.backgroundColor,
        floatingActionButton: widget.floatingActionButton,
        body: SafeArea(
          child: Row(
            children: [
              Sidebar(
                expanded: _sidebarExpanded,
                destination: widget.destination,
                showToggle: true,
                onToggleExpanded: () {
                  setState(() {
                    _sidebarExpanded = !_sidebarExpanded;
                  });
                },
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                      child: Row(
                        children: [
                          Text(
                            widget.title,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Color.fromARGB(255, 47, 9, 54),
                            ),
                          ),
                          const Spacer(),
                          ..._actionWidgets(widget.actions),
                        ],
                      ),
                    ),
                    Expanded(child: widget.body),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: widget.backgroundColor,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: const Color.fromARGB(255, 47, 9, 54),
        foregroundColor: Colors.white,
        actions: widget.actions,
      ),
      drawer: Drawer(
        child: Sidebar(
          expanded: true,
          destination: widget.destination,
          showToggle: false,
        ),
      ),
      floatingActionButton: widget.floatingActionButton,
      body: SafeArea(child: widget.body),
    );
  }

  List<Widget> _actionWidgets(List<Widget> actions) {
    if (actions.isEmpty) {
      return const [];
    }

    return [
      for (int index = 0; index < actions.length; index++) ...[
        if (index > 0) const SizedBox(width: 8),
        actions[index],
      ],
    ];
  }
}
