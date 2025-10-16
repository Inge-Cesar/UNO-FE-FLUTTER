import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:jueves/core/di/injection_container.dart';
import 'package:jueves/core/session/session_manager.dart';
import 'package:jueves/features/login/presentation/pages/login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _hovering = false;
  int _selectedIndex = 0; // 0: Perfil, 1: Dashboard, 2: Configuración

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
        
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          body: SafeArea( // SafeArea envuelve el Row
            child: Row(
                  children: [
                    MouseRegion(
                      onEnter: (_) => setState(() => _hovering = true),
                      onExit: (_) => setState(() => _hovering = false),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: _hovering ? 220 : 64,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainer,
                          border: Border(
                            right: BorderSide(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.08)),
                          ),
                        ),
                          child: Column(
                            children: [
                              const SizedBox(height: 24),
                              _NavItem(
                                icon: Icons.person,
                                label: 'Perfil',
                                expanded: _hovering,
                                selected: _selectedIndex == 0,
                                onTap: () => setState(() => _selectedIndex = 0),
                              ),
                              _NavItem(
                                icon: Icons.dashboard,
                                label: 'Dashboard',
                                expanded: _hovering,
                                selected: _selectedIndex == 1,
                                onTap: () => setState(() => _selectedIndex = 1),
                              ),
                              _NavItem(
                                icon: Icons.settings,
                                label: 'Configuración',
                                expanded: _hovering,
                                selected: _selectedIndex == 2,
                                onTap: () {
                                  // Lógica para configuración
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Sección de configuración no implementada.')),
                                  );
                                },
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
                      child: _buildContent(session),
                    ),
                  ],
                ),
          ),
        );
      },
    );
  }

  Widget _buildContent(Session session) {
    switch (_selectedIndex) {
      case 0:
        return _ProfileContent(username: session.userName, userRole: session.userRole);
      case 1:
        // Dashboard basado en el rol del usuario
        switch (session.userRole) {
          case 'admin':
            return _AdminDashboard(session: session);
          case 'student':
            return _StudentDashboard(session: session);
          default:
            return _StudentDashboard(session: session);
        }
      default:
        return _ProfileContent(username: session.userName, userRole: session.userRole);
    }
  }
}

class _ProfileContent extends StatelessWidget {
  final String username;
  final String userRole;
  const _ProfileContent({required this.username, required this.userRole});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.surfaceContainer,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      username.isNotEmpty ? username[0].toUpperCase() : 'U',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Theme.of(context).colorScheme.onPrimary),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(username, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      Text(
                        userRole == 'admin' ? 'Administrador' : 'Estudiante',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.secondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
    final colors = Theme.of(context).colorScheme;
    final color = selected ? colors.primary : colors.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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

class _AdminDashboard extends StatelessWidget {
  final Session session;
  const _AdminDashboard({required this.session});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Panel de Administrador', style: textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text('Resumen general del sistema.', style: textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 24),
          GridView.count(
            shrinkWrap: true, // Para que el GridView no intente ocupar espacio infinito
            physics: const NeverScrollableScrollPhysics(), // Deshabilita el scroll del GridView
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _StatCard(icon: Icons.school_outlined, value: '89', label: 'Cursos Publicados'),
              _StatCard(icon: Icons.show_chart_outlined, value: '\$15,7K', label: 'Ventas (Mes)'),
            ].animate(interval: 100.ms).fadeIn(duration: 300.ms).slideY(begin: 0.5, curve: Curves.easeOut),
          ),
          const SizedBox(height: 16),
          const Expanded(child: _ActivityChart()),
        ],
      ),
    );
  }
}

class _StudentDashboard extends StatelessWidget {
  final Session session;
  const _StudentDashboard({required this.session});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('¡Hola, ${session.userName}!', style: textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text('Panel de Estudiante - ¿Qué te gustaría hacer hoy?', style: textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 24),
          Row(
            children: [
              const Expanded(child: _ProgressChart()),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: _ActionCard(
                  icon: Icons.video_library_outlined,
                  title: 'Continuar tu último curso',
                  subtitle: 'Fundamentos de Flutter - 75% completado',
                  onTap: () {}).animate().fadeIn(duration: 300.ms).slideX(begin: -0.5, curve: Curves.easeOut),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _StatCard({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card( 
      elevation: 0,
      color: colors.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.onSurface.withOpacity(0.1)),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: colors.primary, width: 4))
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: colors.onSurfaceVariant,
                child: Icon(icon, color: colors.onPrimary), // Icono negro
              ),
              Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: colors.onSurface)),
              Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityChart extends StatelessWidget {
  const _ActivityChart();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: colors.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.onSurface.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: CustomPaint(
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: const [
                    FlSpot(0, 3), FlSpot(1, 1), FlSpot(2, 4), FlSpot(3, 2),
                    FlSpot(4, 5), FlSpot(5, 3), FlSpot(6, 4),
                  ],
                  isCurved: true,
                  color: colors.primary,
                  barWidth: 4,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(show: false),
                ),
              ],
            ),
          ),
        ),
      ),
    ); 
  }
}

class _ProgressChart extends StatelessWidget {
  const _ProgressChart();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 0,
              centerSpaceRadius: 45,
              startDegreeOffset: -90,
              sections: [
                PieChartSectionData(
                  color: colors.secondary,
                  value: 75,
                  title: '',
                  radius: 20,
                ),
                PieChartSectionData(
                  color: colors.surfaceVariant,
                  value: 25,
                  title: '',
                  radius: 20,
                ),
              ],
            ),
          ), 
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '75%',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.secondary,
                ),
              ),
              Text(
                'Progreso',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card( 
      elevation: 0,
      color: colors.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.onSurface.withOpacity(0.1)),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: colors.secondary, width: 4))
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(icon, size: 40, color: colors.secondary),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: colors.onSurface)),
                      Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant)),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 16, color: colors.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
