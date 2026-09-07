# Tasks

## 1. Fix the documented solution path

- [x] 1.1 Rewrite `docs/WALKTHROUGH.md` Stage 5 to note the SUID-`find` shell
  gives euid=rebeca (ruid stays gleb) and to read `/home/rebeca/.ssh/id_rsa`
  through it.
- [x] 1.2 Rewrite `docs/WALKTHROUGH.md` Stage 6 to `ssh -i id_rsa rebeca@localhost`
  for a real `rebeca` login (ruid=rebeca) before `sudo -l` / `sudo nano`.
- [x] 1.3 Delete the "red herring" note for `rebeca`'s SSH key in the Notes
  section of `docs/WALKTHROUGH.md`.

## 2. Fix build and config hygiene

- [x] 2.1 Drop the `crontab /etc/crontab &&` clause in
  `docker-web/nginx.Dockerfile` (keep the system `/etc/crontab` and
  `service cron start`).
- [x] 2.2 Remove the redundant `rebeca ... NOPASSWD: /usr/bin/sudo -l` grant and
  the trailing-whitespace line in `docker-web/sudoers`.

## 3. Document

- [x] 3.1 Add a maintainer note near the version list about bumping
  `DOCKER_CLI_VERSION` when the pinned static tarball stops resolving.
- [x] 3.2 Add a note that `docker-web/.ssh.tar` is an intentional disposable
  challenge key (preempts false-positive secret scans).
- [x] 3.3 Add a `CHANGELOG.md` entry dated 2026-09-06 summarizing the integrity
  fixes.
