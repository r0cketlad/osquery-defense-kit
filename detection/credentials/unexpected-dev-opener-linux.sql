-- Detects unexpected programs opening files in /dev on Linux
--
-- references:
--   * https://attack.mitre.org/techniques/T1056/001/ (Input Capture: Keylogging)
--
-- false positives:
--   * any program which needs access to device drivers
--
-- platform: linux
-- tags: persistent state sniffer
SELECT
  pof.pid,
  pof.path AS device,
  p.path AS program,
  p.name AS program_name,
  p.cmdline AS cmdline,
  pp.cmdline AS parent_cmdline,
  gp.cmdline AS gparent_cmdline,
  hash.sha256,
  CONCAT (
    IIF(
      REGEX_MATCH (
        TRIM(REPLACE(pof.path, ' (deleted)', '')),
        '(/dev/.*)[\d ]+$',
        1
      ) != '',
      REGEX_MATCH (
        TRIM(REPLACE(pof.path, ' (deleted)', '')),
        '(/dev/.*)[\d ]+$',
        1
      ),
      TRIM(REPLACE(pof.path, ' (deleted)', ''))
    ),
    ',',
    REPLACE(
      p.path,
      RTRIM(p.path, REPLACE(p.path, '/', '')),
      ''
    )
  ) AS path_exception,
  CONCAT (
    TRIM(
      REPLACE(
        pof.path,
        CONCAT (
          '/',
          REPLACE(
            pof.path,
            RTRIM(pof.path, REPLACE(pof.path, '/', '')),
            ''
          )
        ),
        ''
      )
    ),
    ',',
    REPLACE(
      p.path,
      RTRIM(p.path, REPLACE(p.path, '/', '')),
      ''
    )
  ) AS dir_exception
FROM
  process_open_files pof
  LEFT JOIN processes p ON pof.pid = p.pid
  LEFT JOIN processes pp ON p.parent = pp.pid
  LEFT JOIN processes gp ON pp.parent = gp.pid
  LEFT JOIN hash ON hash.path = p.path
