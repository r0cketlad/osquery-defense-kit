-- Unexpected programs communicating over non-HTTPS running from weird locations
--
-- references:
--   * https://attack.mitre.org/techniques/T1071/ (C&C, Application Layer Protocol)
--
-- tags: transient state net often
-- platform: macos
SELECT pos.protocol,
  pos.local_port,
  pos.remote_port,
  remote_address,
  pos.local_port,
  pos.local_address,
  CONCAT (MIN(p0.euid, 500), ',', s.authority) AS signed_exception,
  CONCAT (
    MIN(p0.euid, 500),
    ',',
    pos.protocol,
    ',',
    MIN(pos.remote_port, 32768),
    ',',
    REGEX_MATCH (p0.path, '.*/(.*?)$', 1),
    ',',
    p0.name
  ) AS unsigned_exception,
  -- Child
  p0.pid AS p0_pid,
  p0.path AS p0_path,
  s.authority AS p0_sauth,
  s.identifier AS p0_sid,
  p0.name AS p0_name,
  p0.cmdline AS p0_cmd,
  p0.cwd AS p0_cwd,
  p0.euid AS p0_euid,
  p0_hash.sha256 AS p0_sha256,
  -- Parent
  p0.parent AS p1_pid,
  p1.path AS p1_path,
  p1.name AS p1_name,
  p1.euid AS p1_euid,
  p1.cmdline AS p1_cmd,
  p1_hash.sha256 AS p1_sha256
FROM process_open_sockets pos
  LEFT JOIN processes p0 ON pos.pid = p0.pid
  LEFT JOIN hash p0_hash ON p0.path = p0_hash.path
  LEFT JOIN processes p1 ON p0.parent = p1.pid
  LEFT JOIN hash p1_hash ON p1.path = p1_hash.path
  LEFT JOIN file f ON p0.path = f.path
  LEFT JOIN signature s ON p0.path = s.path
