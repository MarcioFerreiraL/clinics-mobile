import 'package:flutter/material.dart';

import '../../../../core/widgets/app_logo.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/input_masks.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool isLoginTab = true;
  bool obscurePassword = true;
  bool loading = false;
  String? errorMessage;
  ApiException? apiError;

  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final cpfController = TextEditingController();
  final emailController = TextEditingController();
  final birthController = TextEditingController();

  @override
  void dispose() {
    phoneController.dispose();
    passwordController.dispose();
    nameController.dispose();
    cpfController.dispose();
    emailController.dispose();
    birthController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: parseBrDate(birthController.text) ?? DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) birthController.text = formatBrDate(picked);
  }

  Future<void> _handleAuth() async {
    final name = nameController.text.trim();
    final phone = onlyDigits(phoneController.text);
    final cpf = onlyDigits(cpfController.text);
    final email = emailController.text.trim();
    final birth = parseBrDate(birthController.text);
    final password = passwordController.text;

    String? problem;
    if (phone.isEmpty || password.isEmpty) {
      problem = 'Preencha todos os campos.';
    } else if (!isLoginTab) {
      if (name.isEmpty ||
          cpf.isEmpty ||
          email.isEmpty ||
          birthController.text.isEmpty) {
        problem = 'Preencha todos os campos.';
      } else if (birth == null || birth.isAfter(DateTime.now())) {
        problem = 'Informe uma data de nascimento válida (dd/mm/aaaa).';
      }
    }
    if (problem != null) {
      setState(() {
        apiError = null;
        errorMessage = problem;
      });
      return;
    }

    setState(() {
      loading = true;
      errorMessage = null;
      apiError = null;
    });
    final auth = ref.read(authProvider.notifier);
    try {
      if (isLoginTab) {
        await auth.login(phone, password);
      } else {
        await auth.register(
          fullName: name,
          phone: phone,
          cpf: cpf,
          email: email,
          birthDate: toIsoDate(birth!),
          password: password,
        );
      }
      if (mounted) context.go('/home');
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          apiError = e;
          errorMessage = e.message;
        });
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.surfaceCanvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            AppLogo(size: 28),
            const SizedBox(width: 8),
            Text(
              'Clinics',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.atmosphericBlue,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on,
                  size: 14,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Surubim, PE',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              Center(child: AppLogo(size: 54)),
              const SizedBox(height: 16),
              Text(
                isLoginTab ? 'Acesse sua conta' : 'Crie sua conta',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Economize e compare exames e clínicas em Surubim.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.slateSecondary,
                ),
              ),
              const SizedBox(height: 24),

              // Segmented Tab Switcher (Entrar / Cadastrar)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => isLoginTab = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isLoginTab
                                ? Colors.white
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(999),
                            boxShadow: isLoginTab
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.05,
                                      ),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Entrar',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: isLoginTab
                                  ? AppColors.primary
                                  : AppColors.slateSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => isLoginTab = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: !isLoginTab
                                ? Colors.white
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(999),
                            boxShadow: !isLoginTab
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.05,
                                      ),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Cadastrar',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: !isLoginTab
                                  ? AppColors.primary
                                  : AppColors.slateSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Form Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderOutline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isLoginTab) ...[
                      Text(
                        'Nome Completo',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.person_outline, size: 20),
                          hintText: 'Ex: Maria da Silva',
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    Text(
                      'WhatsApp ou Celular',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [MaskFormatter.phone],
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.phone_iphone, size: 20),
                        hintText: '(81) 99876-5432',
                        errorText: apiError?.fieldMessage('phone'),
                        suffixIcon: Container(
                          margin: const EdgeInsets.all(8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceMuted,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'DDD 81',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.slateSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    if (!isLoginTab) ...[
                      Text(
                        'CPF',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: cpfController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [MaskFormatter.cpf],
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.badge_outlined,
                            size: 20,
                          ),
                          hintText: '000.000.000-00',
                          errorText: apiError?.fieldMessage('cpf'),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'E-mail',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.email_outlined,
                            size: 20,
                          ),
                          hintText: 'seuemail@exemplo.com',
                          errorText: apiError?.fieldMessage('email'),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Data de nascimento',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: birthController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [MaskFormatter.date],
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.cake_outlined, size: 20),
                          hintText: 'dd/mm/aaaa',
                          errorText: apiError?.fieldMessage('birth_date'),
                          suffixIcon: IconButton(
                            icon: const Icon(
                              Icons.calendar_month_outlined,
                              size: 20,
                            ),
                            onPressed: _pickBirthDate,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    Text(
                      'Sua senha',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock_outline, size: 20),
                        hintText: '••••••••',
                        errorText: apiError?.fieldMessage('password'),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            size: 20,
                            color: AppColors.slateSecondary,
                          ),
                          onPressed: () => setState(
                            () => obscurePassword = !obscurePassword,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    if (errorMessage != null) ...[
                      Text(
                        errorMessage!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    ElevatedButton(
                      onPressed: loading ? null : _handleAuth,
                      child: loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primaryDeep,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  isLoginTab
                                      ? 'Entrar na Conta'
                                      : 'Criar Conta',
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward, size: 18),
                              ],
                            ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Quick skip button
              Center(
                child: TextButton(
                  onPressed: () => context.go('/home'),
                  child: Text(
                    'Entrar como visitante (Apenas comparar)',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'por MárcioDev e Lucas',
                  style: theme.textTheme.bodySmall,
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
