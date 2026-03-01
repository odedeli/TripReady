import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/trip.dart';
import '../database/database_helper.dart';
import '../theme/app_theme.dart';

class AddEditTripScreen extends StatefulWidget {
  final Trip? trip;

  const AddEditTripScreen({super.key, this.trip});

  @override
  State<AddEditTripScreen> createState() => _AddEditTripScreenState();
}

class _AddEditTripScreenState extends State<AddEditTripScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _destinationController = TextEditingController();
  final _countryController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime? _departureDate;
  DateTime? _returnDate;
  TripType _type = TripType.leisure;
  TripPurpose _purpose = TripPurpose.holiday;
  TripStatus _status = TripStatus.planned;

  bool _isSaving = false;
  bool get _isEditing => widget.trip != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final t = widget.trip!;
      _nameController.text = t.name;
      _destinationController.text = t.destination;
      _countryController.text = t.country ?? '';
      _notesController.text = t.notes ?? '';
      _departureDate = t.departureDate;
      _returnDate = t.returnDate;
      _type = t.type;
      _purpose = t.purpose;
      _status = t.status;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _destinationController.dispose();
    _countryController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isDeparture) async {
    final now = DateTime.now();
    final initial = isDeparture
        ? (_departureDate ?? now)
        : (_returnDate ?? (_departureDate ?? now).add(const Duration(days: 3)));

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2040),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(
            primary: TripReadyTheme.teal,
            onPrimary: Colors.white,
            surface: TripReadyTheme.cream,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() {
        if (isDeparture) {
          _departureDate = picked;
          if (_returnDate != null && _returnDate!.isBefore(picked)) {
            _returnDate = picked.add(const Duration(days: 1));
          }
        } else {
          _returnDate = picked;
        }
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_departureDate == null || _returnDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both departure and return dates.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final db = DatabaseHelper.instance;
      final now = DateTime.now();

      if (_isEditing) {
        final updated = widget.trip!.copyWith(
          name: _nameController.text.trim(),
          destination: _destinationController.text.trim(),
          country: _countryController.text.trim().isEmpty ? null : _countryController.text.trim(),
          departureDate: _departureDate,
          returnDate: _returnDate,
          type: _type,
          purpose: _purpose,
          status: _status,
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
          updatedAt: now,
        );
        await db.updateTrip(updated);
      } else {
        final newTrip = Trip(
          id: const Uuid().v4(),
          name: _nameController.text.trim(),
          destination: _destinationController.text.trim(),
          country: _countryController.text.trim().isEmpty ? null : _countryController.text.trim(),
          departureDate: _departureDate!,
          returnDate: _returnDate!,
          type: _type,
          purpose: _purpose,
          status: _status,
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
          createdAt: now,
          updatedAt: now,
        );
        await db.insertTrip(newTrip);
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving trip: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Trip' : 'New Trip'),
        actions: [
          if (_isSaving)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(right: 16),
                child: SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
              ),
            )
          else
            TextButton(
              onPressed: _save,
              child: const Text('Save', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Trip Name
            _buildLabel('Trip Name *'),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'e.g. Summer in Barcelona',
                prefixIcon: Icon(Icons.luggage_outlined),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Trip name is required' : null,
            ),
            const SizedBox(height: 16),

            // Destination & Country
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Destination *'),
                      TextFormField(
                        controller: _destinationController,
                        decoration: const InputDecoration(
                          hintText: 'City / Region',
                          prefixIcon: Icon(Icons.place_outlined),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Country'),
                      TextFormField(
                        controller: _countryController,
                        decoration: const InputDecoration(hintText: 'Country'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Dates
            _buildLabel('Travel Dates *'),
            Row(
              children: [
                Expanded(
                  child: _DatePickerCard(
                    label: 'Departure',
                    date: _departureDate,
                    formatted: _departureDate != null ? fmt.format(_departureDate!) : null,
                    onTap: () => _pickDate(true),
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.arrow_forward, color: TripReadyTheme.textLight),
                const SizedBox(width: 12),
                Expanded(
                  child: _DatePickerCard(
                    label: 'Return',
                    date: _returnDate,
                    formatted: _returnDate != null ? fmt.format(_returnDate!) : null,
                    onTap: () => _pickDate(false),
                  ),
                ),
              ],
            ),
            if (_departureDate != null && _returnDate != null) ...[
              const SizedBox(height: 8),
              Text(
                '${_returnDate!.difference(_departureDate!).inDays + 1} days',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: TripReadyTheme.teal),
              ),
            ],
            const SizedBox(height: 16),

            // Type & Purpose
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Trip Type'),
                      DropdownButtonFormField<TripType>(
                        value: _type,
                        decoration: const InputDecoration(prefixIcon: Icon(Icons.category_outlined)),
                        items: TripType.values.map((t) => DropdownMenuItem(
                          value: t,
                          child: Text(t.name[0].toUpperCase() + t.name.substring(1)),
                        )).toList(),
                        onChanged: (v) => setState(() => _type = v!),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Purpose'),
                      DropdownButtonFormField<TripPurpose>(
                        value: _purpose,
                        decoration: const InputDecoration(prefixIcon: Icon(Icons.flag_outlined)),
                        items: TripPurpose.values.map((p) {
                          final label = p == TripPurpose.workTrip ? 'Work Trip'
                              : p == TripPurpose.familyVisit ? 'Family Visit'
                              : p.name[0].toUpperCase() + p.name.substring(1);
                          return DropdownMenuItem(value: p, child: Text(label));
                        }).toList(),
                        onChanged: (v) => setState(() => _purpose = v!),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Status (only visible when editing)
            if (_isEditing) ...[
              _buildLabel('Status'),
              DropdownButtonFormField<TripStatus>(
                value: _status,
                decoration: const InputDecoration(prefixIcon: Icon(Icons.toggle_on_outlined)),
                items: TripStatus.values.map((s) => DropdownMenuItem(
                  value: s,
                  child: Text(s.name[0].toUpperCase() + s.name.substring(1)),
                )).toList(),
                onChanged: (v) => setState(() => _status = v!),
              ),
              const SizedBox(height: 16),
            ],

            // Notes
            _buildLabel('Notes (optional)'),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Any notes about this trip...',
                prefixIcon: Icon(Icons.notes_outlined),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 40),

            ElevatedButton.icon(
              onPressed: _isSaving ? null : _save,
              icon: const Icon(Icons.check),
              label: Text(_isEditing ? 'Update Trip' : 'Create Trip'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: Theme.of(context).textTheme.titleSmall),
    );
  }
}

class _DatePickerCard extends StatelessWidget {
  final String label;
  final DateTime? date;
  final String? formatted;
  final VoidCallback onTap;

  const _DatePickerCard({
    required this.label,
    required this.date,
    required this.formatted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: date != null ? TripReadyTheme.teal : TripReadyTheme.warmGrey,
            width: date != null ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(
              formatted ?? 'Select date',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: date != null ? TripReadyTheme.textDark : TripReadyTheme.textLight,
                fontWeight: date != null ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
