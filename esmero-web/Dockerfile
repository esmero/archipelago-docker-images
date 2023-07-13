FROM jonasal/nginx-certbot
LABEL maintainer="Albert Min <amin@metro.org>"

RUN set -ex && \
# Install nginx blocker packages needed to run after build.
    apt-get update && \
    apt-get install -y --no-install-recommends \
            cron \
            curl \
            wget \
            dnsutils \
            mailutils \
            msmtp

# Symlink sendmail to use msmtp.
RUN ln -s /usr/bin/msmtp /usr/sbin/sendmail

# Copy msmtp template file for config to read environment variables.
COPY .msmtprc.template /root/

# Download nginx blocker script files and give execute permissions.
RUN wget https://raw.githubusercontent.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker/master/install-ngxblocker -O /usr/local/sbin/install-ngxblocker && \
wget https://raw.githubusercontent.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker/master/setup-ngxblocker -O /usr/local/sbin/setup-ngxblocker && \
wget https://raw.githubusercontent.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker/master/update-ngxblocker -O /usr/local/sbin/update-ngxblocker && \
chmod +x /usr/local/sbin/*ngxblocker

# Fetch nginx blocker settings files
RUN mkdir /etc/nginx/bots_settings_conf.d && \
wget https://raw.githubusercontent.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker/master/conf.d/botblocker-nginx-settings.conf -O /etc/nginx/bots_settings_conf.d/botblocker-nginx-settings.conf && \
wget https://raw.githubusercontent.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker/master/conf.d/globalblacklist.conf -O /etc/nginx/bots_settings_conf.d/globalblacklist.conf

# Copy our script and give execute permissions.
COPY setup_bot_blocker.sh /scripts/
RUN chmod +x /scripts/setup_bot_blocker.sh

# Insert our script into nginx certbot script so it starts before.
RUN sed -i '2 i /scripts/setup_bot_blocker.sh &&' /scripts/start_nginx_certbot.sh
