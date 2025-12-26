import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:dio/dio.dart';

import '../../core/constants.dart';
import '../../core/utils/responsive_helper.dart';
import '../../shared/widgets/app_sidebar.dart';

import '../auth/domain/providers/auth_provider.dart';
import 'data/models/transaction_request.dart';
import 'domain/providers/category_provider.dart';
import 'data/models/category_request.dart';
import 'data/models/category.dart';
import 'domain/providers/transaction_provider.dart';
import 'domain/providers/dashboard_provider.dart';

import 'data/models/transaction.dart';

class WebAddTransaction extends ConsumerStatefulWidget {
  final bool initialIsExpense;
  final Transaction? transactionToEdit;

  const WebAddTransaction({
    super.key,
    this.initialIsExpense = true,
    this.transactionToEdit,
  });

  @override
  ConsumerState<WebAddTransaction> createState() => _WebAddTransactionState();
}

class _WebAddTransactionState extends ConsumerState<WebAddTransaction> {
  bool _isExpense = true;
  bool _isRecurring = false;
  bool _isActive = true;
  bool _isSubmitting = false;

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _nextExecutionController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  final MapController _mapController = MapController();
  static final LatLng _defaultMapCenter = LatLng(33.5731, -7.5898); // Casablanca as a neutral default.
  LatLng? _selectedLatLng;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<String> _frequencies = ['DAILY', 'WEEKLY', 'MONTHLY', 'YEARLY'];

  int? _selectedCategoryId;
  String? _selectedFrequency;
  
  final Dio _dio = Dio();

