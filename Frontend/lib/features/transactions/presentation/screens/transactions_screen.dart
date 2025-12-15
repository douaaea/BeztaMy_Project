import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../shared/widgets/app_sidebar.dart';
import '../../../../shared/widgets/user_avatar_menu.dart';
import '../../domain/providers/transaction_provider.dart';
import '../../domain/providers/category_provider.dart';
import '../../domain/providers/dashboard_provider.dart';
import '../../data/models/transaction.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Widget _buildTransactionCard(Transaction transaction) {
    final isIncome = transaction.type == 'INCOME';
    final icon = _getCategoryIcon(transaction.category.icon);
    final title = transaction.category.name;
    final subtitle = '${transaction.transactionDate} • ${transaction.description ?? transaction.category.name}';
    final amount = isIncome
        ? '+\$${transaction.amount.toStringAsFixed(2)}'
        : '-\$${transaction.amount.toStringAsFixed(2)}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isIncome ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              icon,
              color: isIncome ? const Color(0xFF4CAF50) : const Color(0xFFE53935),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Color(0xFF171A1F),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isIncome ? const Color(0xFF4CAF50) : const Color(0xFFE53935),
                ),
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () => _showTransactionDetails(context, transaction),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Details',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Color(0xFF2196F3),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showTransactionDetails(BuildContext context, Transaction transaction) {
    final isIncome = transaction.type == 'INCOME';
    final color = isIncome ? const Color(0xFF4CAF50) : const Color(0xFFE53935);
    final icon = _getCategoryIcon(transaction.category.icon);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 400,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
               // Header with colored card look
               Container(
                 height: 120,
                 width: double.infinity,
                 color: color.withOpacity(0.1),
                 child: Stack(
                   children: [
                     Positioned(
                       right: 16,
                       top: 16,
                       child: IconButton(
                         icon: const Icon(Icons.close, color: Colors.grey),
                         onPressed: () => Navigator.pop(context),
                       ),
                     ),
                     Center(
                       child: Container(
                         padding: const EdgeInsets.all(16),
                         decoration: BoxDecoration(
                           color: Colors.white,
                           shape: BoxShape.circle,
                           boxShadow: [
                             BoxShadow(
                               color: color.withOpacity(0.2),
                               blurRadius: 15,
                               offset: const Offset(0, 5),
                             ),
                           ],
                         ),
                         child: Icon(icon, size: 40, color: color),
                       ),
                     ),
                   ],
                 ),
               ),
               
               Padding(
                 padding: const EdgeInsets.all(24),
                 child: Column(
                   children: [
                     Text(
                       transaction.category.name,
                       style: const TextStyle(
                         fontSize: 22,
                         fontWeight: FontWeight.bold,
                         color: Color(0xFF171A1F),
                       ),
                     ),
                     const SizedBox(height: 8),
                     Text(
                       (isIncome ? '+' : '-') + '\$${transaction.amount.toStringAsFixed(2)}',
                       style: TextStyle(
                         fontSize: 32,
                         fontWeight: FontWeight.bold,
                         color: color,
                       ),
                     ),
                     const SizedBox(height: 24),
                     Container(
                       padding: const EdgeInsets.all(16),
                       decoration: BoxDecoration(
                         color: Colors.grey[50], 
                         borderRadius: BorderRadius.circular(12),
                         border: Border.all(color: Colors.grey[200]!)
                       ),
                       child: Column(
                        children: [
                          _buildDetailRow(Icons.calendar_today, 'Date', transaction.transactionDate),
                          if (transaction.description != null && transaction.description!.isNotEmpty)
                            _buildDetailRow(Icons.description, 'Description', transaction.description!),
                          if (transaction.location != null && transaction.location!.isNotEmpty)
                            _buildDetailRow(Icons.location_on, 'Location', transaction.location!),
                          if (transaction.isRecurring)
                            _buildDetailRow(Icons.repeat, 'Recurring', transaction.frequency ?? 'Yes'),
                        ],
                       ),
                     ),
                   ],
                 ),
               ),
               
               // Actions
               Padding(
                 padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                 child: SizedBox(
                   width: double.infinity,
                   child: ElevatedButton(
                     onPressed: () {
                       Navigator.pop(context);
                       context.push('/add-transaction', extra: transaction);
                     },
                     style: ElevatedButton.styleFrom(
                       backgroundColor: const Color(0xFF171A1F),
                       padding: const EdgeInsets.symmetric(vertical: 16),
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                              elevation: 0,
                     ),
                     child: const Text('Edit Transaction', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                   ),
                 ),
               ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[400]),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          const Spacer(),
          Flexible(
            child: Text(
              value, 
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF171A1F)),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final padding = ResponsiveHelper.getResponsivePadding(context);

    // Watch the filtered transactions
    final transactionsState = ref.watch(filteredTransactionsProvider);

    return Scaffold(
      key: _scaffoldKey,
      appBar: (isMobile || isTablet) ? _buildAppBar() : null,
      drawer: (isMobile || isTablet) ? _buildDrawer() : null,
      body: Row(
        children: [
          // Desktop Sidebar
          if (ResponsiveHelper.isDesktop(context))
            const AppSidebar(activeItem: 'Transactions'),
          // Main Content
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    SizedBox(height: padding),
                    _buildSearchAndFilters(),
                    SizedBox(height: padding),
                    // Transaction List
                    transactionsState.when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (error, stack) => Center(child: Text('Error: $error')),
                      data: (transactions) {
                        if (transactions.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(40.0),
                              child: Text('No transactions found matching your criteria'),
                            ),
                          );
                        }
                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: transactions.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final transaction = transactions[index];
                            return Slidable(
                              key: ValueKey(transaction.id),
                              endActionPane: ActionPane(
                                motion: const ScrollMotion(),
                                children: [
                                  SlidableAction(
                                    onPressed: (context) {
                                      context.push('/add-transaction', extra: transaction);
                                    },
                                    backgroundColor: const Color(0xFF2196F3),
                                    foregroundColor: Colors.white,
                                    icon: Icons.edit,
                                    label: 'Edit',
                                  ),
                                  SlidableAction(
                                    onPressed: (context) async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Delete Transaction'),
                                          content: const Text('Are you sure you want to delete this transaction?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context, false),
                                              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.pop(context, true),
                                              child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (confirm == true) {
                                        try {
                                          await ref.read(transactionServiceProvider).deleteTransaction(transaction.id);
                                          // Refresh all providers
                                          ref.invalidate(transactionsProvider);
                                          ref.invalidate(dashboardBalanceProvider);
                                          ref.invalidate(dashboardRecentTransactionsProvider);
                                          ref.invalidate(dashboardSpendingCategoriesProvider);
                                          ref.invalidate(dashboardMonthlySummaryProvider);
                                          
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Transaction deleted')),
                                            );
                                          }
                                        } catch (e) {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Error deleting: $e'), backgroundColor: Colors.red),
                                            );
                                          }
                                        }
                                      }
                                    },
                                    backgroundColor: const Color(0xFFFE4A49),
                                    foregroundColor: Colors.white,
                                    icon: Icons.delete,
                                    label: 'Delete',
                                  ),
                                ],
                              ),
                              child: _buildTransactionCard(transaction),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.black87),
      title: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Image.asset(
          'assets/images/beztami_logo.png',
          height: 48,
          fit: BoxFit.contain,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.menu, color: Colors.black87),
        onPressed: () {
          _scaffoldKey.currentState?.openDrawer();
        },
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: UserAvatarMenu(size: 40),
        ),
      ],
    );
  }

  Widget _buildDrawer() {
    return const Drawer(
      child: AppSidebar(activeItem: 'Transactions'),
    );
  }

  Widget _buildHeader() {
    return const Text(
      'Transactions',
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1B5E20),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    final filterNotifier = ref.read(transactionFilterProvider.notifier);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          onChanged: (value) => filterNotifier.setSearchQuery(value),
          decoration: InputDecoration(
            hintText: 'Search by name, description, or category...',
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF4CAF50)),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Filter by:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF171A1F),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildTypeFilter(),
            _buildCategoryFilter(),
            _buildSortFilter(),
          ],
        ),
      ],
    );
  }


  Widget _buildTypeFilter() {
    final currentType = ref.watch(transactionFilterProvider).type;
    final notifier = ref.read(transactionFilterProvider.notifier);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () => notifier.setType(null),
          child: _buildFilterChip(
            Icons.filter_list,
            'All Types',
            isSelected: currentType == null,
          ),
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: () => notifier.setType('INCOME'),
          child: _buildFilterChip(
            Icons.arrow_upward,
            'Income',
            isSelected: currentType == 'INCOME',
          ),
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: () => notifier.setType('EXPENSE'),
          child: _buildFilterChip(
            Icons.arrow_downward,
            'Expense',
            isSelected: currentType == 'EXPENSE',
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    final currentCategoryId = ref.watch(transactionFilterProvider).categoryId;
    final categoriesAsync = ref.watch(categoriesProvider);
    final notifier = ref.read(transactionFilterProvider.notifier);

    return categoriesAsync.when(
      loading: () => _buildFilterChip(Icons.category, 'Loading...'),
      error: (_, __) => _buildFilterChip(Icons.error, 'Error'),
      data: (categories) {
        // Find current category name
        String currentLabel = 'All Categories';
        if (currentCategoryId != null) {
          try {
            final currentCat = categories.firstWhere(
              (c) => c.id == currentCategoryId,
            );
            currentLabel = currentCat.name;
          } catch (_) {
            // Category not found, reset to null
            currentLabel = 'All Categories';
          }
        }

        return PopupMenuButton<int?>(
          onSelected: (value) {
            // Explicitly handle both null and non-null values
            notifier.setCategory(value);
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: null,
              onTap: () {
                // Force update to null after menu closes
                Future.delayed(Duration.zero, () => notifier.setCategory(null));
              },
              child: const Text('All Categories'),
            ),
            ...categories.map((cat) => PopupMenuItem(
              value: cat.id,
              child: Text(cat.name),
            )),
          ],
          child: _buildFilterChip(
            Icons.category,
            currentLabel,
            isSelected: currentCategoryId != null,
          ),
        );
      },
    );
  }

  Widget _buildSortFilter() {
    final currentSort = ref.watch(transactionFilterProvider).sortOrder;
    return PopupMenuButton<String>(
      initialValue: currentSort,
      onSelected: (value) => ref.read(transactionFilterProvider.notifier).setSortOrder(value),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'newest', child: Text('Newest')),
        const PopupMenuItem(value: 'oldest', child: Text('Oldest')),
      ],
      child: _buildFilterChip(Icons.swap_vert, currentSort == 'newest' ? 'Newest' : 'Oldest'),
    );
  }

  Widget _buildFilterChip(IconData icon, String label, {bool isSelected = false}) {
    final isMobile = ResponsiveHelper.isMobile(context);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 16,
        vertical: isMobile ? 10 : 12,
      ),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF4CAF50).withOpacity(0.1) : Colors.white,
        border: Border.all(
          color: isSelected ? const Color(0xFF4CAF50) : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: isMobile ? 14 : 16,
            color: isSelected ? const Color(0xFF4CAF50) : const Color(0xFF171A1F),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: isMobile ? 12 : 14,
              color: isSelected ? const Color(0xFF4CAF50) : const Color(0xFF171A1F),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(IconData icon, String label, VoidCallback onPressed) {
     return InkWell(
       onTap: onPressed,
       child: _buildFilterChip(icon, label),
     );
  }

  // Helper to map string icon names to IconData
  IconData _getCategoryIcon(String? iconName) {
    switch (iconName) {
      case 'home': return Icons.home;
      case 'shopping_cart': return Icons.shopping_cart;
      case 'restaurant': return Icons.restaurant;
      case 'directions_bus': return Icons.directions_bus;
      case 'work': return Icons.work;
      case 'attach_money': return Icons.attach_money;
      case 'movie': return Icons.movie;
      case 'bolt': return Icons.bolt;
      case 'music_note': return Icons.music_note;
      case 'receipt_long': return Icons.receipt_long;
      case 'cloud': return Icons.cloud;
      case 'code': return Icons.code;
      default: return Icons.category;
    }
  }
}
