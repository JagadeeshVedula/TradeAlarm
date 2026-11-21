import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/top_tokens.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/alarm.dart';
import '../../domain/models/token_pair.dart';
import '../providers/alarm_provider.dart';
import '../widgets/live_preview_card.dart';
import '../widgets/token_picker_modal.dart';

class CreateEditAlarmScreen extends StatefulWidget {
  final Alarm? existingAlarm;

  const CreateEditAlarmScreen({super.key, this.existingAlarm});

  @override
  State<CreateEditAlarmScreen> createState() => _CreateEditAlarmScreenState();
}

class _CreateEditAlarmScreenState extends State<CreateEditAlarmScreen> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();

  late String _selectedChain;
  late TokenOption _selectedToken;
  late CrossDirection _direction;
  late TextEditingController _thresholdController;
  late int _pollingIntervalSec;
  late TextEditingController _noteController;
  late TextEditingController _labelController;
  late bool _enabled;
  late TriggerMode _triggerMode;
  late TextEditingController _hysteresisController;

  bool _isAutoLabel = true;
  TokenPair? _livePair;
  bool _isLoadingPreview = false;
  Timer? _liveRefreshTimer;

  // Popular tokens for quick selection chips
  final List<String> _popularSymbols = [
    'BTC-USD',
    'ETH-USD',
    'SOL-USD',
    'DOGE-USD',
    'PEPE-USD',
    'ARB-USD',
    'LINK-USD',
    'SUI-USD',
    'AVAX-USD',
    'GMX-USD',
  ];

  @override
  void initState() {
    super.initState();
    final existing = widget.existingAlarm;

    _selectedChain = existing?.chain ?? AppConstants.defaultChain;
    _selectedToken = existing != null
        ? TopTokens.findBySymbolOrId(existing.tokenSymbol)
        : TopTokens.list.first;

    _direction = existing?.direction ?? CrossDirection.up;
    _thresholdController = TextEditingController(
      text: existing?.threshold.toString() ?? AppConstants.defaultThreshold.toStringAsFixed(0),
    );
    _pollingIntervalSec = existing?.pollingIntervalSec ?? AppConstants.defaultPollingIntervalSec;
    _noteController = TextEditingController(text: existing?.note ?? '');
    _labelController = TextEditingController(
      text: existing?.label ?? Alarm.generateDefaultLabel(_selectedToken.symbol, _direction, AppConstants.defaultThreshold),
    );
    _enabled = existing?.enabled ?? true;
    _triggerMode = existing?.triggerMode ?? TriggerMode.repeating;
    _hysteresisController = TextEditingController(
      text: existing?.hysteresisBuffer.toString() ?? AppConstants.defaultHysteresisBuffer.toStringAsFixed(0),
    );

    _isAutoLabel = existing == null;

    _loadLivePreview();

    // Live auto-refresh every 10 seconds while viewing the screen
    _liveRefreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted) {
        _loadLivePreview(silent: true);
      }
    });
  }

  @override
  void dispose() {
    _liveRefreshTimer?.cancel();
    _thresholdController.dispose();
    _noteController.dispose();
    _labelController.dispose();
    _hysteresisController.dispose();
    super.dispose();
  }

  void _updateAutoLabel() {
    if (_isAutoLabel) {
      final double thresh = double.tryParse(_thresholdController.text) ?? 55.0;
      _labelController.text = Alarm.generateDefaultLabel(_selectedToken.symbol, _direction, thresh);
    }
  }

  Future<void> _loadLivePreview({bool silent = false}) async {
    if (!silent) {
      setState(() => _isLoadingPreview = true);
    }
    try {
      final provider = Provider.of<AlarmProvider>(context, listen: false);
      await provider.fetchLivePairs();
      
      if (!mounted) return;
      if (provider.livePairs.isNotEmpty) {
        final match = TopTokens.findMatchingPair(_selectedToken.symbol, provider.livePairs);
        if (mounted) {
          setState(() {
            _livePair = match;
            _isLoadingPreview = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoadingPreview = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingPreview = false);
    }
  }

  void _selectToken(TokenOption token) {
    setState(() {
      _selectedToken = token;
      _updateAutoLabel();
    });
    _loadLivePreview();
  }

  Future<void> _openTokenPicker() async {
    final provider = Provider.of<AlarmProvider>(context, listen: false);
    final selected = await TokenPickerModal.show(
      context,
      currentToken: _selectedToken,
      livePairs: provider.livePairs,
    );
    if (selected != null && mounted) {
      _selectToken(selected);
    }
  }

  void _saveAlarm() {
    if (!_formKey.currentState!.validate()) return;

    final threshold = double.parse(_thresholdController.text);
    final hysteresis = double.parse(_hysteresisController.text);

    final alarm = Alarm(
      id: widget.existingAlarm?.id ?? _uuid.v4(),
      chain: _selectedChain,
      tokenSymbol: _selectedToken.symbol,
      label: _labelController.text.trim(),
      direction: _direction,
      threshold: threshold,
      triggerMode: _triggerMode,
      hysteresisBuffer: hysteresis,
      pollingIntervalSec: _pollingIntervalSec,
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      enabled: _enabled,
      armed: widget.existingAlarm?.armed ?? true,
      lastSeenPct: widget.existingAlarm?.lastSeenPct,
      lastTriggeredAt: widget.existingAlarm?.lastTriggeredAt,
      acknowledged: widget.existingAlarm?.acknowledged ?? true,
      createdAt: widget.existingAlarm?.createdAt ?? DateTime.now(),
    );

    final provider = Provider.of<AlarmProvider>(context, listen: false);
    if (widget.existingAlarm == null) {
      provider.addAlarm(alarm);
    } else {
      provider.updateAlarm(alarm);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingAlarm != null;
    final provider = Provider.of<AlarmProvider>(context);

    // Dynamically resolve matching live pair from provider's livePairs
    final dynamicMatch = provider.livePairs.isNotEmpty
        ? TopTokens.findMatchingPair(_selectedToken.symbol, provider.livePairs)
        : null;
    final effectiveLivePair = dynamicMatch ?? _livePair;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Alarm' : 'Create Alarm'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quick Token Selection Chips
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Quick Token Select',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                    ),
                    InkWell(
                      onTap: _openTokenPicker,
                      child: Text(
                        'View all (${provider.allTokens.length}) →',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.accentNeonGreen),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _popularSymbols.length + 1,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      if (index == _popularSymbols.length) {
                        return ActionChip(
                          avatar: const Icon(Icons.search_rounded, size: 16, color: AppTheme.accentNeonGreen),
                          label: Text(
                            'All Tokens (${provider.allTokens.length})',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: AppTheme.accentNeonGreen,
                            ),
                          ),
                          backgroundColor: AppTheme.cardDark,
                          side: const BorderSide(color: AppTheme.accentNeonGreen),
                          onPressed: _openTokenPicker,
                        );
                      }
                      final sym = _popularSymbols[index];
                      final option = TopTokens.findBySymbolOrId(sym, livePairs: provider.livePairs);
                      final isSelected = _selectedToken.symbol == option.symbol;

                      return ChoiceChip(
                        label: Text(
                          option.symbol.split('-').first,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: isSelected ? Colors.black : AppTheme.textPrimary,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: AppTheme.accentNeonGreen,
                        backgroundColor: AppTheme.cardDark,
                        side: BorderSide(
                          color: isSelected ? AppTheme.accentNeonGreen : AppTheme.cardBorderDark,
                        ),
                        onSelected: (selected) {
                          if (selected) _selectToken(option);
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Live Preview Card (Comprehensive live market data)
                LivePreviewCard(
                  symbol: _selectedToken.symbol,
                  tickerId: effectiveLivePair?.tickerId ?? _selectedToken.tickerId,
                  longPct: effectiveLivePair?.longPct ?? 50.0,
                  shortPct: effectiveLivePair?.shortPct ?? 50.0,
                  price: effectiveLivePair?.lastPrice ?? 0.0,
                  longOpenInterestUsd: effectiveLivePair?.longOpenInterestUsd ?? 0.0,
                  shortOpenInterestUsd: effectiveLivePair?.shortOpenInterestUsd ?? 0.0,
                  totalOpenInterestUsd: effectiveLivePair?.totalOpenInterestUsd ?? 0.0,
                  volumeUsd: effectiveLivePair?.volumeUsd ?? 0.0,
                  lastUpdated: provider.lastSyncTime,
                  isLoading: _isLoadingPreview,
                  onRefresh: () => _loadLivePreview(),
                ),
                const SizedBox(height: 24),

                // Chain & Token Dropdowns
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Chain', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedChain,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: AppTheme.cardDark,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.cardBorderDark)),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'Arbitrum', child: Text('Arbitrum')),
                            ],
                            onChanged: (val) => setState(() => _selectedChain = val!),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Token / Market', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                              InkWell(
                                onTap: _openTokenPicker,
                                child: Text(
                                  'Search (${provider.allTokens.length})',
                                  style: const TextStyle(fontSize: 11, color: AppTheme.accentNeonGreen, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: _openTokenPicker,
                            borderRadius: BorderRadius.circular(12),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: AppTheme.cardDark,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.cardBorderDark)),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.cardBorderDark)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                suffixIcon: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.search_rounded, size: 18, color: AppTheme.accentNeonGreen),
                                    SizedBox(width: 2),
                                    Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.textSecondary),
                                    SizedBox(width: 6),
                                  ],
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppTheme.accentPurple.withValues(alpha: 0.25),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      _selectedToken.baseCurrency,
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.accentNeonGreen),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _selectedToken.symbol,
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Cross Direction Toggle
                const Text('Cross Direction', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.arrow_upward_rounded, size: 18),
                            SizedBox(width: 6),
                            Text('Crosses UP'),
                          ],
                        ),
                        selected: _direction == CrossDirection.up,
                        selectedColor: AppTheme.accentNeonGreen.withValues(alpha: 0.25),
                        backgroundColor: AppTheme.cardDark,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _direction = CrossDirection.up;
                              _updateAutoLabel();
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ChoiceChip(
                        label: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.arrow_downward_rounded, size: 18),
                            SizedBox(width: 6),
                            Text('Crosses DOWN'),
                          ],
                        ),
                        selected: _direction == CrossDirection.down,
                        selectedColor: AppTheme.accentRed.withValues(alpha: 0.25),
                        backgroundColor: AppTheme.cardDark,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _direction = CrossDirection.down;
                              _updateAutoLabel();
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Threshold & Polling Interval
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Threshold (%)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _thresholdController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: AppTheme.cardDark,
                              suffixText: '%',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            validator: (val) {
                              if (val == null || val.isEmpty) return 'Required';
                              final d = double.tryParse(val);
                              if (d == null || d < 1 || d > 99) return 'Enter 1 - 99';
                              return null;
                            },
                            onChanged: (_) => _updateAutoLabel(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Polling Cadence', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<int>(
                            initialValue: _pollingIntervalSec,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: AppTheme.cardDark,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            items: const [
                              DropdownMenuItem(value: 15, child: Text('15 sec (Default)')),
                              DropdownMenuItem(value: 30, child: Text('30 sec')),
                              DropdownMenuItem(value: 60, child: Text('1 min')),
                              DropdownMenuItem(value: 300, child: Text('5 min')),
                            ],
                            onChanged: (val) => setState(() => _pollingIntervalSec = val!),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Trigger Mode & Hysteresis Buffer
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Trigger Mode', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<TriggerMode>(
                            initialValue: _triggerMode,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: AppTheme.cardDark,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            items: const [
                              DropdownMenuItem(value: TriggerMode.repeating, child: Text('Repeating')),
                              DropdownMenuItem(value: TriggerMode.oneTime, child: Text('One-time')),
                            ],
                            onChanged: (val) => setState(() => _triggerMode = val!),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Re-arm Buffer (%)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _hysteresisController,
                            keyboardType: TextInputType.number,
                            enabled: _triggerMode == TriggerMode.repeating,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: _triggerMode == TriggerMode.repeating ? AppTheme.cardDark : AppTheme.backgroundDark,
                              suffixText: '%',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            validator: (val) {
                              if (_triggerMode == TriggerMode.repeating) {
                                if (val == null || val.isEmpty) return 'Required';
                                final d = double.tryParse(val);
                                if (d == null || d < 0) return 'Invalid';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Alarm Label
                const Text('Alarm Label', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _labelController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppTheme.cardDark,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onChanged: (_) => _isAutoLabel = false,
                  validator: (val) => (val == null || val.trim().isEmpty) ? 'Enter a label' : null,
                ),
                const SizedBox(height: 20),

                // Note
                const Text('Note (Optional)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _noteController,
                  decoration: InputDecoration(
                    hintText: 'Included in push notification when triggered...',
                    filled: true,
                    fillColor: AppTheme.cardDark,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 20),

                // Enabled Toggle
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.cardDark,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.cardBorderDark),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Enable Alarm Immediately',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      Switch(
                        value: _enabled,
                        activeTrackColor: AppTheme.accentNeonGreen,
                        onChanged: (val) => setState(() => _enabled = val),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _saveAlarm,
                    child: Text(isEditing ? 'Save Alarm Changes' : 'Create Alarm'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