  @override
  void initState() {
    super.initState();
    if (widget.transactionToEdit != null) {
      final t = widget.transactionToEdit!;
      _isExpense = t.type == 'EXPENSE';
      _amountController.text = t.amount.toString();
      _descriptionController.text = t.description ?? '';
      _locationController.text = t.location ?? '';
      
      // Format YYYY-MM-DD -> MM/DD/YYYY
      if (t.transactionDate != null) {
        final parts = t.transactionDate.split('-');
        if (parts.length == 3) {
           _dateController.text = '${parts[1]}/${parts[2]}/${parts[0]}';
        }
      }

      _selectedCategoryId = t.category.id;
      _isRecurring = t.isRecurring ?? false;
      _isActive = t.isActive ?? true;
      _selectedFrequency = t.frequency;

      if (t.nextExecutionDate != null) {
        final parts = t.nextExecutionDate!.split('-');
        if (parts.length == 3) {
           _nextExecutionController.text = '${parts[1]}/${parts[2]}/${parts[0]}';
        }
      }

      if (t.endDate != null) {
        final parts = t.endDate!.split('-');
        if (parts.length == 3) {
           _endDateController.text = '${parts[1]}/${parts[2]}/${parts[0]}';
        }
      }
      
      // Parse location string "lat, lng" if available to set map pin
      // _locationController might hold address text or coordinates, assume generic for now
    } else {
      _isExpense = widget.initialIsExpense;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppConstants.appBackgroundColor,
      drawer: !isDesktop ? const Drawer(child: AppSidebar(activeItem: 'Add Entry')) : null,
      body: Row(
        children: [
          if (isDesktop) const AppSidebar(activeItem: 'Add Entry'),
          Expanded(
            child: Column(
              children: [
                _buildTopBar(isDesktop),
                Expanded(child: _buildFormShell(isDesktop)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(bool isDesktop) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppConstants.appBackgroundColor,
        border: const Border(bottom: BorderSide(color: Color(0xFFE6E0D2))),
      ),
      child: Row(
        children: [
          if (!isDesktop)
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.black87),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
          Image.asset('assets/images/beztami_logo.png', height: 48, fit: BoxFit.contain),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildFormShell(bool isDesktop) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isDesktop ? 860 : 640),
          child: _buildFormCard(),
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE6E0D2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 26,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.transactionToEdit != null ? 'Edit Transaction' : 'New Entry',
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: Color(0xFF1B4332)),
          ),
          const SizedBox(height: 8),
          const Text('Capture a new income or expense to keep your finances aligned.', style: TextStyle(color: Color(0xFF6F6F6F))),
          const SizedBox(height: 28),
          _buildEntryTypeToggle(),
          const SizedBox(height: 28),
          _buildSectionLabel('Amount'),
          const SizedBox(height: 12),
          _buildAmountField(),
          const SizedBox(height: 32),
          _buildSectionLabel('Description'),
          const SizedBox(height: 12),
          _buildTonalField(
            child: TextField(
              key: const Key('descField'),
              controller: _descriptionController,
              decoration: InputDecoration(
                hintText: _isExpense ? 'e.g. Coffee with a friend' : 'e.g. Salary',
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 32),
          _buildSectionLabel('Date'),
          const SizedBox(height: 12),
          _buildDateField(_dateController, placeholder: 'Select date', firstDate: DateTime(2000)),
          const SizedBox(height: 32),
          _buildSectionLabel('Category'),
          const SizedBox(height: 12),
          _buildCategoryDropdown(),
          const SizedBox(height: 20),
          _buildSectionLabel('Location'),
          const SizedBox(height: 8),
          _buildTonalField(
            child: TextField(
              controller: _locationController,
              decoration: const InputDecoration(hintText: 'e.g. Carrefour, Restaurant X, Paris', border: InputBorder.none),
            ),
          ),
          const SizedBox(height: 12),
          _buildLocationMap(),
          const SizedBox(height: 24),
          _buildSectionLabel('Recurring'),
          const SizedBox(height: 8),
          Row(
            children: [
              const Expanded(child: Text('Make this transaction recurring', style: TextStyle(color: Color(0xFF6F6F6F)))),
              Switch.adaptive(
                value: _isRecurring,
                activeTrackColor: const Color(0xFF1B5E20),
                activeThumbColor: Colors.white,
                onChanged: (value) => setState(() => _isRecurring = value),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_isRecurring) ...[
            _buildSectionLabel('Frequency'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              key: ValueKey(_selectedFrequency),
              initialValue: _selectedFrequency,
              dropdownColor: Colors.white,
              style: const TextStyle(color: Color(0xFF1B4332), fontWeight: FontWeight.w600),
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF1B4332)),
              decoration: _dropdownDecoration(),
              hint: const Text('Select frequency'),
              items: _frequencies.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
              onChanged: (value) => setState(() => _selectedFrequency = value),
            ),
            const SizedBox(height: 12),
            _buildSectionLabel('Next Execution Date'),
            const SizedBox(height: 8),
            _buildDateField(_nextExecutionController, placeholder: 'Select date', firstDate: DateTime.now()),
            const SizedBox(height: 12),
            _buildSectionLabel('End Date (optional)'),
            const SizedBox(height: 8),
            _buildDateField(_endDateController, placeholder: 'No end date', firstDate: DateTime.now()),
            const SizedBox(height: 12),
            Row(
              children: [
                const Expanded(child: Text('Enable/disable recurrence', style: TextStyle(color: Color(0xFF6F6F6F)))),
                Switch.adaptive(
                  value: _isActive,
                  activeTrackColor: const Color(0xFF1B5E20),
                  activeThumbColor: Colors.white,
                  onChanged: (value) => setState(() => _isActive = value),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
          _buildTipCard(),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              key: const Key('saveTransactionButton'),
              onPressed: _isSubmitting ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isExpense ? const Color(0xFFE53935) : const Color(0xFF1B5E20),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      widget.transactionToEdit != null 
                        ? 'Update Transaction' 
                        : (_isExpense ? 'Confirm Expense' : 'Confirm Income'),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryTypeToggle() {
    return Container(
      decoration: BoxDecoration(
        color: AppConstants.appBackgroundColor,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(6),
      child: Row(
        children: [
          Expanded(
            child: _EntryChip(
              key: const Key('expenseChoice'),
              label: 'Expense',
              isActive: _isExpense,
              activeColor: const Color(0xFFE53935),
              onTap: () => setState(() {
                _isExpense = true;
                _selectedCategoryId = null;
              }),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _EntryChip(
              key: const Key('incomeChoice'),
              label: 'Income',
              isActive: !_isExpense,
              activeColor: const Color(0xFF1B5E20),
              onTap: () => setState(() {
                _isExpense = false;
                _selectedCategoryId = null;
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F1E7),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Icon(
              _isExpense ? Icons.arrow_downward : Icons.arrow_upward,
              color: _isExpense ? const Color(0xFFE53935) : const Color(0xFF1B5E20),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              key: const Key('amountField'),
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(border: InputBorder.none, hintText: 'Enter amount'),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            _isExpense ? 'Expense' : 'Income',
            style: TextStyle(fontWeight: FontWeight.w600, color: _isExpense ? const Color(0xFFE53935) : const Color(0xFF1B5E20)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Color(0xFF8C92A4),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildTonalField({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: const Color(0xFFF5F1E7), borderRadius: BorderRadius.circular(16)),
      child: child,
    );
  }

  Widget _buildLocationMap() {
    final latLng = _selectedLatLng;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 260,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: latLng ?? _defaultMapCenter,
                initialZoom: 12,
                minZoom: 2,
                maxZoom: 18,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.drag | InteractiveFlag.pinchZoom | InteractiveFlag.doubleTapZoom,
                ),
                onTap: (tapPosition, selectedPoint) => _handleMapTap(selectedPoint),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.bezta.my',
                ),
                if (latLng != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        width: 48,
                        height: 48,
                        point: latLng,
                        alignment: Alignment.topCenter,
                        child: Column(
                          children: const [
                            Icon(Icons.location_pin, size: 36, color: Color(0xFF1B5E20)),
                            SizedBox(height: 4),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Icon(Icons.place, size: 18, color: const Color(0xFF1B5E20).withValues(alpha: 0.8)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                latLng == null
                    ? 'Tap anywhere on the map to drop a pin for this transaction.'
                    : 'Selected: ${latLng.latitude.toStringAsFixed(4)}, ${latLng.longitude.toStringAsFixed(4)}',
                style: const TextStyle(color: Color(0xFF4E565B)),
              ),
            ),
            if (latLng != null)
              TextButton(
                onPressed: () => setState(() => _selectedLatLng = null),
                child: const Text('Clear pin'),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateField(TextEditingController controller, {required String placeholder, required DateTime firstDate}) {
    return _buildTonalField(
      child: GestureDetector(
        onTap: () async {
          final theme = Theme.of(context);
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: firstDate,
            lastDate: DateTime(2100),
            builder: (context, child) {
              // Force the picker to use the warm neutral palette used across the rest of the UI.
              const accent = Color(0xFF1B5E20);
              const primaryText = Color(0xFF1B4332);
              final dateTheme = theme.copyWith(
                colorScheme: theme.colorScheme.copyWith(
                  primary: accent,
                  onPrimary: Colors.white,
                  onSurface: primaryText,
                  surface: Colors.white,
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor: accent,
                    textStyle: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                dialogTheme: theme.dialogTheme.copyWith(
                  backgroundColor: Colors.white,
                ),
                datePickerTheme: theme.datePickerTheme.copyWith(
                  backgroundColor: Colors.white,
                  headerBackgroundColor: accent,
                  headerForegroundColor: Colors.white,
                  surfaceTintColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                  dayForegroundColor: WidgetStateProperty.resolveWith(
                    (states) => states.contains(WidgetState.selected) ? Colors.white : primaryText,
                  ),
                  dayOverlayColor: WidgetStateProperty.resolveWith(
                    (states) => states.contains(WidgetState.selected)
                        ? accent.withValues(alpha: 0.12)
                        : accent.withValues(alpha: 0.05),
                  ),
                  todayForegroundColor: WidgetStateProperty.resolveWith(
                    (states) => states.contains(WidgetState.selected) ? Colors.white : accent,
                  ),
                  rangeSelectionOverlayColor: WidgetStatePropertyAll(accent.withValues(alpha: 0.12)),
                ),
              );
              if (child == null) return const SizedBox.shrink();
              return Theme(data: dateTheme, child: child);
            },
          );
          if (picked != null) {
            controller.text = '${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}';
            setState(() {});
          }
        },
        child: Row(
          children: [
            Expanded(
              child: Text(
                controller.text.isEmpty ? placeholder : controller.text,
                style: const TextStyle(color: Color(0xFF4A4F5E)),
              ),
            ),
            const Icon(Icons.calendar_today, size: 18, color: Color(0xFF6E7567)),
          ],
        ),
      ),
    );
  }

  Widget _buildTipCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppConstants.appBackgroundColor, borderRadius: BorderRadius.circular(18)),
      child: Row(
        children: const [
          Icon(Icons.lightbulb_outline, color: Color(0xFF1B5E20)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Tip: give recurring entries a clear category so projections stay accurate.',
              style: TextStyle(color: Color(0xFF5D646F)),
            ),
          ),
        ],
      ),
    );
  }

  void _handleMapTap(LatLng latLng) async {
    setState(() {
      _selectedLatLng = latLng;
      // Show loading or coordinates initially
      _locationController.text = 'Fetching address...';
    });
    
    try {
      final address = await _getAddressFromCoordinates(latLng);
      if (mounted && _selectedLatLng == latLng) {
        setState(() {
          _locationController.text = address;
        });
      }
    } catch (e) {
      if (mounted && _selectedLatLng == latLng) {
         setState(() {
          _locationController.text = '${latLng.latitude.toStringAsFixed(4)}, ${latLng.longitude.toStringAsFixed(4)}';
        });
      }
    }
  }

  Future<String> _getAddressFromCoordinates(LatLng latLng) async {
    try {
      final response = await _dio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'format': 'json',
          'lat': latLng.latitude,
          'lon': latLng.longitude,
        },
        options: Options(
          headers: {'User-Agent': 'BeztaMy/1.0'},
          receiveTimeout: const Duration(seconds: 5),
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null && data['display_name'] != null) {
          return data['display_name'];
        }
      }
      return '${latLng.latitude.toStringAsFixed(4)}, ${latLng.longitude.toStringAsFixed(4)}';
    } catch (e) {
      // Fallback to coordinates on error
      return '${latLng.latitude.toStringAsFixed(4)}, ${latLng.longitude.toStringAsFixed(4)}';
    }
  }

  InputDecoration _dropdownDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFFF5F1E7),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    final categoriesState = ref.watch(categoriesProvider);

    return categoriesState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Text('Error loading categories: $error'),
      data: (allCategories) {
        // Filter categories by type
        final filteredCategories = allCategories
            .where((cat) => cat.type == (_isExpense ? 'EXPENSE' : 'INCOME'))
            .toList();

        if (filteredCategories.isEmpty) {
          return Row(
            children: [
              Expanded(
                child: Text(
                  'No categories available. Please add a category.',
                  style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
                ),
              ),
              const SizedBox(width: 12),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _showAddCategoryDialog(),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B5E20).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF1B5E20).withValues(alpha: 0.2),
                      ),
                    ),
                    child: const Icon(Icons.add, color: Color(0xFF1B5E20)),
                  ),
                ),
              ),
            ],
          );
        }

        // Deduplicate categories by ID to prevent Dropdown crash
        final uniqueCategories = <int, Category>{};
        for (var cat in filteredCategories) {
          uniqueCategories[cat.id] = cat;
        }
        final dedupedList = uniqueCategories.values.toList();

        // Defensive check: Ensure selected ID exists exactly once in the list
        final validSelectedId = dedupedList.any((cat) => cat.id == _selectedCategoryId) 
            ? _selectedCategoryId 
            : null;

        if (validSelectedId == null && _selectedCategoryId != null) {
           // If selected ID is not in the list (e.g. data refresh lag), don't crash, just show hint
        }

        return Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<int>(
                key: ValueKey(validSelectedId), // Use valid ID for key to prevent stale state
                value: validSelectedId,
                dropdownColor: Colors.white,
                style: const TextStyle(color: Color(0xFF1B4332), fontWeight: FontWeight.w600),
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF1B4332)),
                decoration: _dropdownDecoration(),
                hint: const Text('Select category'),
                items: dedupedList
                    .map((cat) => DropdownMenuItem<int>(
                          value: cat.id,
                          child: Text(cat.name),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _selectedCategoryId = value),
              ),
            ),
            const SizedBox(width: 12),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showAddCategoryDialog(),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B5E20).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF1B5E20).withValues(alpha: 0.2),
                    ),
                  ),
                  child: const Icon(Icons.add, color: Color(0xFF1B5E20)),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleSubmit() async {
    // Validation
    if (_amountController.text.trim().isEmpty) {
      _showError('Please enter an amount');
      return;
    }

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      _showError('Please enter a valid amount');
      return;
    }

    if (_selectedCategoryId == null) {
      _showError('Please select a category');
      return;
    }

    if (_dateController.text.trim().isEmpty) {
      _showError('Please select a date');
      return;
    }

    // Parse date from MM/DD/YYYY to yyyy-MM-dd
    final dateParts = _dateController.text.split('/');
    if (dateParts.length != 3) {
      _showError('Invalid date format');
      return;
    }
    final transactionDate = '${dateParts[2]}-${dateParts[0].padLeft(2, '0')}-${dateParts[1].padLeft(2, '0')}';

    // Validate recurring fields
    if (_isRecurring) {
      if (_selectedFrequency == null) {
        _showError('Please select a frequency for recurring transaction');
        return;
      }
      if (_nextExecutionController.text.trim().isEmpty) {
        _showError('Please select next execution date for recurring transaction');
        return;
      }
    }

    setState(() => _isSubmitting = true);

    try {
      final userId = ref.read(userIdProvider);
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Parse next execution date if recurring
      String? nextExecutionDate;
      if (_isRecurring && _nextExecutionController.text.isNotEmpty) {
        final parts = _nextExecutionController.text.split('/');
        if (parts.length == 3) {
          nextExecutionDate = '${parts[2]}-${parts[0].padLeft(2, '0')}-${parts[1].padLeft(2, '0')}';
        }
      }

      // Parse end date if provided
      String? endDate;
      if (_endDateController.text.isNotEmpty) {
        final parts = _endDateController.text.split('/');
        if (parts.length == 3) {
          endDate = '${parts[2]}-${parts[0].padLeft(2, '0')}-${parts[1].padLeft(2, '0')}';
        }
      }

      final request = TransactionRequest(
        categoryId: _selectedCategoryId!,
        type: _isExpense ? 'EXPENSE' : 'INCOME',
        amount: amount,
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
        transactionDate: transactionDate,
        isRecurring: _isRecurring,
        frequency: _isRecurring ? _selectedFrequency : null,
        nextExecutionDate: nextExecutionDate,
        endDate: endDate,
      );

      final transactionService = ref.read(transactionServiceProvider);
      
      if (widget.transactionToEdit != null) {
        await transactionService.updateTransaction(widget.transactionToEdit!.id, request);
      } else {
        await transactionService.createTransaction(userId, request);
      }

      // Invalidate dashboard providers to refresh data
      ref.invalidate(dashboardBalanceProvider);
      ref.invalidate(dashboardRecentTransactionsProvider);
      ref.invalidate(dashboardSpendingCategoriesProvider);
      ref.invalidate(dashboardMonthlySummaryProvider);
      ref.invalidate(transactionsProvider);

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.transactionToEdit != null ? 'Transaction updated successfully!' : 'Transaction created successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back
      if (widget.transactionToEdit != null) {
        context.pop();
      } else {
        context.go('/dashboard');
      }
    } catch (e) {
      if (!mounted) return;
      _showError('Error creating transaction: $e');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showAddCategoryDialog() {
    final nameController = TextEditingController();
    
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing while submitting
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          bool isDialogLoading = false;

          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Text(
              _isExpense ? 'New Expense Category' : 'New Income Category',
              style: const TextStyle(color: Color(0xFF1B4332), fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'NAME',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF7A7A7A)),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: nameController,
                  enabled: !isDialogLoading,
                  decoration: InputDecoration(
                    hintText: 'e.g., Groceries, Salary',
                    filled: true,
                    fillColor: const Color(0xFFF5F1E7),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  autofocus: true,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isDialogLoading ? null : () => Navigator.pop(context),
                child: const Text('Cancel', style: TextStyle(color: Color(0xFF6F6F6F))),
              ),
              ElevatedButton(
                onPressed: isDialogLoading
                    ? null
                    : () async {
                        final name = nameController.text.trim();
                        if (name.isEmpty) return;

                        setDialogState(() => isDialogLoading = true);

                        try {
                          final userId = ref.read(userIdProvider);
                          if (userId == null) return;

                          final request = CategoryRequest(
                            name: name,
                            type: _isExpense ? 'EXPENSE' : 'INCOME',
                            icon: 'code',
                          );

                          final categoryService = ref.read(categoryServiceProvider);
                          final newCategory = await categoryService.createCategory(userId, request);

                          if (!context.mounted) return;

                          // Refresh categories and wait
                          await ref.refresh(categoriesProvider.future);
                          
                          if (!context.mounted) return;
                          Navigator.pop(context);

                          // Set the new category in the main widget
                          if (mounted) {
                            setState(() {
                              _selectedCategoryId = newCategory.id;
                            });
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Category added successfully!'),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        } catch (e) {
                          setDialogState(() => isDialogLoading = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error adding category: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: isDialogLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Add Category', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    _locationController.dispose();
    _nextExecutionController.dispose();
    _endDateController.dispose();
    _mapController.dispose();
    super.dispose();
  }
}

class _EntryChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;

  const _EntryChip({
    super.key,
    required this.label,
    required this.isActive,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: isActive ? activeColor : Colors.transparent, width: 1.5),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.18),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: isActive ? activeColor : const Color(0xFF7A7A7A)),
        ),
      ),
    );
  }
}
