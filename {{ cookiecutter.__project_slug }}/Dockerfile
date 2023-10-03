FROM python:{{ cookiecutter.python_version }}-slim-bookworm as base

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

# TODO: make poetry version configurable in template
ENV POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_CREATE=false \
    POETRY_VERSION=1.6.1

RUN pip install "poetry==$POETRY_VERSION" --no-warn-script-location

COPY pyproject.toml poetry.lock README.md LICENSE.txt ./

RUN python3 -m poetry export --without dev -f requirements.txt -o requirements.txt && \
    python3 -m poetry export -f requirements.txt -o dev_requirements.txt


FROM base as test

COPY --from=build /home/appuser/app/dev_requirements.txt .

RUN pip install --force-reinstall -r dev_requirements.txt

COPY Makefile Makefile
COPY {{ cookiecutter.__package_name }} {{ cookiecutter.__package_name }}
COPY tests tests

CMD ["make", "test"]


FROM base as production

COPY --from=build /home/appuser/app/requirements.txt .

RUN pip install --force-reinstall -r requirements.txt

COPY entrypoint.sh .
COPY {{ cookiecutter.__package_name }} {{ cookiecutter.__package_name }}

ENTRYPOINT ["/bin/bash", "entrypoint.sh"]
