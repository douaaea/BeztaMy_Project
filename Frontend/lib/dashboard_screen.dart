import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'core/utils/responsive_helper.dart';
import 'shared/widgets/app_sidebar.dart';
import 'shared/widgets/user_avatar_menu.dart';
import 'features/transactions/domain/providers/dashboard_provider.dart';

import 'features/auth/domain/providers/auth_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = ResponsiveHelper.isMobile(context);
        final isTablet = ResponsiveHelper.isTablet(context);

        return Scaffold(
          key: _scaffoldKey,
          appBar: (isMobile || isTablet) ? _buildAppBar() : null,
          drawer: (isMobile || isTablet) ? _buildDrawer() : null,
          body: Row(
            children: [
              // Desktop Sidebar
              if (ResponsiveHelper.isDesktop(context))
                const AppSidebar(activeItem: 'Dashboard'),
              // Main Content
              Expanded(
                child: _buildMainContent(),
              ),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 1,
      iconTheme: const IconThemeData(color: Colors.black87),
      title: Image.asset(
        'assets/images/beztami_logo.png',
        width: 100,
        height: 100,
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
      child: AppSidebar(activeItem: 'Dashboard'),
    );
  }

  Widget _buildMainContent() {
    final padding = ResponsiveHelper.getResponsivePadding(context);

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            SizedBox(height: padding),
            _buildBalanceAndChart(),
            SizedBox(height: padding * 0.75),
            _buildTransactionsAndSpendingRow(),
            SizedBox(height: padding * 0.75),
            _buildFinancialTrendsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final currentUser = ref.watch(currentUserProvider);
    final titleFontSize = ResponsiveHelper.getResponsiveFontSize(context, 28);
    final subtitleFontSize = ResponsiveHelper.getResponsiveFontSize(context, 14);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back, ${currentUser?.firstName ?? 'BeztaMy User'}!',
          style: TextStyle(
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1B5E20),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Here\'s a snapshot of your finances at a glance.',
          style: TextStyle(
            fontSize: subtitleFontSize,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }


  void _openAddTransaction({required bool asExpense}) {
    context.go('/add-transaction?type=${asExpense ? 'expense' : 'income'}');
  }

  Widget _buildBalanceAndChart() {
    final isMobile = ResponsiveHelper.isMobile(context);

    if (isMobile) {
      return Column(
        children: [
          _buildBalanceCard(),
          const SizedBox(height: 16),
          _buildChartCard(),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: _buildBalanceCard(),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: ResponsiveHelper.getChartFlex(context),
          child: _buildChartCard(),
        ),
      ],
    );
  }

  Widget _buildBalanceCard() {
    final balanceFontSize = ResponsiveHelper.getResponsiveFontSize(context, 48);
    final balanceState = ref.watch(dashboardBalanceProvider);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 250, 250, 250).withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: balanceState.when(
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(40.0),
            child: CircularProgressIndicator(),
          ),
        ),
        error: (error, _) => Center(
          child: Text('Error loading balance: $error'),
        ),
        data: (balance) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Total Current Balance',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '\$${balance.currentBalance.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: balanceFontSize,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1B5E20),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _openAddTransaction(asExpense: false),
                    icon: const Icon(Icons.add, size: 16, color: Colors.white),
                    label: const Text('Add Income', style: TextStyle(fontSize: 14)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _openAddTransaction(asExpense: true),
                    icon: const Icon(Icons.add, size: 16, color: Colors.white),
                    label: const Text('Add Expense', style: TextStyle(fontSize: 14)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B4332),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 520;
                final cardWidth = isWide ? (constraints.maxWidth - 12) / 2 : constraints.maxWidth;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SizedBox(
                      width: cardWidth,
                      child: _buildBalanceStatCard(
                        title: 'Total Income',
                        value: '\$${balance.totalIncome.toStringAsFixed(2)}',
                        accent: const Color(0xFF1B5E20),
                        icon: Icons.trending_up,
                      ),
                    ),
                    SizedBox(
                      width: cardWidth,
                      child: _buildBalanceStatCard(
                        title: 'Total Expenses',
                        value: '\$${balance.totalExpense.toStringAsFixed(2)}',
                        accent: const Color(0xFFB71C1C),
                        icon: Icons.trending_down,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceStatCard({
    required String title,
    required String value,
    required Color accent,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF5D646F),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: accent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard() {
    final isMobile = ResponsiveHelper.isMobile(context);
    final chartHeight = isMobile ? 200.0 : 250.0;
    final summaryState = ref.watch(dashboardMonthlySummaryProvider);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Income vs. Expenses',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Monthly overview of your financial flow.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: chartHeight,
            child: summaryState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
              data: (summaries) {
                if (summaries.isEmpty) {
                  return const Center(child: Text('No data available'));
                }

                final barGroups = summaries.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final s = entry.value;
                  // Convert to thousands for display
                  return _buildBarGroup(idx, s.income / 1000, s.expense / 1000);
                }).toList();

                // Calculate max value for Y axis
                final maxIncome = summaries.map((s) => s.income).reduce((a, b) => a > b ? a : b);
                final maxExpense = summaries.map((s) => s.expense).reduce((a, b) => a > b ? a : b);
                final maxY = ((maxIncome > maxExpense ? maxIncome : maxExpense) / 1000 * 1.2).ceilToDouble();

                return BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: maxY,
                    barTouchData: BarTouchData(enabled: true),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                            final idx = value.toInt();
                            if (idx >= 0 && idx < summaries.length && idx < months.length) {
                              return Text(
                                months[idx],
                                style: TextStyle(
                                  fontSize: isMobile ? 10 : 12,
                                ),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              '\$${value.toInt()}k',
                              style: TextStyle(
                                fontSize: isMobile ? 9 : 11,
                              ),
                            );
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 1,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.grey[200],
                          strokeWidth: 1,
                        );
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: barGroups,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double income, double expense) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final barWidth = isMobile ? 12.0 : 16.0;

    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: income,
          color: const Color(0xFF42A5F5),
          width: barWidth,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
        BarChartRodData(
          toY: expense,
          color: const Color(0xFF66BB6A),
          width: barWidth,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
      barsSpace: isMobile ? 2 : 4,
    );
  }

  Widget _buildRecentTransactions() {
    final transactionsState = ref.watch(dashboardRecentTransactionsProvider);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Transactions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Your latest income and expense activities.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          transactionsState.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (error, _) => Center(child: Text('Error: $error')),
            data: (transactions) {
              if (transactions.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text('No transactions yet'),
                  ),
                );
              }

              return Column(
                children: [
                  for (int i = 0; i < transactions.length; i++) ...[
                    if (i > 0) const Divider(height: 32),
                    _buildTransactionItem(
                      transactions[i].category.name,
                      transactions[i].transactionDate,
                      transactions[i].type == 'INCOME'
                          ? '+\$${transactions[i].amount.toStringAsFixed(2)}'
                          : '-\$${transactions[i].amount.toStringAsFixed(2)}',
                      transactions[i].type == 'INCOME',
                      transactions[i].type == 'INCOME'
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                    ),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          Center(
            child: TextButton(
              onPressed: () => context.go('/transactions'),
              child: const Text(
                'View All Transactions',
                style: TextStyle(
                  color: Color(0xFF4CAF50),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(
    String title,
    String date,
    String amount,
    bool isIncome,
    IconData icon,
  ) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final titleFontSize = isMobile ? 13.0 : 14.0;
    final amountFontSize = isMobile ? 14.0 : 16.0;

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isIncome ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isIncome ? const Color(0xFF4CAF50) : const Color(0xFFE53935),
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                date,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: amountFontSize,
            fontWeight: FontWeight.bold,
            color: isIncome ? const Color(0xFF4CAF50) : const Color(0xFFE53935),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionsAndSpendingRow() {
    final isMobile = ResponsiveHelper.isMobile(context);

    if (isMobile) {
      return Column(
        children: [
          _buildRecentTransactions(),
          const SizedBox(height: 16),
          _buildSpendingCategoriesCard(),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: _buildRecentTransactions()),
        const SizedBox(width: 24),
        Expanded(flex: 2, child: _buildSpendingCategoriesCard()),
      ],
    );
  }

  Widget _buildSpendingCategoriesCard() {
    final theme = Theme.of(context);
    final spendingState = ref.watch(dashboardSpendingCategoriesProvider);

    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Spending Categories', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            spendingState.when(
              loading: () => const SizedBox(
                height: 160,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => SizedBox(
                height: 160,
                child: Center(child: Text('Error: $error')),
              ),
              data: (response) {
                if (response.categories.isEmpty) {
                  return const SizedBox(
                    height: 160,
                    child: Center(child: Text('No spending data')),
                  );
                }

                final categories = response.categories;
                return Column(
                  children: [
                    SizedBox(
                      height: 160,
                      child: PieChart(
                        PieChartData(
                          sections: categories
                              .map((c) => PieChartSectionData(
                                    value: c.value,
                                    color: _hexToColor(c.color),
                                    title: '${c.value.toStringAsFixed(0)}%',
                                    radius: 40,
                                    titleStyle: const TextStyle(color: Colors.white, fontSize: 12),
                                  ))
                              .toList(),
                          centerSpaceRadius: 36,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...categories.map((c) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: _hexToColor(c.color),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${c.label} ${c.value.toStringAsFixed(0)}%',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        )),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to convert hex color string to Color
  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex'; // Add alpha if not present
    }
    return Color(int.parse(hex, radix: 16));
  }

  Widget _buildFinancialTrendsCard() {
    final isMobile = ResponsiveHelper.isMobile(context);
    final theme = Theme.of(context);
    final trendsState = ref.watch(dashboardTrendsProvider);

    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Financial Trends Over Time', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            SizedBox(
              height: isMobile ? 200 : 300,
              child: trendsState.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text('Error: $error')),
                data: (trends) {
                  if (trends.isEmpty) {
                    return const Center(child: Text('No trend data available'));
                  }

                  final spots = trends
                      .map((t) => FlSpot(t.month.toDouble(), t.balance))
                      .toList();

                  return LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (v) => FlLine(
                          color: Colors.grey[200]!,
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1, // Ensure only integer values (months) are shown
                            getTitlesWidget: (v, meta) {
                              const months = [
                                'Jan',
                                'Feb',
                                'Mar',
                                'Apr',
                                'May',
                                'Jun',
                                'Jul',
                                'Aug',
                                'Sep',
                                'Oct',
                                'Nov',
                                'Dec'
                              ];
                              final idx = v.toInt() - 1; // Convert 1-based month to 0-based index
                              if (idx >= 0 && idx < months.length) {
                                return Text(
                                  months[idx],
                                  style: TextStyle(fontSize: isMobile ? 9 : 11),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '\$${value.toInt()}k',
                                style: TextStyle(
                                  fontSize: isMobile ? 9 : 11,
                                  color: Colors.grey[600],
                                ),
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: const Color(0xFF42A5F5),
                          barWidth: 2,
                          dotData: FlDotData(show: true), // Show dots for better visibility
                          belowBarData: BarAreaData(
                            show: true,
                            color: const Color(0x3342A5F5),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
