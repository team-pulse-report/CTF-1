FROM nginx:1.30.4

# Exact pin for reproducibility. Bump this when the pinned static tarball stops
# resolving (download.docker.com prunes old patch releases over time).
ARG DOCKER_CLI_VERSION=29.8.0

# Installing needed software
RUN apt-get update && \
    apt-get install -y sudo nano openssh-server cron ncat net-tools curl ca-certificates && \

    echo "Installing a static Docker CLI (used for the final socket breakout)" \
    && arch="$(uname -m)" \
    && curl -fsSL "https://download.docker.com/linux/static/stable/${arch}/docker-${DOCKER_CLI_VERSION}.tgz" -o /tmp/docker.tgz \
    && tar -xzf /tmp/docker.tgz -C /usr/local/bin --strip-components=1 docker/docker \
    && rm -f /tmp/docker.tgz && \

    echo "Cleaning cache" \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Adding users | passwords | .bash_history > /dev/null
RUN useradd -m gleb && useradd -m rebeca && \
    echo "gleb:sunshine" | chpasswd && \
    echo rebeca:$(openssl rand -base64 20) | chpasswd && \
    ln -sf /dev/null /home/gleb/.bash_history && \
    ln -sf /dev/null /home/rebeca/.bash_history && \
    ln -sf /dev/null /root/.bash_history

# for ssh
ADD ./.ssh.tar /home/rebeca/
RUN mkdir -p /var/run/sshd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config && \
    chmod 700 -R /home/rebeca/.ssh && chown rebeca:rebeca -R /home/rebeca/.ssh

# FLAGS
COPY --chown=gleb:gleb --chmod=600 ./flags/gleb.txt /home/gleb/gleb.txt
COPY --chown=rebeca:rebeca --chmod=600 ./flags/rebeca.txt /home/rebeca/rebeca.txt
COPY --chown=root:root --chmod=600 ./flags/docker-root.txt /root/docker-root.txt

# figure out yourself)))
COPY ./default.conf /etc/nginx/conf.d/default.conf
COPY ./html /home/gleb/html
COPY --chmod=644 ./crontab /etc/crontab
COPY --chmod=644 ./demotivation /root/demotivation
COPY --chown=root:root --chmod=440 ./sudoers /etc/sudoers

RUN chown rebeca:root /usr/bin/find && \
    chmod u+s /usr/bin/find && \
    chown gleb:gleb -R /home/gleb/html && \
    chown root:root /home/gleb/html/logs && chmod 777 /home/gleb/html/logs && \
    # Let the nginx worker traverse gleb's home to reach the docroot. Newer
    # Debian bases create home dirs as 0700; 0711 allows traversal only, so
    # gleb.txt (0600) stays private.
    chmod 711 /home/gleb

EXPOSE 8080 22

CMD service ssh start && service cron start && nginx -g 'daemon off;'
