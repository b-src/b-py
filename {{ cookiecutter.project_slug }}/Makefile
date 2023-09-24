PROJECT_NAME := {{ cookiecutter.project_slug }}
PYTHON_VERSION := {{ cookiecutter.python_version }}

VENV_NAME ?= $(PROJECT_NAME)-$(PYTHON_VERSION)
# It would be better to respect $PYENV_ROOT in the environment
PYENV_ROOT = $(HOME)/.pyenv
PYENV_BIN = $(PYENV_ROOT)/bin/pyenv
PYENV_VERSIONS ?= $(PYENV_ROOT)/versions
PYENV_PLUGINS ?= $(PYENV_ROOT)/plugins
PYENV_VENV_ROOT ?= $(PYENV_PLUGINS)/pyenv-virtualenv
PYENV_VENV_BIN ?= $(PYENV_VENV_ROOT)/bin/pyenv-virtualenv
PYENV_PYRIGHT_ROOT ?= $(PYENV_PLUGINS)/pyenv-pyright
PYENV_PYRIGHT_BIN ?= $(PYENV_PYRIGHT_ROOT)/bin/pyenv-pyright
PYENV_VERSION_PATH ?= $(PYENV_VERSIONS)/$(PYTHON_VERSION)

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

##@ Environment Targets

$(PYENV_BIN):
	@echo pyenv not installed at $(PYENV_BIN)
	exit 1

pyenv: ## NOT IMPLEMENTED - Install pyenv
pyenv: $(PYENV_BIN)

$(PYENV_VENV_ROOT):
	@echo pyenv-virtualenv not installed at $(PYENV_VENV_ROOT)
	exit 1

pyenv_virtualenv: ## NOT IMPLEMENTED Install pyenv-virtualenv
pyenv_virtualenv: pyenv $(PYENV_VENV_ROOT)

$(PYENV_PYRIGHT_ROOT):
	@echo pyenv-pyright not installed at $(PYENV_PYRIGHT_ROOT)
	exit 1

pyenv_pyright: ## NOT IMPLEMENTED Install pyenv-virtualenv
pyenv_pyright: pyenv $(PYENV_PYRIGHT_ROOT)

$(PYENV_VERSION_PATH):
	pyenv install $(PYTHON_VERSION)

install_python: ## Install the project version of python using pyenv
install_python: pyenv pyenv_virtualenv $(PYENV_VERSION_PATH)

.python-version: install_python
	pyenv virtualenv $(PYTHON_VERSION) $(VENV_NAME) && \
		pyenv local $(VENV_NAME)

create_venv: ## Create venv with pyenv-virutalenv in the CI environment
create_venv: .python-version

pyrightconfig.json:
	pyenv pyright $(PYTHON_VERSION)

link_pyright_to_venv: ## Create pyrightconfig.json linking pyright to the venv
link_pyright_to_venv: pyenv_pyright pyrightconfig.json

set_up_local_environment: ## Fully set up the local environment
set_up_local_environment: create_venv link_pyright_to_venv
	

##@ Clean Targets

clean: ## Clear existing test reports
clean:
	@rm -rf $(TEST_OUTPUT_DIR)
	@mkdir $(TEST_OUTPUT_DIR)


##@ Docker Targets

# TODO: properly tag
docker_build: ## build the production docker container
docker_build:
	docker build --target production .

docker_test: ## run tests in docker
docker_test:
	docker build --target tests .


##@ Run Targets

run: ## Run the project
run: set_up_local_environment
	$(POETRY) run python {{ cookiecutter.project_slug }}/main.py


##@ Test Targets

# TODO: add set_up_local_environment as a dependency after that won't break CI
test: ## Run automated tests
test: clean
	$(POETRY) run pytest


##@ Linting Targets

ARGS ?= .
black: ## Auto-format code with black
black: set_up_local_environment
	$(POETRY) run black $(ARGS)

black_check_only: ## Used by CI. Check if auto-formatter would make changes and fail if so
black_check_only:
	$(POETRY) run black --check .

# TODO: add set_up_local_environment as a dependency after that won't break CI
flake: ## Run the flakeheaven linter, which is a pyproject.toml compatible wrapper for flake8
flake:
	$(POETRY) run flakeheaven lint

# TODO: add set_up_local_environment as a dependency after that won't break CI
mypy: ## Check type hints with mypy
mypy:
	$(POETRY) run mypy .


lint: ## Run all linting and auto-formatting
lint: black flake mypy

lint_check_only: ## Used by CI. Run all linting and formatting checks without making any changes
lint_check_only: black_check_only flake mypy


