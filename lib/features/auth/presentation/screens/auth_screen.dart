import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/user_model.dart';
import '../../../admin/main/presentation/screens/admin_main_screen.dart';
import '../../../employee/main/presentation/screens/employee_main_screen.dart';
import '../providers/auth_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _isLogin = true;
  bool _obscurePassword = true;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Login Controllers
  final TextEditingController _loginIdentifierController = TextEditingController();
  final TextEditingController _loginPasswordController = TextEditingController();

  // Register Controllers
  final TextEditingController _registerNameController = TextEditingController();
  final TextEditingController _registerEmailController = TextEditingController();
  final TextEditingController _registerPasswordController = TextEditingController();

  @override
  void dispose() {
    _loginIdentifierController.dispose();
    _loginPasswordController.dispose();
    _registerNameController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    super.dispose();
  }

  void _toggleMode(bool isLogin) {
    if (_isLogin == isLogin) return;
    setState(() {
      _isLogin = isLogin;
      _formKey.currentState?.reset();
      _loginIdentifierController.clear();
      _loginPasswordController.clear();
      _registerNameController.clear();
      _registerEmailController.clear();
      _registerPasswordController.clear();
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).clearSnackBars();
      
      try {
        if (_isLogin) {
          final String email = _loginIdentifierController.text.trim();
          final String password = _loginPasswordController.text.trim();
          await ref.read(authProvider.notifier).login(email, password);
        } else {
          final userData = UserData(
            email: _registerEmailController.text.trim(),
            password: _registerPasswordController.text.trim(),
            name: _registerNameController.text.trim(),
            id: '', 
            employeeId: '', 
            role: UserRole.karyawan,
            isVerified: false,
          );
          await ref.read(authProvider.notifier).register(userData);
        }
        
        if (!mounted) return;
        
        final authState = ref.read(authProvider);
        
        if (authState.error != null) {
          final isSuccessMessage = authState.error!.contains('berhasil') || authState.error!.contains('Link reset');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authState.error!),
              backgroundColor: isSuccessMessage ? Colors.green : Colors.redAccent,
            ),
          );
          
          if (isSuccessMessage && !_isLogin) {
            _toggleMode(true); 
          }
        } else if (authState.user != null) {
          final user = authState.user!;
          if (user.role == UserRole.admin) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute<void>(builder: (context) => const AdminMainScreen()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute<void>(builder: (context) => const EmployeeMainScreen()),
            );
          }
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan sistem: $e')),
        );
      }
    }
  }

  void _showForgotPasswordDialog() {
    final TextEditingController forgotEmailController = TextEditingController();
    final forgotFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final authState = ref.watch(authProvider);
          return AlertDialog(
            title: const Text("Lupa Password"),
            content: Form(
              key: forgotFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Masukkan email terdaftar Anda untuk menerima link reset password.",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: forgotEmailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: "Email Anda",
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return "Email wajib diisi";
                      if (!value.contains('@')) return "Format email tidak valid";
                      return null;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Batal"),
              ),
              ElevatedButton(
                onPressed: authState.isLoading 
                  ? null 
                  : () async {
                      if (forgotFormKey.currentState!.validate()) {
                        final email = forgotEmailController.text.trim();
                        
                        await ref.read(authProvider.notifier).forgotPassword(email);
                        
                        if (!context.mounted) return;
                        
                        final finalState = ref.read(authProvider);
                        final isSuccess = finalState.error?.contains('dikirim') == true;
                        
                        if (isSuccess) {
                          Navigator.pop(context);
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(finalState.error ?? "Terjadi kesalahan"),
                            backgroundColor: isSuccess ? Colors.green : Colors.redAccent,
                            duration: const Duration(seconds: 4),
                          ),
                        );
                      }
                    },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                child: authState.isLoading 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text("Kirim Email"),
              ),
            ],
          );
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AuthState authState = ref.watch(authProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Icon(Icons.business_center, size: 80, color: Colors.indigo),
              const SizedBox(height: 16),
              Text(
                _isLogin ? "System login" : "Register Akun",
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              Text(
                _isLogin ? "Silahkan masuk ke akun Anda" : "Lengkapi data untuk pendaftaran",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              // Tab Login/Register
              Container(
                decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _toggleMode(true),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _isLogin ? Colors.indigo : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text("LOGIN", style: TextStyle(color: _isLogin ? Colors.white : Colors.grey.shade700, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _toggleMode(false),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !_isLogin ? Colors.indigo : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text("REGISTER", style: TextStyle(color: !_isLogin ? Colors.white : Colors.grey.shade700, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    if (_isLogin) ...[
                      // Login Email Field
                      TextFormField(
                        controller: _loginIdentifierController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          hintText: "Email Terdaftar",
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: (String? value) {
                          if (value == null || value.isEmpty) return "Email wajib diisi";
                          if (!value.contains('@')) return "Format email tidak valid";
                          return null;
                        },
                      ),
                    ] else ...[
                      // Register Fields
                      TextFormField(
                        controller: _registerNameController,
                        decoration: const InputDecoration(hintText: "Nama Lengkap", prefixIcon: Icon(Icons.person_outline)),
                        validator: (value) => (value == null || value.isEmpty) ? "Nama Lengkap wajib diisi" : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _registerEmailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(hintText: "Email", prefixIcon: Icon(Icons.email_outlined)),
                        validator: (value) {
                          if (value == null || value.isEmpty) return "Email wajib diisi";
                          if (!value.contains('@')) return "Format email tidak valid";
                          return null;
                        },
                      ),
                    ],
                    const SizedBox(height: 16),
                    // Password Field (Common for both)
                    TextFormField(
                      controller: _isLogin ? _loginPasswordController : _registerPasswordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: "Password",
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (value) => (value == null || value.length < 6) ? "Password minimal 6 karakter" : null,
                    ),
                  ],
                ),
              ),
              if (_isLogin)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _showForgotPasswordDialog,
                    child: const Text("Lupa Password?"),
                  ),
                ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: authState.isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: authState.isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(_isLogin ? "MASUK" : "DAFTAR", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              if (!_isLogin)
                const Padding(
                  padding: EdgeInsets.only(top: 16.0),
                  child: Text(
                    "Pendaftaran akan ditinjau oleh Admin",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
