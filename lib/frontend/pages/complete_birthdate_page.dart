import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../backend/blocs/user_bloc.dart';
import '../../backend/models/user_model.dart';

class CompleteBirthdatePage extends StatefulWidget {
  final UserModel user;

  const CompleteBirthdatePage({super.key, required this.user});

  @override
  State<CompleteBirthdatePage> createState() => _CompleteBirthdatePageState();
}

class _CompleteBirthdatePageState extends State<CompleteBirthdatePage> {
  DateTime? _selectedDate;

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('it', 'IT'),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  void _submit() {
    if (_selectedDate == null) {
      // Mostra un SnackBar di errore
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleziona una data di nascita'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Invia l'evento al BLoC
    context.read<UserBloc>().add(
      CompleteBirthdateEvent(
        userId: widget.user.id,
        birthdate: _selectedDate!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Completa il tuo profilo'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Benvenuto!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Per completare la registrazione, inserisci la tua data di nascita',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ListTile(
              title: Text(
                _selectedDate == null
                    ? 'Seleziona data di nascita'
                    : 'Data: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _selectDate,
              tileColor: Colors.grey[200],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Continua'),
            ),
          ],
        ),
      ),
    );
  }
}