import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/auth_bloc.dart';
import '../models/auth_user.dart';
import '../models/login_request.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/animated_grid_background.dart';
import '../widgets/role_dropdown.dart';
import '../../../shared/widgets/ms_text_field.dart';
import '../../../shared/widgets/ms_primary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  // ── Form ──────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  final _hospitalIdCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  UserRole? _selectedRole;
  bool _obscurePassword = true;

  // ── Animation ─────────────────────────────────────────────
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;
  late final AnimationController _slideCtrl;
  late final Animation<Offset> _slideAnim;

  // ── Aura / ambient ────────────────────────────────────────
  Offset _auraPos = const Offset(0.5, 0.5); // normalised 0–1

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));

    // Stagger entrance
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _fadeCtrl.forward();
        _slideCtrl.forward();
      }
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _slideCtrl.dispose();
    _hospitalIdCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────

  void _handleLogin() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRole == null) {
      _showSnack('Please select your role.', isError: true);
      return;
    }
    FocusScope.of(context).unfocus();
    context.read<AuthBloc>().add(
      AuthLoginEvent(
        LoginRequest(
          hospitalId: _hospitalIdCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
          role: _selectedRole!,
        ),
      ),
    );
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? AppColors.error : AppColors.success,
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthErrorState) {
          _showSnack(state.message, isError: true);
        }
        // Navigation is handled by go_router redirect in AppRouter
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: GestureDetector(
          onPanUpdate: (details) {
            final size = MediaQuery.of(context).size;
            setState(() {
              _auraPos = Offset(
                (details.globalPosition.dx / size.width).clamp(0.0, 1.0),
                (details.globalPosition.dy / size.height).clamp(0.0, 1.0),
              );
            });
          },
          child: Stack(
            children: [
              // ── Animated grid background
              const AnimatedGridBackground(),

              // ── Aura glow following touch
              _AuraGlow(position: _auraPos),

              // ── Moving scan lines
              const _MovingLines(),

              // ── Main content
              SafeArea(
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 800;
                        return isWide
                            ? _WideLayout(formContent: _buildFormCard())
                            : _NarrowLayout(formContent: _buildFormCard());
                      },
                    ),
                  ),
                ),
              ),

              // ── Footer
              const _SiteFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoadingState;
        return Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 390),
          decoration: BoxDecoration(
            color: AppColors.surfaceGlass,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 60,
                offset: const Offset(0, 25),
                spreadRadius: -15,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Card header
                    _CardHeader(),
                    const SizedBox(height: 24),

                    // ── Hospital / Org ID
                    const _FieldLabel('Hospital / Organization ID'),
                    const SizedBox(height: 6),
                    MsTextField(
                      controller: _hospitalIdCtrl,
                      hintText: 'apollo_chennai',
                      prefixIcon: Icons.domain_rounded,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.text,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[a-zA-Z0-9_\-]'),
                        ),
                      ],
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Organisation ID is required'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // ── Email
                    const _FieldLabel('Email Address'),
                    const SizedBox(height: 6),
                    MsTextField(
                      controller: _emailCtrl,
                      hintText: 'name@hospital.com',
                      prefixIcon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Email is required';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
                          return 'Enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // ── Password
                    const _FieldLabel('Password'),
                    const SizedBox(height: 6),
                    MsTextField(
                      controller: _passwordCtrl,
                      hintText: '••••••••',
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _handleLogin(),
                      suffixIcon: GestureDetector(
                        onTap: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                        child: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 18,
                          color: AppColors.textMuted,
                        ),
                      ),
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Password is required'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // ── Role selector
                    const _FieldLabel('Select Role'),
                    const SizedBox(height: 6),
                    RoleDropdown(
                      value: _selectedRole,
                      onChanged: (role) => setState(() => _selectedRole = role),
                    ),
                    const SizedBox(height: 20),

                    // ── Login button
                    MsPrimaryButton(
                      label: 'Login to MediSynC',
                      isLoading: isLoading,
                      onPressed: isLoading ? null : _handleLogin,
                    ),

                    // ── Forgot password link
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: () => context.push('/login/forgot-password'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.textMuted,
                          textStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: const Text('Forgot Password?'),
                      ),
                    ),

                    // ── Divider + Book Demo
                    const SizedBox(height: 4),
                    const Divider(color: AppColors.divider, height: 1),
                    const SizedBox(height: 20),
                    Text(
                      'New hospital to the network?',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: OutlinedButton(
                        onPressed: () => context.push('/login/book-demo'),
                        child: const Text('Book Demo'),
                      ),
                    ),

                    // ── Security badge
                    const SizedBox(height: 20),
                    const _SecurityBadge(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SUB-WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _CardHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Welcome Back',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
            color: AppColors.textMain,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Login to your MediSynC workspace',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.textMain,
      ),
    );
  }
}

