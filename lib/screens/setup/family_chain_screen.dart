import 'package:flutter/material.dart';
import '../../constants/constants.dart';
import '../../widgets/widgets.dart';
import 'account_preferences_screen.dart';

class FamilyChainScreen extends StatefulWidget {
  const FamilyChainScreen({super.key});

  @override
  State<FamilyChainScreen> createState() => _FamilyChainScreenState();
}

class _FamilyChainScreenState extends State<FamilyChainScreen> {
  bool _enableFamilyChain = false;
  final List<FamilyMember> _familyMembers = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HolographicBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.arrow_back_ios,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Family Chain',
                            style: AppTextStyles.headlineLarge,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      'Step 4 of 5',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: AppSpacing.md),
                    // Progress indicator
                    Row(
                      children: List.generate(5, (index) {
                        return Expanded(
                          child: Container(
                            height: 4,
                            margin: EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: index < 4
                                  ? AppColors.accent
                                  : AppColors.accent.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Info Card
                      GlassCard(
                        padding: EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(AppSpacing.sm),
                                  decoration: BoxDecoration(
                                    color: AppColors.accent.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.family_restroom,
                                    color: AppColors.accent,
                                    size: 28,
                                  ),
                                ),
                                SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Family Monitoring',
                                        style: AppTextStyles.headlineSmall,
                                      ),
                                      Text(
                                        'Optional feature',
                                        style: AppTextStyles.labelSmall.copyWith(
                                          color: AppColors.positive,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: AppSpacing.md),
                            Text(
                              'Monitor transactions of family members under 18 or senior citizens (65+) to help protect them from fraud and unauthorized transfers.',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: AppSpacing.lg),

                      // Enable Toggle
                      GlassCard(
                        padding: EdgeInsets.all(AppSpacing.lg),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Enable Family Chain',
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: AppSpacing.xs),
                                  Text(
                                    'You can always set this up later in Settings',
                                    style: AppTextStyles.labelSmall.copyWith(
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
                      ),

                      if (_enableFamilyChain) ...[
                        SizedBox(height: AppSpacing.lg),
                        _buildSecurityNotice(),
                        SizedBox(height: AppSpacing.lg),
                        _buildVerificationRequirements(),
                        SizedBox(height: AppSpacing.lg),
                        Text('Family Members', style: AppTextStyles.headlineSmall),
                        SizedBox(height: AppSpacing.sm),
                        Text(
                          'Add family members you want to monitor. Each member must verify and consent.',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: AppSpacing.md),
                        ..._familyMembers.map((member) => _buildMemberCard(member)),
                        GestureDetector(
                          onTap: () => _showAddMemberDialog(),
                          child: GlassCard(
                            padding: EdgeInsets.all(AppSpacing.lg),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_circle_outline, color: AppColors.accent),
                                SizedBox(width: AppSpacing.sm),
                                Text(
                                  'Add Family Member',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.accent,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: AppSpacing.lg),
                        _buildTermsSection(),
                      ],
                      SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                ),
              ),

              // Bottom Button
              Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: PrimaryButton(
                  text: _enableFamilyChain ? 'Continue with Family Chain' : 'Skip & Continue',
                  onPressed: () {
                    if (_enableFamilyChain && _familyMembers.isEmpty) {
                      _showNoMembersWarning();
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AccountPreferencesScreen(),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityNotice() {
    return GlassCard(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.security, color: const Color(0xFFFF9800), size: 24),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Security Notice',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFFF9800),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          _buildSecurityItem(Icons.lock_clock, '72-Hour Cooling Period',
              'Changes to Family Chain take 72 hours to activate for security.'),
          SizedBox(height: AppSpacing.sm),
          _buildSecurityItem(Icons.notifications_active, 'Mutual Notifications',
              'Both parties receive alerts for all monitoring activities.'),
          SizedBox(height: AppSpacing.sm),
          _buildSecurityItem(Icons.gavel, 'Legal Compliance',
              'This feature complies with financial regulations and privacy laws.'),
        ],
      ),
    );
  }

  Widget _buildSecurityItem(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.accent, size: 16),
        ),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600)),
              Text(description, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVerificationRequirements() {
    return GlassCard(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Required Verification Steps', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700)),
          SizedBox(height: AppSpacing.md),
          _buildVerificationStep(1, 'Identity Verification', 'Upload NRIC/Passport of family member', true),
          _buildVerificationStep(2, 'Relationship Proof', 'Birth certificate or legal guardianship document', true),
          _buildVerificationStep(3, 'OTP Verification', 'Family member receives SMS/Email code', true),
          _buildVerificationStep(4, 'Video Consent', 'Brief video recording of consent (for seniors)', false),
          _buildVerificationStep(5, 'Cooling Period', '72-hour waiting before activation', true),
        ],
      ),
    );
  }

  Widget _buildVerificationStep(int step, String title, String description, bool required) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text('$step', style: AppTextStyles.bodySmall.copyWith(color: AppColors.accent, fontWeight: FontWeight.w700)),
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(title, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                    if (required) ...[
                      SizedBox(width: AppSpacing.xs),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.negative.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('Required', style: TextStyle(fontSize: 10, color: AppColors.negative, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ],
                ),
                Text(description, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(FamilyMember member) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.md),
      child: GlassCard(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: member.isMinor ? AppColors.accentBlue.withValues(alpha: 0.2) : AppColors.accent.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                member.isMinor ? Icons.child_care : Icons.elderly,
                color: member.isMinor ? AppColors.accentBlue : AppColors.accent,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(member.name, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                  Row(
                    children: [
                      Text(member.relationship, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                      SizedBox(width: AppSpacing.sm),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getStatusColor(member.status).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(member.status, style: TextStyle(fontSize: 10, color: _getStatusColor(member.status), fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _removeMember(member),
              icon: Icon(Icons.remove_circle_outline, color: AppColors.negative),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending Consent':
        return const Color(0xFFFF9800);
      case 'Verified':
        return AppColors.positive;
      case 'Cooling Period':
        return AppColors.accentBlue;
      default:
        return AppColors.textSecondary;
    }
  }

  Widget _buildTermsSection() {
    return GlassCard(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.article_outlined, color: AppColors.accent, size: 20),
              SizedBox(width: AppSpacing.sm),
              Text('Terms & Responsibilities', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Text('By enabling Family Chain, you agree to:', style: AppTextStyles.bodySmall),
          SizedBox(height: AppSpacing.sm),
          _buildTermItem('Use this feature only for legitimate family protection'),
          _buildTermItem('Not misuse monitoring for unauthorized surveillance'),
          _buildTermItem('Respect the privacy and autonomy of monitored members'),
          _buildTermItem('Allow monitored members to request removal at any time'),
          _buildTermItem('Accept liability for any misuse of this feature'),
          SizedBox(height: AppSpacing.md),
          Container(
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.negative.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.negative.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber, color: AppColors.negative, size: 20),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Misuse of Family Chain may result in account suspension and legal action.',
                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.negative),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: AppColors.positive, size: 16),
          SizedBox(width: AppSpacing.xs),
          Expanded(child: Text(text, style: AppTextStyles.labelSmall)),
        ],
      ),
    );
  }

  void _showAddMemberDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final nricController = TextEditingController();
    String? selectedType;
    String? selectedRelationship;
    bool consentChecked = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: AppSpacing.md),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    Text('Add Family Member', style: AppTextStyles.headlineSmall),
                    Spacer(),
                    IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.close)),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Member Type', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                      SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Expanded(child: _buildTypeOption('Minor (Under 18)', Icons.child_care, selectedType == 'minor', () => setModalState(() => selectedType = 'minor'))),
                          SizedBox(width: AppSpacing.md),
                          Expanded(child: _buildTypeOption('Senior (65+)', Icons.elderly, selectedType == 'senior', () => setModalState(() => selectedType = 'senior'))),
                        ],
                      ),
                      SizedBox(height: AppSpacing.lg),
                      Text('Relationship', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                      SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          _buildRelationshipChip('Parent', selectedRelationship, (v) => setModalState(() => selectedRelationship = v)),
                          _buildRelationshipChip('Child', selectedRelationship, (v) => setModalState(() => selectedRelationship = v)),
                          _buildRelationshipChip('Grandparent', selectedRelationship, (v) => setModalState(() => selectedRelationship = v)),
                          _buildRelationshipChip('Spouse', selectedRelationship, (v) => setModalState(() => selectedRelationship = v)),
                          _buildRelationshipChip('Sibling', selectedRelationship, (v) => setModalState(() => selectedRelationship = v)),
                          _buildRelationshipChip('Guardian', selectedRelationship, (v) => setModalState(() => selectedRelationship = v)),
                        ],
                      ),
                      SizedBox(height: AppSpacing.lg),
                      _buildInputField('Full Name (as per NRIC)', nameController, TextInputType.name, 'Enter full legal name'),
                      SizedBox(height: AppSpacing.md),
                      _buildInputField('NRIC / Passport Number', nricController, TextInputType.text, 'e.g., S1234567A'),
                      SizedBox(height: AppSpacing.md),
                      _buildInputField('Phone Number', phoneController, TextInputType.phone, '+65 XXXX XXXX'),
                      SizedBox(height: AppSpacing.lg),
                      Container(
                        padding: EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.accentBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.accentBlue.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.upload_file, color: AppColors.accentBlue, size: 20),
                                SizedBox(width: AppSpacing.sm),
                                Text('Documents Required', style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600, color: AppColors.accentBlue)),
                              ],
                            ),
                            SizedBox(height: AppSpacing.sm),
                            Text(
                              'After submission, you will need to upload:\n• Family member\'s NRIC/Passport\n• Proof of relationship (Birth cert/Marriage cert)\n• Guardianship document (if applicable)',
                              style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: AppSpacing.lg),
                      GestureDetector(
                        onTap: () => setModalState(() => consentChecked = !consentChecked),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: consentChecked ? AppColors.accent : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: consentChecked ? AppColors.accent : AppColors.textSecondary, width: 2),
                              ),
                              child: consentChecked ? Icon(Icons.check, size: 16, color: Colors.white) : null,
                            ),
                            SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                'I confirm that I have the legal authority to add this family member and that they have been informed about this monitoring arrangement.',
                                style: AppTextStyles.labelSmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: PrimaryButton(
                  text: 'Send Verification Request',
                  onPressed: (selectedType != null && selectedRelationship != null && nameController.text.isNotEmpty && nricController.text.isNotEmpty && phoneController.text.isNotEmpty && consentChecked)
                      ? () {
                          setState(() {
                            _familyMembers.add(FamilyMember(name: nameController.text, relationship: selectedRelationship!, isMinor: selectedType == 'minor', status: 'Pending Consent'));
                          });
                          Navigator.pop(context);
                          _showVerificationSentDialog(nameController.text);
                        }
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeOption(String label, IconData icon, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent.withValues(alpha: 0.1) : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? AppColors.accent : AppColors.textSecondary.withValues(alpha: 0.3), width: selected ? 2 : 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? AppColors.accent : AppColors.textSecondary, size: 32),
            SizedBox(height: AppSpacing.xs),
            Text(label, style: AppTextStyles.labelSmall.copyWith(color: selected ? AppColors.accent : AppColors.textSecondary, fontWeight: selected ? FontWeight.w600 : FontWeight.normal), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildRelationshipChip(String label, String? selected, Function(String) onSelect) {
    final isSelected = selected == label;
    return GestureDetector(
      onTap: () => onSelect(label),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.accent : AppColors.textSecondary.withValues(alpha: 0.3)),
        ),
        child: Text(label, style: AppTextStyles.labelSmall.copyWith(color: isSelected ? Colors.white : AppColors.textPrimary, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, TextInputType keyboardType, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
        SizedBox(height: AppSpacing.xs),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.textSecondary.withValues(alpha: 0.3)),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: AppTextStyles.bodyMedium,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(AppSpacing.md),
            ),
          ),
        ),
      ],
    );
  }

  void _showVerificationSentDialog(String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(color: AppColors.positive.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(Icons.send, color: AppColors.positive, size: 48),
            ),
            SizedBox(height: AppSpacing.lg),
            Text('Verification Sent!', style: AppTextStyles.headlineSmall),
            SizedBox(height: AppSpacing.sm),
            Text(
              'A verification request has been sent to $name. They will receive:\n\n• SMS with OTP code\n• Email verification link\n• In-app consent request\n\nOnce they verify, you\'ll need to upload the required documents.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.md),
            Container(
              padding: EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(color: const Color(0xFFFF9800).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  Icon(Icons.schedule, color: const Color(0xFFFF9800), size: 20),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(child: Text('72-hour cooling period applies after verification', style: AppTextStyles.labelSmall.copyWith(color: const Color(0xFFFF9800)))),
                ],
              ),
            ),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('Got it', style: TextStyle(color: AppColors.accent)))],
      ),
    );
  }

  void _removeMember(FamilyMember member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Remove ${member.name}?'),
        content: Text('This will cancel the verification request. You can add them again later.', style: AppTextStyles.bodySmall),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          TextButton(
            onPressed: () {
              setState(() => _familyMembers.remove(member));
              Navigator.pop(context);
            },
            child: Text('Remove', style: TextStyle(color: AppColors.negative)),
          ),
        ],
      ),
    );
  }

  void _showNoMembersWarning() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('No Members Added'),
        content: Text('You enabled Family Chain but haven\'t added any members. Would you like to add someone or disable the feature?', style: AppTextStyles.bodySmall),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _enableFamilyChain = false);
            },
            child: Text('Disable'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showAddMemberDialog();
            },
            child: Text('Add Member', style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }
}

class FamilyMember {
  final String name;
  final String relationship;
  final bool isMinor;
  final String status;

  FamilyMember({required this.name, required this.relationship, required this.isMinor, required this.status});
}
