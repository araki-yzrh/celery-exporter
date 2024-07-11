#FROM amazonlinux:2
FROM amazonlinux:2023

RUN yum update -y && yum groupinstall -y "Development Tools"
#RUN yum install -y gcc zlib-devel bzip2 bzip2-devel readline-devel sqlite sqlite-devel openssl11-devel tk-devel libffi-devel xz-devel
RUN yum install -y gcc zlib-devel bzip2 bzip2-devel readline-devel sqlite sqlite-devel openssl-devel tk-devel libffi-devel xz-devel

ENV PYENV_ROOT="/root/.pyenv"
ENV PATH="$PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH"
#ENV PYTHON_CONFIGURE_OPTS=--enable-shared
ENV PYTHON_CONFIGURE_OPTS='LDFLAGS="-static" --disable-shared'
ENV POETRY_VIRTUALENVS_CREATE=false

RUN curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash

ARG PYTHON_VERSION=3.9.1

RUN pyenv install $PYTHON_VERSION && pyenv global $PYTHON_VERSION

RUN pip install poetry

WORKDIR /app/

COPY ./pyproject.toml ./poetry.lock /app/

RUN poetry install

COPY . /app/

RUN eval "$(pyenv init -)"

RUN pyinstaller cli.py -y --onefile --name celery-exporter \
        --hidden-import=celery.fixups \
        --hidden-import=celery.fixups.django \
        --hidden-import=celery.app.events \
        --hidden-import=celery.loaders.app \
        --hidden-import=celery.app.amqp \
        --hidden-import=celery.app.control \
        --hidden-import=kombu.transport.redis \
        --hidden-import=kombu.transport.pyamqp \
        --log-level=DEBUG
