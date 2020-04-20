/* 启动后恢复上次会话 */
user_pref("browser.startup.page", 3);
/* 主页使用空白页 */
user_pref("browser.startup.homepage", "about:blank");
/* 新标签页使用空白页 */
user_pref("browser.newtabpage.enabled", false);
/* 所有情况下都启用跟踪保护 */
user_pref("privacy.trackingprotection.enabled", true);

/*==== 隐藏设置 ====*/
/* 打开about:config页面不警告 */
user_pref("browser.aboutConfig.showWarning", false);
/* 去除about:addons页面中的推荐页 */
user_pref("extensions.getAddons.showPane", false);
/* 去除about:addons页面中底部的推荐列表 */
user_pref("extensions.htmlaboutaddons.recommendations.enabled", false);
/* 去除Pocket */
user_pref("extensions.pocket.enabled", false);

/* 禁止预连接(地址栏) */
user_pref("browser.urlbar.speculativeConnect.enabled", false);
/* 禁止预连接(鼠标指针停留在链接上) */
user_pref("network.http.speculative-parallel-limit", 0);
/* 禁止链接预读取 */
user_pref("network.prefetch-next", false);
/* 禁止DNS预读取 */
user_pref("network.dns.disablePrefetch", true);
/* 禁止超链接审计
 * 无需设置: 默认设置已禁止, 而且uBlock Origin也提供禁止选项 */
// user_pref("browser.send_pings", false);
/* 禁止sendBeacon API
 * 无需设置: 使用uBlock Origin过滤
 * https://bugzilla.mozilla.org/show_bug.cgi?id=1454252#c6
 * https://github.com/gorhill/uBlock/issues/1884#issuecomment-253813062 */
// user_pref("beacon.enabled", false);

/*==== 可能破坏网页 ====*/
/* RFP: 阻止多种收集浏览器指纹的行为 */
user_pref("privacy.resistFingerprinting", true);
/* 禁止WebGL
 * 开启RFP后无需设置: RFP伪装了WebGL指纹 */
// user_pref("webgl.disabled", true);
/* 禁止Web Audio API */
user_pref("dom.webaudio.enabled", false);
/* 禁止WebRTC */
user_pref("media.peerconnection.enabled", false);
/* 禁止获取媒体设备列表API
 * 注意: 需要同时禁止WebRTC */
user_pref("media.navigator.enabled", false);
