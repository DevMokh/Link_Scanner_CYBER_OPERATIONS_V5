import 'package:flutter/material.dart';

import '../core/app_info.dart';
import '../core/models.dart';
import '../core/theme.dart';
import '../services/history_store.dart';
import '../services/settings_store.dart';
import '../widgets/app_menu_glyph.dart';
import '../widgets/brand_logo.dart';
import '../widgets/common.dart';
import '../widgets/stats_card.dart';

const List<String> _tips = <String>[
  'لو رسالة بتهدّدك بإيقاف حسابك خلال ساعات، دي علامة نصب كلاسيكية. البنوك الحقيقية مش بتستعجلك كده.',
  'محدش رسمي (بنك، محفظة، شركة اتصالات) هيطلب منك كود التحقق أو الـ CVV في مكالمة أو رسالة. اقفل الخط.',
  'اقرأ اسم الدومين من اليمين لليسار قبل الـ.com أو .eg. الجزء الأهم هو أقرب حاجة لنوع الامتداد.',
  'لو حد قالك "رقمي اتغير" وطلب فلوس، اتصل بالرقم القديم أو اسأله سؤال يعرفه هو بس قبل ما تحول.',
  'رمز QR ممكن يتلصق فوق رمز حقيقي في محل أو عداد ركن. راجع اسم الموقع بعد ما تفحصه قبل الدفع.',
  'لا تثبت تطبيق تحكم عن بعد بناءً على طلب حد اتصل بيك وقال إنه دعم فني.',
  'وظيفة بتطلب فلوس تسجيل مقدمًا هي نصب في الأغلب، مهما كان المرتب المعروض مغري.',
  'لو الرسالة فيها رابط ومعاه استعجال أو تهديد، افتراض إنه نصب أأمن ليك من فتحه.',
  'غيّر كلمة السر فورًا لو ضغطت على رابط مشبوه وكتبت بياناتك، وفعّل التحقق بخطوتين لو متاح.',
  'الجهات الحكومية (تموين، تأمينات، كهرباء) مش بترسل روابط دفع أو تهديد بقطع خدمة برسالة SMS.',
];

String _tipOfDay() {
  final day = DateTime.now().difference(DateTime(2026, 1, 1)).inDays;
  return _tips[day % _tips.length];
}

String _t(String ar, String en) => SettingsStore.instance.english ? en : ar;

int countThreats(List<HistoryItem> items) {
  var n = 0;
  for (final it in items) {
    if (it.level == RiskLevel.high || it.level == RiskLevel.critical) n++;
  }
  return n;
}

int countUrlScans(List<HistoryItem> items) {
  var n = 0;
  for (final it in items) {
    if (it.kind == ScanKind.url) n++;
  }
  return n;
}

String agoText(DateTime t, {DateTime? now}) {
  final d = (now ?? DateTime.now()).difference(t);
  if (d.inMinutes < 1) return _t('الآن', 'just now');
  if (d.inMinutes < 60) return _t('منذ ${d.inMinutes} دقيقة', '${d.inMinutes} min ago');
  if (d.inHours < 24) return _t('منذ ${d.inHours} ساعة', '${d.inHours} h ago');
  return _t('منذ ${d.inDays} يوم', '${d.inDays} d ago');
}

/// Cyber operations dashboard. Actions and scan destinations remain unchanged.
class HomeDashboard extends StatelessWidget {
  const HomeDashboard({
    super.key,
    required this.onTab,
    required this.onQr,
    required this.onImage,
    required this.onSender,
    required this.onBatch,
    required this.onTrain,
    required this.onLearn,
    required this.onSettings,
    required this.onMenu,
  });

  final void Function(int tabIndex) onTab;
  final VoidCallback onQr;
  final VoidCallback onImage;
  final VoidCallback onSender;
  final VoidCallback onBatch;
  final VoidCallback onTrain;
  final VoidCallback onLearn;
  final VoidCallback onSettings;
  final VoidCallback onMenu;

