import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/reminder.dart';
import '../models/trip_stop.dart';
import '../services/reminder_service.dart';
import '../theme/app_theme.dart';
import 'reminder_section.dart';

/// Sentinel stop indices — stored in reminders.stop_index to identify leg type.
class TripLegIndex {
  static const int departure = -1;
  static const int returnLeg = 999;
}

/// A _leg_ descriptor passed into [_LegBlock].
class _Leg {
  final String label;
  final DateTime? date;
  final int stopIndex;
  final IconData icon;

  const _Leg({
    required this.label,
    required this.date,
    required this.stopIndex,
    required this.icon,
  });
}

/// Renders one collapsible reminder block per trip leg:
///   • Departure  (stopIndex: -1)  — always shown
///   • Stop N     (stopIndex: N)   — shown only if stop has arrivalDate
///   • Return     (stopIndex: 999) — always shown
///
/// Call [commitAll] from the parent's _save() to persist all changes.
class TripLegReminderSection extends StatefulWidget {
  final String? tripId;           // null when creating a new trip
  final String departureCity;
  final DateTime? departureDate;
  final List<TripStop> stops;
  final String? returnCity;
  final DateTime? returnDate;

  final int defaultLeadDays;
  final String defaultTimeOfDay;

  const TripLegReminderSection({
    super.key,
    required this.tripId,
    required this.departureCity,
    required this.departureDate,
    required this.stops,
    required this.returnCity,
    required this.returnDate,
    this.defaultLeadDays  = 1,
    this.defaultTimeOfDay = '08:00',
  });

  @override
  State<TripLegReminderSection> createState() => TripLegReminderSectionState();
}

class TripLegReminderSectionState extends State<TripLegReminderSection> {
  // One GlobalKey per leg — keyed by stopIndex
  final Map<int, GlobalKey<ReminderSectionState>> _keys = {};

  List<_Leg> get _legs {
    final fmt = DateFormat('dd MMM yyyy');
    final legs = <_Leg>[];

    // Departure
    legs.add(_Leg(
      label:      'Departure${widget.departureCity.isNotEmpty ? " · ${widget.departureCity}" : ""}',
      date:       widget.departureDate,
      stopIndex:  TripLegIndex.departure,
      icon:       Icons.flight_takeoff,
    ));

    // Dated stops only
    for (int i = 0; i < widget.stops.length; i++) {
      final stop = widget.stops[i];
      if (stop.arrivalDate == null) continue;
      legs.add(_Leg(
        label:     'Stop ${i + 1} · ${stop.city} (${fmt.format(stop.arrivalDate!)})',
        date:      stop.arrivalDate,
        stopIndex: i,
        icon:      Icons.place_outlined,
      ));
    }

    // Return
    legs.add(_Leg(
      label:      'Return${(widget.returnCity?.isNotEmpty == true) ? " · ${widget.returnCity}" : ""}',
      date:       widget.returnDate,
      stopIndex:  TripLegIndex.returnLeg,
      icon:       Icons.flight_land,
    ));

    return legs;
  }

  GlobalKey<ReminderSectionState> _keyFor(int stopIndex) {
    return _keys.putIfAbsent(stopIndex, () => GlobalKey<ReminderSectionState>());
  }

  /// Called by parent _save() — commit each leg's reminders.
  Future<void> commitAll(String tripId) async {
    for (final leg in _legs) {
      final key = _keys[leg.stopIndex];
      if (key?.currentState != null) {
        await key!.currentState!.commitForRef(tripId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final legs = _legs;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          const Icon(Icons.notifications_outlined, size: 15, color: TripReadyTheme.teal),
          const SizedBox(width: 6),
          const Text('Leg Reminders', style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w600, color: TripReadyTheme.textMid,
          )),
        ]),
        const SizedBox(height: 4),
        if (legs.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text('Set departure and return dates to configure reminders.',
              style: TextStyle(fontSize: 12, color: TripReadyTheme.textLight)),
          )
        else
          ...legs.map((leg) => _LegBlock(
            key:              ValueKey('leg_${leg.stopIndex}'),
            leg:              leg,
            tripId:           widget.tripId,
            sectionKey:       _keyFor(leg.stopIndex),
            stopIndex:        leg.stopIndex,
            defaultLeadDays:  widget.defaultLeadDays,
            defaultTimeOfDay: widget.defaultTimeOfDay,
          )),
      ],
    );
  }
}

// ── Single collapsible leg block ─────────────────────────────────────────────

class _LegBlock extends StatefulWidget {
  final _Leg leg;
  final String? tripId;
  final GlobalKey<ReminderSectionState> sectionKey;
  final int stopIndex;
  final int defaultLeadDays;
  final String defaultTimeOfDay;

  const _LegBlock({
    super.key,
    required this.leg,
    required this.tripId,
    required this.sectionKey,
    required this.stopIndex,
    required this.defaultLeadDays,
    required this.defaultTimeOfDay,
  });

  @override
  State<_LegBlock> createState() => _LegBlockState();
}

class _LegBlockState extends State<_LegBlock> {
  bool _expanded = false;
  bool _hasReminder = false;

  @override
  void initState() {
    super.initState();
    _checkHasReminder();
  }

  Future<void> _checkHasReminder() async {
    if (widget.tripId == null) return;
    final reminders = await ReminderService.instance.getForRef(
      ReminderRefType.tripStop, widget.tripId!,
    );
    final has = reminders.any((r) =>
        r.stopIndex == widget.stopIndex && r.isEnabled);
    if (mounted) setState(() => _hasReminder = has);
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM yyyy');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: _hasReminder
              ? TripReadyTheme.amber.withOpacity(0.4)
              : TripReadyTheme.warmGrey,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          // ── Leg header row ──────────────────────────────────────
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(children: [
                Icon(widget.leg.icon, size: 15,
                    color: _hasReminder ? TripReadyTheme.amber : TripReadyTheme.teal),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.leg.label,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      if (widget.leg.date != null)
                        Text(fmt.format(widget.leg.date!),
                          style: const TextStyle(fontSize: 11, color: TripReadyTheme.textLight)),
                      if (widget.leg.date == null)
                        const Text('No date set — reminder unavailable',
                          style: TextStyle(fontSize: 11, color: TripReadyTheme.textLight,
                              fontStyle: FontStyle.italic)),
                    ],
                  ),
                ),
                if (_hasReminder)
                  Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: TripReadyTheme.amber.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('ON',
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800,
                          color: TripReadyTheme.amber, letterSpacing: 0.5)),
                  ),
                Icon(_expanded ? Icons.expand_less : Icons.expand_more,
                    size: 18, color: TripReadyTheme.textLight),
              ]),
            ),
          ),

          // ── Expanded reminder section ───────────────────────────
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: ReminderSection(
                key:     widget.sectionKey,
                refType: ReminderRefType.tripStop,
                refId:   widget.tripId,
                stopIndex: widget.stopIndex,
                defaultLeadDays:  widget.defaultLeadDays,
                defaultTimeOfDay: widget.defaultTimeOfDay,
              ),
            ),
        ],
      ),
    );
  }
}
