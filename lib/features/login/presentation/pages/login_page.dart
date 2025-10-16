import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/di/injection_container.dart';
import '../bloc/login_bloc.dart';
import '../../../../core/theme/theme_manager.dart';
import '../../../profile/presentation/pages/profile_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LoginBloc>(
      create: (_) => sl<LoginBloc>(),
      child: Scaffold(
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bool isWide = constraints.maxWidth > 600;
              final content = Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(context),
                          const SizedBox(height: 32),
                          _buildForm(context),
                        ],
                      ),
                    ),
                  ),
                ),
              );
              return isWide
                  ? Row(
                      children: [
                        Expanded(child: _LoginHero()),
                        Expanded(child: content),
                      ],
                    )
                  : content;
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Iniciar sesión', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Ingresa tus credenciales para continuar', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
            ],
          ),
        ),
        ValueListenableBuilder<ThemeMode>(
          valueListenable: sl<ThemeManager>().themeMode,
          builder: (context, currentMode, child) {
            final isDark = currentMode == ThemeMode.dark ||
                (currentMode == ThemeMode.system && MediaQuery.of(context).platformBrightness == Brightness.dark);
            return IconButton(
              icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
              onPressed: () => sl<ThemeManager>().toggleTheme(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildForm(BuildContext context) {
    return BlocConsumer<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is LoginSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Inicio de sesión exitoso')),
          );
          Future.delayed(const Duration(seconds: 1), () {
            if (!mounted) return;
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const ProfilePage()),
            );
          });
        } else if (state is LoginError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is LoginLoading;
        return Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Usuario', style: TextStyle(fontWeight: FontWeight.w500)).animate().fadeIn(delay: 200.ms).slideX(),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.text,
                autofillHints: const [AutofillHints.username],
                validator: (value) { 
                  final v = (value ?? '').trim();
                  if (v.isEmpty) return 'Ingresa tu usuario';
                  return null;
                },
                enabled: !isLoading,
              ),
              const SizedBox(height: 16),
              const Text('Contraseña', style: TextStyle(fontWeight: FontWeight.w500)).animate().fadeIn(delay: 300.ms).slideX(),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  hintText: '••••••••',
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _obscure = !_obscure),
                    icon: _obscure ? const Text('👀', style: TextStyle(fontSize: 22)) : const Text('🤫', style: TextStyle(fontSize: 22)),
                  ),
                ),
                obscureText: _obscure,
                autofillHints: const [AutofillHints.password],
                validator: (value) {
                  final v = (value ?? '').trim();
                  if (v.isEmpty) return 'Ingresa tu contraseña';
                  return null;
                },
                enabled: !isLoading,
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  icon: isLoading
                      ? const SizedBox(
                          width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.login),
                  label: Text(isLoading ? 'Ingresando...' : 'Ingresar'),
                  onPressed: isLoading
                      ? null
                      : () {
                          if (_formKey.currentState!.validate()) {
                            context.read<LoginBloc>().add(LoginSubmitted(
                                  email: _emailController.text.trim(),
                                  password: _passwordController.text.trim(),
                                ));
                          }
                        },
                ),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.5),
            ],
          ),
        );
      },
    );
  }
}

class _LoginHero extends StatefulWidget {
  @override
  State<_LoginHero> createState() => _LoginHeroState();
}

class _LoginHeroState extends State<_LoginHero> {
  Offset _offset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (event) {
        final renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox == null || !renderBox.hasSize) return;
        final size = renderBox.size;
        final x = (event.localPosition.dx - size.width / 2) / size.width;
        final y = (event.localPosition.dy - size.height / 2) / size.height;
        setState(() {
          _offset = Offset(x, y); 
        });
      },
      onExit: (_) => setState(() => _offset = Offset.zero),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.identity()..setEntry(3, 2, 0.001) // Perspectiva 3D
          ..rotateY(_offset.dx * -0.25)
          ..rotateX(_offset.dy * 0.25),
        transformAlignment: FractionalOffset.center,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          gradient: RadialGradient(
            center: Alignment(_offset.dx * 0.5, _offset.dy * 0.5),
            radius: 1.5,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(1.0),
              Theme.of(context).colorScheme.primary.withOpacity(0.8),
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(48.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  transform: Matrix4.translationValues(_offset.dx * 20, _offset.dy * 20, 0),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                    border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: Offset(_offset.dx * -30, _offset.dy * -30),
                      )
                    ],
                  ),
                  child: Icon(
                    Icons.school_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Bienvenido a tu Espacio',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Tu plataforma educativa para alcanzar tus metas académicas',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
