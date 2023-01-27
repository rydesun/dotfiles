/* 启动后恢复上次会话 */
user_pref("browser.startup.page", 3);
/* 主页使用空白页 */
user_pref("browser.startup.homepage", "about:blank");
/* 新标签页使用空白页 */
user_pref("browser.newtabpage.enabled", false);
/* 所有情况下都启用跟踪保护 */
user_pref("privacy.trackingprotection.enabled", true);
/* 阻止重定向形式的跟踪(效果有限) */
user_pref("privacy.purge_trackers.enabled",  true);

/* 打开about:config页面不警告 */
user_pref("browser.aboutConfig.showWarning", false);
/* 去除about:addons页面中的推荐页 */
user_pref("extensions.getAddons.showPane", false);
/* 去除about:addons页面中底部的推荐列表 */
user_pref("extensions.htmlaboutaddons.recommendations.enabled", false);
/* 去除Pocket服务 */
user_pref("extensions.pocket.enabled", false);

/* 禁止投机性预连接 */
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
 * 开启RFP即可减少WebGL信息熵 */
// user_pref("webgl.disabled", true);
/* 禁止WebRTC */
user_pref("media.peerconnection.enabled", false);
/* 禁止获取媒体设备列表API
 * 注意: 需要同时禁止WebRTC */
user_pref("media.navigator.enabled", false);

/*==== 硬件视频加速 ====*/
/* 开启WebRender */
user_pref("gfx.webrender.all", true);
/* 使用VA-API */
user_pref("media.ffmpeg.vaapi.enabled", true);
/* 禁用firefox内置的VP8/VP9解码 */
user_pref("media.ffvpx.enabled", false);
/* 显卡不支持AV1解码 */
user_pref("media.av1.enabled", false);
