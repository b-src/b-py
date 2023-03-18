FROM python:{{ cookiecutter.python_version }}-slim-buster as base

RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV PYTHONFAULTHANDLER=1

RUN useradd --create-home appuser
USER appuser

RUN mkdir /home/appuser/app 

WORKDIR /home/appuser/app

FROM base as build

ENV POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_CREATE=false \
    POETRY_VERSION=1.2.1

RUN pip install "poetry==$POETRY_VERSION"

COPY pyproject.toml poetry.lock README.md LICENSE.txt ./

RUN python3 -m poetry export --without dev -f requirements.txt -o requirements.txt


FROM base

COPY --from=build /home/appuser/app/requirements.txt .

RUN pip install --force-reinstall -r requirements.txt

COPY entrypoint.sh .
COPY {{ cookiecutter.project_slug }} {{ cookiecutter.project_slug }}

ENTRYPOINT ["/bin/bash", "entrypoint.sh"]
