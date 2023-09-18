FROM python:3.11-slim-bookworm

ENV TGBOT_USER ${TGBOT_USER:-tgbot}
ENV TGBOT_GROUP ${TGBOT_GROUP:-tgbot}
ENV TGBOT_UID ${TGBOT_UID:-10000}
ENV TGBOT_GID ${TGBOT_UID:-10000}
ENV TGBOT_HOME_DIR ${TGBOT_HOME_DIR:-/home/tgbot}
ENV TGBOT_WORK_DIR ${TGBOT_WORK_DIR:-/home/tgbot/app}

ARG DEBIAN_FRONTEND noninteractive

# Prepare owner
RUN \
    set -eux; \
    mkdir -p $TGBOT_HOME_DIR; \
    mkdir -p $TGBOT_WORK_DIR; \
    addgroup --gid $TGBOT_GID $TGBOT_GROUP; \
    adduser --uid $TGBOT_UID --home $TGBOT_HOME_DIR --ingroup $TGBOT_GROUP $TGBOT_USER; \
    chown -R $TGBOT_USER:$TGBOT_GROUP $TGBOT_HOME_DIR; \
    chown -R $TGBOT_USER:$TGBOT_GROUP $TGBOT_WORK_DIR;

COPY . $TGBOT_WORK_DIR

# Install
RUN \
    set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ffmpeg \
        gosu \
        tini \
        ; \
    pip3 --no-color \
         --disable-pip-version-check \
         --no-cache-dir \
         install -r $TGBOT_WORK_DIR/requirements.txt;

# Clean
RUN \
    set -eux; \
    apt autoclean; \
    rm -f $TGBOT_WORK_DIR/requirements.txt; \
    rm -rf /var/lib/apt/lists/*;

WORKDIR $TGBOT_WORK_DIR

ENTRYPOINT ["tini", "--"]

CMD ["sh", "-c", "gosu $TGBOT_USER python3 bot/bot.py"]
