// Écran "Espace Pro — Magasin" refait avec la nouvelle identité visuelle.
//
// Sert d'exemple concret de transformation : comparez avec votre écran actuel
// (fond rouge plein écran, bouton rouge plein) pour voir la différence de
// style une fois AppTheme appliqué + la structure ci-dessous.
//
// Remplace le contenu de votre store_login_screen.dart actuel (ou équivalent).
// La logique de connexion (StoreService.signIn / signInWithGoogle) reste
// identique à ce que vous avez déjà — seule l'UI change ici.

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
// import '../services/store_service.dart'; // votre service existant

class StoreLoginScreen extends StatefulWidget {
  const StoreLoginScreen({super.key});

  @override
  State<StoreLoginScreen> createState() => _StoreLoginScreenState();
}

class _StoreLoginScreenState extends State<StoreLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = true;
  bool _loading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Espace Pro — Magasin')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),

              // Icône dans un cercle doux plutôt qu'affichée nue sur fond
              // rouge plein écran.
              Center(
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.storefront_rounded,
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Text(
                'Reçois les demandes de pièces des clients autour de toi et réponds avec ton prix.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 32),

              // Carte qui regroupe le formulaire — plus de structure visuelle
              // qu'un simple empilement de champs sur fond nu.
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.mail_outline),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Mot de passe',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            activeColor: AppColors.primary,
                            onChanged: (v) =>
                                setState(() => _rememberMe = v ?? true),
                          ),
                          const Text('Se souvenir de moi'),
                        ],
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _error!,
                            style: const TextStyle(
                              color: AppColors.error,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _handleSignIn,
                          child: _loading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Se connecter'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('ou',
                        style: TextStyle(color: Colors.grey.shade500)),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                ],
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _loading ? null : _handleGoogleSignIn,
                  icon: const Icon(Icons.g_mobiledata, size: 28),
                  label: const Text('Continuer avec Google'),
                ),
              ),

              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () {
                    // Navigator.push(...) vers votre écran de création de compte
                  },
                  child: const Text('Créer un compte magasin'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSignIn() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // await StoreService.signIn(
      //   email: _emailController.text.trim(),
      //   password: _passwordController.text,
      //   rememberMe: _rememberMe,
      // );
      // Navigator.pushReplacement(...) vers le tableau de bord magasin
    } catch (e) {
      setState(() => _error = 'Erreur : $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // await StoreService.signInWithGoogle(rememberMe: _rememberMe);
      // Navigator.pushReplacement(...) vers le tableau de bord magasin
    } catch (e) {
      setState(() => _error = 'Erreur : $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
