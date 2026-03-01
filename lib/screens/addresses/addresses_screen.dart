import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import '../../models/trip.dart';
import '../../models/trip_details.dart';
import '../../database/database_helper.dart';
import '../../database/trip_details_database.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

class AddressesScreen extends StatefulWidget {
  final Trip trip;
  const AddressesScreen({super.key, required this.trip});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  List<TripAddress> _addresses = [];
  bool _isLoading = true;
  AddressCategory? _filterCategory;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final addresses = await DatabaseHelper.instance.getAddresses(widget.trip.id);
    setState(() {
      _addresses = addresses;
      _isLoading = false;
    });
  }

  Map<AddressCategory, List<TripAddress>> get _grouped {
    final filtered = _filterCategory != null
        ? _addresses.where((a) => a.category == _filterCategory).toList()
        : _addresses;
    final Map<AddressCategory, List<TripAddress>> grouped = {};
    for (final addr in filtered) {
      grouped.putIfAbsent(addr.category, () => []).add(addr);
    }
    return Map.fromEntries(
      grouped.entries.toList()..sort((a, b) => a.key.name.compareTo(b.key.name)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArchived = widget.trip.isArchived;
    final usedCategories = _addresses.map((a) => a.category).toSet().toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Addresses'),
        actions: [
          if (usedCategories.length > 1)
            PopupMenuButton<AddressCategory?>(
              icon: const Icon(Icons.filter_list_outlined),
              onSelected: (cat) => setState(() => _filterCategory = cat),
              itemBuilder: (_) => [
                const PopupMenuItem(value: null, child: Text('All Categories')),
                const PopupMenuDivider(),
                ...usedCategories.map((c) => PopupMenuItem(
                  value: c,
                  child: Text(c.name[0].toUpperCase() + c.name.substring(1)),
                )),
              ],
            ),
        ],
      ),
      floatingActionButton: isArchived
          ? null
          : FloatingActionButton.extended(
              onPressed: _addAddress,
              icon: const Icon(Icons.add_location_alt_outlined),
              label: const Text('Add Address'),
            ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: TripReadyTheme.teal))
          : _addresses.isEmpty
              ? EmptyState(
                  icon: Icons.place_outlined,
                  title: 'No addresses yet',
                  subtitle: isArchived
                      ? 'This trip is archived.'
                      : 'Add hotels, restaurants, landmarks and more.',
                  buttonLabel: isArchived ? null : 'Add Address',
                  onButtonPressed: isArchived ? null : _addAddress,
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                  itemCount: _grouped.length,
                  itemBuilder: (ctx, i) {
                    final entry = _grouped.entries.elementAt(i);
                    return _AddressCategoryGroup(
                      category: entry.key,
                      addresses: entry.value,
                      isArchived: isArchived,
                      onEdit: _editAddress,
                      onDelete: _deleteAddress,
                      onOpenMap: _openMap,
                      onOpenWebsite: _openWebsite,
                    );
                  },
                ),
    );
  }

  Future<void> _addAddress() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => _AddEditAddressDialog(tripId: widget.trip.id),
    );
    if (result == true) _load();
  }

  Future<void> _editAddress(TripAddress address) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => _AddEditAddressDialog(tripId: widget.trip.id, address: address),
    );
    if (result == true) _load();
  }

  Future<void> _deleteAddress(TripAddress address) async {
    final confirm = await showConfirmDialog(
      context,
      title: 'Delete Address',
      message: 'Delete "${address.name}"?',
      confirmLabel: 'Delete',
    );
    if (confirm == true) {
      await DatabaseHelper.instance.deleteAddress(address.id);
      _load();
    }
  }

  Future<void> _openMap(TripAddress address) async {
    String? urlStr = address.mapLink;
    if (urlStr == null || urlStr.isEmpty) {
      // Build a google maps search URL from the address text
      final query = Uri.encodeComponent(
          '${address.name} ${address.address ?? ''}');
      urlStr = 'https://www.google.com/maps/search/?api=1&query=$query';
    }
    final uri = Uri.parse(urlStr);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open map link.')),
      );
    }
  }

  Future<void> _openWebsite(TripAddress address) async {
    if (address.website == null || address.website!.isEmpty) return;
    final uri = Uri.parse(address.website!);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open website link.')),
      );
    }
  }
}

// ── Category Group ────────────────────────────────────────────
class _AddressCategoryGroup extends StatelessWidget {
  final AddressCategory category;
  final List<TripAddress> addresses;
  final bool isArchived;
  final Function(TripAddress) onEdit;
  final Function(TripAddress) onDelete;
  final Function(TripAddress) onOpenMap;
  final Function(TripAddress) onOpenWebsite;

  const _AddressCategoryGroup({
    required this.category,
    required this.addresses,
    required this.isArchived,
    required this.onEdit,
    required this.onDelete,
    required this.onOpenMap,
    required this.onOpenWebsite,
  });

  IconData get _categoryIcon {
    switch (category) {
      case AddressCategory.hotel: return Icons.hotel_outlined;
      case AddressCategory.airport: return Icons.flight_outlined;
      case AddressCategory.restaurant: return Icons.restaurant_outlined;
      case AddressCategory.landmark: return Icons.account_balance_outlined;
      case AddressCategory.office: return Icons.business_outlined;
      case AddressCategory.hospital: return Icons.local_hospital_outlined;
      case AddressCategory.transport: return Icons.directions_bus_outlined;
      case AddressCategory.shopping: return Icons.shopping_bag_outlined;
      case AddressCategory.other: return Icons.place_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
          child: Row(
            children: [
              Icon(_categoryIcon, size: 14, color: TripReadyTheme.teal),
              const SizedBox(width: 6),
              Text(
                addresses.first.categoryLabel.toUpperCase(),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: TripReadyTheme.teal,
                  letterSpacing: 0.8,
                  fontSize: 11,
                ),
              ),
              const SizedBox(width: 8),
              Text('${addresses.length}',
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
        ...addresses.map((a) => _AddressCard(
              address: a,
              isArchived: isArchived,
              onEdit: () => onEdit(a),
              onDelete: () => onDelete(a),
              onOpenMap: () => onOpenMap(a),
              onOpenWebsite: () => onOpenWebsite(a),
            )),
      ],
    );
  }
}

// ── Address Card ──────────────────────────────────────────────
class _AddressCard extends StatelessWidget {
  final TripAddress address;
  final bool isArchived;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onOpenMap;
  final VoidCallback onOpenWebsite;

