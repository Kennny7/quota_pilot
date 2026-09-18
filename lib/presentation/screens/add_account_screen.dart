// lib/presentation/screens/add_account_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/account.dart';
import '../../domain/entities/service_definition.dart';
import '../providers/account_providers.dart';
import '../widgets/service_dropdown.dart';

class AddAccountScreen extends ConsumerStatefulWidget {
  const AddAccountScreen({super.key});

  @override
  ConsumerState<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends ConsumerState<AddAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _apiKeyController = TextEditingController();

  ServiceDefinition? _service;
  AccountAuthType _authType = AccountAuthType.apiKey;
  bool _obscureKey = true;
  bool _saving = false;

  @override
  void dispose() {
    _emailController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  bool get _needsApiKey =>
      _authType == AccountAuthType.apiKey && (_service?.supportsApiKey ?? false);

  void _onServiceChanged(ServiceDefinition? service) {
    setState(() {
      _service = service;
      if (service != null && !service.supportsApiKey) {
        _authType = AccountAuthType.manual;
      }
    });
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final service = _service;
    if (service == null) return;

    setState(() => _saving = true);
    try {
      await ref.read(accountsProvider.notifier).add(
            email: _emailController.text.trim(),
            serviceId: service.id,
            authType: _authType,
            apiKey: _needsApiKey ? _apiKeyController.text.trim() : null,
          );
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not add account: $error')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Add account')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Account email / label',
                hintText: 'you@example.com',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.alternate_email),
              ),
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) return 'Email is required';
                if (!text.contains('@')) return 'Enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: 16),
            ServiceDropdown(
              value: _service,
              onChanged: _onServiceChanged,
            ),
            const SizedBox(height: 24),
            Text('Authentication', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            SegmentedButton<AccountAuthType>(
              segments: [
                ButtonSegment<AccountAuthType>(
                  value: AccountAuthType.apiKey,
                  label: const Text('API key'),
                  icon: const Icon(Icons.key_outlined),
                  enabled: _service?.supportsApiKey ?? true,
                ),
                const ButtonSegment<AccountAuthType>(
                  value: AccountAuthType.manual,
                  label: Text('Manual'),
                  icon: Icon(Icons.edit_outlined),
                ),
              ],
              selected: {_authType},
              onSelectionChanged: (selection) =>
                  setState(() => _authType = selection.first),
            ),
            const SizedBox(height: 16),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _needsApiKey
                  ? TextFormField(
                      key: const ValueKey('api-key'),
                      controller: _apiKeyController,
                      obscureText: _obscureKey,
                      autofillHints: const [AutofillHints.password],
                      decoration: InputDecoration(
                        labelText: 'API key',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.vpn_key_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureKey
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () =>
                              setState(() => _obscureKey = !_obscureKey),
                        ),
                      ),
                      validator: (value) {
                        if (!_needsApiKey) return null;
                        if ((value ?? '').trim().isEmpty) {
                          return 'API key is required';
                        }
                        return null;
                      },
                    )
                  : Container(
                      key: const ValueKey('manual-hint'),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 18,
                            color: theme.colorScheme.outline,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'You will enter the quota values manually from '
                              'the account detail screen.',
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              label: Text(_saving ? 'Saving…' : 'Save account'),
            ),
          ],
        ),
      ),
    );
  }
}