WHERE
  pof.path LIKE '/dev/%'
  AND pof.path NOT IN (
    '/dev/dri/card0',
    '/dev/dri/card1',
    '/dev/dri/renderD128',
    '/dev/dri/renderD129',
    '/dev/fuse',
    '/dev/io8log',
    '/dev/io8logmt',
    '/dev/io8logtemp',
    '/dev/null',
    '/dev/nvidia-modeset',
    '/dev/nvidia-uvm',
    '/dev/nvidia0',
    '/dev/nvidiactl',
    '/dev/ptmx',
    '/dev/pts/ptmx',
    '/dev/shm/u1000-ValveIPCSharedObj-Steam',
    '/dev/random',
    '/dev/rfkill',
    '/dev/snd/seq',
    '/dev/urandom',
    '/dev/vga_arbiter',
    '/dev/video10' -- workaround for poor regex management (ffmpeg)
  )
  AND pof.path NOT LIKE '/dev/pts/%'
  AND pof.path NOT LIKE '/dev/snd/%'
  AND pof.path NOT LIKE '/dev/tty%'
  AND pof.path NOT LIKE '/dev/hidraw%'
  AND pof.path NOT LIKE '/dev/shm/.com.google.Chrome.%'
  AND pof.path NOT LIKE '/dev/shm/.org.chromium.Chromium.%'
  -- Zoom
  AND pof.path NOT LIKE '/dev/shm/aomshm.%'
  AND pof.path NOT LIKE '/dev/shm/authentik_%'
  AND NOT dir_exception IN (
    '/dev/bus/usb,pcscd',
    '/dev/input,acpid',
    '/dev/input,gnome-shell',
    '/dev/input,systemd',
    '/dev/input,systemd-logind',
    '/dev/input,thermald',
    '/dev/input,upowerd',
    '/dev/input,Xorg',
    '/dev/net,tailscaled',
    '/dev/net,.tailscaled-wrapped',
    '/dev/net/tun,qemu-system-x86_64',
    '/dev/shm,1password',
    '/dev/shm,Brackets',
    '/dev/shm,chrome',
    '/dev/shm,code',
    '/dev/shm,electron',
    '/dev/shm,firefox',
    '/dev/shm,gameoverlayui',
    '/dev/shm,gopls',
    '/dev/shm,hl2_linux',
    '/dev/shm,java',
    '/dev/shm,jcef_helper',
    '/dev/shm,Melvor Idle',
    '/dev/shm,reaper',
    '/dev/shm,slack',
    '/dev/shm,spotify',
    '/dev/shm,steam',
    '/dev/shm,steamwebhelper',
    '/dev/shm,wine64-preloader',
    '/dev/shm,winedevice.exe',
    '/dev/snd,alsactl',
    '/dev/snd,pipewire',
    '/dev/snd,pulseaudio',
    '/dev/snd,.pulseaudio-wrapped',
    '/dev/snd,wireplumber',
    '/dev/usb,apcupsd',
    '/dev/usb,upowerd'
  )
  AND NOT path_exception IN (
    '/dev/autofs,systemd',
    '/dev/hidraw,chrome',
    '/dev/hwrng,rngd',
    '/dev/input/event,thermald',
    '/dev/input/event,touchegg',
    '/dev/input/event,Xorg',
    '/dev/kmsg,dmesg',
    '/dev/kmsg,k3s',
    '/dev/kmsg,kubelet',
    '/dev/kmsg,systemd',
    '/dev/kmsg,systemd-coredump',
    '/dev/kmsg,systemd-journald',
    '/dev/kvm,qemu-system-x86_64',
    '/dev/mapper/control,dockerd',
    '/dev/mcelog,mcelog',
    '/dev/media0,pipewire',
    '/dev/media0,wireplumber',
    '/dev/media,pipewire',
    '/dev/media,wireplumber',
    '/dev/net/tun,slirp4netns',
    '/dev/shm/envoy_shared_memory_1,envoy',
    '/dev/tty,agetty',
    '/dev/tty,gdm-wayland-session',
    '/dev/tty,gdm-x-session',
    '/dev/tty,systemd-logind',
    '/dev/tty,Xorg',
    '/dev/uhid,bluetoothd',
    '/dev/uinput,bluetoothd',
    '/dev/usb/hiddev,apcupsd',
    '/dev/usb/hiddev,upowerd',
    '/dev/video0,chrome',
    '/dev/video,brave',
    '/dev/video,chrome',
    '/dev/video,ffmpeg',
    '/dev/cpu/0/msr,nvidia-powerd',
    '/dev/video,firefox',
    '/dev/video,obs',
    '/dev/video,obs-ffmpeg-mux',
    '/dev/video,pipewire',
    '/dev/video,vlc',
    '/dev/video,wireplumber',
    '/dev/video,zoom',
    '/dev/video,zoom.real',
    '/dev/mapper/control,gpartedbin',
    '/dev/zfs,zed',
    '/dev/zfs,zfs',
    '/dev/zfs,',
    '/dev/zfs,zpool'
  )
  -- Halflife
  AND path_exception NOT LIKE '/dev/shm/u1000-Shm_%,bash'
  -- lvmdbusd
  AND path_Exception NOT LIKE '/dev/shm/pym-%python3.%'
  AND NOT (
    device LIKE '/dev/bus/usb/%'
    AND program_name IN (
      'adb',
      'fprintd',
      'fwupd',
      'gphoto2',
      'gvfsd-gphoto2',
      'gvfsd-mtp',
      'gvfs-gphoto2-vo',
      'gvfs-gphoto2-volume-monitor',
      'pcscd',
      'streamdeck',
      'usbmuxd'
    )
  )
GROUP BY
  pof.pid
