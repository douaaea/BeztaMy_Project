import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/domain/providers/auth_provider.dart';

class AppSidebar extends ConsumerWidget {
  final String activeItem;

  const AppSidebar({super.key, required this.activeItem});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    final user = ref.watch(currentUserProvider);
    final userName = user != null ? '${user.firstName} ${user.lastName}' : 'BeztaMy User';

    // Collapse sidebar on small screens
    final isCollapsed = width < 900;
    
    if (isCollapsed) {
      return Container(
        width: 72,
        color: const Color(0xFFD4E8E0),
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Hamburger circle at top
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
                child: IconButton(
                  icon: const Icon(Icons.menu, color: Colors.black87),
                  onPressed: () {
                    // When collapsed we might open a drawer; navigate to root for now
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Open menu')));
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Icons
            _buildCollapsedNavIcon(context, Icons.dashboard, 'Dashboard', activeItem == 'Dashboard', () => context.go('/dashboard')),
            const SizedBox(height: 8),
            _buildCollapsedNavIcon(context, Icons.swap_horiz, 'Transactions', activeItem == 'Transactions', () => context.go('/transactions')),
            const SizedBox(height: 8),
            _buildCollapsedNavIcon(context, Icons.add_circle_outline, 'Add Entry', activeItem == 'Add Entry', () => context.go('/add-transaction')),
            const SizedBox(height: 8),
            _buildCollapsedNavIcon(context, Icons.chat_bubble_outline, 'Chatbot', activeItem == 'Chatbot', () => context.go('/chatbot')),
            const SizedBox(height: 8),
            _buildCollapsedNavIcon(context, Icons.person_outline, 'Profile', activeItem == 'Profile', () => context.go('/profile')),
            const SizedBox(height: 8),
            const SizedBox(height: 8),
            _buildCollapsedNavIcon(
              context, 
              Icons.logout, 
              'Log Out', 
              false, 
              () async {
                await ref.read(authTokenProvider.notifier).clearToken();
                await ref.read(currentUserProvider.notifier).clearUser();
                if (context.mounted) context.go('/login');
              }
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: user?.profilePicture != null
                  ? CircleAvatar(
                      key: ValueKey(user!.profilePicture.hashCode),
                      radius: 18,
                      backgroundImage: MemoryImage(
                        const Base64Decoder().convert(user!.profilePicture!),
                      ),
                    )
                  : CircleAvatar(
                      key: const ValueKey('default_avatar_collapsed'),
                      radius: 18,
                      backgroundColor: Colors.grey[300],
                      child: const Icon(Icons.person, color: Colors.grey),
                    ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: 256,
      color: const Color(0xFFD4E8E0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Image.asset(
                        'assets/images/beztami_logo.png',
                        width: 80,
                        height: 80,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildNavItem(
                      context,
                      icon: Icons.dashboard,
                      label: 'Dashboard',
                      isActive: activeItem == 'Dashboard',
                      onTap: () => context.go('/dashboard'),
                    ),
                    const SizedBox(height: 24),
                    _buildNavItem(
                      context,
                      icon: Icons.swap_horiz,
                      label: 'Transactions',
                      isActive: activeItem == 'Transactions',
                      onTap: () => context.go('/transactions'),
                    ),
                    const SizedBox(height: 24),
                    _buildNavItem(
                      context,
                      icon: Icons.add_circle_outline,
                      label: 'Add Entry',
                      isActive: activeItem == 'Add Entry',
                      onTap: () => context.go('/add-transaction'),
                    ),
                    const SizedBox(height: 24),
                    _buildNavItem(
                      context,
                      icon: Icons.chat_bubble_outline,
                      label: 'Chatbot',
                      isActive: activeItem == 'Chatbot',
                      onTap: () => context.go('/chatbot'),
                    ),
                    const SizedBox(height: 24),
                    _buildNavItem(
                      context,
                      icon: Icons.person_outline,
                      label: 'Profile',
                      isActive: activeItem == 'Profile',
                      onTap: () => context.go('/profile'),
                    ),
                    const SizedBox(height: 16),
            _buildNavItem(
              context,
              icon: Icons.logout,
              label: 'Log Out',
              isActive: false, // Log out is an action, not a navigable state usually, or we can leave it false
              onTap: () async {
                await ref.read(authTokenProvider.notifier).clearToken();
                await ref.read(currentUserProvider.notifier).clearUser();
                if (context.mounted) context.go('/login');
              },
            ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          if (user?.profilePicture != null)
                            CircleAvatar(
                              key: ValueKey(user!.profilePicture.hashCode),
                              radius: 20,
                              backgroundImage: MemoryImage(
                                  const Base64Decoder().convert(user!.profilePicture!)),
                            )
                          else
                            CircleAvatar(
                              key: const ValueKey('default_avatar'),
                              radius: 20,
                              backgroundColor: Colors.grey[300],
                              child: const Icon(Icons.person, color: Colors.grey),
                            ),
                          const SizedBox(width: 10),
                           Expanded(
                            child: Text(
                              userName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildCollapsedNavIcon(BuildContext context, IconData icon, String tooltip, bool isActive, VoidCallback onTap) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF4FA759) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 22,
            color: isActive ? Colors.white : const Color(0xFF565D6D),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 223,
        height: 40,
        decoration: isActive
            ? BoxDecoration(
                color: const Color(0xFF4FA759),
                borderRadius: BorderRadius.circular(16),
              )
            : null,
        child: Row(
          children: [
            const SizedBox(width: 28), // Matches Figma padding
            Icon(
              icon,
              size: 16,
              color: isActive ? Colors.white : const Color(0xFF565D6D),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: isActive ? Colors.white : const Color(0xFF565D6D),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
