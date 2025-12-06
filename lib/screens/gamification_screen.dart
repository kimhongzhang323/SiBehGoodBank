import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/constants.dart';
import '../widgets/widgets.dart';

/// Gamification - Rewards, badges, and challenges
class GamificationScreen extends StatefulWidget {
  const GamificationScreen({super.key});

  @override
  State<GamificationScreen> createState() => _GamificationScreenState();
}

class _GamificationScreenState extends State<GamificationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // User stats
  final int _currentPoints = 12850;
  final int _currentLevel = 8;
  final int _pointsToNextLevel = 15000;
  final String _currentTier = 'Gold';

  // Challenges
  final List<Challenge> _activeChallenges = [
    Challenge(
      id: '1',
      title: 'Savings Streak',
      description: 'Save money for 7 consecutive days',
      progress: 5,
      total: 7,
      reward: 500,
      icon: Icons.savings,
      color: Colors.green,
      expiresIn: '2 days',
    ),
    Challenge(
      id: '2',
      title: 'Bill Payment Pro',
      description: 'Pay 5 different bills this month',
      progress: 3,
      total: 5,
      reward: 300,
      icon: Icons.receipt_long,
      color: Colors.blue,
      expiresIn: '15 days',
    ),
    Challenge(
      id: '3',
      title: 'Transfer Master',
      description: 'Complete 10 successful transfers',
      progress: 8,
      total: 10,
      reward: 400,
      icon: Icons.swap_horiz,
      color: Colors.purple,
      expiresIn: '10 days',
    ),
    Challenge(
      id: '4',
      title: 'Budget Guardian',
      description: 'Stay under budget for 30 days',
      progress: 22,
      total: 30,
      reward: 1000,
      icon: Icons.shield,
      color: Colors.orange,
      expiresIn: '8 days',
    ),
  ];

  // Badges
  final List<Badge> _badges = [
    Badge(
      id: '1',
      title: 'Early Adopter',
      description: 'Joined SibehGood Bank in the first month',
      icon: Icons.star,
      color: Colors.amber,
      earned: true,
      earnedDate: 'Jan 2024',
    ),
    Badge(
      id: '2',
      title: 'First Transfer',
      description: 'Completed your first transfer',
      icon: Icons.send,
      color: Colors.blue,
      earned: true,
      earnedDate: 'Jan 2024',
    ),
    Badge(
      id: '3',
      title: 'Savings Champion',
      description: 'Saved RM10,000 in total',
      icon: Icons.emoji_events,
      color: Colors.green,
      earned: true,
      earnedDate: 'Mar 2024',
    ),
    Badge(
      id: '4',
      title: 'Security First',
      description: 'Enabled all security features',
      icon: Icons.security,
      color: Colors.purple,
      earned: true,
      earnedDate: 'Feb 2024',
    ),
    Badge(
      id: '5',
      title: 'Bill Ninja',
      description: 'Paid 50 bills through the app',
      icon: Icons.receipt,
      color: Colors.teal,
      earned: true,
      earnedDate: 'Jun 2024',
    ),
    Badge(
      id: '6',
      title: 'Investment Pro',
      description: 'Started your first investment',
      icon: Icons.trending_up,
      color: Colors.indigo,
      earned: false,
    ),
    Badge(
      id: '7',
      title: 'Referral King',
      description: 'Referred 10 friends successfully',
      icon: Icons.people,
      color: Colors.pink,
      earned: false,
    ),
    Badge(
      id: '8',
      title: 'Goal Getter',
      description: 'Completed 5 savings goals',
      icon: Icons.flag,
      color: Colors.orange,
      earned: false,
    ),
  ];

  // Rewards
  final List<Reward> _rewards = [
    Reward(
      id: '1',
      title: 'Grab RM10 Voucher',
      description: 'Valid for GrabFood & GrabMart',
      pointsCost: 2000,
      image: 'grab',
      category: 'Vouchers',
      stock: 50,
    ),
    Reward(
      id: '2',
      title: 'Touch n Go RM5',
      description: 'Instant reload to your TnG eWallet',
      pointsCost: 1000,
      image: 'touchngo',
      category: 'eWallet',
      stock: 100,
    ),
    Reward(
      id: '3',
      title: 'Boost RM5 Voucher',
      description: 'Use for any Boost payment',
      pointsCost: 1000,
      image: 'boost',
      category: 'eWallet',
      stock: 75,
    ),
    Reward(
      id: '4',
      title: 'Agoda RM50 Off',
      description: 'Min. booking RM200',
      pointsCost: 5000,
      image: 'agoda',
      category: 'Travel',
      stock: 25,
    ),
    Reward(
      id: '5',
      title: 'Fee Waiver (1 month)',
      description: 'No monthly maintenance fee',
      pointsCost: 3000,
      image: 'fee',
      category: 'Banking',
      stock: 999,
    ),
    Reward(
      id: '6',
      title: 'Premium Rate Boost',
      description: '+0.5% savings interest for 3 months',
      pointsCost: 8000,
      image: 'rate',
      category: 'Banking',
      stock: 30,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.accent.withOpacity(0.1),
              AppColors.cardBackground,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),
              
              // Stats Card
              _buildStatsCard(),

              // Tab Bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.accent, Color(0xFF667EEA)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorPadding: const EdgeInsets.all(4),
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.textSecondary,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: 'Challenges'),
                    Tab(text: 'Badges'),
                    Tab(text: 'Rewards'),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildChallengesTab(),
                    _buildBadgesTab(),
                    _buildRewardsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rewards Center',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Earn points & unlock rewards',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.amber[600]!, Colors.amber[400]!],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.workspace_premium, color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Text(
                  _currentTier,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    final progress = _currentPoints / _pointsToNextLevel;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF667EEA),
            Color(0xFF764BA2),
            AppColors.accent,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Points',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _currentPoints.toString().replaceAllMapped(
                          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                          (Match m) => '${m[1]},',
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 4, left: 4),
                        child: Text(
                          'pts',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Lv.$_currentLevel',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Icon(
                        Icons.military_tech,
                        color: Colors.amber,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Progress to Level 9',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    '${(_currentPoints / _pointsToNextLevel * 100).toInt()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${_pointsToNextLevel - _currentPoints} points to next level',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChallengesTab() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _activeChallenges.length,
      itemBuilder: (context, index) {
        final challenge = _activeChallenges[index];
        return _buildChallengeCard(challenge);
      },
    );
  }

  Widget _buildChallengeCard(Challenge challenge) {
    final progress = challenge.progress / challenge.total;
    final isCompleted = challenge.progress >= challenge.total;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: challenge.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(challenge.icon, color: challenge.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      challenge.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      challenge.description,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.stars, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '+${challenge.reward}',
                      style: TextStyle(
                        color: Colors.amber[800],
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isCompleted ? AppColors.positive : challenge.color,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${challenge.progress}/${challenge.total}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.timer, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Expires in ${challenge.expiresIn}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              if (isCompleted)
                GestureDetector(
                  onTap: () => _claimChallenge(challenge),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [challenge.color, challenge.color.withOpacity(0.7)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Claim',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadgesTab() {
    final earnedBadges = _badges.where((b) => b.earned).toList();
    final lockedBadges = _badges.where((b) => !b.earned).toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        Text(
          'Earned (${earnedBadges.length})',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: earnedBadges.length,
          itemBuilder: (context, index) {
            return _buildBadgeCard(earnedBadges[index]);
          },
        ),
        const SizedBox(height: 24),
        Text(
          'Locked (${lockedBadges.length})',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: lockedBadges.length,
          itemBuilder: (context, index) {
            return _buildBadgeCard(lockedBadges[index]);
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildBadgeCard(Badge badge) {
    return GestureDetector(
      onTap: () => _showBadgeDetails(badge),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: badge.earned ? Colors.white : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          boxShadow: badge.earned
              ? [
                  BoxShadow(
                    color: badge.color.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: badge.earned
                    ? badge.color.withOpacity(0.1)
                    : Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Icon(
                badge.icon,
                color: badge.earned ? badge.color : Colors.grey[400],
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              badge.title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 11,
                color: badge.earned ? AppColors.textPrimary : Colors.grey[400],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardsTab() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _rewards.length,
      itemBuilder: (context, index) {
        final reward = _rewards[index];
        return _buildRewardCard(reward);
      },
    );
  }

  Widget _buildRewardCard(Reward reward) {
    final canAfford = _currentPoints >= reward.pointsCost;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.card_giftcard,
              color: AppColors.accent,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    reward.category,
                    style: TextStyle(
                      color: AppColors.accent,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  reward.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  reward.description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.stars,
                          color: Colors.amber,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${reward.pointsCost} pts',
                          style: TextStyle(
                            color: canAfford ? AppColors.accent : Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: canAfford ? () => _redeemReward(reward) : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: canAfford
                              ? const LinearGradient(
                                  colors: [AppColors.accent, Color(0xFF667EEA)],
                                )
                              : null,
                          color: canAfford ? null : Colors.grey[300],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Redeem',
                          style: TextStyle(
                            color: canAfford ? Colors.white : Colors.grey[600],
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _claimChallenge(Challenge challenge) {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.positive.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.celebration,
                size: 48,
                color: AppColors.positive,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Challenge Complete!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'You earned +${challenge.reward} points',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 12,
                ),
              ),
              child: const Text('Awesome!'),
            ),
          ),
        ],
      ),
    );
  }

  void _showBadgeDetails(Badge badge) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: badge.earned
                    ? badge.color.withOpacity(0.1)
                    : Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Icon(
                badge.icon,
                size: 48,
                color: badge.earned ? badge.color : Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              badge.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              badge.description,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            if (badge.earned && badge.earnedDate != null) ...[
              const SizedBox(height: 12),
              Text(
                'Earned: ${badge.earnedDate}',
                style: TextStyle(
                  color: badge.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ),
        ],
      ),
    );
  }

  void _redeemReward(Reward reward) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Confirm Redemption'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Redeem ${reward.title}?'),
            const SizedBox(height: 8),
            Text(
              'This will deduct ${reward.pointsCost} points from your balance.',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showRedemptionSuccess(reward);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showRedemptionSuccess(Reward reward) {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.positive.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                size: 48,
                color: AppColors.positive,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Redemption Successful!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${reward.title} has been added to your rewards.',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 12,
                ),
              ),
              child: const Text('Done'),
            ),
          ),
        ],
      ),
    );
  }
}

// Models
class Challenge {
  final String id;
  final String title;
  final String description;
  final int progress;
  final int total;
  final int reward;
  final IconData icon;
  final Color color;
  final String expiresIn;

  const Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.progress,
    required this.total,
    required this.reward,
    required this.icon,
    required this.color,
    required this.expiresIn,
  });
}

class Badge {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool earned;
  final String? earnedDate;

  const Badge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.earned,
    this.earnedDate,
  });
}

class Reward {
  final String id;
  final String title;
  final String description;
  final int pointsCost;
  final String image;
  final String category;
  final int stock;

  const Reward({
    required this.id,
    required this.title,
    required this.description,
    required this.pointsCost,
    required this.image,
    required this.category,
    required this.stock,
  });
}
