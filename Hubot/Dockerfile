FROM alpine:latest

ENV HUBOT_ADAPTER slack
ENV HUBOT_SLACK_TOKEN tbd
ENV HUBOT_GITHUB_API tbd
ENV HUBOT_GITHUB_TOKEN tbd
ENV HUBOT_NAME gitbot
ENV HUBOT_OWNER none
ENV HUBOT_DESCRIPTION $HUBOT_NAME
ENV EXTERNAL_SCRIPTS "hubot-help,underscore"
ENV INSTALL_PACKAGES "hubot-scripts,hubot-slack,hubot-sshbot,githubot,$EXTERNAL_SCRIPTS"
ENV HUBOT_SSH_PORT 122
ENV HUBOT_SSH_HOST "127.0.0.1"
ENV HUBOT_SSH_HOST_KEY /home/hubot/.ssh
ENV HUBOT_LOG_FILE "hubot.log"
ENV HUBOT_LOG_LEVEL "info"

USER root

RUN adduser --disabled-password -s /bin/bash hubot && \
    apk add --update npm && \
    apk add bash && \
    apk add jq && \
    apk add openssh && \
    npm install -g hubot coffeescript yo generator-hubot

# Apple only
#ADD "https://pages.github.pie.apple.com/crypto-services/trust-apple-corp-root-cas/trust_apple_corp_root_cas.sh" "/usr/local/bin"
#RUN chmod 755 "/usr/local/bin/trust_apple_corp_root_cas.sh" && \
#    bash "/usr/local/bin/trust_apple_corp_root_cas.sh"

USER hubot
WORKDIR /home/hubot

RUN yo hubot --owner="${HUBOT_OWNER}" --name="${HUBOT_NAME}" --description="${HUBOT_DESCRIPTION}" --defaults \
    --HUBOT_SLACK_TOKEN="${HUBOT_SLACK_TOKEN}" \
    --HUBOT_GITHUB_TOKEN="${HUBOT_GITHUB_TOKEN}" \
    --HUBOT_GITHUB_API="${HUBOT_GITHUB_API}" \
    && \
    sed -i /heroku/d ./external-scripts.json && \
    sed -i /redis-brain/d ./external-scripts.json && \
    node -e "console.log(JSON.stringify('$EXTERNAL_SCRIPTS'.split(',')))" > external-scripts.json && \
    npm install $(node -e "console.log('$INSTALL_PACKAGES'.split(',').join(' '))") --save

VOLUME ["/home/hubot/scripts"]

# Hubot 'Logger' patch
COPY patch/hubot/robot.js /home/hubot/node_modules/hubot/src/robot.js

CMD bin/hubot -n $HUBOT_NAME --adapter ${HUBOT_ADAPTER}
