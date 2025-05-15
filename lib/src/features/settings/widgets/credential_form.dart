import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CredentialForm extends StatefulWidget {
  final Function(String clientId, String clientSecret) onSave;
  final bool hasExistingCredentials;

  const CredentialForm({
    super.key,
    required this.onSave,
    required this.hasExistingCredentials,
  });

  @override
  CredentialFormState createState() => CredentialFormState();
}

class CredentialFormState extends State<CredentialForm> {
  final _formKey = GlobalKey<FormState>();
  final _clientIdController = TextEditingController();
  final _clientSecretController = TextEditingController();
  
  bool _obscureSecret = true;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    // If no existing credentials, expand the form by default
    _isExpanded = !widget.hasExistingCredentials;
  }

  @override
  void dispose() {
    _clientIdController.dispose();
    _clientSecretController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      widget.onSave(
        _clientIdController.text.trim(),
        _clientSecretController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text(
              widget.hasExistingCredentials
                  ? 'Update Credentials'
                  : 'Configure Credentials',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            subtitle: Text(
              widget.hasExistingCredentials
                  ? 'Update your existing API credentials'
                  : 'Set up your API credentials to get started',
            ),
            trailing: IconButton(
              icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _clientIdController,
                      decoration: InputDecoration(
                        labelText: 'Client ID',
                        prefixIcon: const Icon(Icons.key),
                        border: const OutlineInputBorder(),
                        helperText: 'Your 42 OAuth application Client ID',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.paste),
                          tooltip: 'Paste from clipboard',
                          onPressed: () async {
                            final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
                            if (clipboardData != null && clipboardData.text != null) {
                              _clientIdController.text = clipboardData.text!;
                            }
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your Client ID';
                        }
                        if (value.length < 10) {
                          return 'Client ID seems too short';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _clientSecretController,
                      obscureText: _obscureSecret,
                      decoration: InputDecoration(
                        labelText: 'Client Secret',
                        prefixIcon: const Icon(Icons.lock),
                        border: const OutlineInputBorder(),
                        helperText: 'Your 42 OAuth application Client Secret',
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(_obscureSecret ? Icons.visibility : Icons.visibility_off),
                              onPressed: () {
                                setState(() {
                                  _obscureSecret = !_obscureSecret;
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.paste),
                              tooltip: 'Paste from clipboard',
                              onPressed: () async {
                                final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
                                if (clipboardData != null && clipboardData.text != null) {
                                  _clientSecretController.text = clipboardData.text!;
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your Client Secret';
                        }
                        if (value.length < 10) {
                          return 'Client Secret seems too short';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _submitForm,
                        icon: const Icon(Icons.save),
                        label: Text(
                          widget.hasExistingCredentials
                              ? 'Update Credentials'
                              : 'Save Credentials',
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Theme.of(context).colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Your credentials are stored securely on this device and never shared',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }
}
