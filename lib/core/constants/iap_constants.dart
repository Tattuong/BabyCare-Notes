class IapConstants {
  IapConstants._();

  static const String productPrefix = 'bcn';

  static const String remoteConfigUrl = 'https://api2.blwsmartware.net/N216.json';

  static const Duration configTimeout = Duration(seconds: 10);

  static const List<String> coinPackIds = [
    'bcn_pack_1',
    'bcn_pack_2',
    'bcn_pack_3',
    'bcn_pack_4',
    'bcn_pack_5',
    'bcn_pack_6',
    'bcn_pack_7',
    'bcn_pack_8',
    'bcn_pack_9',
    'bcn_pack_10',
  ];

  static const String removeAdsProductId = 'bcn_remove_ads';

  static List<String> get allProductIds => [...coinPackIds, removeAdsProductId];

  static const List<int> coinPackAmounts = [
    50, 100, 200, 350, 500, 750, 1000, 1500, 2200, 3000,
  ];

  static int coinsForProduct(String productId) {
    final index = coinPackIds.indexOf(productId);
    if (index < 0) return 0;
    return coinPackAmounts[index];
  }

  static bool isRemoveAdsProduct(String productId) => productId == removeAdsProductId;

  static const int freeBabyLimit = 2;
  static const int premiumBabyLimit = 2;
  static const int dailyLoginReward = 10;
  static const int logActivityReward = 5;
  static const int maxLogActivityRewardsPerDay = 15;
  static const int milestoneReward = 8;
  static const int maxMilestoneRewardsPerDay = 5;
  static const int streakReward = 15;
  static const int maxStreakRewardsPerDay = 1;
}
