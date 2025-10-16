import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/di/injection_container.dart';
import '../bloc/login_bloc.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../../core/theme/dark_gradient_background.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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
          top: false,
          bottom: false,
          child: Stack(
            children: [
              const _AnimatedBackground(),
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: _LoginForm(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _LoginForm(BuildContext context) {
    // Usamos un StatefulWidget para manejar el estado de _obscureText
    return _LoginFormBody(
        formKey: _formKey, emailController: _emailController, passwordController: _passwordController);
  }
}

class _LoginFormBody extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const _LoginFormBody({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
  });

  @override
  State<_LoginFormBody> createState() => _LoginFormBodyState();
}

class _LoginFormBodyState extends State<_LoginFormBody> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
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
        return ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const _LoginHeader(),
              const SizedBox(height: 48),
              ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: Colors.white.withOpacity(0.12)),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 20, spreadRadius: 2),
                      ],
                    ),
                    child: Form(
                      key: widget.formKey, // Accede a través de widget porque estamos en un State
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: widget.emailController,
                            enabled: !isLoading,
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [AutofillHints.username],
                            style: TextStyle(color: colors.onSurface),
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.person_outline, color: colors.onSurfaceVariant),
                              hintText: 'tu@email.com',
                              hintStyle: TextStyle(color: colors.onSurfaceVariant.withOpacity(0.7)),
                            ),
                            validator: (v) => (v?.isEmpty ?? true) ? 'Ingresa tu usuario' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: widget.passwordController,
                            enabled: !isLoading,
                            obscureText: _obscure,
                            autofillHints: const [AutofillHints.password],
                            style: TextStyle(color: colors.onSurface),
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.lock_outline, color: colors.onSurfaceVariant),
                              hintText: '••••••••',
                              hintStyle: TextStyle(color: colors.onSurfaceVariant.withOpacity(0.7)),
                              suffixIcon: IconButton(
                                icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: colors.onSurfaceVariant),
                                onPressed: () => setState(() => _obscure = !_obscure),
                              ),
                            ),
                            validator: (v) => (v?.isEmpty ?? true) ? 'Ingresa tu contraseña' : null,
                          ),
                          const SizedBox(height: 24),
                          _LoginButton(
                            isLoading: isLoading,
                            onPressed: () {
                              if (widget.formKey.currentState!.validate()) { // Accede a través de widget
                                context.read<LoginBloc>().add(LoginSubmitted(
                                      email: widget.emailController.text.trim(),
                                      password: widget.passwordController.text.trim(),
                                    ));
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.5),
            ],
          ),
        );
      },
    );
  }
}

class _LoginHeader extends StatelessWidget {
  const _LoginHeader();
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: Transform.rotate(
            angle: 3.14 / 4,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  colors: [Color(0xFFF2B33D), Color(0xFFF29A2E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Transform.rotate(
                angle: -3.14 / 4,
                child: Icon(Icons.school_outlined, size: 40, color: colors.onPrimary),
              ),
            ),
          ),
        ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(duration: 3.seconds, begin: const Offset(1, 1), end: const Offset(1.05, 1.05), curve: Curves.easeInOut),
        const SizedBox(height: 24),
        Text('Bienvenido', style: Theme.of(context).textTheme.displaySmall?.copyWith(color: colors.onSurface, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Accede a tu cuenta', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: colors.onSurfaceVariant, fontWeight: FontWeight.w300)),
      ],
    ).animate().fadeIn(delay: 200.ms).slideY(begin: -0.5);
  }
}

class _LoginButton extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onPressed;
  const _LoginButton({required this.isLoading, required this.onPressed});

  @override
  State<_LoginButton> createState() => _LoginButtonState();
}

class _LoginButtonState extends State<_LoginButton> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: AnimatedScale(
        scale: _isHovering ? 1.03 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: SizedBox(
          height: 64,
          child: ElevatedButton(
            onPressed: widget.isLoading ? null : widget.onPressed,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              elevation: 8,
              shadowColor: const Color(0xFFF2B33D).withOpacity(0.5),
            ),
            child: Ink(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF2B33D), Color(0xFFF29A2E), Color(0xFFF2B33D)],
                  stops: [0.0, 0.5, 1.0],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Container(
                alignment: Alignment.center,
                child: widget.isLoading
                    ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 3, color: colors.onPrimary))
                    : Text(
                        'Iniciar Sesión',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: colors.onPrimary, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedBackground extends StatelessWidget {
  const _AnimatedBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const DarkGradientBackground(),
        ...List.generate(20, (index) => const _Particle()),
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(-0.8, -0.5),
                radius: 1.0,
                colors: [Color(0xFFF2B33D), Colors.transparent],
              ),
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true)).fadeOut(duration: 8.seconds, curve: Curves.easeInOut),
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.8, 0.5),
                radius: 1.0,
                colors: [Color(0xFFF29A2E), Colors.transparent],
              ),
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true)).fadeOut(duration: 10.seconds, curve: Curves.easeInOut),
      ],
    );
  }
}

class _Particle extends StatelessWidget {
  const _Particle();

  @override
  Widget build(BuildContext context) {
    final random = Random();
    return Animate(
      onPlay: (c) => c.repeat(),
      effects: [
        MoveEffect(
          delay: (1 + 4 * random.nextDouble()).seconds,
          duration: (5 + 10 * random.nextDouble()).seconds,
          begin: const Offset(0, 100),
          end: const Offset(0, -1200),
          curve: Curves.linear,
        ),
        FadeEffect(
          delay: (1 + 4 * random.nextDouble()).seconds,
          duration: (5 + 10 * random.nextDouble()).seconds,
          begin: 0.0,
          end: 1.0,
          curve: const Interval(0.0, 0.1, curve: Curves.easeOut),
        ),
        FadeEffect(
          delay: (1 + 4 * random.nextDouble()).seconds,
          duration: (5 + 10 * random.nextDouble()).seconds,
          begin: 1.0,
          end: 0.0,
          curve: const Interval(0.9, 1.0, curve: Curves.easeIn),
        ),
      ],
      child: Align(
        alignment: Alignment(random.nextDouble() * 2.0 - 1.0, 1.1),
        child: Container(
          width: 2,
          height: 2,
          decoration: const BoxDecoration(
            color: Color(0xFFF2B33D),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
