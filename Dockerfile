FROM python:3.12-slim-bulleye
LABEL maintainer="Kevin Fronczak <kfronczak@gmail.com>"

VOLUME /work
VOLUME /share

ENV TZ=America/New_York

RUN mkdir /app
WORKDIR /app

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    cron \
    rsyslog \
    logrotate && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Prebuild packages
ADD prebuild /tmp
RUN cd /tmp && \
   pip install numpy*.whl \
   pandas*.whl \
   astral*.whl
RUN rm -rf /tmp/numpy*.whl /tmp/pandas*.whl /tmp/astral*.whl

COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt
COPY VERSION VERSION
COPY app/ .
COPY system/rsyslog.conf /etc/rsyslog.conf

RUN python setup.py bdist_wheel && pip install dist/*.whl
RUN rm -rf build dist *egg.info

WORKDIR /work
RUN chmod +x /app/start.sh
RUN chmod +x /app/run.py

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

CMD ["/app/start.sh"]
