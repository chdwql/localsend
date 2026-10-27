import 'package:flutter/material.dart';
import 'package:localsend_app/gen/strings.g.dart';
import 'package:localsend_app/model/state/server/server_state.dart';
import 'package:localsend_app/pages/home_page.dart';
import 'package:localsend_app/pages/home_page_controller.dart';
import 'package:localsend_app/pages/receive_history_page.dart';
import 'package:localsend_app/pages/web_share_page.dart';
import 'package:localsend_app/provider/animation_provider.dart';
import 'package:localsend_app/provider/local_ip_provider.dart';
import 'package:localsend_app/provider/network/server/server_provider.dart';
import 'package:localsend_app/provider/settings_provider.dart';
import 'package:localsend_app/util/ip_helper.dart';
import 'package:localsend_app/util/ui/nav_bar_padding.dart';
import 'package:localsend_app/widget/animations/initial_fade_transition.dart';
import 'package:localsend_app/widget/custom_icon_button.dart';
import 'package:localsend_app/widget/local_send_logo.dart';
import 'package:localsend_app/widget/responsive_list_view.dart';
import 'package:localsend_app/widget/rotating_widget.dart';
import 'package:localsend_isolates/util/sleep.dart';
import 'package:refena_flutter/addons.dart';
import 'package:refena_flutter/refena_flutter.dart';
import 'package:routerino/routerino.dart';

class ReceiveTab extends StatefulWidget {
  const ReceiveTab();

  @override
  State<ReceiveTab> createState() => _ReceiveTabState();
}

class _ReceiveTabState extends State<ReceiveTab> {
  bool _showAdvanced = false;

  void _toggleAdvanced() {
    setState(() => _showAdvanced = !_showAdvanced);
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch(settingsProvider);
    final serverState = context.watch(serverProvider);
    final localIps = context.watch(localIpProvider.select((s) => s.localIps));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    final cardBg = isDark ? const Color(0xFF1E1F24) : Colors.white;
    final borderColor = isDark ? Colors.white.withAlpha(18) : Colors.black.withAlpha(10);
    final isOnline = serverState != null;

    return Stack(
      children: [
        ResponsiveListView(
          padding: EdgeInsets.fromLTRB(20, 24, 20, 30 + getNavBarPadding(context)),
          children: [
            // Top Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.receiveTab.title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isOnline ? Colors.green : Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isOnline ? 'Online • ${serverState.port}' : t.general.offline,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white.withAlpha(160) : const Color(0xFF6B7280),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    CustomIconButton(
                      onPressed: () async {
                        await context.push(() => const ReceiveHistoryPage());
                      },
                      child: const Icon(Icons.history, size: 22),
                    ),
                    const SizedBox(width: 4),
                    CustomIconButton(
                      onPressed: _toggleAdvanced,
                      child: Icon(
                        _showAdvanced ? Icons.info : Icons.info_outline,
                        size: 22,
                        color: _showAdvanced ? colorScheme.primary : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Main Device Status Card
            Card(
              margin: EdgeInsets.zero,
              color: cardBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(color: borderColor, width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
                child: Column(
                  children: [
                    Consumer(
                      builder: (context, ref) {
                        final animations = ref.watch(animationProvider);
                        final activeTab = ref.watch(homePageControllerProvider.select((state) => state.currentTab));
                        return RotatingWidget(
                          duration: const Duration(seconds: 15),
                          spinning: isOnline && animations && activeTab == HomeTab.receive,
                          child: const LocalSendLogo(withText: false),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      serverState?.alias ?? settings.alias,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: ShapeDecoration(
                        shape: const StadiumBorder(),
                        color: isDark ? Colors.white.withAlpha(14) : Colors.black.withAlpha(8),
                      ),
                      child: Text(
                        !isOnline
                            ? t.general.offline
                            : localIps.map((ip) => '#${ip.visualId}').toSet().join(' '),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white.withAlpha(200) : const Color(0xFF4B5563),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Dual Quick Action Cards (Dashboard style)
            Row(
              children: [
                // Quick Save toggle card
                Expanded(
                  child: Card(
                    margin: EdgeInsets.zero,
                    color: cardBg,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: borderColor, width: 1),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () async {
                        await context.ref.notifier(settingsProvider).setQuickSave(!settings.quickSave);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(
                                  Icons.bolt,
                                  size: 22,
                                  color: settings.quickSave ? Colors.amber : (isDark ? Colors.white54 : Colors.black45),
                                ),
                                Switch(
                                  value: settings.quickSave,
                                  onChanged: (val) async {
                                    await context.ref.notifier(settingsProvider).setQuickSave(val);
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              t.general.quickSave,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              settings.quickSave ? t.general.save : t.general.close,
                              style: TextStyle(
                                fontSize: 12,
                                color: settings.quickSave
                                    ? Colors.green
                                    : (isDark ? Colors.white.withAlpha(140) : const Color(0xFF6B7280)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Web Share card
                Expanded(
                  child: Card(
                    margin: EdgeInsets.zero,
                    color: cardBg,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: borderColor, width: 1),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () async {
                        await context.global.dispatchAsync(NavigateAction.push(const WebSharePage()));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(
                                  Icons.language,
                                  size: 22,
                                  color: colorScheme.primary,
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 14,
                                  color: isDark ? Colors.white.withAlpha(120) : Colors.black.withAlpha(100),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Text(
                              t.receiveTab.link,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Web Browser',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.white.withAlpha(140) : const Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Advanced Network Info (collapsible)
            if (_showAdvanced)
              Card(
                margin: EdgeInsets.zero,
                color: cardBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: borderColor, width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.receiveTab.infoBox.ip,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      if (localIps.isEmpty)
                        Text(t.general.unknown)
                      else
                        ...localIps.map(
                          (ip) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: SelectableText(
                              ip,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.white.withAlpha(200) : const Color(0xFF374151),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(t.receiveTab.infoBox.port, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          SelectableText(serverState?.port.toString() ?? '-'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
