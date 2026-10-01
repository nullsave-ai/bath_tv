# بث تي في (Flutter)

تطبيق عربي بالكامل (RTL) للأفلام والمسلسلات والأنمي والبث المباشر، يعمل على الهاتف والتابلت وAndroid TV وGoogle TV بواجهة مخصصة لكل نوع جهاز.

## التشغيل

المتطلبات: Flutter 3.24 أو أحدث، وAndroid SDK.

```bash
bash setup.sh          # يولّد ملفات Android الأساسية ويطبق تعديلات التلفاز
flutter run            # تشغيل على جهاز أو محاكي
flutter build apk --release --split-per-abi
```

سكربت `setup.sh` ضروري مرة واحدة فقط، لأن مجلد `android/` (Gradle) يُولَّد بواسطة Flutter نفسه ثم تُطبَّق فوقه ملفات `android_overrides/`:

- `AndroidManifest.xml`: صلاحيات الشبكة، `LEANBACK_LAUNCHER` لظهور التطبيق في شاشة التلفاز، وعدم اشتراط اللمس.
- `MainActivity.kt`: قناة أصلية `bath_tv/device` لاكتشاف التلفاز.

إن كنت تستخدم Android Studio يدوياً: نفّذ `flutter create --platforms=android --org com.bath --project-name bath_tv .` ثم انسخ محتوى `android_overrides/app` فوق `android/app`.

## الاتصال بخادمك

افتراضياً يعمل التطبيق ببيانات تجريبية محلية (عناوين وقنوات افتراضية وروابط HLS اختبارية). للاتصال بخادم حقيقي:

```bash
flutter run --dart-define=API_BASE_URL=https://api.example.com/v1
```

نقاط النهاية المطلوبة (كلها GET وتعيد JSON):

| المسار | المعاملات | الاستجابة |
|---|---|---|
| `/content` | `section` (`latest`, `popular`, `movies`, `series`, `anime`)، `page`، `page_size` | `{"items":[...],"has_more":true}` |
| `/search` | `q`، `type` (اختياري: `movie`, `series`, `anime`)، `page`، `page_size` | نفس الشكل |
| `/channels` | `category` (اختياري)، `page`، `page_size` | `{"items":[Channel],"has_more":true}` |
| `/channels/search` | `q` | `{"items":[Channel]}` |

عنصر المحتوى: `id`, `title`, `type`, `poster`, `backdrop`, `year`, `rating`, `duration`, `genres[]`, `description`, `stream_url`, `views`، والمسلسلات/الأنمي تحمل `episodes[]` بحقول `id`, `title`, `number`, `season`, `stream_url`, `duration`.

القناة: `id`, `name`, `logo`, `category` (`sports`, `news`, `entertainment`, `kids`, `movies`, `series`), `stream_url`.

## البنية

```
lib/
  core/        الثيم، اكتشاف الجهاز، الأبعاد، ويدجتات مشتركة (Focusable، بطاقات، حالات)
  data/        Models، طبقة API (Dio + مصدر تجريبي)، Repositories
  providers/   إدارة الحالة (Riverpod) مع Pagination
  features/    home, search, live, settings, details, player, shell
```

- فصل كامل بين الواجهة والمنطق: الواجهة تقرأ من Providers، والـ Providers تستدعي Repositories، والـ Repositories تعتمد على `ContentDataSource`.
- كل شاشة لها حالات Loading وEmpty وError.
- Pagination وLazy Loading في صفوف الرئيسية والبحث والقنوات.
- تخزين مؤقت للصور (`cached_network_image`) ولصفحات البيانات في الذاكرة، ومسحهما من الإعدادات.

## دعم التلفاز

- اكتشاف تلقائي (Leanback / UI_MODE_TYPE_TELEVISION)، وواجهة مختلفة: شريط تنقل علوي، أبعاد أكبر، وشبكات أوسع.
- تركيز واضح (إطار أبيض وتكبير خفيف) ومنطقي بالأسهم، وOK/Enter للتنفيذ، وBack للرجوع (من أي قسم يرجع للرئيسية أولاً).
- المشغل بالريموت:
  - أزرار الوسائط: تشغيل/إيقاف، تقديم/ترجيع 30 ثانية، إيقاف.
  - عند إخفاء الأدوات: يمين/يسار تقدّم/ترجّع 10 ثوانٍ، وأي زر آخر يُظهرها.
  - عند ظهورها: الأسهم تنتقل بين الأزرار وOK ينفذ.
  - القنوات المباشرة: `Channel Up/Down` أو `Page Up/Down` للتنقل بين القنوات.
- المشغل مبني على `media_kit` (libmpv) لدعم HLS والتحكم بالجودة وفك الترميز العتادي حتى 4K حسب الجهاز.


## المظهر والتصميم الزجاجي

- لون التطبيق الأساسي `#0057D9`.
- تدرج أسود شفاف ثابت أعلى الشاشة خلف شريط الحالة (أعتم من الأعلى ويخف نزولا)، لا يتأثر بالتمرير.
- شريط تنقل عائم بتمويه زجاجي، مؤشر سائل بفيزياء نابض يتمدد مع السرعة ويدعم السحب.
- تفاعلات نابضة (Spring) عند اللمس والتركيز، وتمرير مرتد بدل أسلوب Material، وانتقالات ضبابية ناعمة.
- صفحة البث: ثلاث بطاقات أفقية في الصف (أربع على التلفاز) مع البرنامج الحالي وشريط تقدمه وظهور متتابع.
- تبديل الوضع النهاري والليلي من الإعدادات.

## ملاحظات مهمة

- **جودة الفيديو**: القائمة تُبنى من مسارات الفيديو (variants) التي يكشفها البث نفسه. إن لم يوفر البث أكثر من مسار تظهر رسالة بذلك. اختيار "تلقائي" هو الوضع الافتراضي.
- **الإشعارات**: الإعداد محفوظ محلياً فقط. الإشعارات الفعلية تتطلب ربط Firebase Cloud Messaging أو خدمتك الخاصة.
- **الحساب**: اسم عرض محلي فقط. تسجيل دخول حقيقي يحتاج ربطاً بخادمك.
- **سياسة الخصوصية**: نص عام مبدئي، استبدله بنصك القانوني قبل النشر.
- **Play Store للتلفاز**: يلزم `android:banner` بصورة 320x180، وهو الآن يستخدم أيقونة التطبيق مؤقتاً.
- روابط البث والصور التجريبية عامة للاختبار فقط.
- الحزم المستخدمة: `flutter_riverpod`, `dio`, `cached_network_image`, `shared_preferences`, `media_kit`, `wakelock_plus`, `package_info_plus`.
