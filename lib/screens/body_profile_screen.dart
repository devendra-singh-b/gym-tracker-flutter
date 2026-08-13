import 'package:flutter/material.dart';

import '../database_helper.dart';

class BodyProfileScreen extends StatefulWidget {
  const BodyProfileScreen({super.key});

  @override
  State<BodyProfileScreen> createState() => _BodyProfileScreenState();
}

class _BodyProfileScreenState extends State<BodyProfileScreen> {
  final TextEditingController _heightController =
      TextEditingController();

  final TextEditingController _weightController =
      TextEditingController();

  double? _currentWeight;
  List<Map<String, dynamic>> _weightHistory = [];

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final profile =
        await DatabaseHelper.instance.getBodyProfile();

    final latestWeight =
        await DatabaseHelper.instance.getLatestWeight();

    final history =
        await DatabaseHelper.instance.getWeightHistory();

    if (!mounted) return;

    setState(() {
  if (profile != null && profile['height'] != null) {
    _heightController.text =
        (profile['height'] as num).toString();
  }

  if (latestWeight != null) {
    final weightValue = latestWeight['weight'];

    if (weightValue is num) {
      _currentWeight = weightValue.toDouble();
    } else {
      _currentWeight = null;
    }
  } else {
    _currentWeight = null;
  }

  _weightHistory = history;
  _loading = false;
});
  }

  Future<void> _saveHeight() async {
    final height =
        double.tryParse(_heightController.text.trim());

    if (height == null || height <= 0) {
      _showMessage('Please enter a valid height.');
      return;
    }

    await DatabaseHelper.instance.saveHeight(height);

    if (!mounted) return;

    _showMessage('Height saved');
  }

  Future<void> _addWeight() async {
    final weight =
        double.tryParse(_weightController.text.trim());

    if (weight == null || weight <= 0) {
      _showMessage('Please enter a valid weight.');
      return;
    }

    await DatabaseHelper.instance.addWeight(weight);

    _weightController.clear();

    await _loadProfile();

    if (!mounted) return;

    _showMessage('Weight added');
  }

  Future<void> _editHeight() async {
    _heightController.text =
        _heightController.text.trim();

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Height'),
          content: TextField(
            controller: _heightController,
            keyboardType:
                const TextInputType.numberWithOptions(
              decimal: true,
            ),
            decoration: const InputDecoration(
              labelText: 'Height',
              suffixText: 'cm',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () async {
                final height = double.tryParse(
                  _heightController.text.trim(),
                );

                if (height == null || height <= 0) {
                  _showMessage('Please enter a valid height.');
                  return;
                }

                await DatabaseHelper.instance
                    .saveHeight(height);

                if (!context.mounted) return;

                Navigator.pop(context);
                setState(() {});
                _showMessage('Height updated');
              },
              child: const Text('SAVE'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteWeight(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Weight?'),
          content: const Text(
            'Do you want to delete this weight entry?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text(
                'DELETE',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    await DatabaseHelper.instance.deleteWeight(id);

    await _loadProfile();

    if (!mounted) return;

    _showMessage('Weight deleted');
  }

  String _formatDate(String value) {
    final date = DateTime.tryParse(value);

    if (date == null) {
      return value;
    }

    return '${date.day.toString().padLeft(2, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.year}';
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Body Profile'),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: _loadProfile,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Height',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _heightController
                                          .text
                                          .isEmpty
                                      ? 'Not set'
                                      : '${_heightController.text} cm',
                                  style: const TextStyle(
                                    fontSize: 22,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.edit_outlined,
                                ),
                                tooltip: 'Edit height',
                                onPressed: _editHeight,
                              ),
                            ],
                          ),
                          if (_heightController.text.isEmpty)
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                onPressed: _saveHeight,
                                child:
                                    const Text('SAVE HEIGHT'),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Current Weight',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _currentWeight == null
                                ? 'Not set'
                                : '${_currentWeight!.toStringAsFixed(1)} kg',
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _weightController,
                            keyboardType:
                                const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Enter weight',
                              suffixText: 'kg',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _addWeight,
                              icon: const Icon(Icons.add),
                              label:
                                  const Text('ADD WEIGHT'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Weight History',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  if (_weightHistory.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'No weight history found.',
                        ),
                      ),
                    )
                  else
                    ..._weightHistory.map(
                      (entry) {
                        final weight =
                            (entry['weight'] as num)
                                .toDouble();

                        final date =
                            entry['recordedDate']
                                ?.toString() ??
                            '';

                        return Card(
                          child: ListTile(
                            leading: const CircleAvatar(
                              child: Icon(
                                Icons.monitor_weight_outlined,
                              ),
                            ),
                            title: Text(
                              '${weight.toStringAsFixed(1)} kg',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              _formatDate(date),
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                              tooltip: 'Delete weight',
                              onPressed: () {
                                final id =
                                    entry['id'] as int?;

                                if (id != null) {
                                  _deleteWeight(id);
                                }
                              },
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
    );
  }
}
