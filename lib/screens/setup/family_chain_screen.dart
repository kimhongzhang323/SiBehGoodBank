import 'package:flutter/material.dart';
import '../../constants/constants.dart';
import '../../widgets/widgets.dart';
import 'account_preferences_screen.dart';

/// Family Chain setup screen - optional feature to monitor
/// children (under 18) or senior citizens' transactions
class FamilyChainScreen extends StatefulWidget {
  const FamilyChainScreen({super.key});

  @override
  State<FamilyChainScreen> createState() => _FamilyChainScreenState();
}

class _FamilyChainScreenState extends State<FamilyChainScreen> {
  final List<FamilyMember> _familyMembers = [];
  bool _enableFamilyChain = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBackground,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            _buildProgressIndicator(),

            // Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.screenPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: AppSpacing.xl),

                    // Enable toggle
                    _buildEnableToggle(),
                    const SizedBox(height: AppSpacing.lg),

                    // Family chain explanation
                    if (_enableFamilyChain) ...[
                      _buildExplanationCard(),
                      const SizedBox(height: AppSpacing.xl),

                      // Member type selection
                      _buildMemberTypeSection(),
                      const SizedBox(height: AppSpacing.xl),

                      // Added members list
                      if (_familyMembers.isNotEmpty) ...[
                        _buildMembersList(),
                        const SizedBox(height: AppSpacing.lg),
                      ],

                      // Notification settings
                      _buildNotificationSettings(),
                      const SizedBox(height: AppSpacing.xl),
                    ],

