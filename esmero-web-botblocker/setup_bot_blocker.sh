#!/bin/bash
set -e

if [ ! -z "${MSMTP_EMAIL}" ]; then
    envsubst < /root/.msmtprc.template > /root/.msmtprc
fi

if [ "${NGXBLOCKER_CRON_START}" = true ]; then
    if [ ! -z "${MSMTP_EMAIL}" ]; then
      echo "Ultimate bot blocker Cron and Email enabled"
      CRON_COMMAND="${NGXBLOCKER_CRON} ${NGXBLOCKER_CRON_COMMAND} -e ${MSMTP_EMAIL}"
    else
      echo "Ultimate bot blocker Cron enabled"
      CRON_COMMAND="${NGXBLOCKER_CRON} ${NGXBLOCKER_CRON_COMMAND} -n"
    fi
    echo "${CRON_COMMAND}" | crontab -
fi

if [ ! -f /etc/nginx/templates/bots.include.copy ]; then
    echo "Touching templates/bots.include.copy"
    touch /etc/nginx/templates/bots.include.copy
fi
if [ ! -f /etc/nginx/templates/bots.include.template ]; then
    echo "Touching templates/bots.include.template"
    touch /etc/nginx/templates/bots.include.template
fi

if [ "${NGXBLOCKER_ENABLE}" = true ]; then
    echo "Starting with Ultimate bot blocker enabled"
    if [ ! -L /etc/nginx/conf.d/botblocker-nginx-settings.conf ]; then
        ln -s /etc/nginx/bots_settings_conf.d/botblocker-nginx-settings.conf /etc/nginx/conf.d/botblocker-nginx-settings.conf
    fi
    if [ ! -L /etc/nginx/conf.d/globalblacklist.conf ]; then
        ln -s /etc/nginx/bots_settings_conf.d/globalblacklist.conf /etc/nginx/conf.d/globalblacklist.conf
    fi
    if ! grep -q blockbots.conf /etc/nginx/templates/bots.include.copy; then
        echo "include /etc/nginx/bots.d/blockbots.conf;" >> /etc/nginx/templates/bots.include.copy
    fi
    if ! grep -q ddos.conf /etc/nginx/templates/bots.include.copy; then
        echo "include /etc/nginx/bots.d/ddos.conf;" >> /etc/nginx/templates/bots.include.copy
    fi
    if ! grep -q blockbots.conf /etc/nginx/user_conf.d/bots.include; then
        echo "include /etc/nginx/bots.d/blockbots.conf;" >> /etc/nginx/user_conf.d/bots.include
    fi
    if ! grep -q ddos.conf /etc/nginx/user_conf.d/bots.include; then
        echo "include /etc/nginx/bots.d/ddos.conf;" >> /etc/nginx/user_conf.d/bots.include
    fi
    cp /etc/nginx/templates/bots.include.copy /etc/nginx/templates/bots.include.template
else
    echo "Starting without Ultimate bot blocker enabled"
    >|/etc/nginx/templates/bots.include.template
    >|/etc/nginx/user_conf.d/bots.include
    if [ -L /etc/nginx/conf.d/botblocker-nginx-settings.conf ]; then
        rm /etc/nginx/conf.d/botblocker-nginx-settings.conf
    fi
    if [ -L /etc/nginx/conf.d/globalblacklist.conf ]; then
        rm /etc/nginx/conf.d/globalblacklist.conf
    fi
fi
