

import 'package:flutter/material.dart';
void main() => runApp(const MyApp());
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: const MultiStepFormScreen(),
    );
  }
}


class MultiStepFormScreen extends StatefulWidget {
  const MultiStepFormScreen({super.key});
  @override
  State<MultiStepFormScreen> createState() => _MultiStepFormScreenState();
}
class _MultiStepFormScreenState extends State<MultiStepFormScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
  void _nextStep() {
    if (_formKey.currentState!.validate()) {
      if (_currentStep < 1) {
        setState(() => _currentStep++);
      }
    }
  }
  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }


  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Submission Successful!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Multi-Step Registration Form'),
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          type: StepperType.vertical,
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep < 1) {
              _nextStep();
            } else {
              _submitForm();
            }
          },
          onStepCancel: _currentStep > 0 ? _previousStep : null,
          steps: [
            Step(
              title: const Text('Account'),
              isActive: _currentStep >= 0,
              state: _currentStep > 0 ? StepState.complete: StepState.indexed,
              content: Column(
                children: [
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (_currentStep != 0) return null;
                      if (value == null || !RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                        return 'Please enter a valid email address.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (value) {
                      if (_currentStep != 0) return null;
                      if (value == null || value.length < 8) {
                        return 'Password must be at least 8 characters long.';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            Step(
              title: const Text('Personal Details'),
              isActive: _currentStep >= 1,
              state: _currentStep > 1 ? StepState.complete : StepState.indexed,
              content: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Full Name'),
                    validator: (value) {
                      if (_currentStep != 1) return null;
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: 'Phone Number'),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (_currentStep != 1) return null;
                      if (value == null || value.length < 10) {
                        return 'Please enter a valid phone number.';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
