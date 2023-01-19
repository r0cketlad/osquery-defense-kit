-- A program where the parent PID is not on disk
--
-- Reveals boopkit if a child is spawned
-- TODO: Make mount namespace aware
--
-- false positives:
--   * none observed
--
-- references:
--   * https://attack.mitre.org/techniques/T1070/004/ (Indicator Removal on Host: File Deletion)
--
-- false positives:
--   * none observed
--
-- tags: persistent daemon
SELECT
  p.name AS child_name,
  p.pid AS child_pid,
  p.path AS child_path,
  p.cmdline AS child_cmd,
  p.euid AS child_euid,
  p.gid AS child_gid,
  p.cgroup_path AS child_cgroup,
  hash.path,
  p.on_disk AS child_on_disk,
  pp.pid AS parent_pid,
  pp.name AS parent_name,
  pp.path AS parent_path,
  pp.cmdline AS cmd,
  pp.on_disk AS parent_on_disk,
  pp.cgroup_path AS parent_cgroup,
  pp.uid AS parent_uid,
  pp.gid AS parent_gid
FROM
  processes p
  JOIN processes pp ON pp.pid = p.parent
  LEFT JOIN hash ON p.path = hash.path
WHERE
  parent_on_disk != 1
  AND child_on_disk = 1
  AND NOT child_pid IN (1, 2)
  AND NOT parent_pid IN (1, 2) -- launchd, kthreadd
  AND NOT parent_path IN (
    '/opt/google/chrome/chrome',
    '/usr/bin/alacritty',
    '/usr/bin/dockerd',
    '/usr/bin/fusermount3',
    '/usr/bin/osqueryd',
    '/usr/bin/yay',
    '/usr/bin/doas',
    '/usr/bin/gnome-shell',
    '/usr/lib/systemd/systemd'
  ) -- long-running launchers
  AND NOT parent_name IN (
    'lightdm',
    'nvim',
    'gnome-shell',
    'slack',
    'kube-proxy',
    'kubelet'
  ) -- These alerts were unfortunately useless - lots of spam on macOS
  AND NOT (
    parent_path LIKE '/app/%'
    AND child_cgroup LIKE '/user.slice/user-1000.slice/user@1000.service/app.slice/%'
  )
  AND child_cgroup NOT LIKE '/system.slice/docker-%'
  AND parent_cgroup NOT LIKE '/system.slice/docker-%'
  AND parent_cgroup NOT LIKE '/user.slice/user-1000.slice/user@1000.service/user.slice/nerdctl-%'
  AND parent_path NOT LIKE '/opt/homebrew/Cellar/%'
  AND parent_path NOT LIKE '/tmp/.mount_%/%'
  AND parent_path NOT LIKE '%google-cloud-sdk/.install/.backup%'
  AND NOT (
    parent_name LIKE 'kworker/%+events_unbound'
    AND child_name IN ('modprobe')
  )