##@ CI Environment Targets
# There is a lot of overlap between these and local environment targets.
# This should be refactored to share as much as possible after figuring out the best way to handle local env setup

CI_USERNAME ?= runner

CI_USER_HOME ?= /home/$(CI_USERNAME)
CI_PYENV_ROOT ?= $(CI_USER_HOME)/.pyenv
CI_PYENV_PLUGINS ?= $(CI_PYENV_ROOT)/plugins
CI_PYENV_VENV_ROOT ?= $(CI_PYENV_PLUGINS)/pyenv-virtualenv
CI_PYENV_VERSIONS ?= $(CI_PYENV_ROOT)/versions
CI_PYENV_VERSION_PATH ?= $(CI_PYENV_VERSIONS)/$(PYTHON_VERSION)
CI_PYENV_VENV_ACTIVATE_PATH ?= $(PYENV_VERSIONS)/$(VENV_NAME)/bin/activate

CI_POETRY_DIR ?= $(HOME)/.local
CI_POETRY_BIN ?= $(CI_POETRY_DIR)/bin/poetry

CI_PYENV_SETUP_MACRO ?= export PYENV_ROOT=$(CI_PYENV_ROOT) && \
	export PATH=$$PYENV_ROOT/bin:$$PYENV_ROOT/shims:$$PATH

CI_PYENV_VENV_SETUP_MACRO ?= $(CI_PYENV_SETUP_MACRO) && \
	export PATH=$(CI_PYENV_VENV_ROOT)/shims:$$PATH

CI_POETRY_PATH_MACRO ?= export PATH=$(CI_POETRY_DIR)/bin:$$PATH

# source is not available in dash, use '.' instead
CI_VENV_ACTIVATE_MACRO ?= . $(CI_PYENV_VENV_ACTIVATE_PATH)

$(CI_PYENV_ROOT):
	git clone https://github.com/pyenv/pyenv.git $(CI_PYENV_ROOT)

ci_pyenv: ## Install pyenv in the CI environment
ci_pyenv: $(CI_PYENV_ROOT)

$(CI_PYENV_PLUGINS)/pyenv-virtualenv:
	git clone https://github.com/pyenv/pyenv-virtualenv.git $(PYENV_PLUGINS)/pyenv-virtualenv

ci_pyenv_virtualenv: ## Install pyenv-virtualenv in the CI environment
ci_pyenv_virtualenv: ci_pyenv $(CI_PYENV_PLUGINS)/pyenv-virtualenv

$(CI_PYENV_VERSION_PATH):
	$(CI_POETRY_PATH_MACRO) && \
	$(CI_PYENV_SETUP_MACRO) && \
	pyenv install $(PYTHON_VERSION)

ci_install_python: ## Install the project version of python using pyenv in the CI environment
ci_install_python: ci_pyenv_virtualenv $(CI_PYENV_VERSION_PATH)

# Call commands to create .python-version directly instead of making a separate target.
# This avoids interfering with the local environment .python-version recipe.
# It's fine for now because we know this will only be called once during CI env setup.
ci_create_venv: ## Create venv with pyenv-virutalenv in the CI environment
ci_create_venv: ci_install_python 
	$(CI_PYENV_VENV_SETUP_MACRO) && \
	export PYENV_VERSION=$(PYTHON_VERSION) && \
	pyenv virtualenv $(PYTHON_VERSION) $(VENV_NAME) && \
		pyenv local $(VENV_NAME)

$(CI_POETRY_BIN):
	echo "installing poetry"
	curl -sSL https://install.python-poetry.org | python3 - && \
		echo "defining POETRY HOME" && \
		export POETRY_HOME=~/.local/bin && \
		echo "adding poetry to path" && \
		export PATH=$$POETRY_HOME:$$PATH && \
		echo "setting poetry to not create venvs" && \
		poetry config virtualenvs.create false

ci_install_poetry: ## Install poetry in the CI environment
ci_install_poetry: $(CI_POETRY_BIN)

ci_env_setup: ## Install pyenv, python version, and poetry
ci_env_setup: ci_create_venv ci_install_poetry
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
	pyenv \
	pyenv_virtualenv \
	pyenv_pyright \
	install_python \
	create_venv \
	link_pyright_to_venv \
	set_up_local_environment \
	clean \
	docker_build \
	docker_test \
	run \
	black \
	black_check_only \
	flake \
	mypy \
	lint \
	lint_check_only \
	ci_pyenv \
	ci_install_python \
	ci_create_venv \
	ci_activate_venv \
	ci_install_poetry \
	ci_env_setup \
	ci_lint \
	ci_test
