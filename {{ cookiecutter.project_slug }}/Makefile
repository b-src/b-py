PROJECT_NAME := {{ cookiecutter.project_slug }}
PYTHON_VERSION := {{ cookiecutter.python_version }}

POETRY ?= $(shell command -v poetry 2> /dev/null)

TEST_OUTPUT_DIR := test_output


##@ Help Targets

help: ## Print this help text
help:
	@awk 'BEGIN { \
		FS = ":.*##"; \
		printf "Usage: make \033[36m<target>\033[0m\n" \
	} \
	/^[a-zA-Z_-]+:.*?##/ { \
		printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2 \
	} \
	/^##@/ { \
	printf "\n\033[1m%s\033[0m\n", substr($$0, 5) \
	} \
	' $(MAKEFILE_LIST)


##@ Clean Targets
clean: ## Clear existing test reports
clean:
	@rm -rf $(TEST_OUTPUT_DIR)
	@mkdir $(TEST_OUTPUT_DIR)


##@ Run Targets

run: ## Run the project
run:
	$(POETRY) run python {{ cookiecutter.project_slug }}/main.py


##@ Test Targets

test: clean
	$(POETRY) run pytest


##@ Linting Targets

black: ## Auto-format code with black
black:
	$(POETRY) run black .

black_check_only: ## Used by CI. Check if auto-formatter would make changes and fail if so
black_check_only:
	$(POETRY) run black --check .

flake: ## Run the flakeheaven linter, which is a pyproject.toml compatible wrapper for flake8
flake:
	$(POETRY) run flakeheaven lint

mypy:
	$(POETRY) run mypy .


lint: ## Run all linting and auto-formatting
lint: black flake mypy

lint_check_only: ## Used by CI. Run all linting and formatting checks without making any changes
lint_check_only: black_check_only flake mypy


##@ Environment Targets

VENV_NAME ?= $(PROJECT_NAME)-$(PYTHON_VERSION)
CI_USERNAME ?= runner
CI_USER_HOME ?= /home/$(CI_USERNAME)

PYENV_ROOT ?= /home/$(CI_USERNAME)/.pyenv
PYENV_VENV_ROOT ?= $(PYENV_ROOT)/plugins/pyenv-virtualenv
PYENV_BIN ?= $(PYENV_ROOT)/bin/pyenv
PYENV_PLUGINS ?= $(PYENV_ROOT)/plugins
PYENV_VERSIONS ?= $(PYENV_ROOT)/versions
PYENV_VERSION_PATH ?= $(PYENV_VERSIONS)/$(PYTHON_VERSION)
PYENV_VENV_ACTIVATE_PATH ?= $(PYENV_VERSIONS)/$(VENV_NAME)/bin/activate

POETRY_DIR ?= $(CI_USER_HOME)/.local
CI_POETRY_BIN ?= $(POETRY_DIR)/bin/poetry

PYENV_SETUP_MACRO ?= export PYENV_ROOT=$(PYENV_ROOT) && \
	export PATH=$$PYENV_ROOT/bin:$$PYENV_ROOT/shims:$$PATH

PYENV_VENV_SETUP_MACRO ?= $(PYENV_SETUP_MACRO) && \
	export PATH=$(PYENV_VENV_ROOT)/shims:$$PATH

POETRY_PATH_MACRO ?= export PATH=$(POETRY_DIR)/bin:$$PATH

# source is not available in dash, use '.' instead
VENV_ACTIVATE_MACRO ?= . $(PYENV_VENV_ACTIVATE_PATH)

$(PYENV_ROOT):
	git clone https://github.com/pyenv/pyenv.git $(PYENV_ROOT)

pyenv: ## Install pyenv in the CI environment
pyenv: $(PYENV_ROOT)

$(PYENV_PLUGINS)/pyenv-virtualenv:
	git clone https://github.com/pyenv/pyenv-virtualenv.git $(PYENV_PLUGINS)/pyenv-virtualenv

pyenv_virtualenv: ## Install pyenv-virtualenv in the CI environment
pyenv_virtualenv: pyenv $(PYENV_PLUGINS)/pyenv-virtualenv

$(PYENV_VERSION_PATH):
	$(POETRY_PATH_MACRO) && \
	$(PYENV_SETUP_MACRO) && \
	pyenv install $(PYTHON_VERSION)

install_python: ## Install the project version of python using pyenv in the CI environment
install_python: pyenv_virtualenv $(PYENV_VERSION_PATH)

.python-version:
	$(PYENV_VENV_SETUP_MACRO) && \
	export PYENV_VERSION=$(PYTHON_VERSION) && \
	pyenv virtualenv $(PYTHON_VERSION) $(VENV_NAME) && \
		pyenv local $(VENV_NAME)

create_venv: ## Create venv with pyenv-virutalenv in the CI environment
create_venv: install_python .python-version

$(CI_POETRY_BIN):
	echo "installing poetry"
	curl -sSL https://install.python-poetry.org | python3 - && \
		echo "defining POETRY HOME" && \
		export POETRY_HOME=~/.local/bin && \
		echo "adding poetry to path" && \
		export PATH=$$POETRY_HOME:$$PATH && \
		echo "setting poetry to not create venvs" && \
		poetry config virtualenvs.create false

install_poetry: ## Install poetry in the CI environment
install_poetry: $(CI_POETRY_BIN)

ci_env_setup: ## Install pyenv, python version, and poetry
ci_env_setup: create_venv install_poetry
	$(POETRY_PATH_MACRO) && \
	$(VENV_ACTIVATE_MACRO) && \
	poetry install --with dev

ci_lint: ## Call check-only linting checks in the CI environment
ci_lint: POETRY=$(VENV_ACTIVATE_MACRO) && $(CI_POETRY_BIN)
ci_lint: lint_check_only

ci_test: ## Run tests in the CI environment
ci_test: POETRY=$(VENV_ACTIVATE_MACRO) && $(CI_POETRY_BIN)
ci_test: test


.PHONY: help \
	clean \
	run \
	black \
	black_check_only \
	flake \
	mypy \
	lint \
	lint_check_only \
	pyenv \
	install_python \
	create_venv \
	activate_venv \
	install_poetry \
	ci_env_setup \
	ci_lint \
	ci_test
