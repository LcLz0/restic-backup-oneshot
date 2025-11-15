Simple container designed to include in other deployments.
Will run a restic backup on /backup path, keeping 7 daily and 4 weekly snapshots.
Runs a check before finishing
Mount any volumes you want to take a backup of into `/backups/volume_name`

Supply the following env vars:
```bash
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
RESTIC_REPOSITORY=
RESTIC_PASSWORD=
```

You can also take a psql dump before running the restic backup.
Following env vars is needed for psql:
```bash
PSQL_DATABASE=
PSQL_USER=
PSQL_PASS=
```

I use podman and quadlets, so I usually just ship a systemd-timer together with the backup systemd-container. Example:
#### eatlz0-backup.container
```bash
[Unit]
Description=Eatlz0 backup

[Container]
ContainerName=eatlz0-backup
Environment=APP_NAME=eatlz0
Environment=PSQL_DATABASE=tandoor
Environment=PSQL_USER=tandoor
EnvironmentFile=./secrets_backup
Image=git.lz0.link/lz0/restic-backup-oneshot:latest
Pod=eatlz0.pod
Pull=newer
StartWithPod=false
Volume=eatlz0-www-media.volume:/backup/media:ro
Volume=eatlz0-www-static.volume:/backup/static:ro

[Service]
Type=oneshot
```
#### eatlz0-backup.timer
```bash
[Unit]
Description=Run daily eatlz0 backup

[Timer]
OnCalendar=*-*-* 1:30:00

[Install]
WantedBy=timers.target
```