                    // Info card
                    _buildInfoCard(),
                  ],
                ),
              ),
            ),

            // Bottom button
            _buildBottomButton(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.cardBackground,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.arrow_back_ios_new,
            size: 16,
            color: AppColors.textPrimary,
          ),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Family Chain',
        style: AppTextStyles.headlineSmall,
      ),
      centerTitle: true,
      actions: [
        TextButton(
          onPressed: () => _skipToNext(),
          child: Text(
            'Skip',
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.md,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Step 4 of 5',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                '80%',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          LinearProgressIndicator(
            value: 0.8,
            backgroundColor: AppColors.lavender.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
            borderRadius: BorderRadius.circular(4),
            minHeight: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Family icon
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.accentBlue.withOpacity(0.2),
                AppColors.lavender.withOpacity(0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.family_restroom,
            color: AppColors.accentBlue,
            size: 32,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        const Text(
          'Family Chain\nProtection',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            height: 1.2,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Keep your loved ones safe. Get notified when children under 18 or senior family members make transfers.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildEnableToggle() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: _enableFamilyChain ? AppColors.accent : AppColors.glassBorder,
          width: _enableFamilyChain ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _enableFamilyChain
                  ? AppColors.accent.withOpacity(0.1)
                  : AppColors.lavender.withOpacity(0.3),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.link,
              color: _enableFamilyChain
                  ? AppColors.accent
                  : AppColors.textSecondary,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enable Family Chain',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Monitor transfers for family members',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _enableFamilyChain,
            onChanged: (value) {
              setState(() {
                _enableFamilyChain = value;
              });
            },
            activeColor: AppColors.accent,
          ),
        ],
      ),
    );
  }

  Widget _buildExplanationCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accentBlue.withOpacity(0.1),
            AppColors.lavender.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: AppColors.accentBlue.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          _buildFeatureRow(
            Icons.notifications_active,
            'Real-time Alerts',
            'Get instant notifications for every transfer',
          ),
          const Divider(height: AppSpacing.lg),
          _buildFeatureRow(
            Icons.visibility,
            'Transaction Visibility',
            'See who they\'re sending money to',
          ),
          const Divider(height: AppSpacing.lg),
          _buildFeatureRow(
            Icons.security,
            'Peace of Mind',
            'Protect vulnerable family members from scams',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Icon(icon, color: AppColors.accentBlue, size: 20),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.labelLarge),
              Text(
                subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMemberTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Add Family Members', style: AppTextStyles.titleLarge),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _buildMemberTypeCard(
                icon: Icons.child_care,
                title: 'Child',
                subtitle: 'Under 18 years',
                color: AppColors.pinkTint,
                onTap: () => _showAddMemberDialog(MemberType.child),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildMemberTypeCard(
                icon: Icons.elderly,
                title: 'Senior',
                subtitle: '60+ years',
                color: AppColors.lavender,
                onTap: () => _showAddMemberDialog(MemberType.senior),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMemberTypeCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.glassBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.textPrimary, size: 28),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(title, style: AppTextStyles.titleMedium),
            Text(
              subtitle,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, size: 16, color: AppColors.accent),
                  const SizedBox(width: 4),
                  Text(
                    'Add',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMembersList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Linked Members', style: AppTextStyles.titleLarge),
            Text(
              '${_familyMembers.length} added',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: _familyMembers.map((member) {
              final index = _familyMembers.indexOf(member);
              return Column(
                children: [
                  _buildMemberTile(member, index),
                  if (index < _familyMembers.length - 1)
                    const Divider(height: 1, indent: 72),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMemberTile(FamilyMember member, int index) {
    final isChild = member.type == MemberType.child;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isChild
                  ? AppColors.pinkTint.withOpacity(0.3)
                  : AppColors.lavender.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isChild ? Icons.child_care : Icons.elderly,
              color: AppColors.textPrimary,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member.name, style: AppTextStyles.titleMedium),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isChild
                            ? AppColors.pinkTint.withOpacity(0.3)
                            : AppColors.lavender.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isChild ? 'Child' : 'Senior',
                        style: AppTextStyles.labelSmall,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      member.relationship,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.remove_circle_outline,
              color: AppColors.negative,
            ),
            onPressed: () {
              setState(() {
                _familyMembers.removeAt(index);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Notification Settings', style: AppTextStyles.titleLarge),
        const SizedBox(height: AppSpacing.md),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildNotificationOption(
                icon: Icons.attach_money,
                title: 'All Transfers',
                subtitle: 'Notify for every outgoing transfer',
                isEnabled: true,
              ),
              const Divider(height: 1, indent: 72),
              _buildNotificationOption(
                icon: Icons.warning_amber,
                title: 'Large Amounts',
                subtitle: 'Extra alert for transfers over \$100',
                isEnabled: true,
              ),
              const Divider(height: 1, indent: 72),
              _buildNotificationOption(
                icon: Icons.person_off,
                title: 'New Recipients',
                subtitle: 'Alert when sending to new contacts',
                isEnabled: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isEnabled,
  }) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.lavender.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.accent, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.titleMedium),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.check_circle,
            color: AppColors.positive,
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.lavender.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: AppColors.lavender.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.info_outline,
              color: AppColors.accent,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This feature is optional',
                  style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'You can enable or modify Family Chain anytime in Settings.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PrimaryButton(
            text: _enableFamilyChain && _familyMembers.isNotEmpty
                ? 'Continue with ${_familyMembers.length} Member${_familyMembers.length > 1 ? 's' : ''}'
                : 'Continue',
            backgroundColor: AppColors.textPrimary,
            textColor: Colors.white,
            onPressed: () => _navigateToNext(),
          ),
          if (!_enableFamilyChain) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'You can set this up later in Settings',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showAddMemberDialog(MemberType type) {
    final nameController = TextEditingController();
    String selectedRelationship = type == MemberType.child ? 'Son' : 'Parent';
    final relationships = type == MemberType.child
        ? ['Son', 'Daughter', 'Grandchild', 'Nephew', 'Niece', 'Other']
        : ['Parent', 'Grandparent', 'Spouse', 'Relative', 'Other'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.glassBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Header
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: type == MemberType.child
                            ? AppColors.pinkTint.withOpacity(0.3)
                            : AppColors.lavender.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        type == MemberType.child
                            ? Icons.child_care
                            : Icons.elderly,
                        color: AppColors.textPrimary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      'Add ${type == MemberType.child ? 'Child' : 'Senior'} Member',
                      style: AppTextStyles.headlineSmall,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),

                // Name field
                Text('Full Name', style: AppTextStyles.labelLarge),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: 'Enter their full name',
                    filled: true,
                    fillColor: AppColors.cardBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Relationship dropdown
                Text('Relationship', style: AppTextStyles.labelLarge),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedRelationship,
                      isExpanded: true,
                      items: relationships.map((r) {
                        return DropdownMenuItem(
                          value: r,
                          child: Text(r),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setSheetState(() {
                            selectedRelationship = value;
                          });
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Add button
                PrimaryButton(
                  text: 'Add Member',
                  backgroundColor: AppColors.accent,
                  textColor: Colors.white,
                  onPressed: () {
                    if (nameController.text.trim().isNotEmpty) {
                      setState(() {
                        _familyMembers.add(FamilyMember(
                          name: nameController.text.trim(),
                          relationship: selectedRelationship,
                          type: type,
                        ));
                      });
                      Navigator.pop(context);
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _skipToNext() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AccountPreferencesScreen(),
      ),
    );
  }

  void _navigateToNext() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AccountPreferencesScreen(),
      ),
    );
  }
}

enum MemberType {
  child,
  senior,
}

class FamilyMember {
  final String name;
  final String relationship;
  final MemberType type;

  FamilyMember({
    required this.name,
    required this.relationship,
    required this.type,
  });
}