WHERE pos.pid IN (
    SELECT pid
    from process_open_sockets
    WHERE protocol > 0
      AND NOT (
        remote_port IN (53, 443)
        AND protocol IN (6, 17)
      )
      AND remote_address NOT IN (
        '0.0.0.0',
        '::127.0.0.1',
        '127.0.0.1',
        '::ffff:127.0.0.1',
        '::1',
        '::'
      )
      AND remote_address NOT LIKE 'fe80:%'
      AND remote_address NOT LIKE '127.%'
      AND remote_address NOT LIKE '192.168.%'
      AND remote_address NOT LIKE '172.1%'
      AND remote_address NOT LIKE '172.2%'
      AND remote_address NOT LIKE '169.254.%'
      AND remote_address NOT LIKE '172.30.%'
      AND remote_address NOT LIKE '172.31.%'
      AND remote_address NOT LIKE '::ffff:172.%'
      AND remote_address NOT LIKE '10.%'
      AND remote_address NOT LIKE '::ffff:10.%'
      AND remote_address NOT LIKE 'fc00:%'
      AND remote_address NOT LIKE 'fdfd:%'
      AND state != 'LISTEN'
  ) -- Ignore most common application paths
  AND p0.path NOT LIKE '/Applications/%.app/Contents/MacOS/%'
  AND p0.path NOT LIKE '/Applications/%.app/Contents/Resources/%'
  AND p0.path NOT LIKE '/Library/Apple/%'
  AND p0.path NOT LIKE '/Library/Application Support/%/Contents/%'
  AND p0.path NOT LIKE '/System/%'
  AND p0.path NOT LIKE '/Users/%/bin/%'
  AND p0.path NOT LIKE '/opt/%/bin/%'
  AND p0.path NOT LIKE '/usr/bin/%'
  AND p0.path NOT LIKE '/usr/sbin/%'
  AND p0.path NOT LIKE '/usr/libexec/%'
  AND NOT signed_exception IN (
    '0,Developer ID Application: Tailscale Inc. (W5364U7YZB)',
    '500,Apple Mac OS Application Signing',
    '500,Developer ID Application: Cisco (DE8Y96K9QP)',
    '500,Developer ID Application: Google LLC (EQHXZ8M8AV)'
  )
  AND NOT exception_key IN (
    '0,6,7300,safeqclientcore,safeqclientcore,Developer ID Application: Y Soft Corporation, a.s. (3CPED8WGS9),safeqclientcore',
    '0,6,80,fcconfig,fcconfig,Developer ID Application: Fortinet, Inc (AH4XFXJ7DK),fcconfig',
    '0,6,80,prl_naptd,prl_naptd,Developer ID Application: Parallels International GmbH (4C6364ACXT),com.parallels.naptd',
    '0,6,853,at.obdev.littlesnitch.networkextension,at.obdev.littlesnitch.networkextension,Developer ID Application: Objective Development Software GmbH (MLZF7K7B5R),at.obdev.littlesnitch.networkextension',
    '500,17,123,agent,agent,Developer ID Application: Datadog, Inc. (JKFCB4CN7C),agent',
    '500,17,123,Garmin Express,Garmin Express,Developer ID Application: Garmin International (72ES32VZUA),com.garmin.renu.client',
    '500,17,32768,Luna Display,Luna Display,Developer ID Application: Astro HQ LLC (8356ZZ8Y5K),com.astro-hq.LunaDisplayMac',
    '500,17,68,com.docker.backend,com.docker.backend,500u,80g',
    '500,17,68,com.docker.backend,com.docker.backend,Developer ID Application: Docker Inc (9BNSXJN65R),com.docker.docker',
    '500,17,8801,zoom.us,zoom.us,Developer ID Application: Zoom Video Communications, Inc. (BJ4HAAB9B3),us.zoom.xos',
    '500,17,9000,Meeting Center,Meeting Center,Developer ID Application: Cisco (DE8Y96K9QP),com.webex.meetingmanager',
    '500,6,21,Cyberduck,Cyberduck,Developer ID Application: David Kocher (G69SCX94XU),ch.sudo.cyberduck',
    '500,6,22,Cyberduck,Cyberduck,Developer ID Application: David Kocher (G69SCX94XU),ch.sudo.cyberduck',
    '500,6,22,devpod-provider-gcloud-darwin-arm64,devpod-provider-gcloud-darwin-arm64,,a.out',
    '500,6,22,goland,goland,Developer ID Application: JetBrains s.r.o. (2ZEFAR8TH3),com.jetbrains.goland',
    '500,6,22,Transmit,Transmit,Developer ID Application: Panic, Inc. (VE8FC488U5),com.panic.Transmit',
    '500,6,2869,Spotify,Spotify,Developer ID Application: Spotify (2FNC3A47ZF),com.spotify.client',
    '500,6,32000,Spotify Helper,Spotify Helper,Developer ID Application: Spotify (2FNC3A47ZF),com.spotify.client.helper',
    '500,6,32400,PlexMobile,PlexMobile,Apple iPhone OS Application Signing,com.plexapp.plex',
    '500,6,32768,IPNExtension,IPNExtension,Apple Mac OS Application Signing,io.tailscale.ipn.macos.network-extension',
    '500,6,32768,MobileDevicesService,MobileDevicesService,Developer ID Application: GUILHERME RAMBO (8C7439RJLG),codes.rambo.AirBuddy.MobileDevicesService',
    '500,6,3306,dbeaver,dbeaver,Developer ID Application: DBeaver Corporation (42B6MDKMW8),org.jkiss.dbeaver.core.product',
    '500,6,3389,Microsoft Remote Desktop,Microsoft Remote Desktop,Apple Mac OS Application Signing,com.microsoft.rdc.macos',
    '500,6,3389,Microsoft Remote Desktop,Microsoft Remote Desktop,Developer ID Application: Microsoft Corporation (UBF8T346G9),com.microsoft.rdc.macos',
    '500,6,4070,Spotify,Spotify,Developer ID Application: Spotify (2FNC3A47ZF),com.spotify.client',
    '500,6,4317,flyctl,flyctl,,a.out',
    '500,6,4318,Code Helper (Plugin),Code Helper (Plugin),Developer ID Application: Microsoft Corporation (UBF8T346G9),com.github.Electron.helper',
    '500,6,5053,bridge,bridge,Developer ID Application: Proton Technologies AG (6UN54H93QT),bridge',
    '500,6,5091,ZoomPhone,ZoomPhone,Developer ID Application: Zoom Video Communications, Inc. (BJ4HAAB9B3),us.zoom.ZoomPhone',
    '500,6,5222,Telegram,Telegram,Apple Mac OS Application Signing,ru.keepcoder.Telegram',
    '500,6,5222,WhatsApp,WhatsApp,Apple Mac OS Application Signing,net.whatsapp.WhatsApp',
    '500,6,5222,WhatsApp,WhatsApp,Developer ID Application: WhatsApp Inc. (57T9237FN3),net.whatsapp.WhatsApp',
    '500,6,5223,KakaoTalk,KakaoTalk,Apple Mac OS Application Signing,com.kakao.KakaoTalkMac',
    '500,6,5228,Clay,Clay,Developer ID Application: Clay Software, Inc. (C68GA48KN3),com.clay.mac',
    '500,6,3389,Windows App,Windows App,Developer ID Application: Microsoft Corporation (UBF8T346G9),com.microsoft.rdc.macos',
    '500,6,5228,com.adguard.mac.adguard.network-extension,com.adguard.mac.adguard.network-extension,0u,0g',
    '500,6,5228,com.adguard.mac.adguard.network-extension,com.adguard.mac.adguard.network-extension,Developer ID Application: Adguard Software Limited (TC3Q7MAJXF),com.adguard.mac.adguard.network-extension',
    '500,6,5228,Fellow,Fellow,Developer ID Application: Fellow Insights, Inc. (2NF46HY8D8),com.electron.fellow',
    '500,6,5228,Superhuman,Superhuman,Developer ID Application: SUPERHUMAN LABS INC. (6XHFYUTQGX),com.superhuman.electron',
    '500,6,7881,zed,zed,Developer ID Application: Zed Industries, Inc. (MQ55VZLNZQ),dev.zed.Zed',
    '500,6,8009,Spotify Helper,Spotify Helper,Developer ID Application: Spotify (2FNC3A47ZF),com.spotify.client.helper',
    '500,6,8080,goland,goland,Developer ID Application: JetBrains s.r.o. (2ZEFAR8TH3),com.jetbrains.goland',
    '500,6,8080,Speedtest,Speedtest,Apple Mac OS Application Signing,com.ookla.speedtest-macos',
    '500,6,80,AdobeAcrobat,AdobeAcrobat,Developer ID Application: Adobe Inc. (JQ525L2MZD),com.adobe.Acrobat.Pro',
    '500,6,80,agent,agent,Developer ID Application: Datadog, Inc. (JKFCB4CN7C),agent',
    '500,6,80,Arc Helper,Arc Helper,Developer ID Application: The Browser Company of New York Inc. (S6N382Y83G),company.thebrowser.browser.helper',
    '500,6,80,Brackets,Brackets,Developer ID Application: CORE.AI SCIENTIFIC TECHNOLOGIES PRIVATE LIMITED (8F632A866K),io.brackets.appshell',
    '500,6,80,Camtasia 2022,Camtasia 2022,Developer ID Application: TechSmith Corporation (7TQL462TU8),com.techsmith.camtasia2022',
    '500,6,80,CEPHtmlEngine Helper,CEPHtmlEngine Helper,Developer ID Application: Adobe Inc. (JQ525L2MZD),com.adobe.cep.CEPHtmlEngine Helper',
    '500,6,80,Chromium Helper,Chromium Helper,,Chromium Helper',
    '500,6,80,Code Helper (Plugin),Code Helper (Plugin),Developer ID Application: Microsoft Corporation (UBF8T346G9),com.github.Electron.helper',
    '500,6,80,Code - Insiders Helper (Plugin),Code - Insiders Helper (Plugin),Developer ID Application: Microsoft Corporation (UBF8T346G9),com.github.Electron.helper',
    '500,6,80,com.docker.backend,com.docker.backend,Developer ID Application: Docker Inc (9BNSXJN65R),com.docker',
    '500,6,80,Creative Cloud UI Helper,Creative Cloud UI Helper,Developer ID Application: Adobe Inc. (JQ525L2MZD),com.adobe.acc.HEXHelper',
    '500,6,80,Discord Helper,Discord Helper,Developer ID Application: Discord, Inc. (53Q6R32WPB),com.hnc.Discord.helper',
    '500,6,80,firefox,firefox,Developer ID Application: Mozilla Corporation (43AQ936H96),org.mozilla.firefox',
    '500,6,80,Google Drive Helper,Google Drive Helper,Developer ID Application: Google LLC (EQHXZ8M8AV),com.google.drivefs.helper',
    '500,6,80,IPNExtension,IPNExtension,Apple Mac OS Application Signing,io.tailscale.ipn.macos.network-extension',
    '500,6,80,Jabra Direct,Jabra Direct,Developer ID Application: GN Audio AS (55LV32M29R),com.jabra.directonline',
    '500,6,80,jcef Helper,jcef Helper,Developer ID Application: JetBrains s.r.o. (2ZEFAR8TH3),org.jcef.jcef.helper',
    '500,6,80,KakaoTalk,KakaoTalk,Apple Mac OS Application Signing,com.kakao.KakaoTalkMac',
    '500,6,80,ksfetch,ksfetch,Developer ID Application: Google LLC (EQHXZ8M8AV),ksfetch',
    '500,6,80,launcher-Helper,launcher-Helper,Developer ID Application: Mojang AB (HR992ZEAE6),com.mojang.mclauncher.helper',
    '500,6,80,Loom Helper,Loom Helper,Developer ID Application: Loom, Inc (QGD2ZPXZZG),com.loom.desktop.helper',
    '500,6,80,Mem Helper,Mem Helper,Developer ID Application: Kevin Moody (9ZLK8RSRVN),org.memlabs.Mem.helper',
    '500,6,80,ngrok,ngrok,Developer ID Application: ngrok LLC (TEX8MHRDQ9),a.out',
    '500,6,80,node,node,Developer ID Application: Node.js Foundation (HX7739G8FX),node',
    '500,6,80,rpi-imager,rpi-imager,Developer ID Application: Floris Bos (WYH7G79LM6),org.raspberrypi.imagingutility',
    '500,6,80,Signal Helper (Renderer),Signal Helper (Renderer),Developer ID Application: Quiet Riddle Ventures LLC (U68MSDN6DR),org.whispersystems.signal-desktop.helper.Renderer',
    '500,6,80,Sky Go,Sky Go,Developer ID Application: Sky UK Limited (GJ24C8864F),com.bskyb.skygoplayer',
    '500,6,80,Slack Helper,Slack Helper,Apple Mac OS Application Signing,com.tinyspeck.slackmacgap.helper',
    '500,6,80,Snagit 2020,Snagit 2020,Apple Mac OS Application Signing,com.TechSmith.Snagit2020',
    '500,6,80,Snagit 2023,Snagit 2023,Developer ID Application: TechSmith Corporation (7TQL462TU8),com.TechSmith.Snagit2023',
    '500,6,80,Snagit 2024,Snagit 2024,Developer ID Application: TechSmith Corporation (7TQL462TU8),com.TechSmith.Snagit2024',
    '500,6,80,SnagitHelper2020,SnagitHelper2020,Apple Mac OS Application Signing,com.techsmith.snagit.capturehelper2020',
    '500,6,80,SnagitHelper2023,SnagitHelper2023,Developer ID Application: TechSmith Corporation (7TQL462TU8),com.techsmith.snagit.capturehelper2023',
    '500,6,80,Spark Desktop Helper,Spark Desktop Helper,Developer ID Application: Readdle Technologies Limited (3L68KQB4HG),com.readdle.SparkDesktop.helper',
    '500,6,80,Spotify,Spotify,Developer ID Application: Spotify (2FNC3A47ZF),com.spotify.client',
    '500,6,80,Telegram,Telegram,Apple Mac OS Application Signing,ru.keepcoder.Telegram',
    '500,6,80,thunderbird,thunderbird,Defveloper ID Application: Mozilla Corporation (43AQ936H96),org.mozilla.thunderbird',
    '500,6,80,TIDAL Helper,TIDAL Helper,Developer ID Application: TIDAL Music AS (GK2243L7KB),com.tidal.desktop.helper',
    '500,6,80,Twitter,Twitter,Apple Mac OS Application Signing,maccatalyst.com.atebits.Tweetie2',
    '500,6,80,Wavebox Helper,Wavebox Helper,Developer ID Application: Bookry Ltd (4259LE8SU5),com.bookry.wavebox.helper',
    '500,6,80,WhatsApp,WhatsApp,Apple Mac OS Application Signing,net.whatsapp.WhatsApp',
    '500,6,80,WhatsApp,WhatsApp,Developer ID Application: WhatsApp Inc. (57T9237FN3),WhatsApp',
    '500,6,8282,GeForceNOW,GeForceNOW,Developer ID Application: NVIDIA Corporation (6KR3T733EC),com.nvidia.gfnpc.mall',
    '500,6,9123,Elgato Control Center,Elgato Control Center,Developer ID Application: Corsair Memory, Inc. (Y93VXCB8Q5),com.corsair.ControlCenter',
    '500,6,993,Mimestream,Mimestream,Developer ID Application: Mimestream, LLC (P2759L65T8),com.mimestream.Mimestream',
    '500,6,993,Spark Desktop Helper,Spark Desktop Helper,Developer ID Application: Readdle Technologies Limited (3L68KQB4HG),com.readdle.SparkDesktop.helper',
    '500,6,993,thunderbird,thunderbird,Developer ID Application: Mozilla Corporation (43AQ936H96),org.mozilla.thunderbird',
    '500,6,995,KakaoTalk,KakaoTalk,Apple Mac OS Application Signing,com.kakao.KakaoTalkMac'
  ) -- Useful for unsigned binaries
  AND NOT alt_exception_key IN (
    '0,6,80,tailscaled,tailscaled,500u,80g',
    '500,6,22,ssh,ssh,0u,500g',
    '500,6,5432,psql,psql,500u,80g',
    '500,6,22,ssh,ssh,500u,0g',
    '500,17,123,limactl,limactl,500u,80g',
    '500,17,123,gvproxy,gvproxy,500u,80g',
    '500,6,80,qemu-system-x86_64,qemu-system-x86_64,500u,80g',
    '500,6,22,ssh,ssh,500u,20g',
    '500,6,22,ssh,ssh,500u,80g',
    '500,6,80,git-remote-http,git-remote-http,500u,20g',
    '500,6,3307,cloud_sql_proxy,cloud_sql_proxy,0u,0g',
    '500,6,3307,cloud-sql-proxy,cloud-sql-proxy,500u,20g',
    '500,6,3307,cloud_sql_proxy,cloud_sql_proxy,500u,20g',
    '500,6,80,chainlink,chainlink,500u,20g',
    '500,6,80,copilot-agent-macos-arm64,copilot-agent-macos-arm64,500u,20g',
    '500,6,80,firefox,firefox,500u,20g',
    '500,6,80,qemu-system-aarch64,qemu-system-aarch64,500u,80g'
  )
  AND NOT alt_exception_key LIKE '500,6,22,packer-plugin-amazon%,packer-plugin-amazon_%,500u,20g'
  AND NOT (
    unsigned_exception = '500,6,80,main,main'
    AND p0.path LIKE '/var/folders/%/T/go-build%/b001/exe/main'
  )
GROUP BY p0.cmdline