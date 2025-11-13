import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/colors.dart';
import '../../pages/notification_page.dart';

/// Custom App Bar with notification and profile icons
/// Shows hamburger menu icon to open drawer
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showMenuIcon;
  final bool showNotificationIcon;
  final bool showProfileIcon;
  final VoidCallback? onMenuTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;
  final int notificationCount;

  const CustomAppBar({
    super.key,
    this.title,
    this.showMenuIcon = true,
    this.showNotificationIcon = true,
    this.showProfileIcon = true,
    this.onMenuTap,
    this.onNotificationTap,
    this.onProfileTap,
    this.notificationCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      leading: showMenuIcon
          ? IconButton(
        icon: const Icon(Icons.menu, color: AppColors.textPrimary),
        onPressed: onMenuTap ?? () => Scaffold.of(context).openDrawer(),
      )
          : null,
      title: title != null
          ? Text(
        title!,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      )
          : Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'E',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Esprit-InterLink',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      actions: [
        if (showNotificationIcon)
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                color: AppColors.textPrimary,
                onPressed: onNotificationTap ?? () {
                  context.pushNamed('notifications');
                },
              ),
              if (notificationCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      notificationCount > 9 ? '9+' : '$notificationCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        if (showProfileIcon)
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            color: AppColors.textPrimary,
            onPressed: onProfileTap ?? () {
              context.pushNamed('studentProfile');
            },
          ),
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: AppColors.divider,
          height: 1,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}