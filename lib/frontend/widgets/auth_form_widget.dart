import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../backend/blocs/user_bloc.dart';
import '../../core/utils/responsive_utils.dart';

class AuthFormWidget extends StatefulWidget {
  @override
  State<AuthFormWidget> createState() => _AuthFormWidgetState();
}

class _AuthFormWidgetState extends State<AuthFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();

  bool _isLogin = true;
  bool _isPasswordVisible = false;
  DateTime _selectedBirthdate = DateTime.now();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _surnameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        final isLoading = state is UserLoading;

        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildToggleButtons(context),
              const SizedBox(height: 24),

              // Google Sign-In Button
              _buildGoogleSignInButton(context, isLoading),

              const SizedBox(height: 24),
              _buildDivider(context),
              const SizedBox(height: 24),

              // Form fields
              if (!_isLogin) ...[
                _buildNameField(),
                const SizedBox(height: 16),
                _buildSurnameField(),
                const SizedBox(height: 16),
                _buildBirthdateField(context),
                const SizedBox(height: 16),
              ],

              _buildEmailField(),
              const SizedBox(height: 16),
              _buildPasswordField(),

              const SizedBox(height: 24),
              _buildSubmitButton(context, isLoading),

              if (_isLogin) ...[
                const SizedBox(height: 16),
                _buildForgotPasswordButton(context),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildToggleButtons(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleButton(context, 'Accedi', _isLogin, () {
              setState(() => _isLogin = true);
            }),
          ),
          Expanded(
            child: _buildToggleButton(context, 'Registrati', !_isLogin, () {
              setState(() => _isLogin = false);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(
      BuildContext context,
      String text,
      bool isSelected,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleSignInButton(BuildContext context, bool isLoading) {
    return ElevatedButton.icon(
      onPressed: isLoading ? null : _handleGoogleSignIn,
      icon: Image.asset(
        'assets/images/google_logo.png',
        height: 20,
        width: 20,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.login),
      ),
      label: Text(_isLogin ? 'Accedi con Google' : 'Registrati con Google'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        side: BorderSide(color: Colors.grey.shade300),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'oppure',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(child: Divider()),
      ],
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: 'Nome',
        prefixIcon: Icon(Icons.person),
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Nome richiesto';
        }
        if (value.trim().length < 2) {
          return 'Nome troppo corto';
        }
        return null;
      },
    );
  }

  Widget _buildSurnameField() {
    return TextFormField(
      controller: _surnameController,
      decoration: const InputDecoration(
        labelText: 'Cognome',
        prefixIcon: Icon(Icons.person_outline),
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Cognome richiesto';
        }
        if (value.trim().length < 2) {
          return 'Cognome troppo corto';
        }
        return null;
      },
    );
  }

  Widget _buildBirthdateField(BuildContext context) {
    return InkWell(
      onTap: () => _selectBirthdate(context),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Data di nascita',
          prefixIcon: Icon(Icons.calendar_today),
          border: OutlineInputBorder(),
        ),
        child: Text(
          _selectedBirthdate != null
              ? '${_selectedBirthdate!.day}/${_selectedBirthdate!.month}/${_selectedBirthdate!.year}'
              : 'Seleziona data',
          style: TextStyle(
            color: _selectedBirthdate != null
                ? Theme.of(context).colorScheme.onSurface
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
        labelText: 'Email',
        prefixIcon: Icon(Icons.email),
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Email richiesta';
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Email non valida';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _handleSubmit(),
      decoration: InputDecoration(
        labelText: 'Password',
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility),
          onPressed: () {
            setState(() => _isPasswordVisible = !_isPasswordVisible);
          },
        ),
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Password richiesta';
        }
        if (!_isLogin && value.length < 6) {
          return 'Password deve essere di almeno 6 caratteri';
        }
        return null;
      },
    );
  }

  Widget _buildSubmitButton(BuildContext context, bool isLoading) {
    return ElevatedButton(
      onPressed: isLoading ? null : _handleSubmit,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: isLoading
          ? const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      )
          : Text(_isLogin ? 'Accedi' : 'Registrati'),
    );
  }

  Widget _buildForgotPasswordButton(BuildContext context) {
    return TextButton(
      onPressed: _handleForgotPassword,
      child: const Text('Password dimenticata?'),
    );
  }

  Future<void> _selectBirthdate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedBirthdate ?? DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() => _selectedBirthdate = date);
    }
  }

  void _handleGoogleSignIn() {
    context.read<UserBloc>().add(const GoogleSignInEvent());
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final userBloc = context.read<UserBloc>();

    if (_isLogin) {
      userBloc.add(LoginUserEvent(
        email: _emailController.text,
        password: _passwordController.text,
      ));
    } else {
      userBloc.add(RegisterUserEvent(
        email: _emailController.text,
        password: _passwordController.text,
        name: _nameController.text,
        surname: _surnameController.text,
        birthdate: _selectedBirthdate,
      ));
    }
  }

  void _handleForgotPassword() {
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inserisci la tua email prima di richiedere il reset'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    context.read<UserBloc>().add(ResetPasswordEvent(email: _emailController.text));
  }
}