  Widget _topBar(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, top + 10, 16, 15),
      child: Row(
        children: [
          const LinkScannerLogo(size: 42, glowing: false),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(kAppNameAr, style: TextStyle(color: C.text, fontSize: 17, fontWeight: FontWeight.w900)),
                const SizedBox(height: 2),
                const Text(
                  'LINK SCANNER  //  SOC TERMINAL',
                  style: TextStyle(color: C.secondary, fontSize: 9, fontWeight: FontWeight.w900, fontFamily: 'monospace', letterSpacing: 0.45),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
            decoration: BoxDecoration(
              color: alpha(C.green, 0.07),
              border: Border.all(color: alpha(C.green, 0.28)),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 6, height: 6, decoration: const BoxDecoration(color: C.green, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              const Text('READY', style: TextStyle(color: C.green, fontSize: 9, fontWeight: FontWeight.w900, fontFamily: 'monospace')),
            ]),
          ),
          const SizedBox(width: 7),
          Material(
            color: C.surface2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7), side: const BorderSide(color: C.line)),
            child: InkWell(
              borderRadius: BorderRadius.circular(7),
              onTap: onMenu,
              child: Tooltip(
                message: 'فتح القائمة الجانبية',
                child: Semantics(
                  button: true,
                  label: 'فتح القائمة الجانبية',
                  child: const SizedBox(width: 40, height: 40, child: Center(child: AppMenuGlyph(size: 22))),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _hero({required String detail, required VoidCallback onScan}) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: C.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: alpha(C.accent, 0.52)),
        boxShadow: glow(C.accent, opacity: 0.10, blur: 22),
      ),
      child: Stack(
        children: [
          const Positioned.fill(child: CyberGrid(opacity: 0.55, child: SizedBox.expand())),
          Positioned(left: -36, top: -48, child: Container(
            width: 130, height: 130,
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: alpha(C.secondary, 0.10), width: 20)),
          )),
          Padding(
            padding: const EdgeInsets.fromLTRB(17, 16, 17, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(children: [
                  const Icon(Icons.terminal_rounded, color: C.accent, size: 17),
                  const SizedBox(width: 7),
                  Text(_t('لوحة العمليات الأمنية', 'SECURITY OPERATIONS'), style: const TextStyle(color: C.secondary, fontFamily: 'monospace', fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.55)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(color: alpha(C.green, 0.08), border: Border.all(color: alpha(C.green, 0.30)), borderRadius: BorderRadius.circular(5)),
                    child: Text(_t('المحرك جاهز', 'ENGINE READY'), style: const TextStyle(color: C.green, fontSize: 9, fontFamily: 'monospace', fontWeight: FontWeight.w900)),
                  ),
                ]),
                const SizedBox(height: 18),
                Text(
                  _t('افحص. حلّل.\nاتخذ قرارك.', 'SCAN. ANALYZE.\nMAKE YOUR CALL.'),
                  style: const TextStyle(color: C.text, fontSize: 25, height: 1.18, fontWeight: FontWeight.w900, letterSpacing: -0.3),
                ),
                const SizedBox(height: 9),
                Text(detail, style: const TextStyle(color: C.muted, fontSize: 11.5, height: 1.55)),
                const SizedBox(height: 17),
                SizedBox(
                  height: 50,
                  child: FilledButton.icon(
                    onPressed: onScan,
                    style: FilledButton.styleFrom(
                      backgroundColor: C.accent,
                      foregroundColor: C.onAccent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                    ),
                    icon: const Icon(Icons.radar_rounded, size: 21),
                    label: Text(_t('ابدأ تحليل رابط', 'START URL ANALYSIS')),
                  ),
                ),
                const SizedBox(height: 9),
                Row(children: [
                  const Icon(Icons.lock_outline_rounded, color: C.green, size: 13),
                  const SizedBox(width: 6),
                  Expanded(child: Text(_t('التحليل الأساسي محلي على جهازك', 'Core analysis runs locally on your device'), style: const TextStyle(color: C.muted, fontSize: 10))),
                  const Text('NODE / 01', style: TextStyle(color: C.secondary, fontFamily: 'monospace', fontSize: 9, fontWeight: FontWeight.w800)),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(IconData icon, String value, String label, Color color, String code) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(9, 10, 9, 11),
        decoration: BoxDecoration(color: C.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: C.line)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Icon(icon, color: color, size: 17), const Spacer(), Text(code, style: const TextStyle(color: C.muted, fontFamily: 'monospace', fontSize: 8))]),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w900, fontFamily: 'monospace')),
          const SizedBox(height: 2),
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: C.muted, fontSize: 9.5, fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }

  Widget _toolTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color tint = C.accent,
    bool featured = false,
  }) {
    return Material(
      color: C.surface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 84),
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: featured ? alpha(tint, 0.055) : C.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: featured ? alpha(tint, 0.55) : C.line),
          ),
          child: Row(children: [
            Container(
              width: 37, height: 37,
              decoration: BoxDecoration(color: alpha(tint, 0.09), border: Border.all(color: alpha(tint, 0.25)), borderRadius: BorderRadius.circular(7)),
              child: Icon(icon, color: tint, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: C.text, fontSize: 12, fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: C.muted, fontSize: 9.5, height: 1.25)),
            ])),
            const SizedBox(width: 4),
            Icon(Icons.chevron_left_rounded, color: alpha(tint, 0.85), size: 18),
          ]),
        ),
      ),
    );
  }

  Widget _quick(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: Material(
        color: C.surface2,
        borderRadius: BorderRadius.circular(7),
        child: InkWell(
          borderRadius: BorderRadius.circular(7),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 11),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(7), border: Border.all(color: C.line)),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(icon, color: C.secondary, size: 16),
              const SizedBox(width: 7),
              Flexible(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: C.text, fontWeight: FontWeight.w800, fontSize: 10.5))),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _recent(HistoryItem it) {
    final c = levelColor(it.level);
    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
      decoration: BoxDecoration(color: C.surface, borderRadius: BorderRadius.circular(7), border: Border.all(color: C.line)),
      child: Row(children: [
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(color: alpha(c, 0.07), borderRadius: BorderRadius.circular(6), border: Border.all(color: alpha(c, 0.35))),
          child: Center(child: Text('${it.score}', style: TextStyle(color: c, fontWeight: FontWeight.w900, fontSize: 12, fontFamily: 'monospace'))),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Directionality(
            textDirection: it.kind == ScanKind.url ? TextDirection.ltr : TextDirection.rtl,
            child: Text(it.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: C.text, fontSize: 11.5, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(height: 4),
          Text('${it.level.label}  /  ${agoText(it.time)}', style: TextStyle(color: c, fontSize: 9.5, fontFamily: 'monospace')),
        ])),
        Icon(it.kind == ScanKind.url ? Icons.link_rounded : Icons.mark_email_unread_rounded, color: C.secondary, size: 17),
      ]),
    );
  }

  Widget _tipCard() {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(color: alpha(C.secondary, 0.035), borderRadius: BorderRadius.circular(8), border: Border.all(color: alpha(C.secondary, 0.25))),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.terminal_rounded, color: C.secondary, size: 19),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_t('ملاحظة أمنية // SECURITY NOTE', 'SECURITY NOTE // DAILY INTEL'), style: const TextStyle(color: C.secondary, fontSize: 9, fontWeight: FontWeight.w900, fontFamily: 'monospace', letterSpacing: 0.45)),
          const SizedBox(height: 6),
          Text(_tipOfDay(), style: const TextStyle(color: C.text, fontSize: 11.5, height: 1.55)),
        ])),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: HistoryStore.instance,
      builder: (context, _) {
        final items = HistoryStore.instance.items;
        final detail = items.isEmpty
            ? _t('افحص الروابط والرسائل المشبوهة قبل فتحها. كل أدوات التحليل في لوحة واحدة.', 'Inspect suspicious links and messages before opening them. All analysis tools in one console.')
            : '${_t('آخر عملية', 'LAST OPERATION')}: ${agoText(items.first.time)}  /  ${_t('الفحص يبدأ بطلبك فقط', 'SCANS RUN ONLY ON REQUEST')}';

        return ListView(
          padding: EdgeInsets.zero,
          children: [
            _topBar(context),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 26),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                _hero(detail: detail, onScan: () => onTab(1)),
                const SizedBox(height: 13),
                Row(children: [
                  _stat(Icons.link_rounded, '${countUrlScans(items)}', _t('روابط مفحوصة', 'URL SCANS'), C.secondary, 'URL'),
                  const SizedBox(width: 8),
                  _stat(Icons.warning_amber_rounded, '${countThreats(items)}', _t('تهديدات', 'THREATS'), C.red, 'RISK'),
                  const SizedBox(width: 8),
                  _stat(Icons.manage_search_rounded, '${items.length}', _t('إجمالي الفحوص', 'TOTAL'), C.accent, 'ALL'),
                ]),
                const SizedBox(height: 7),
                Text(
                  items.length >= HistoryStore.maxItems
                      ? _t('إحصائيات من سجل الجهاز — يتم الاحتفاظ بآخر ${HistoryStore.maxItems} فحص.', 'On-device history — the latest ${HistoryStore.maxItems} scans are kept.')
                      : _t('الأرقام مأخوذة من سجل الفحوصات المحفوظ على جهازك.', 'Metrics are derived from your on-device scan history.'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: C.muted, fontSize: 9.5),
                ),
                const SizedBox(height: 16),
                SectionTitle(_t('وحدات التحليل', 'ANALYSIS MODULES')),
                Text(_t('اختر وحدة الفحص المطلوبة.', 'Select an analysis module.'), style: const TextStyle(color: C.muted, fontSize: 10.5)),
                const SizedBox(height: 9),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1.66,
                  children: [
                    _toolTile(icon: Icons.link_rounded, title: _t('فحص رابط', 'URL ANALYZER'), subtitle: _t('تحليل عنوان الموقع', 'URL risk analysis'), onTap: () => onTab(1), featured: true),
                    _toolTile(icon: Icons.mark_email_unread_rounded, title: _t('فحص رسالة', 'MESSAGE SCAN'), subtitle: _t('استخراج الروابط والإشارات', 'Links and warning signs'), onTap: () => onTab(2), tint: C.secondary),
                    _toolTile(icon: Icons.qr_code_scanner_rounded, title: _t('فحص QR', 'QR INSPECTOR'), subtitle: _t('قراءة الرمز وفحصه', 'Read and inspect a code'), onTap: onQr, tint: C.green),
                    _toolTile(icon: Icons.image_search_rounded, title: _t('فحص صورة', 'IMAGE ANALYSIS'), subtitle: _t('استخراج النصوص والروابط', 'Extract text and links'), onTap: onImage, tint: C.amber),
                    _toolTile(icon: Icons.alternate_email_rounded, title: _t('فحص المرسل', 'SENDER CHECK'), subtitle: _t('تحليل بيانات المرسل', 'Inspect sender details'), onTap: onSender, tint: C.orange),
                    _toolTile(icon: Icons.playlist_add_check_rounded, title: _t('فحص مجمّع', 'BATCH SCAN'), subtitle: _t('فحص أكثر من رابط', 'Scan multiple URLs'), onTap: onBatch, tint: C.accent),
                  ],
                ),
                const SizedBox(height: 17),
                SectionTitle(_t('التدريب والمعرفة', 'TRAINING & KNOWLEDGE')),
                Row(children: [
                  Expanded(child: _toolTile(icon: Icons.sports_esports_rounded, title: _t('تدرّب على الكشف', 'TRAINING LAB'), subtitle: _t('تحديات كشف الاحتيال', 'Phishing detection drills'), onTap: onTrain, tint: C.secondary)),
                  const SizedBox(width: 8),
                  Expanded(child: _toolTile(icon: Icons.school_rounded, title: _t('دروس الحماية', 'FIELD GUIDE'), subtitle: _t('إرشادات عملية', 'Practical guidance'), onTap: onLearn, tint: C.accent)),
                ]),
                const SizedBox(height: 9),
                Row(children: [
                  _quick(Icons.grid_view_rounded, _t('كل الأدوات', 'ALL TOOLS'), () => onTab(4)),
                  const SizedBox(width: 8),
                  _quick(Icons.settings_rounded, _t('الإعدادات', 'SETTINGS'), onSettings),
                ]),
                const SizedBox(height: 17),
                if (items.isNotEmpty) ...[
                  SectionTitle(_t('سجل النشاط الأخير', 'RECENT ACTIVITY'), trailing: TextButton(onPressed: () => onTab(3), child: Text(_t('عرض الكل', 'VIEW ALL')))),
                  for (final it in items.take(3)) _recent(it),
                  const SizedBox(height: 3),
                  StatsCard(items: items),
                  const SizedBox(height: 16),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 13),
                    decoration: BoxDecoration(color: C.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: C.line)),
                    child: Row(children: [
                      const Icon(Icons.history_toggle_off_rounded, color: C.muted, size: 25),
                      const SizedBox(width: 11),
                      Expanded(child: Text(_t('لا توجد عمليات محفوظة حتى الآن. أول فحص سيظهر هنا.', 'No saved operations yet. Your first scan will appear here.'), style: const TextStyle(color: C.muted, fontSize: 11.5, height: 1.5))),
                    ]),
                  ),
                  const SizedBox(height: 16),
                ],
                _tipCard(),
              ]),
            ),
          ],
        );
      },
    );
  }
}
