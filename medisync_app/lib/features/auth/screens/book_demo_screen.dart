import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../widgets/animated_grid_background.dart';
import '../../../shared/widgets/ms_text_field.dart';
import '../../../shared/widgets/ms_primary_button.dart';

class BookDemoScreen extends StatefulWidget {
  const BookDemoScreen({super.key});

  @override
  State<BookDemoScreen> createState() => _BookDemoScreenState();
}

class _BookDemoScreenState extends State<BookDemoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _messageCtrl = TextEditingController(
    text: AppConstants.defaultDemoMessage,
  );
  bool _isLoading = false;

  @override
  void dispose() {
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final uri = Uri(
      scheme: 'mailto',
      path: AppConstants.salesEmail,
      queryParameters: {
        'subject': AppConstants.demoSubject,
        'body': _messageCtrl.text,
      },
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() => _isLoading = false);
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const AnimatedGridBackground(),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        color: AppColors.textMain,
                        onPressed: () => context.pop(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 450),
                        child: Container(
                          padding: const EdgeInsets.all(36),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 60,
                                offset: const Offset(0, 25),
                                spreadRadius: -15,
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Request a Demo',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Ready to synchronize your data? Send us a message and we\'ll get back to you shortly.',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    color: AppColors.textMuted,
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'Your Message',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                MsTextField(
                                  controller: _messageCtrl,
                                  hintText: 'Type your message here...',
                                  maxLines: 5,
                                  minLines: 5,
                                  validator: (v) =>
                                      (v == null || v.trim().isEmpty)
                                      ? 'Please enter a message'
                                      : null,
                                ),
                                const SizedBox(height: 20),
                                MsPrimaryButton(
                                  label: 'Send Request',
                                  isLoading: _isLoading,
                                  onPressed: _isLoading ? null : _send,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
