FROM python:3.9-alpine3.13

ENV PYTHONUNBEFFERED 1

COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app
WORKDIR /app

EXPOSE 8000

ARG DEV=false
RUN pip install --upgrade pip && \
    # install postgresql client
    apk add --update --no-cache postgresql-client && \
    # install dependencies needed to build psycopg2 in a virtual package
    apk add --update --no-cache --virtual .tmp-build-deps \
        # dependencies needed to install psycopg2
        build-base postgresql-dev musl-dev && \
    pip install -r /tmp/requirements.txt && \
    if [ $DEV = "true" ]; \
        # if dev environment, install dev dependencies
        then pip install -r /tmp/requirements.dev.txt; \
    fi && \
    rm -rf /tmp && \
    # remove virtual package
    apk del .tmp-build-deps && \
    # Create a non-root user to run the application
    adduser \
      # no password needed
      --disabled-password \
      # no home directory
      --no-create-home \
      # user name
      django-user

USER django-user
