
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/app_header.dart';
import '../../../../shared/widgets/app_sidebar.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Row(
        children: [
          const AppSidebar(activeItem: 'Dashboard'),
          Expanded(
            child: Column(
              children: [
                const AppHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(48),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Section: Welcome & Add Buttons
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 22),
                                  const Text(
                                    'Welcome back, FinaTrack User!',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30,
                                      color: Color(0xFF171A1F),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    "Here's a snapshot of your finances at a glance.",
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 16,
                                      color: Color(0xFF565D6D),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 24),
                            // Add Income button
                            Container(
                              width: 254,
                              height: 144,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: const Color(0xFFDEE1E6)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.all(17),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: Icon(Icons.arrow_outward, size: 32, color: Colors.black),
                                  ),
                                  const Center(
                                    child: Text(
                                      'Add Income',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w500,
                                        fontSize: 18,
                                        color: Color(0xFF171A1F),
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  ElevatedButton(
                                    onPressed: () {
                                      context.go('/add-transaction');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF3899FA),
                                      minimumSize: const Size(double.infinity, 40),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add, size: 16, color: Colors.white),
                                        const SizedBox(width: 8),
                                        const Text(
                                          'Add',
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 24),
                            // Add Expense button
                            Container(
                              width: 254,
                              height: 144,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: const Color(0xFFDEE1E6)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.all(17),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: Icon(Icons.call_received, size: 32, color: Colors.black),
                                  ),
                                  const Center(
                                    child: Text(
                                      'Add Expense',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w500,
                                        fontSize: 18,
                                        color: Color(0xFF171A1F),
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  ElevatedButton(
                                    onPressed: () {
                                      context.go('/add-transaction');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF3899FA),
                                      minimumSize: const Size(double.infinity, 40),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add, size: 16, color: Colors.white),
                                        const SizedBox(width: 8),
                                        const Text(
                                          'Add',
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 48),
                        // Middle Section: Balance & Chart
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Balance
                            Container(
                              width: 347,
                              height: 270,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: const Color(0xFFDEE1E6)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.all(40),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Total Current Balance',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      color: Color(0xFF565D6D),
                                    ),
                                  ),
                                  const SizedBox(height: 47),
                                  const Text(
                                    '\$12,450.75',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 48,
                                      color: Color(0xFF171A1F),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 24),
                            // Chart
                            Expanded(
                              child: Container(
                                height: 428,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: const Color(0xFFDEE1E6)),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.all(25),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Income vs. Expenses',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w500,
                                        fontSize: 18,
                                        color: Color(0xFF171A1F),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'Monthly overview of your financial flow.',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 14,
                                        color: Color(0xFF565D6D),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Expanded(
                                      child: _buildMonthlyChart(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 48),
                        // Recent Transactions
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: const Color(0xFFDEE1E6)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.all(25),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Recent Transactions',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 18,
                                  color: Color(0xFF171A1F),
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Your latest income and expense activities.',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  color: Color(0xFF565D6D),
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Transaction items
                              _buildTransactionItem('Salary Deposit', '2024-06-25', '+\$3,500.00', true),
                              const Divider(height: 48, color: Color(0xFFF3F4F6)),
                              _buildTransactionItem('Grocery Shopping', '2024-06-24', '-\$120.50', false),
                              const Divider(height: 48, color: Color(0xFFF3F4F6)),
                              _buildTransactionItem('Freelance Payment', '2024-06-22', '+\$800.00', true),
                              const Divider(height: 48, color: Color(0xFFF3F4F6)),
                              _buildTransactionItem('Internet Bill', '2024-06-20', '-\$65.00', false),
                              const Divider(height: 48, color: Color(0xFFF3F4F6)),
                              _buildTransactionItem('Dinner Out', '2024-06-19', '-\$75.30', false),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: () {
                                  context.go('/transactions');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF171A1F),
                                  minimumSize: const Size(double.infinity, 40),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    side: const BorderSide(color: Color(0xFFDEE1E6)),
                                  ),
                                ),
                                child: const Text(
                                  'View All Transactions',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w500,
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
                // Footer
                Container(
                  height: 85,
                  color: Colors.grey[100],
                  child: const Center(
                    child: Text(
                      '© 2025 FinaTrack. All rights reserved.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: Color(0xFF565D6D),
                      ),
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

  // ...existing code...
  Widget _buildTransactionItem(String title, String date, String amount, bool isIncome) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: isIncome ? const Color(0x1A4CAF50) : const Color(0x1AEB4747),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isIncome ? Icons.arrow_outward : Icons.call_received,
            size: 12,
            color: isIncome ? Colors.green : const Color(0xFFEB4747),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: Color(0xFF171A1F),
                ),
              ),
              Text(
                date,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: Color(0xFF565D6D),
                ),
              ),
            ],
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
            fontSize: 18,
            color: isIncome ? Colors.green : const Color(0xFFEB4747),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyChart() {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
    final data = [
      {'income': 4500.0, 'expense': 3200.0},
      {'income': 4800.0, 'expense': 3500.0},
      {'income': 5200.0, 'expense': 3800.0},
      {'income': 5500.0, 'expense': 4100.0},
      {'income': 5800.0, 'expense': 4300.0},
      {'income': 6000.0, 'expense': 4500.0},
    ];
    const double maxValue = 6500.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Y-Axis Labels
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('\$6k', style: TextStyle(fontSize: 12, color: Color(0xFF565D6D))),
            Text('\$4.5k', style: TextStyle(fontSize: 12, color: Color(0xFF565D6D))),
            Text('\$3k', style: TextStyle(fontSize: 12, color: Color(0xFF565D6D))),
            Text('\$1.5k', style: TextStyle(fontSize: 12, color: Color(0xFF565D6D))),
            Text('\$0k', style: TextStyle(fontSize: 12, color: Color(0xFF565D6D))),
          ],
        ),
        const SizedBox(width: 16),
        // Bars
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(months.length, (index) {
              final income = data[index]['income'] as double;
              final expense = data[index]['expense'] as double;
              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: 12,
                        height: (income / maxValue) * 250,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4FA759),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 12,
                        height: (expense / maxValue) * 250,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEB4747),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    months[index],
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: Color(0xFF565D6D),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

