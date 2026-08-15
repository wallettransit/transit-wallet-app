import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/components/tw_button.dart';
import '../../../../core/components/tw_profile_avatar.dart';
import '../../../../core/components/tw_live_tracking_map.dart';
import '../../../../core/components/tw_snackbar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../data/group_ride_repository.dart';
import '../../../wallet/data/wallet_repository.dart';
import 'passenger_group_fare_review_screen.dart';

class PassengerGroupDetailsScreen extends ConsumerStatefulWidget {
  final String groupId;
  final String creatorId;
  final String groupName;
  final String creatorName;
  final String route;
  final double baseFare;

  const PassengerGroupDetailsScreen({
    super.key,
    required this.groupId,
    required this.creatorId,
    required this.groupName,
    required this.creatorName,
    required this.route,
    required this.baseFare,
  });

  @override
  ConsumerState<PassengerGroupDetailsScreen> createState() => _PassengerGroupDetailsScreenState();
}

class _PassengerGroupDetailsScreenState extends ConsumerState<PassengerGroupDetailsScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authRepositoryProvider).currentUser;
    final isCreator = currentUser?.id == widget.creatorId;

    return Scaffold(
      backgroundColor: AppColors.cardBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildIconButton(
                        icon: Icons.arrow_back_ios_new,
                        onTap: () => Navigator.pop(context),
                      ),
                      Text(
                        widget.groupName,
                        style: GoogleFonts.outfit(
                          color: AppColors.paper,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      _buildIconButton(
                        icon: Icons.help_outline,
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Route: ${widget.route}',
                    style: GoogleFonts.manrope(
                      color: AppColors.muted,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ).animate().fade(duration: 300.ms).slideY(begin: -0.1),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Map Preview
                    const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: TWLiveTrackingMap(height: 150),
                    ).animate().fade(duration: 400.ms, delay: 100.ms),

                    // Members
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Consumer(
                            builder: (context, ref, child) {
                              final membersAsync = ref.watch(groupRideMembersProvider(widget.groupId));
                              return membersAsync.when(
                                data: (members) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Joined Commuters (${members.length})',
                                        style: GoogleFonts.outfit(
                                          color: AppColors.paper,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          ...members.take(4).map((m) {
                                            final fullName = m['users']?['full_name'] as String? ?? 'User';
                                            final initials = fullName.isNotEmpty ? fullName.trim().split(RegExp(' +')).map((s) => s[0]).take(2).join().toUpperCase() : 'U';
                                            return Padding(
                                              padding: const EdgeInsets.only(right: 8.0),
                                              child: TWProfileAvatar(initials: initials, radius: 20),
                                            );
                                          }),
                                          if (members.length > 4)
                                            Container(
                                              width: 40,
                                              height: 40,
                                              margin: const EdgeInsets.only(right: 8.0),
                                              decoration: BoxDecoration(
                                                color: AppColors.highlightBackground,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Center(
                                                child: Text(
                                                  '+${members.length - 4}',
                                                  style: GoogleFonts.manrope(
                                                    color: AppColors.muted,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(color: AppColors.borderStroke),
                                            ),
                                            child: const Center(
                                              child: Icon(Icons.add, size: 14, color: AppColors.muted),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                                loading: () => const CircularProgressIndicator(color: AppColors.kekeGreen),
                                error: (e, st) => Text('Error loading commuters', style: GoogleFonts.manrope(color: Colors.red)),
                              );
                            },
                          ),
                        ],
                      ),
                    ).animate().fade(duration: 400.ms, delay: 200.ms).slideY(begin: 0.1),

                    // Fare Breakdown
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Commute Pricing Breakdown',
                            style: GoogleFonts.outfit(
                              color: AppColors.paper,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.ink,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.borderStroke),
                            ),
                            child: Column(
                              children: [
                                _buildFareRow('Standard Private Fare', '₦${(widget.baseFare * 2.5).toStringAsFixed(0)}', AppColors.muted, AppColors.paper),
                                const SizedBox(height: 12),
                                _buildFareRow('Group Discount (60%)', '-₦${(widget.baseFare * 1.5).toStringAsFixed(0)}', AppColors.muted, AppColors.errorRed),
                                const SizedBox(height: 12),
                                const Divider(color: AppColors.borderStroke, height: 1),
                                const SizedBox(height: 12),
                                _buildFareRow(
                                  'Your Price to Pay',
                                  '₦${widget.baseFare.toStringAsFixed(0)}',
                                  AppColors.paper,
                                  AppColors.kekeGreen,
                                  isTotal: true,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).animate().fade(duration: 400.ms, delay: 300.ms).slideY(begin: 0.1),

                    const SizedBox(height: 24),
                    Consumer(
                      builder: (context, ref, child) {
                        final rideAsync = ref.watch(groupRideDetailsStreamProvider(widget.groupId));
                        return rideAsync.when(
                          data: (ride) {
                            if (ride == null) return const SizedBox();
                            
                            final status = ride['status'] as String?;
                            final driverId = ride['driver_id'] as String?;
                            
                            if (status == 'departed' && driverId != null) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: TWButton(
                                    label: 'Pay for Ride (₦${widget.baseFare.toStringAsFixed(0)})',
                                    icon: Icons.payment,
                                    isLoading: _isLoading,
                                    onPressed: _isLoading ? () {} : () => _payForRide(driverId),
                                  ),
                                ),
                              );
                            }
                            
                            final membersAsync = ref.watch(groupRideMembersProvider(widget.groupId));
                            final isMember = membersAsync.maybeWhen(
                              data: (members) => members.any((m) => m['user_id'] == currentUser?.id),
                              orElse: () => false,
                            );

                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24.0),
                              child: isCreator 

                                ? Row(
                                    children: [
                                      Expanded(
                                        child: TWButton(
                                          label: 'Delete',
                                          icon: Icons.delete_outline,
                                          onPressed: _isLoading ? () {} : () => _showDeleteDialog(context),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: TWButton(
                                          label: 'Rename',
                                          icon: Icons.edit_outlined,
                                          onPressed: _isLoading ? () {} : () => _showRenameDialog(context),
                                        ),
                                      ),
                                    ],
                                  )
                                : SizedBox(
                                    width: double.infinity,
                                    child: isMember
                                        ? TWButton(
                                            label: 'Already Joined',
                                            icon: Icons.check_circle_outline,
                                            onPressed: null, // This disables the button and applies opacity
                                            variant: TWButtonVariant.secondary,
                                          )
                                        : TWButton(
                                            label: 'Join Group Ride',
                                            icon: Icons.arrow_forward,
                                            onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => PassengerGroupFareReviewScreen(
                                                    groupId: widget.groupId,
                                                    baseFare: widget.baseFare,
                                                  )),
                                                );
                                            },
                                          ),
                                  ),
                            );
                          },
                          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.kekeGreen)),
                          error: (e, st) => const SizedBox(),
                        );
                      }
                    ).animate().fade(duration: 400.ms, delay: 400.ms),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.ink,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderStroke),
        ),
        child: Icon(icon, size: 20, color: AppColors.paper),
      ),
    );
  }

  Widget _buildFareRow(String title, String amount, Color titleColor, Color amountColor, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: isTotal
              ? GoogleFonts.outfit(color: titleColor, fontSize: 16, fontWeight: FontWeight.w800)
              : GoogleFonts.manrope(color: titleColor, fontSize: 14),
        ),
        Text(
          amount,
          style: isTotal
              ? GoogleFonts.outfit(color: amountColor, fontSize: 20, fontWeight: FontWeight.w800)
              : GoogleFonts.manrope(color: amountColor, fontSize: 14),
        ),
      ],
    );
  }

  void _payForRide(String driverId) async {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) return;
    
    setState(() => _isLoading = true);
    
    final repo = ref.read(walletRepositoryProvider);
    final res = await repo.processRidePayment(
      passengerId: user.id,
      driverId: driverId,
      amount: widget.baseFare,
      groupId: widget.groupId,
    );
    
    if (mounted) {
      setState(() => _isLoading = false);
      if (res['success'] == true) {
        TWSnackbar.showSuccess(context, 'Payment successful!');
        ref.invalidate(walletBalanceProvider);
      } else {
        TWSnackbar.showError(context, res['message'] ?? 'Payment failed');
      }
    }
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.ink,
        title: Text('Delete Group', style: GoogleFonts.outfit(color: AppColors.paper)),
        content: Text('Are you sure you want to delete this group ride?', style: GoogleFonts.manrope(color: AppColors.muted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.muted)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isLoading = true);
              final repo = ref.read(groupRideRepositoryProvider);
              final res = await repo.deleteGroupRide(widget.groupId);
              if (mounted) {
                setState(() => _isLoading = false);
                if (res['success'] == true) {
                  // ref.refresh(availableGroupRidesProvider);
                  Navigator.pop(context);
                } else {
                  TWSnackbar.showError(context, 'Error: ${res['message']}');
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.errorRed)),
          ),
        ],
      ),
    );
  }

  void _showRenameDialog(BuildContext context) {
    final controller = TextEditingController(text: widget.groupName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.ink,
        title: Text('Rename Group', style: GoogleFonts.outfit(color: AppColors.paper)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: AppColors.paper),
          decoration: const InputDecoration(
            hintText: 'New group name',
            hintStyle: TextStyle(color: AppColors.muted),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.borderStroke)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.kekeGreen)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.muted)),
          ),
          TextButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isEmpty) return;
              Navigator.pop(ctx);
              
              setState(() => _isLoading = true);
              final repo = ref.read(groupRideRepositoryProvider);
              final res = await repo.renameGroupRide(widget.groupId, newName);
              if (mounted) {
                setState(() => _isLoading = false);
                if (res['success'] == true) {
                  // ref.refresh(availableGroupRidesProvider);
                  Navigator.pop(context);
                } else {
                  TWSnackbar.showError(context, 'Error: ${res['message']}');
                }
              }
            },
            child: const Text('Save', style: TextStyle(color: AppColors.kekeGreen)),
          ),
        ],
      ),
    );
  }
}
