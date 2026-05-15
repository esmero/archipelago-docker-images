FROM jonasal/nginx-certbot:latest-alpine

RUN set -eux; \
	apk update && \
	apk add --no-cache --virtual \
            cron \
            curl \
            wget \
            bind-tools \
            mailutils \
            msmtp\
            supercronic \
            shadow \
            texinfo

# Busy Box already has a sendmail, so we override those.
RUN ln -sf /usr/bin/msmtp /usr/bin/sendmail
RUN ln -sf /usr/bin/msmtp /usr/sbin/sendmail

COPY .msmtprc.template /root/

RUN mkdir -p /usr/local/sbin/ && \
wget https://raw.githubusercontent.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker/master/install-ngxblocker -O /usr/local/sbin/install-ngxblocker && \
wget https://raw.githubusercontent.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker/master/setup-ngxblocker -O /usr/local/sbin/setup-ngxblocker && \
wget https://raw.githubusercontent.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker/master/update-ngxblocker -O /usr/local/sbin/update-ngxblocker

RUN chmod +x /usr/local/sbin/*ngxblocker

RUN mkdir /etc/nginx/bots_settings_conf.d && \
wget https://raw.githubusercontent.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker/master/conf.d/botblocker-nginx-settings.conf -O /etc/nginx/bots_settings_conf.d/botblocker-nginx-settings.conf && \
wget https://raw.githubusercontent.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker/master/conf.d/globalblacklist.conf -O /etc/nginx/bots_settings_conf.d/globalblacklist.conf

COPY setup_bot_blocker.sh /scripts/
RUN chmod +x /scripts/setup_bot_blocker.sh

RUN sed -i '2i /usr/bin/supercronic -inotify /etc/crontabs/root &' /scripts/start_nginx_certbot.sh
RUN sed -i '2a /scripts/setup_bot_blocker.sh &&' /scripts/start_nginx_certbot.sh
