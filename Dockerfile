FROM python:3.12-slim

WORKDIR /sample-app

COPY requirements.txt requirements-server.txt /sample-app/

RUN pip3 install --no-cache-dir -r requirements.txt && \
    pip3 install --no-cache-dir -r requirements-server.txt

COPY . /sample-app/

ENV LC_ALL="C.UTF-8"
ENV LANG="C.UTF-8"

EXPOSE 8000/tcp

CMD ["/bin/sh", "-c", "flask db upgrade && gunicorn app:app -b 0.0.0.0:8000"]
