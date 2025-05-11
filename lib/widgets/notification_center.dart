import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';
import '../services/notification_service.dart';

class NotificationCenter extends StatefulWidget {
  const NotificationCenter({super.key});

  @override
  State<NotificationCenter> createState() => _NotificationCenterState();
}

class _NotificationCenterState extends State<NotificationCenter> {
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final activeNotifications = _notificationService.activeNotifications;

    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          gradient:
              isDarkMode
                  ? LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).scaffoldBackgroundColor,
                      Theme.of(context).colorScheme.surface.withOpacity(0.9),
                    ],
                  )
                  : LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.blue.shade50, Colors.white],
                  ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
            ),

            // Header - REMOVED YELLOW UNDERLINE
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: FadeInDown(
                duration: const Duration(milliseconds: 500),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        BounceInDown(
                          duration: const Duration(milliseconds: 800),
                          child: Icon(
                            Icons.water_drop,
                            color: Theme.of(context).colorScheme.primary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Plain text without decoration
                        Text(
                          'Hydration Hub',
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.blue[900],
                            // Explicitly set no decoration
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 28),
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      onPressed: () => Navigator.of(context).pop(),
                      splashRadius: 24,
                    ),
                  ],
                ),
              ),
            ),

            // Notification history - REMOVED YELLOW UNDERLINE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: FadeInUp(
                duration: const Duration(milliseconds: 700),
                child: Text(
                  'Recent Notifications',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : Colors.blue[900],
                    // Explicitly set no decoration
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ),

            // Notification list
            Expanded(
              child:
                  activeNotifications.isEmpty
                      ? Center(
                        child: FadeInUp(
                          duration: const Duration(milliseconds: 800),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.water_drop_outlined,
                                size: 60,
                                color:
                                    isDarkMode
                                        ? Colors.grey[600]
                                        : Colors.blue[200],
                              ),
                              const SizedBox(height: 16),
                              // REMOVED YELLOW UNDERLINE
                              Text(
                                'No Notifications Yet',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color:
                                      isDarkMode
                                          ? Colors.grey[400]
                                          : Colors.grey[700],
                                  // Explicitly set no decoration
                                  decoration: TextDecoration.none,
                                ),
                              ),
                              const SizedBox(height: 8),
                              // REMOVED YELLOW UNDERLINE
                              Text(
                                'Your hydration reminders will flow in here!',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color:
                                      isDarkMode
                                          ? Colors.grey[500]
                                          : Colors.grey[600],
                                  fontStyle: FontStyle.italic,
                                  // Explicitly set no decoration
                                  decoration: TextDecoration.none,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                      : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        itemCount: activeNotifications.length,
                        separatorBuilder:
                            (context, index) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final notification =
                              activeNotifications[activeNotifications.length -
                                  1 -
                                  index];
                          return FadeInUp(
                            duration: Duration(milliseconds: 800 + index * 100),
                            child: Dismissible(
                              key: Key('notification_${notification.id}'),
                              background: Container(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                              ),
                              direction: DismissDirection.endToStart,
                              onDismissed: (direction) {
                                _notificationService.cancelNotification(
                                  notification.id,
                                );
                                setState(() {});
                                ScaffoldMessenger.of(context).showSnackBar(
                                  _buildCustomSnackBar(
                                    'Notification dismissed.',
                                    Icons.delete,
                                    action: SnackBarAction(
                                      label: 'UNDO',
                                      textColor: Colors.white,
                                      onPressed: () {
                                        _notificationService
                                            .scheduleNotification(
                                              id: notification.id,
                                              title: notification.title,
                                              body: notification.body,
                                              scheduledDate:
                                                  notification.timestamp,
                                            );
                                        setState(() {});
                                      },
                                    ),
                                  ),
                                );
                              },
                              child: Card(
                                elevation: isDarkMode ? 0 : 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                color:
                                    isDarkMode
                                        ? Colors.grey[850]!.withOpacity(0.7)
                                        : Colors.white.withOpacity(0.95),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color:
                                          isDarkMode
                                              ? Colors.white.withOpacity(0.1)
                                              : Colors.blue[100]!,
                                      width: 1,
                                    ),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    leading: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary.withOpacity(0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        notification.isScheduled
                                            ? Icons.schedule
                                            : Icons.notifications_active,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                        size: 24,
                                      ),
                                    ),
                                    title: Text(
                                      notification.title,
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 4),
                                        Text(
                                          notification.body,
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            color:
                                                isDarkMode
                                                    ? Colors.grey[400]
                                                    : Colors.grey[700],
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          notification.isScheduled
                                              ? 'Scheduled: ${DateFormat('h:mm a, MMM d').format(notification.timestamp)}'
                                              : 'Sent: ${DateFormat('h:mm a, MMM d').format(notification.timestamp)}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            color:
                                                isDarkMode
                                                    ? Colors.grey[500]
                                                    : Colors.grey[600],
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ],
                                    ),
                                    trailing:
                                        notification.isScheduled
                                            ? IconButton(
                                              icon: Icon(
                                                Icons.cancel,
                                                color: Colors.red[400],
                                                size: 24,
                                              ),
                                              onPressed: () {
                                                _notificationService
                                                    .cancelNotification(
                                                      notification.id,
                                                    );
                                                setState(() {});
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  _buildCustomSnackBar(
                                                    'Reminder cancelled.',
                                                    Icons.cancel,
                                                  ),
                                                );
                                              },
                                            )
                                            : null,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
            ),

            // Clear all button
            if (activeNotifications.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: FadeInUp(
                  duration: const Duration(milliseconds: 900),
                  child: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        _notificationService.cancelAllNotifications();
                        setState(() {});
                        ScaffoldMessenger.of(context).showSnackBar(
                          _buildCustomSnackBar(
                            'All notifications cleared.',
                            Icons.delete_sweep,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        elevation: 4,
                      ),
                      child: Text(
                        'Clear All Notifications',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  SnackBar _buildCustomSnackBar(
    String message,
    IconData icon, {
    SnackBarAction? action,
  }) {
    return SnackBar(
      content: Row(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
            ),
          ),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 3),
      action: action,
      showCloseIcon: true,
      closeIconColor: Colors.white,
    );
  }
}
