SELECT file.path, gid, uid, mode, type, size, sha256
--  missed many directories
FROM file
JOIN hash ON file.path = hash.path
WHERE
(
    file.path LIKE "/bin/%"
    OR file.path LIKE "/sbin/%"
    OR file.path LIKE "/usr/sbin/%"
    OR file.path LIKE "/usr/lib/%"
    OR file.path LIKE "/usr/lib64/%"
    OR file.path LIKE "/usr/bin/%"
    OR file.path LIKE "/usr/libexec/%"
    OR file.path LIKE "/usr/local/bin/%"
    OR file.path LIKE "/usr/local/sbin/%"
    OR file.path LIKE "/opt/%/bin/%"
    OR file.path LIKE "/opt/%/sbin/%"
    OR file.path LIKE "/usr/local/lib/%"
    OR file.path LIKE "/usr/local/lib64/%"
    OR file.path LIKE "/usr/local/libexec/%"
    OR file.path LIKE "/var/lib/%"
    OR file.path LIKE "/var/tmp/%"
    OR file.path LIKE "/tmp/%"
    OR file.path LIKE "/home/%/bin/%"
    OR file.path LIKE "/Users/%/bin/%"
)
AND type='regular'
AND mode NOT LIKE "0%"
AND mode NOT LIKE "1%"
AND mode NOT LIKE "2%"
AND NOT (mode LIKE '4%11' AND uid=0 AND gid=0 AND
    file.path IN (
        '/usr/sbin/wodim',
        '/usr/sbin/userhelper',
        '/usr/sbin/umount.nfs4',
        '/usr/sbin/umount.nfs',
        '/usr/sbin/rscsi',
        '/usr/sbin/readom',
        '/usr/sbin/readcd',
        '/usr/sbin/mount.nfs4',
        '/usr/sbin/mount.nfs',
        '/usr/sbin/icedax',
        '/usr/sbin/cdrecord',
        '/usr/sbin/cdda2wav',
        '/usr/bin/wodim',
        '/usr/bin/umount.nfs4',
        '/usr/bin/umount.nfs',
        '/usr/bin/sudoedit',
        '/usr/bin/sudo',
        '/usr/bin/rscsi',
        '/usr/bin/readom',
        '/usr/bin/readcd',
        '/usr/bin/mount.nfs4',
        '/usr/bin/mount.nfs',
        '/usr/bin/icedax',
        '/usr/bin/cdrecord',
        '/usr/bin/cdda2wav',
        '/sbin/wodim',
        '/sbin/userhelper',
        '/sbin/umount.nfs4',
        '/sbin/umount.nfs',
        '/sbin/rscsi',
        '/sbin/readom',
        '/sbin/readcd',
        '/sbin/mount.nfs4',
        '/sbin/mount.nfs',
        '/sbin/icedax',
        '/sbin/cdrecord',
        '/sbin/cdda2wav',
        '/bin/wodim',
        '/bin/umount.nfs4',
        '/bin/umount.nfs',
        '/bin/sudoedit',
        '/bin/sudo',
        '/bin/rscsi',
        '/bin/readom',
        '/bin/readcd',
        '/bin/mount.nfs4',
        '/bin/mount.nfs',
        '/bin/icedax',
        '/bin/cdrecord',
        '/bin/cdda2wav',
        '/usr/bin/staprun',
        '/bin/staprun',
        '/usr/libexec/security_authtrampoline'
    )
)
AND NOT (mode LIKE '4%55' AND uid=0 AND gid=0 AND
    file.path IN (
        '/usr/sbin/unix_chkpwd',
        '/usr/sbin/umount.nfs4',
        '/usr/sbin/umount.nfs',
        '/usr/sbin/umount',
        '/usr/libexec/authopen',
        '/bin/nvidia-modprobe',
        '/sbin/nvidia-modprobe',
        '/usr/bin/nvidia-modprobe',
        '/usr/sbin/nvidia-modprobe',
        '/usr/sbin/traceroute6',
        '/usr/sbin/traceroute',
        '/usr/sbin/suexec',
        '/usr/sbin/sudoedit',
        '/usr/sbin/sudo',
        '/usr/sbin/su',
        '/usr/sbin/sg',
        '/usr/sbin/rltraceroute6',
        '/usr/sbin/rdisc6',
        '/usr/sbin/pkexec',
        '/usr/sbin/passwd',
        '/usr/sbin/pam_timestamp_check',
        '/usr/sbin/newgrp',
        '/usr/sbin/ndisc6',
        '/usr/sbin/mount.nfs4',
        '/usr/sbin/mount.nfs',
        '/usr/sbin/mount',
        '/usr/sbin/ksu',
        '/usr/sbin/grub2-set-bootflag',
        '/usr/sbin/gpasswd',
        '/usr/sbin/fusermount3',
        '/usr/sbin/fusermount',
        '/usr/sbin/expiry',
        '/usr/sbin/doas',
        '/usr/sbin/crontab',
        '/usr/sbin/chsh',
        '/usr/sbin/chfn',
        '/usr/sbin/chage',
        '/usr/bin/vmware-user-suid-wrapper',
        '/usr/bin/vmware-user',
        '/usr/bin/umount',
        '/usr/bin/top',
        '/usr/bin/suexec',
        '/usr/bin/sudoedit',
        '/usr/bin/sudo',
        '/usr/bin/su',
        '/usr/bin/sg',
        '/usr/bin/rltraceroute6',
        '/usr/bin/rdisc6',
        '/usr/bin/quota',
        '/usr/bin/pkexec',
        '/usr/bin/passwd',
        '/usr/bin/newgrp',
        '/usr/bin/ndisc6',
        '/usr/bin/mount',
        '/usr/bin/login',
        '/usr/bin/ksu',
        '/usr/bin/gpasswd',
        '/usr/bin/fusermount-glusterfs',
        '/usr/bin/fusermount3',
        '/usr/bin/fusermount',
        '/usr/bin/expiry',
        '/usr/bin/doas',
        '/usr/bin/crontab',
        '/usr/bin/chsh',
        '/usr/bin/chfn',
        '/usr/bin/chage',
        '/usr/bin/batch',
        '/usr/bin/atrm',
        '/usr/bin/atq',
        '/usr/bin/at',
        '/sbin/unix_chkpwd',
        '/sbin/umount.nfs4',
        '/sbin/umount.nfs',
        '/sbin/umount',
        '/sbin/suexec',
        '/sbin/sudoedit',
        '/sbin/sudo',
        '/sbin/su',
        '/sbin/sg',
        '/sbin/rltraceroute6',
        '/sbin/rdisc6',
        '/sbin/pkexec',
        '/sbin/passwd',
        '/sbin/pam_timestamp_check',
        '/sbin/newgrp',
        '/sbin/ndisc6',
        '/sbin/mount.nfs4',
        '/sbin/mount.nfs',
        '/sbin/mount',
        '/sbin/ksu',
        '/sbin/grub2-set-bootflag',
        '/sbin/gpasswd',
        '/sbin/fusermount3',
        '/sbin/fusermount',
        '/sbin/expiry',
        '/sbin/doas',
        '/sbin/crontab',
        '/sbin/chsh',
        '/sbin/chfn',
        '/sbin/chage',
        '/bin/vmware-user-suid-wrapper',
        '/bin/vmware-user',
        '/bin/umount',
        '/bin/suexec',
        '/bin/sudoedit',
        '/bin/sudo',
        '/bin/su',
        '/bin/sg',
        '/bin/rltraceroute6',
        '/bin/rdisc6',
        '/bin/ps',
        '/bin/pkexec',
        '/bin/passwd',
        '/bin/newgrp',
        '/bin/ndisc6',
        '/bin/mount',
        '/bin/ksu',
        '/bin/gpasswd',
        '/bin/fusermount-glusterfs',
        '/bin/fusermount3',
        '/bin/fusermount',
        '/bin/expiry',
        '/bin/doas',
        '/bin/crontab',
        '/bin/chsh',
        '/bin/chfn',
        '/bin/chage',
        '/usr/lib/Xorg.wrap',
        '/usr/lib/mail-dotlock',
        '/usr/lib/xf86-video-intel-backlight-helper',
        '/usr/lib64/Xorg.wrap',
        '/usr/lib64/mail-dotlock',
        '/usr/lib64/xf86-video-intel-backlight-helper',
        '/usr/libexec/qemu-bridge-helper',
        '/usr/libexec/Xorg.wrap',
        '/usr/libexec/polkit-agent-helper-1',
        '/bin/newgidmap',
        '/bin/newuidmap'
        '/usr/bin/newgidmap',
        '/usr/bin/newuidmap',
        '/bin/ubuntu-core-launcher',
    )
)
AND NOT (mode ='4754' AND uid=0 AND gid=30 AND
    file.path IN (
        '/usr/sbin/pppd',
        '/sbin/ppd'
    )
)

AND NOT (mode ='6755' AND uid=0 AND gid=0 AND
    file.path IN (
        '/bin/mount.cifs',
        '/bin/mount.smb3',
        '/bin/unix_chkpwd',
        '/sbin/mount.cifs',
        '/sbin/mount.smb3',
        '/sbin/unix_chkpwd',
        '/usr/bin/mount.cifs',
        '/usr/bin/mount.smb3',
        '/usr/bin/unix_chkpwd',
        '/usr/sbin/mount.cifs',
        '/usr/sbin/mount.smb3',
        '/usr/sbin/unix_chkpwd',
        '/usr/lib/xtest',
        '/usr/lib64/xtest'
    )
)
