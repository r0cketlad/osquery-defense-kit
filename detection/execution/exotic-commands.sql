-- Pick out exotic processes based on their command-line (state-based)
--
-- false positives:
--   * possible, but none known
--
-- tags: transient process state
-- platform: posix
SELECT
  p.path,
  p.name,
  p.cmdline AS cmd,
  p.cwd,
  p.cgroup_path,
  p.euid,
  p.parent,
  pp.name AS parent_name,
  pp.cmdline AS parent_cmd,
  cp.name AS child_name,
  cp.cmdline AS child_cmd,
  hash.sha256 AS child_sha256,
  phash.sha256 AS parent_sha256
FROM
  processes p
  LEFT JOIN processes pp ON p.parent = pp.pid
  LEFT JOIN processes cp ON p.pid = cp.parent
  LEFT JOIN hash ON p.path = hash.path
  LEFT JOIN hash AS phash ON pp.path = phash.path
WHERE
  -- Known attack scripts
  p.name IN (
    'bitspin',
    'bpftool',
    'heyoka',
    'nstx',
    'dnscat2',
    'tuns',
    'iodine',
    'esxcli',
    'vim-cmd',
    'minerd',
    'cpuminer-multi',
    'cpuminer',
    'httpdns',
    'rshell',
    'rsh',
    'xmrig',
    'incbit',
    'insmod',
    'kmod',
    'lushput',
    'mkfifo',
    'msfvenom',
    'nc',
    'socat'
  )
  OR p.name LIKE '%pwn%'
  OR p.name LIKE '%xig%'
  OR p.name LIKE '%xmr%'
  OR cmd LIKE '%bitspin%'
  OR cmd LIKE '%lushput%'
  OR cmd LIKE '%incbit%'
  OR cmd LIKE '%traitor%'
  OR cmd LIKE '%msfvenom%'
  -- Unusual behaviors
  OR cmd LIKE '%ufw disable%'
  OR cmd LIKE '%iptables -P % ACCEPT%'
  OR cmd LIKE '%iptables -F%'
  OR cmd LIKE '%chattr -ia%'
  OR cmd LIKE '%chflags uchg%'
  OR cmd LIKE '%chmod 777 %'
  OR cmd LIKE '%bpftool%'
  OR cmd LIKE '%touch%acmr%'
  OR cmd LIKE '%ld.so.preload%'
  OR cmd LIKE '%urllib.urlopen%'
  OR cmd LIKE '%launchctl load%'
  OR cmd LIKE '%launchctl bootout%'
  OR cmd LIKE '%nohup%tmp%'
  OR cmd LIKE '%set visible of front window to false%'
  OR cmd LIKE '%chrome%--load-extension%'
  OR (
    cmd LIKE '%UserKnownHostsFile=/dev/null%'
    AND NOT parent_name = 'limactl'
  )
  -- Crypto miners
  OR cmd LIKE '%c3pool%'
  OR cmd LIKE '%cryptonight%'
  OR cmd LIKE '%f2pool%'
  OR cmd LIKE '%hashrate%'
  OR cmd LIKE '%hashvault%'
  OR cmd LIKE '%minerd%'
  OR cmd LIKE '%monero%'
  OR cmd LIKE '%nanopool%'
  OR cmd LIKE '%nicehash%'
  OR cmd LIKE '%stratum%'
  -- Random keywords
  OR cmd LIKE '%ransom%'
  OR cmd LIKE '%malware%'
  OR cmd LIKE '%plant%'
  -- Reverse shells
  OR cmd LIKE '%/dev/tcp/%'
  OR cmd LIKE '%/dev/udp/%'
  OR cmd LIKE '%fsockopen%'
  OR cmd LIKE '%openssl%quiet%'
  OR cmd LIKE '%pty.spawn%'
  OR (
    cmd LIKE '%sh -i'
    AND NOT p.path = '/usr/bin/docker'
    AND NOT parent_name IN ('sh', 'java', 'containerd-shim')
    AND NOT parent_cmd LIKE '%pipenv shell'
    AND NOT p.cgroup_path LIKE '/system.slice/docker-%'
  )
  OR cmd LIKE '%socat%'
  OR cmd LIKE '%SOCK_STREAM%'
  OR INSTR(cmd, '%Socket.%') > 0
  -- Keep the shell running, as in https://blog.aquasec.com/threat-alert-kinsing-malware-container-vulnerability
  OR (
    cmd LIKE '%tail -f /dev/null%'
    AND p.cgroup_path NOT LIKE '/system.slice/docker-%'
  )
  AND NOT cmd IN (
    'socat UNIX-LISTEN:/run/user/1000/app/com.discordapp.Discord/discord-ipc-0,forever,fork UNIX-CONNECT:/run/user/1000/discord-ipc-0'
  )