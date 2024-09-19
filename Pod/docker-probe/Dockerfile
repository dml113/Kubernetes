FROM python:3.9.7-slim-buster

WORKDIR /opt/app

COPY requirements.txt requirements.txt

RUN python3 -m venv .venv && \
    .venv/bin/pip3 install -r requirements.txt

COPY app.py app.py

ENTRYPOINT ["/opt/app/.venv/bin/python3", "app.py"]