import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/models/order.dart';

class AddressScreen extends ConsumerStatefulWidget {
  const AddressScreen({super.key});

  @override
  ConsumerState<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends ConsumerState<AddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _address1Ctrl = TextEditingController();
  final _address2Ctrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _zipCtrl = TextEditingController();
  String _selectedCountry = 'India';

  static const _countries = [
    'India',
    'United Arab Emirates',
    'United Kingdom',
    'United States',
    'Pakistan',
    'Other',
  ];

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _address1Ctrl.dispose();
    _address2Ctrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _zipCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final address = ShippingAddress(
      firstName: _firstNameCtrl.text.trim(),
      lastName: _lastNameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      address1: _address1Ctrl.text.trim(),
      address2: _address2Ctrl.text.trim().isEmpty
          ? null
          : _address2Ctrl.text.trim(),
      city: _cityCtrl.text.trim(),
      province: _stateCtrl.text.trim(),
      zip: _zipCtrl.text.trim(),
      country: _selectedCountry,
    );
    Navigator.of(context).pop(address);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shipping Address')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Delivery Details', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: _Field(
                    controller: _firstNameCtrl,
                    label: 'First Name',
                    validator: _required,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _Field(
                    controller: _lastNameCtrl,
                    label: 'Last Name',
                    validator: _required,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            _Field(
              controller: _phoneCtrl,
              label: 'Phone Number',
              keyboardType: TextInputType.phone,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                if (v.trim().length < 10) return 'Enter a valid phone number';
                return null;
              },
            ),
            const SizedBox(height: 12),

            _Field(
              controller: _address1Ctrl,
              label: 'Address Line 1',
              validator: _required,
            ),
            const SizedBox(height: 12),

            _Field(
              controller: _address2Ctrl,
              label: 'Address Line 2 (optional)',
            ),
            const SizedBox(height: 12),

            _Field(
              controller: _cityCtrl,
              label: 'City',
              validator: _required,
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _Field(
                    controller: _stateCtrl,
                    label: 'State / Province',
                    validator: _required,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _Field(
                    controller: _zipCtrl,
                    label: 'Postal Code',
                    keyboardType: TextInputType.number,
                    validator: _required,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Country picker
            DropdownButtonFormField<String>(
              value: _selectedCountry,
              items: _countries
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _selectedCountry = v);
              },
              decoration: const InputDecoration(labelText: 'Country'),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                child: const Text('Confirm Address'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _required(String? v) {
    if (v == null || v.trim().isEmpty) return 'This field is required';
    return null;
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  const _Field({
    required this.controller,
    required this.label,
    this.validator,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      decoration: InputDecoration(labelText: label),
    );
  }
}
