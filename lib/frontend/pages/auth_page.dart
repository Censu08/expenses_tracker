import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../backend/blocs/user_bloc.dart';
import '../../core/utils/responsive_utils.dart';
import '../widgets/auth_form_widget.dart';
import '../themes/app_theme.dart';
import '../layouts/main_layout.dart';

class AuthPage extends StatefulWidget {
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        if (state is UserAuthenticated ||
            state is UserLoginSuccess ||
            state is UserRegistrationSuccess) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => MainLayout()),
          );
        } else if (state is UserError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Scaffold(
        body: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Theme.of(context).colorScheme.background,
          ],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: ResponsiveUtils.getPagePadding(context),
            child: _buildAuthCard(context),
          ),
        ),
      ),
    );
  }

  Widget _buildAuthCard(BuildContext context) {
    final maxWidth = ResponsiveUtils.isMobile(context) ? double.infinity : 400.0;

    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Card(
        elevation: 8,
        child: Padding(
          padding: EdgeInsets.all(ResponsiveUtils.isMobile(context) ? 24.0 : 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(context),
              SizedBox(height: ResponsiveUtils.getSpacing(context)),
              AuthFormWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.account_balance_wallet,
          size: ResponsiveUtils.isMobile(context) ? 64 : 80,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 16),
        Text(
          'Expenses Tracker',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Gestisci le tue spese in modo semplice',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}