class _SecurityBadge extends StatelessWidget {
  const _SecurityBadge();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.lock_rounded, size: 12, color: AppColors.textLight),
        const SizedBox(width: 5),
        Text(
          'Enterprise-grade Encryption',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            color: AppColors.textLight,
          ),
        ),
      ],
    );
  }
}

// ── Wide layout (tablet): branding left + form right ─────────────────────────
class _WideLayout extends StatelessWidget {
  final Widget formContent;
  const _WideLayout({required this.formContent});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Branding panel
        Expanded(
          flex: 6,
          child: Container(
            decoration: const BoxDecoration(
              border: Border(
                right: BorderSide(color: AppColors.cardBorder, width: 1),
              ),
              color: Color(0x4DFFFFFF),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 64),
            child: const _BrandingPanel(),
          ),
        ),
        // Form panel
        Expanded(
          flex: 5,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
              child: formContent,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Narrow layout (phone): form only, centred ────────────────────────────────
class _NarrowLayout extends StatelessWidget {
  final Widget formContent;
  const _NarrowLayout({required this.formContent});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      child: Column(
        children: [
          // Compact logo for mobile
          _MobileLogo(),
          const SizedBox(height: 28),
          formContent,
          const SizedBox(height: 80), // space for footer
        ],
      ),
    );
  }
}

class _MobileLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Medi',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                  color: AppColors.textMain,
                ),
              ),
              TextSpan(
                text: 'SynC.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'by DevÉlan.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}

// ── Branding panel content (wide only) ───────────────────────────────────────
class _BrandingPanel extends StatelessWidget {
  const _BrandingPanel();

  static const _features = [
    'AI Care Gap Detection',
    'Smart Patient Outreach',
    'Risk Stratification Engine',
    'Population Health Analytics',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Logo
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Medi',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                      color: AppColors.textMain,
                    ),
                  ),
                  TextSpan(
                    text: 'SynC.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'by DevÉlan.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 48),

        // Tagline
        Text(
          'Synchronizing Data,\nDoctors, and Patients.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.5,
            height: 1.1,
            color: AppColors.textMain,
          ),
        ),
        const SizedBox(height: 20),

        // Subtitle
        Text(
          'The AI-powered health orchestration platform for proactive '
          'chronic disease monitoring and clinical precision.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            color: AppColors.textMuted,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 36),

        // Feature list
        ..._features.map(
          (f) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  f,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMain,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Animated ambient glow ─────────────────────────────────────────────────────
class _AuraGlow extends StatelessWidget {
  final Offset position; // 0–1 normalised
  const _AuraGlow({required this.position});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Positioned(
      left: position.dx * size.width - 300,
      top: position.dy * size.height - 300,
      child: IgnorePointer(
        child: Container(
          width: 600,
          height: 600,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [AppColors.primary.withOpacity(0.07), Colors.transparent],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Moving scan lines ─────────────────────────────────────────────────────────
class _MovingLines extends StatefulWidget {
  const _MovingLines();
  @override
  State<_MovingLines> createState() => _MovingLinesState();
}

class _MovingLinesState extends State<_MovingLines>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final h = MediaQuery.of(context).size.height;
        return Stack(
          children: [
            _line(0.25, _ctrl.value, h),
            _line(0.75, (_ctrl.value + 0.33) % 1.0, h),
          ],
        );
      },
    );
  }

  Widget _line(double xFraction, double progress, double screenHeight) {
    final offset = (progress * 2 - 1) * screenHeight;
    return Positioned(
      left: MediaQuery.of(context).size.width * xFraction,
      top: offset,
      child: IgnorePointer(
        child: Container(
          width: 1,
          height: screenHeight,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                AppColors.primary.withOpacity(0.12),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Site footer ───────────────────────────────────────────────────────────────
class _SiteFooter extends StatelessWidget {
  const _SiteFooter();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'MediSynC.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF444444),
                    ),
                  ),
                  Text(
                    'Synchronizing Data, Doctors, and Patients.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: const Color(0xFF999999),
                    ),
                  ),
                ],
              ),
              Text(
                'DevÉlan',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF888888),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
