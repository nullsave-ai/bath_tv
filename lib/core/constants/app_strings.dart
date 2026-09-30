/// جميع نصوص التطبيق (عربية فقط).
class AppStrings {
  AppStrings._();

  static const appName = 'بث تي في';

  // التنقل
  static const navHome = 'الرئيسية';
  static const navSearch = 'البحث';
  static const navLive = 'البث المباشر';
  static const navSettings = 'الإعدادات';

  // الرئيسية
  static const latestAdditions = 'أحدث الإضافات';
  static const mostWatched = 'الأكثر مشاهدة';
  static const movies = 'أفلام';
  static const series = 'مسلسلات';
  static const anime = 'أنمي';
  static const continueWatching = 'متابعة المشاهدة';
  static const watchNow = 'تشغيل';
  static const details = 'التفاصيل';
  static const episodes = 'الحلقات';
  static const episodeWord = 'الحلقة';
  static const seasonWord = 'الموسم';
  static const minutesUnit = 'دقيقة';
  static const resume = 'متابعة المشاهدة';
  static const noSource = 'مصدر التشغيل غير متوفر لهذا المحتوى';

  // البحث
  static const searchHint = 'ابحث عن فيلم أو مسلسل أو أنمي أو قناة';
  static const searchPrompt = 'ابحث عن أفلام ومسلسلات وأنمي وقنوات';
  static const searchPromptSub = 'اكتب اسم المحتوى الذي تريده';
  static const searchHistory = 'سجل البحث';
  static const clearHistory = 'مسح السجل';
  static const filterAll = 'الكل';
  static const filterChannels = 'القنوات';
  static const contentResults = 'الأفلام والمسلسلات والأنمي';
  static const channelResults = 'القنوات';
  static const noResults = 'لا توجد نتائج';
  static String noResultsFor(String q) => 'لم نعثر على نتائج مطابقة لـ "$q"';

  // البث المباشر
  static const liveNow = 'مباشر';
  static const noChannels = 'لا توجد قنوات في هذا التصنيف';
  static const channelCategory = 'تصنيف القناة';

  // المشغل
  static const reconnecting = 'جارٍ إعادة الاتصال';
  static const playbackFailed = 'تعذر تشغيل المحتوى';
  static const retry = 'إعادة المحاولة';
  static const quality = 'جودة الفيديو';
  static const qualityAuto = 'تلقائي';
  static const qualityUnavailable = 'لا تتوفر خيارات جودة لهذا البث';
  static const fullscreen = 'ملء الشاشة';
  static const exitFullscreen = 'تصغير الشاشة';
  static const back = 'رجوع';
  static const play = 'تشغيل';
  static const pause = 'إيقاف مؤقت';
  static const rewind10 = 'رجوع 10 ثوانٍ';
  static const forward10 = 'تقديم 10 ثوانٍ';
  static const nextChannel = 'القناة التالية';
  static const previousChannel = 'القناة السابقة';
  static const ok = 'موافق';
  static const cancel = 'إلغاء';
  static const save = 'حفظ';

  // الإعدادات
  static const settingsAccount = 'الحساب';
  static const accountName = 'اسم العرض';
  static const guest = 'ضيف';
  static const accountSubtitle = 'اضغط لتعديل بيانات الحساب';
  static const signOut = 'مسح بيانات الحساب';
  static const settingsPlayback = 'إعدادات تشغيل الفيديو';
  static const resumePlayback = 'استئناف من آخر موضع';
  static const resumePlaybackSub = 'متابعة المشاهدة من حيث توقفت';
  static const autoReconnect = 'إعادة الاتصال تلقائياً';
  static const autoReconnectSub = 'محاولة استعادة البث عند انقطاعه';
  static const videoQuality = 'جودة الفيديو';
  static const qualityAutoRecommended = 'تلقائي (موصى به)';
  static const qualityMode = 'وضع الجودة';
  static const settingsNotifications = 'الإشعارات';
  static const settingsAppearance = 'المظهر';
  static const darkMode = 'الوضع الليلي';
  static const darkModeSub = 'التبديل بين الوضع الليلي والوضع النهاري';
  static const notificationsToggle = 'تفعيل الإشعارات';
  static const notificationsSub = 'تنبيهات المحتوى الجديد';
  static const settingsStorage = 'التخزين';
  static const clearCache = 'مسح ذاكرة التخزين المؤقت';
  static const clearCacheSub = 'حذف الصور والبيانات المخزنة مؤقتاً';
  static const cacheCleared = 'تم مسح ذاكرة التخزين المؤقت';
  static const settingsAbout = 'حول';
  static const aboutApp = 'حول التطبيق';
  static const privacyPolicy = 'سياسة الخصوصية';
  static const appVersion = 'إصدار التطبيق';
  static const aboutBody =
      'تطبيق عربي لمشاهدة الأفلام والمسلسلات والأنمي والبث المباشر، '
      'مصمم ليعمل بسلاسة على الهاتف والتابلت والتلفاز.';

  // حالات عامة
  static const loading = 'جارٍ التحميل';
  static const loadingMore = 'جارٍ تحميل المزيد';
  static const genericError = 'حدث خطأ غير متوقع';
  static const noContent = 'لا يوجد محتوى حالياً';
  static const pullToRefresh = 'اسحب للتحديث';
  static const noConnection = 'تعذر الاتصال بالإنترنت. تحقق من الشبكة وحاول مرة أخرى.';
  static const timeout = 'انتهت مهلة الاتصال بالخادم. حاول مرة أخرى.';
  static const badResponse = 'استجابة غير صالحة من الخادم';
  static String serverError(int? code) => 'خطأ من الخادم (${code ?? '-'})';
}
