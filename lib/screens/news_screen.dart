import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/constants.dart';

/// News & Updates - Latest banking news, promotions, and financial tips
class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Promotions',
    'Updates',
    'Tips',
    'Security',
  ];

  final List<NewsItem> _newsItems = [
    NewsItem(
      id: '1',
      title: '🎉 Year-End Mega Sale! Up to 20% Cashback',
      summary: 'Enjoy up to 20% cashback when you spend with SibehGood Card at participating merchants this festive season.',
      content: '''
Get ready for the biggest sale of the year! From now until December 31st, enjoy amazing cashback rewards when you use your SibehGood Card.

**Highlights:**
• 20% cashback at selected fashion outlets
• 15% cashback at electronics stores
• 10% cashback at restaurants and cafes
• 5% cashback everywhere else

**Terms & Conditions:**
• Minimum spend of RM50 per transaction
• Maximum cashback of RM500 per month
• Valid for all SibehGood cardholders

Don't miss out on this exclusive offer!
      ''',
      category: 'Promotions',
      imageUrl: 'promo',
      date: DateTime.now().subtract(const Duration(hours: 2)),
      isNew: true,
      isPinned: true,
    ),
    NewsItem(
      id: '2',
      title: '🔒 New Security Feature: Face ID Login',
      summary: 'We\'ve added Face ID support for faster and more secure login to your banking app.',
      content: '''
Your security is our top priority. We're excited to announce that Face ID login is now available for all iOS users!

**How to Enable:**
1. Go to Settings > Security
2. Tap on "Biometric Login"
3. Select "Face ID"
4. Follow the on-screen instructions

**Benefits:**
• Faster login experience
• Enhanced security
• No need to remember passwords
• Works even in low light

Update your app now to enjoy this feature!
      ''',
      category: 'Security',
      imageUrl: 'security',
      date: DateTime.now().subtract(const Duration(hours: 5)),
      isNew: true,
    ),
    NewsItem(
      id: '3',
      title: '💡 Financial Tip: The 50/30/20 Budget Rule',
      summary: 'Learn how to manage your money effectively with this simple budgeting technique.',
      content: '''
Managing your finances doesn't have to be complicated. The 50/30/20 rule is a simple way to budget your income.

**The Rule:**
• **50% Needs** - Rent, utilities, groceries, insurance
• **30% Wants** - Entertainment, dining out, hobbies
• **20% Savings** - Emergency fund, investments, debt repayment

**How to Apply:**
1. Calculate your after-tax income
2. Allocate 50% to necessities
3. Set aside 30% for discretionary spending
4. Save or invest the remaining 20%

**Pro Tip:** Use our Budget Tracker feature to automatically categorize your spending!
      ''',
      category: 'Tips',
      imageUrl: 'tips',
      date: DateTime.now().subtract(const Duration(days: 1)),
    ),
    NewsItem(
      id: '4',
      title: '🚀 App Update v3.5: New Features Inside!',
      summary: 'Check out what\'s new in the latest version of SibehGood Bank app.',
      content: '''
We've been working hard to bring you new features and improvements!

**What's New in v3.5:**
• **Dark Mode** - Easier on your eyes at night
• **Quick Transfer** - Save frequent recipients
• **Bill Reminders** - Never miss a payment
• **Currency Converter** - Real-time exchange rates
• **Enhanced Charts** - Better spending visualization

**Bug Fixes:**
• Fixed notification delays
• Improved app loading speed
• Better Touch ID reliability

Update now from App Store or Google Play!
      ''',
      category: 'Updates',
      imageUrl: 'update',
      date: DateTime.now().subtract(const Duration(days: 2)),
    ),
    NewsItem(
      id: '5',
      title: '🍜 Grab 30% Off with GrabFood!',
      summary: 'Use code SIBEHGOOD30 for 30% off your next GrabFood order.',
      content: '''
Hungry? We've partnered with GrabFood to bring you exclusive savings!

**Offer Details:**
• 30% off with code: SIBEHGOOD30
• Maximum discount: RM15
• Valid until: December 31, 2024

**How to Redeem:**
1. Open GrabFood app
2. Add items to cart
3. Apply code at checkout
4. Pay with SibehGood Card for extra rewards!

*Terms apply. Limited redemptions available.
      ''',
      category: 'Promotions',
      imageUrl: 'grab',
      date: DateTime.now().subtract(const Duration(days: 3)),
    ),
    NewsItem(
      id: '6',
      title: '⚠️ Security Alert: Beware of Phishing Scams',
      summary: 'Learn how to identify and protect yourself from banking scams.',
      content: '''
We've noticed an increase in phishing attempts targeting our customers. Stay vigilant!

**Red Flags to Watch:**
• Emails asking for your TAC or password
• Links to suspicious websites
• Urgent requests for personal information
• Calls claiming to be from "bank security"

**Remember:**
• SibehGood Bank will NEVER ask for your password
• Always verify links before clicking
• Report suspicious activity immediately
• Enable two-factor authentication

**If You're a Victim:**
1. Contact us immediately at 1-800-88-SIBEH
2. Change your password
3. Review recent transactions
4. File a police report if necessary
      ''',
      category: 'Security',
      imageUrl: 'alert',
      date: DateTime.now().subtract(const Duration(days: 4)),
    ),
    NewsItem(
      id: '7',
      title: '💰 High Interest Savings: Now 4.5% p.a.!',
      summary: 'Our premium savings account now offers the highest interest rate in town.',
      content: '''
Great news for savers! We've increased our premium savings interest rate.

**Premium Savings Features:**
• 4.5% p.a. interest rate
• No minimum balance required
• Free unlimited withdrawals
• Daily interest calculation

**How to Upgrade:**
1. Log in to your app
2. Go to Accounts > Upgrade
3. Select Premium Savings
4. Start earning more today!

*Interest rates subject to change. T&C apply.
      ''',
      category: 'Promotions',
      imageUrl: 'savings',
      date: DateTime.now().subtract(const Duration(days: 5)),
    ),
    NewsItem(
      id: '8',
      title: '📊 Tip: How to Read Your Credit Score',
      summary: 'Understanding your credit score and how to improve it.',
      content: '''
Your credit score affects your ability to get loans and credit cards. Here's what you need to know.

**Score Ranges:**
• 750-850: Excellent
• 700-749: Good
• 650-699: Fair
• Below 650: Needs Improvement

**Factors Affecting Your Score:**
1. Payment history (35%)
2. Credit utilization (30%)
3. Length of credit history (15%)
4. Credit mix (10%)
5. New credit inquiries (10%)

**Tips to Improve:**
• Pay bills on time
• Keep credit utilization below 30%
• Don't close old accounts
• Limit new credit applications

Check your free credit score in our app!
      ''',
      category: 'Tips',
      imageUrl: 'credit',
      date: DateTime.now().subtract(const Duration(days: 7)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<NewsItem> get _filteredNews {
    if (_selectedCategory == 'All') {
      return _newsItems;
    }
    return _newsItems
        .where((item) => item.category == _selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Category Filter
            _buildCategoryFilter(),

            // News List
            Expanded(
              child: _buildNewsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
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
                  'News & Updates',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Stay informed with latest updates',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
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
            child: Stack(
              children: [
                const Icon(Icons.notifications_outlined,
                    color: AppColors.textPrimary),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.negative,
                      shape: BoxShape.circle,
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

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedCategory = category);
            },
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [AppColors.accent, Color(0xFF667EEA)],
                      )
                    : null,
                color: isSelected ? null : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? AppColors.accent.withOpacity(0.3)
                        : Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                category,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNewsList() {
    final news = _filteredNews;
    final pinnedNews = news.where((n) => n.isPinned).toList();
    final regularNews = news.where((n) => !n.isPinned).toList();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Pinned/Featured News
        if (pinnedNews.isNotEmpty) ...[
          ...pinnedNews.map((item) => _buildFeaturedCard(item)),
          const SizedBox(height: 16),
        ],

        // Regular News
        if (regularNews.isNotEmpty) ...[
          const Text(
            'Recent Updates',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...regularNews.map((item) => _buildNewsCard(item)),
        ],
      ],
    );
  }

  Widget _buildFeaturedCard(NewsItem item) {
    return GestureDetector(
      onTap: () => _showNewsDetail(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
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
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              'Featured',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      if (item.isNew)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.positive,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'NEW',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    item.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.summary,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDate(item.date),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Read More',
                          style: TextStyle(
                            color: AppColors.accent,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
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
      ),
    );
  }

  Widget _buildNewsCard(NewsItem item) {
    return GestureDetector(
      onTap: () => _showNewsDetail(item),
      child: Container(
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
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: _getCategoryColor(item.category).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getCategoryIcon(item.category),
                color: _getCategoryColor(item.category),
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(item.category).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.category,
                          style: TextStyle(
                            color: _getCategoryColor(item.category),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (item.isNew)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.positive,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'NEW',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(item.date),
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Promotions':
        return Colors.orange;
      case 'Updates':
        return Colors.blue;
      case 'Tips':
        return Colors.green;
      case 'Security':
        return Colors.red;
      default:
        return AppColors.accent;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Promotions':
        return Icons.local_offer;
      case 'Updates':
        return Icons.system_update;
      case 'Tips':
        return Icons.lightbulb;
      case 'Security':
        return Icons.security;
      default:
        return Icons.article;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inHours < 1) {
      return '${diff.inMinutes} minutes ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} hours ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showNewsDetail(NewsItem item) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewsDetailScreen(news: item),
      ),
    );
  }
}

// News Detail Screen
class NewsDetailScreen extends StatelessWidget {
  final NewsItem news;

  const NewsDetailScreen({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBackground,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.accent,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () => _shareNews(context),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.share, color: Colors.white),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF667EEA),
                      Color(0xFF764BA2),
                      AppColors.accent,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -50,
                      top: -50,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      left: -30,
                      bottom: -30,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Center(
                      child: Icon(
                        _getCategoryIcon(news.category),
                        size: 80,
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category & Date
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(news.category).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          news.category,
                          style: TextStyle(
                            color: _getCategoryColor(news.category),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _formatDate(news.date),
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Title
                  Text(
                    news.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Summary
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.accent.withOpacity(0.2),
                      ),
                    ),
                    child: Text(
                      news.summary,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Content
                  Text(
                    news.content,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      height: 1.8,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Action Button
                  if (news.category == 'Promotions')
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Promotion activated! 🎉'),
                              backgroundColor: AppColors.positive,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Activate Promotion',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Promotions':
        return Icons.local_offer;
      case 'Updates':
        return Icons.system_update;
      case 'Tips':
        return Icons.lightbulb;
      case 'Security':
        return Icons.security;
      default:
        return Icons.article;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Promotions':
        return Colors.orange;
      case 'Updates':
        return Colors.blue;
      case 'Tips':
        return Colors.green;
      case 'Security':
        return Colors.red;
      default:
        return AppColors.accent;
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _shareNews(BuildContext context) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Link copied to clipboard!'),
        backgroundColor: AppColors.accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

// News Item Model
class NewsItem {
  final String id;
  final String title;
  final String summary;
  final String content;
  final String category;
  final String imageUrl;
  final DateTime date;
  final bool isNew;
  final bool isPinned;

  const NewsItem({
    required this.id,
    required this.title,
    required this.summary,
    required this.content,
    required this.category,
    required this.imageUrl,
    required this.date,
    this.isNew = false,
    this.isPinned = false,
  });
}
