import 'package:flutter/material.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/session/session_manager.dart';
import '../../../login/presentation/pages/login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final sessionManager = sl<SessionManager>();
    
    return ValueListenableBuilder<Session?>(
      valueListenable: sessionManager.currentSession,
      builder: (context, session, child) {
        if (session == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginPage()),
              (route) => false,
            );
          });
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        
        final username = session.email;
        
        return Scaffold(
          body: SafeArea(
            child: Row(
              children: [
                MouseRegion(
                  onEnter: (_) => setState(() => _hovering = true),
                  onExit: (_) => setState(() => _hovering = false),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: _hovering ? 220 : 64,
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        _NavItem(
                          icon: Icons.person,
                          label: 'Perfil',
                          expanded: _hovering,
                          selected: true,
                          onTap: () {},
                        ),
                        _NavItem(
                          icon: Icons.settings,
                          label: 'Configuración',
                          expanded: _hovering,
                          selected: false,
                          onTap: () {},
                        ),
                        const Spacer(),
                        _NavItem(
                          icon: Icons.logout,
                          label: 'Cerrar sesión',
                          expanded: _hovering,
                          selected: false,
                          onTap: () { 
                            sessionManager.clear();
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Perfil', style: Theme.of(context).textTheme.headlineMedium),
                        const SizedBox(height: 8),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            _InfoRow(label: 'Usuario', value: username),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
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

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool expanded;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.expanded,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurfaceVariant;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
        child: Row(
          children: [
            Icon(icon, color: color),
            if (expanded) ...[
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(color: color),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 120, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
        Expanded(child: Text(value)),
      ],
    );
  }
}