  const _AddressCard({
    required this.address,
    required this.isArchived,
    required this.onEdit,
    required this.onDelete,
    required this.onOpenMap,
    required this.onOpenWebsite,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: TripReadyTheme.navy.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.place, color: TripReadyTheme.navy, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(address.name,
                          style: Theme.of(context).textTheme.titleMedium),
                      if (address.address != null) ...[
                        const SizedBox(height: 2),
                        Text(address.address!,
                            style: Theme.of(context).textTheme.bodySmall),
                      ],
                      if (address.phone != null) ...[
                        const SizedBox(height: 2),
                        Row(children: [
                          const Icon(Icons.phone_outlined,
                              size: 12, color: TripReadyTheme.textMid),
                          const SizedBox(width: 4),
                          Text(address.phone!,
                              style: Theme.of(context).textTheme.bodySmall),
                        ]),
                      ],
                    ],
                  ),
                ),
                if (!isArchived)
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert,
                        size: 18, color: TripReadyTheme.textLight),
                    onSelected: (val) {
                      if (val == 'edit') onEdit();
                      if (val == 'delete') onDelete();
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete',
                              style: TextStyle(color: TripReadyTheme.danger))),
                    ],
                  ),
              ],
            ),
            if (address.notes != null) ...[
              const SizedBox(height: 8),
              Text(address.notes!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: TripReadyTheme.textMid)),
            ],
            const SizedBox(height: 10),
            // Action buttons
            Row(
              children: [
                _ActionButton(
                  icon: Icons.map_outlined,
                  label: 'Map',
                  color: TripReadyTheme.teal,
                  onTap: onOpenMap,
                ),
                if (address.website != null) ...[
                  const SizedBox(width: 8),
                  _ActionButton(
                    icon: Icons.language_outlined,
                    label: 'Website',
                    color: TripReadyTheme.navy,
                    onTap: onOpenWebsite,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }
}

// ── Add/Edit Address Dialog ───────────────────────────────────
class _AddEditAddressDialog extends StatefulWidget {
  final String tripId;
  final TripAddress? address;

  const _AddEditAddressDialog({required this.tripId, this.address});

  @override
  State<_AddEditAddressDialog> createState() => _AddEditAddressDialogState();
}

class _AddEditAddressDialogState extends State<_AddEditAddressDialog> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _mapLinkController = TextEditingController();
  final _websiteController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  AddressCategory _category = AddressCategory.other;
  bool _isSaving = false;

  bool get _isEditing => widget.address != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final a = widget.address!;
      _nameController.text = a.name;
      _addressController.text = a.address ?? '';
      _mapLinkController.text = a.mapLink ?? '';
      _websiteController.text = a.website ?? '';
      _phoneController.text = a.phone ?? '';
      _notesController.text = a.notes ?? '';
      _category = a.category;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _mapLinkController.dispose();
    _websiteController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String? _clean(TextEditingController c) =>
      c.text.trim().isEmpty ? null : c.text.trim();

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) return;
    setState(() => _isSaving = true);
    try {
      if (_isEditing) {
        final updated = widget.address!.copyWith(
          name: _nameController.text.trim(),
          address: _clean(_addressController),
          category: _category,
          mapLink: _clean(_mapLinkController),
          website: _clean(_websiteController),
          phone: _clean(_phoneController),
          notes: _clean(_notesController),
        );
        await DatabaseHelper.instance.updateAddress(updated);
      } else {
        final addr = TripAddress(
          id: const Uuid().v4(),
          tripId: widget.tripId,
          name: _nameController.text.trim(),
          address: _clean(_addressController),
          category: _category,
          mapLink: _clean(_mapLinkController),
          website: _clean(_websiteController),
          phone: _clean(_phoneController),
          notes: _clean(_notesController),
          createdAt: DateTime.now(),
        );
        await DatabaseHelper.instance.insertAddress(addr);
      }
      if (mounted) Navigator.pop(context, true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Edit Address' : 'New Address'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name *',
                hintText: 'e.g. Grand Hotel, Eiffel Tower',
                prefixIcon: Icon(Icons.place_outlined),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<AddressCategory>(
              value: _category,
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: AddressCategory.values.map((c) => DropdownMenuItem(
                value: c,
                child: Text(c.name[0].toUpperCase() + c.name.substring(1)),
              )).toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _addressController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Address',
                hintText: 'Street, city, country',
                prefixIcon: Icon(Icons.location_on_outlined),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone',
                hintText: '+1 234 567 8900',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _mapLinkController,
              decoration: const InputDecoration(
                labelText: 'Map Link (optional)',
                hintText: 'https://maps.google.com/...',
                prefixIcon: Icon(Icons.map_outlined),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _websiteController,
              decoration: const InputDecoration(
                labelText: 'Website (optional)',
                hintText: 'https://...',
                prefixIcon: Icon(Icons.language_outlined),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _notesController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                prefixIcon: Icon(Icons.notes_outlined),
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox(width: 18, height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text(_isEditing ? 'Update' : 'Add Address'),
        ),
      ],
    );
  }
}
