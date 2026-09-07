# Challenge integrity

## ADDED Requirements

### Requirement: Documented solution path is reproducible

The challenge SHALL provide a WALKTHROUGH whose every documented stage succeeds
against the files as built, with no stage that dead-ends or contradicts the
files.

#### Scenario: Escalation stage works as written

- **WHEN** a reader follows the walkthrough's gleb -> rebeca -> container-root
  escalation exactly as written
- **THEN** each step succeeds against the built container: the SUID-`find` shell
  reads `rebeca`'s files, `ssh -i` with `rebeca`'s key yields a real `rebeca`
  login whose real UID `sudo` accepts, and `sudo nano` returns a root shell that
  reads `docker-root.txt`.

#### Scenario: No stage depends on a privilege the prior step did not grant

- **WHEN** a stage invokes `sudo`
- **THEN** the preceding stage has already established the real UID that `sudo`
  authorizes against, rather than only an effective UID that `sudo` ignores.

### Requirement: Walkthrough classifies credentials honestly

The WALKTHROUGH SHALL classify each credential and key by its actual role, and
MUST NOT label as a red herring any key or credential that a documented stage
requires to succeed.

#### Scenario: A load-bearing key is not called a red herring

- **WHEN** a documented stage requires `rebeca`'s SSH private key to obtain a
  real `rebeca` login
- **THEN** the walkthrough presents that key as the intended route and contains
  no note claiming the key opens nothing new.

### Requirement: Scheduled jobs and service startup are free of recurring errors

Service startup and scheduled jobs SHALL be free of recurring errors, and a
system crontab MUST NOT also be installed as a user crontab.

#### Scenario: Cron does not error every minute

- **WHEN** the web container starts and `cron` runs
- **THEN** the container's `/etc/crontab` is used only as the system crontab and
  is not re-installed as root's user crontab, so cron does not log a malformed
  user-crontab error every minute.

### Requirement: Reproducible build pins

Base images, language packages, and any fetched static binary the documented
exploit depends on SHALL be pinned so the challenge builds reproducibly, and the
rot risk of an exact fetched-binary pin SHALL be documented for maintainers.

#### Scenario: Static Docker CLI pin is exact and its bump is documented

- **WHEN** a maintainer inspects how the static `docker` client is fetched
- **THEN** `DOCKER_CLI_VERSION` names an exact version and a maintainer note
  records that the pin must be bumped when the pinned tarball stops resolving.
