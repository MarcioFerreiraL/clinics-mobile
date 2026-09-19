import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLoginTab = true;
  bool isPhoneMethod = true;
  bool obscurePassword = true;

  final phoneController = TextEditingController(text: '(81) 99876-5432');
  final passwordController = TextEditingController(text: '123456');
  final nameController = TextEditingController();

  @override
  void dispose() {
    phoneController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.dispose();
  }

  void _handleAuth() {
    // Navigate to Home
    context.go('/home');
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
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.atmosphericBlue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.health_and_safety, color: AppColors.primary, size: 20),
            ),
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
                const Icon(Icons.location_on, size: 14, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(
                  'Surubim, PE',
                  style: theme.textTheme.labelSmall?.copyWith(color: AppColors.primary),
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
              Center(
                child: Container(
                  width: 54,
                  height: 54,
                  decoration: const BoxDecoration(
                    color: AppColors.atmosphericBlue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.health_and_safety, size: 28, color: AppColors.primary),
                ),
              ),
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
                            color: isLoginTab ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(999),
                            boxShadow: isLoginTab
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Entrar',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: isLoginTab ? AppColors.primary : AppColors.slateSecondary,
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
                            color: !isLoginTab ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(999),
                            boxShadow: !isLoginTab
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Cadastrar',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: !isLoginTab ? AppColors.primary : AppColors.slateSecondary,
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
                    // Phone vs Email pill selector
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Acessar com:',
                          style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceMuted,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () => setState(() => isPhoneMethod = true),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isPhoneMethod ? Colors.white : Colors.transparent,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Telefone',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: isPhoneMethod ? AppColors.primary : AppColors.slateSecondary,
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => setState(() => isPhoneMethod = false),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: !isPhoneMethod ? Colors.white : Colors.transparent,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'E-mail',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: !isPhoneMethod ? AppColors.primary : AppColors.slateSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (!isLoginTab) ...[
                      Text('Nome Completo', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
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
                      isPhoneMethod ? 'WhatsApp ou Celular' : 'Seu E-mail',
                      style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: phoneController,
                      keyboardType: isPhoneMethod ? TextInputType.phone : TextInputType.emailAddress,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          isPhoneMethod ? Icons.phone_iphone : Icons.email_outlined,
                          size: 20,
                        ),
                        hintText: isPhoneMethod ? '(81) 99876-5432' : 'seuemail@exemplo.com',
                        suffixIcon: isPhoneMethod
                            ? Container(
                                margin: const EdgeInsets.all(8),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceMuted,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'DDD 81',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.slateSecondary),
                                ),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 14),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Sua senha', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                        if (isLoginTab)
                          TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Esqueci a senha',
                              style: theme.textTheme.labelSmall?.copyWith(color: AppColors.primary),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock_outline, size: 20),
                        hintText: '••••••••',
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword ? Icons.visibility_off : Icons.visibility,
                            size: 20,
                            color: AppColors.slateSecondary,
                          ),
                          onPressed: () => setState(() => obscurePassword = !obscurePassword),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: _handleAuth,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(isLoginTab ? 'Entrar na Conta' : 'Criar Conta'),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, size: 18),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Social logins
              Row(
                children: [
                  const Expanded(child: Divider(color: AppColors.borderOutline)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('ou acesse com', style: theme.textTheme.bodySmall),
                  ),
                  const Expanded(child: Divider(color: AppColors.borderOutline)),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: AppColors.borderOutline),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: _handleAuth,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('gov.br', style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(width: 6),
                          Text('Conta Única', style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: AppColors.borderOutline),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: _handleAuth,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.g_mobiledata, size: 24, color: Colors.blue),
                          const SizedBox(width: 4),
                          Text('Google', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ],
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
            ],
          ),
        ),
      ),
    );
  }
}
