import '/backend/schema/enums/enums.dart';
import '/backend/schema/structs/index.dart';
import '/components/prayer_type_card_widget.dart';
import '/custom_code/reminders/prayer_catalog_helper.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';

class ReminderPrayerPicker extends StatefulWidget {
  const ReminderPrayerPicker({
    super.key,
    required this.prayerTypes,
    this.selectedPrayerId,
    this.errorText,
    required this.onPrayerSelected,
    this.maxListHeight = 240.0,
  });

  final List<PrayerTypeStruct> prayerTypes;
  final String? selectedPrayerId;
  final String? errorText;
  final ValueChanged<PrayerStruct> onPrayerSelected;
  final double maxListHeight;

  @override
  State<ReminderPrayerPicker> createState() => _ReminderPrayerPickerState();
}

class _ReminderPrayerPickerState extends State<ReminderPrayerPicker> {
  final List<PrayerTypeStruct> _typeStack = [];
  String _searchQuery = '';

  bool get _isSearching => _searchQuery.trim().isNotEmpty;

  List<PrayerTypeStruct> get _sortedRootTypes =>
      sortedPrayerTypes(widget.prayerTypes);

  PrayerTypeStruct? get _currentType =>
      _typeStack.isEmpty ? null : _typeStack.last;

  List<IconData> _prayerTrailingIcons(PrayerStruct prayer) {
    if (prayer.mode == PrayerMode.audioAndText) {
      return const [Icons.chevron_right_rounded];
    }
    return [
      prayer.mode == PrayerMode.audioOnly
          ? Icons.audiotrack_rounded
          : Icons.text_snippet_rounded,
      Icons.chevron_right_rounded,
    ];
  }

  void _selectPrayer(PrayerStruct prayer) {
    widget.onPrayerSelected(prayer);
  }

  void _openType(PrayerTypeStruct type) {
    if (prayerTypeVisibleItemCount(type) == 0) {
      return;
    }
    if (type.subtypes.isEmpty && type.prayers.length == 1) {
      _selectPrayer(type.prayers.first);
      return;
    }
    setState(() => _typeStack.add(type));
  }

  void _goBack() {
    if (_typeStack.isEmpty) {
      return;
    }
    setState(() => _typeStack.removeLast());
  }

  Widget _buildSelectedPrayerTile(
    BuildContext context,
    PrayerStruct prayer, {
    required VoidCallback onTap,
  }) {
    final theme = FlutterFlowTheme.of(context);
    final selected = widget.selectedPrayerId == prayer.id;
    final title = prayer.title.isNotEmpty ? prayer.title : prayer.subtitle;
    final subtitle = prayer.title.isNotEmpty && prayer.subtitle.isNotEmpty
        ? prayer.subtitle
        : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Material(
        color: selected
            ? theme.primary.withValues(alpha: 0.12)
            : theme.alternate,
        borderRadius: BorderRadius.circular(12.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(12.0),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              border: selected
                  ? Border.all(color: theme.primary, width: 1.5)
                  : null,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.bodyLarge.override(
                          fontFamily: 'Merriweather',
                          color: selected ? theme.primary : theme.primaryText,
                          letterSpacing: 0.0,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      if (subtitle != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2.0),
                          child: Text(
                            subtitle,
                            style: theme.bodySmall.override(
                              fontFamily: 'Inter',
                              color: theme.secondaryText,
                              letterSpacing: 0.0,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (selected)
                  Icon(Icons.check_circle_rounded, color: theme.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final results =
        searchPrayersByTitleOrSubtitle(widget.prayerTypes, _searchQuery);

    if (results.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Text(
          'Nu există rugăciuni cu acest nume.',
          style: theme.bodySmall.override(
            fontFamily: 'Inter',
            color: theme.secondaryText,
            letterSpacing: 0.0,
          ),
        ),
      );
    }

    return Column(
      children: results
          .map(
            (prayer) => _buildSelectedPrayerTile(
              context,
              prayer,
              onTap: () => _selectPrayer(prayer),
            ),
          )
          .toList(),
    );
  }

  Widget _buildRootTypes(BuildContext context) {
    return Column(
      children: _sortedRootTypes.map((type) {
        if (prayerTypeVisibleItemCount(type) == 0) {
          return const SizedBox.shrink();
        }

        if (type.subtypes.isEmpty && type.prayers.length == 1) {
          final prayer = type.prayers.first;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: PrayerTypeCardWidget(
              title: prayer.subtitle.isNotEmpty ? prayer.subtitle : prayer.title,
              trailingIcons: _prayerTrailingIcons(prayer),
              onTap: () => _selectPrayer(prayer),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: PrayerTypeCardWidget(
            title: type.type,
            trailingIcons: const [Icons.chevron_right_rounded],
            onTap: () => _openType(type),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTypeLevel(BuildContext context, PrayerTypeStruct type) {
    final sortedSubtypes = sortedPrayerTypes(type.subtypes);
    final sortedPrayers = type.prayers.toList()
      ..sort((a, b) => a.sequence.compareTo(b.sequence));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...sortedPrayers.map(
          (prayer) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: PrayerTypeCardWidget(
              title: prayer.subtitle.isNotEmpty ? prayer.subtitle : prayer.title,
              trailingIcons: _prayerTrailingIcons(prayer),
              onTap: () => _selectPrayer(prayer),
            ),
          ),
        ),
        ...sortedSubtypes.map((subtype) {
          if (prayerTypeVisibleItemCount(subtype) == 0) {
            return const SizedBox.shrink();
          }

          if (subtype.subtypes.isEmpty && subtype.prayers.length == 1) {
            final prayer = subtype.prayers.first;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: PrayerTypeCardWidget(
                title:
                    prayer.subtitle.isNotEmpty ? prayer.subtitle : prayer.title,
                trailingIcons: _prayerTrailingIcons(prayer),
                onTap: () => _selectPrayer(prayer),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: PrayerTypeCardWidget(
              title: subtype.type,
              trailingIcons: const [Icons.chevron_right_rounded],
              onTap: () => _openType(subtype),
            ),
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final currentType = _currentType;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: 'Caută rugăciune...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            errorText: widget.errorText,
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
              if (_isSearching) {
                _typeStack.clear();
              }
            });
          },
        ),
        if (!_isSearching && currentType != null) ...[
          const SizedBox(height: 8.0),
          Row(
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(Icons.arrow_back_rounded, color: theme.primary),
                onPressed: _goBack,
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  currentType.type,
                  style: theme.titleSmall.override(
                    fontFamily: 'Merriweather',
                    letterSpacing: 0.0,
                  ),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 8.0),
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: widget.maxListHeight),
          child: SingleChildScrollView(
            child: _isSearching
                ? _buildSearchResults(context)
                : currentType == null
                    ? _buildRootTypes(context)
                    : _buildTypeLevel(context, currentType),
          ),
        ),
      ],
    );
  }
}
