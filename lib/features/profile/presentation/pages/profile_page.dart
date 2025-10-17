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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool get _isMobile => MediaQuery.of(context).size.width < 768;

  void _showTopNotification(BuildContext context, String message, IconData icon, Color color) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: _isMobile ? MediaQuery.of(context).padding.top + 80 : MediaQuery.of(context).padding.top + 60,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: AnimatedSlide(
            offset: const Offset(0, -1),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutBack,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(0.95),
                    color.withOpacity(0.85),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 25,
                    spreadRadius: 3,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    spreadRadius: 1,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => overlayEntry.remove(),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white70,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // Auto remove after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

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
        
        if (_isMobile) {
          // Layout móvil con Drawer
          return Scaffold(
            key: _scaffoldKey,
            backgroundColor: Theme.of(context).colorScheme.background,
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
              title: Text(_getAppBarTitle()),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () => sessionManager.clear(),
                ),
              ],
            ),
            drawer: _buildMobileDrawer(sessionManager),
            body: _buildContent(session),
          );
        } else {
          // Layout desktop con sidebar
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.background,
            body: SafeArea(
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
                              _showTopNotification(
                                context,
                                'Sección de configuración no implementada.',
                                Icons.info_outline,
                                const Color(0xFFF59E0B),
                              );
                            },
                          ),
                          const Spacer(),
                          _NavItem(
                            icon: Icons.logout,
                            label: 'Cerrar sesión',
                            expanded: _hovering,
                            selected: false,
                            onTap: () => sessionManager.clear(),
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
        }
      },
    );
  }

  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Mi Perfil';
      case 1:
        return 'Dashboard';
      case 2:
        return 'Configuración';
      default:
        return 'Mi Perfil';
    }
  }

  Widget _buildMobileDrawer(SessionManager sessionManager) {
    return ValueListenableBuilder<Session?>(
      valueListenable: sessionManager.currentSession,
      builder: (context, session, child) {
        if (session == null) return const SizedBox.shrink();
        
        return Drawer(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          child: Column(
            children: [
              // Header mejorado con información del usuario
              Container(
                height: 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primary.withOpacity(0.8),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        // Avatar del usuario
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Theme.of(context).colorScheme.onPrimary.withOpacity(0.2),
                              child: Text(
                                session.userName.isNotEmpty ? session.userName[0].toUpperCase() : 'U',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    session.userName,
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      color: Theme.of(context).colorScheme.onPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      session.userRole == 'admin' ? 'Administrador' : 'Estudiante',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context).colorScheme.onPrimary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          'Panel de Control',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Elementos de navegación
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    children: [
                      _MobileNavItem(
                        icon: Icons.person_outline,
                        label: 'Mi Perfil',
                        selected: _selectedIndex == 0,
                        onTap: () {
                          setState(() => _selectedIndex = 0);
                          Navigator.of(context).pop();
                        },
                      ),
                      _MobileNavItem(
                        icon: Icons.dashboard_outlined,
                        label: 'Dashboard',
                        selected: _selectedIndex == 1,
                        onTap: () {
                          setState(() => _selectedIndex = 1);
                          Navigator.of(context).pop();
                        },
                      ),
                      _MobileNavItem(
                        icon: Icons.settings_outlined,
                        label: 'Configuración',
                        selected: _selectedIndex == 2,
                        onTap: () {
                          Navigator.of(context).pop();
                          _showTopNotification(
                            context,
                            'Sección de configuración no implementada.',
                            Icons.info_outline,
                            const Color(0xFFF59E0B),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              // Botón de logout en la parte inferior
              Container(
                padding: const EdgeInsets.all(16.0),
                child: _MobileNavItem(
                  icon: Icons.logout_outlined,
                  label: 'Cerrar Sesión',
                  selected: false,
                  isLogout: true,
                  onTap: () {
                    Navigator.of(context).pop();
                    sessionManager.clear();
                  },
                ),
              ),
            ],
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
    final isMobile = MediaQuery.of(context).size.width < 768;
    
    return Padding(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.surfaceContainer,
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 12.0 : 16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: isMobile ? 24 : 32,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      username.isNotEmpty ? username[0].toUpperCase() : 'U',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: isMobile ? 20 : null,
                      ),
                    ),
                  ),
                  SizedBox(width: isMobile ? 12 : 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          username, 
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: isMobile ? 18 : null,
                          ),
                        ),
                        Text(
                          userRole == 'admin' ? 'Administrador' : 'Estudiante',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: isMobile ? 14 : null,
                          ),
                        ),
                      ],
                    ),
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

class _MobileNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool isLogout;

  const _MobileNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.isLogout = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final color = isLogout 
        ? colors.error 
        : (selected ? colors.primary : colors.onSurfaceVariant);
    final backgroundColor = selected 
        ? colors.primary.withOpacity(0.1) 
        : (isLogout ? colors.error.withOpacity(0.1) : Colors.transparent);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: selected ? Border.all(color: colors.primary.withOpacity(0.3)) : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon, 
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (!isLogout)
                  Icon(
                    Icons.chevron_right,
                    color: color.withOpacity(0.6),
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
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
    final isMobile = MediaQuery.of(context).size.width < 768;
    
    return Padding(
      padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Panel de Administrador', 
            style: textTheme.headlineMedium?.copyWith(
              fontSize: isMobile ? 24 : null,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Resumen general del sistema.', 
            style: textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: isMobile ? 16 : null,
            ),
          ),
          const SizedBox(height: 24),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: isMobile ? 1 : 2,
            crossAxisSpacing: isMobile ? 0 : 16,
            mainAxisSpacing: isMobile ? 12 : 16,
            childAspectRatio: isMobile ? 2.5 : 1.5,
            children: [
              _StatCard(icon: Icons.school_outlined, value: '89', label: 'Cursos Publicados'),
              _StatCard(icon: Icons.show_chart_outlined, value: '\$15,7K', label: 'Ventas (Mes)'),
            ].animate(interval: 100.ms).fadeIn(duration: 300.ms).slideY(begin: 0.5, curve: Curves.easeOut),
          ),
          SizedBox(height: isMobile ? 12 : 16),
          Expanded(child: _ActivityChart()),
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
    final isMobile = MediaQuery.of(context).size.width < 768;
    
    return Padding(
      padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¡Hola, ${session.userName}!', 
            style: textTheme.headlineMedium?.copyWith(
              fontSize: isMobile ? 24 : null,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Panel de Estudiante - ¿Qué te gustaría hacer hoy?', 
            style: textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: isMobile ? 16 : null,
            ),
          ),
          const SizedBox(height: 24),
          if (isMobile) ...[
            // Layout vertical para móvil
            const _ProgressChart(),
            const SizedBox(height: 16),
            _ActionCard(
              icon: Icons.video_library_outlined,
              title: 'Continuar tu último curso',
              subtitle: 'Fundamentos de Flutter - 75% completado',
              onTap: () {},
            ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.5, curve: Curves.easeOut),
          ] else ...[
            // Layout horizontal para desktop
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
                    onTap: () {},
                  ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.5, curve: Curves.easeOut),
                ),
              ],
            ),
          ],
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
    final isMobile = MediaQuery.of(context).size.width < 768;
    
    return Card( 
      elevation: 0,
      color: colors.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        side: BorderSide(color: colors.onSurface.withOpacity(0.1)),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
          border: Border(left: BorderSide(color: colors.primary, width: 4))
        ),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 12.0 : 16.0),
          child: isMobile 
            ? Row(
                children: [
                  CircleAvatar(
                    radius: isMobile ? 16 : 20,
                    backgroundColor: colors.primary,
                    child: Icon(icon, color: colors.onPrimary, size: isMobile ? 18 : 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          value, 
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold, 
                            color: colors.onSurface,
                            fontSize: isMobile ? 20 : null,
                          ),
                        ),
                        Text(
                          label, 
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                            fontSize: isMobile ? 14 : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: colors.primary,
                    child: Icon(icon, color: colors.onPrimary, size: 24),
                  ),
                  Text(
                    value, 
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold, 
                      color: colors.onSurface,
                    ),
                  ),
                  Text(
                    label, 
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
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
    final isMobile = MediaQuery.of(context).size.width < 768;
    
    return Card(
      elevation: 0,
      color: colors.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        side: BorderSide(color: colors.onSurface.withOpacity(0.1)),
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16.0 : 20.0),
        child: SizedBox(
          height: isMobile ? 200 : 150,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: 0,
                  centerSpaceRadius: isMobile ? 35 : 45,
                  startDegreeOffset: -90,
                  sections: [
                    PieChartSectionData(
                      color: colors.secondary,
                      value: 75,
                      title: '',
                      radius: isMobile ? 25 : 20,
                    ),
                    PieChartSectionData(
                      color: colors.surfaceVariant,
                      value: 25,
                      title: '',
                      radius: isMobile ? 25 : 20,
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
                      fontSize: isMobile ? 20 : null,
                    ),
                  ),
                  Text(
                    'Progreso',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: isMobile ? 14 : null,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
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
    final isMobile = MediaQuery.of(context).size.width < 768;
    
    return Card( 
      elevation: 0,
      color: colors.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        side: BorderSide(color: colors.onSurface.withOpacity(0.1)),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
          border: Border(left: BorderSide(color: colors.secondary, width: 4))
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 12.0 : 16.0),
            child: Row(
              children: [
                Icon(
                  icon, 
                  size: isMobile ? 32 : 40, 
                  color: colors.secondary,
                ),
                SizedBox(width: isMobile ? 12 : 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title, 
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold, 
                          color: colors.onSurface,
                          fontSize: isMobile ? 16 : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle, 
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                          fontSize: isMobile ? 13 : null,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios, 
                  size: isMobile ? 14 : 16, 
                  color: colors.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
