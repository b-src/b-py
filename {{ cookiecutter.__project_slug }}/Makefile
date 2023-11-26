PROJECT_NAME := {{ cookiecutter.__project_slug }}
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

.PHONY: help
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

.PHONY: pyenv
pyenv: ## NOT IMPLEMENTED - Install pyenv. For now just checks that pyenv is already installed
pyenv: $(PYENV_BIN)

$(PYENV_VENV_ROOT):
	@echo pyenv-virtualenv not installed at $(PYENV_VENV_ROOT)
	exit 1

.PHONY: pyenv_virtualenv
pyenv_virtualenv: ## NOT IMPLEMENTED Install pyenv-virtualenv. For now just checks that pyenv-virtualenv is already installed
pyenv_virtualenv: pyenv $(PYENV_VENV_ROOT)

$(PYENV_PYRIGHT_ROOT):
	@echo pyenv-pyright not installed at $(PYENV_PYRIGHT_ROOT)
	exit 1

.PHONY: pyenv_pyright
pyenv_pyright: ## NOT IMPLEMENTED Install pyenv-pyright. For now just checks that pyenv-pyright is already installed
pyenv_pyright: pyenv $(PYENV_PYRIGHT_ROOT)

$(PYENV_VERSION_PATH):
	pyenv install $(PYTHON_VERSION)

.PHONY: install_python
install_python: ## Install the project version of python using pyenv
install_python: pyenv pyenv_virtualenv $(PYENV_VERSION_PATH)

.python-version:
	pyenv virtualenv $(PYTHON_VERSION) $(VENV_NAME) && \
		pyenv local $(VENV_NAME)

.PHONY: create_venv
create_venv: ## Create venv with pyenv-virutalenv
create_venv: install_python .python-version

# TODO: store the list of base dependencies elsewhere
# TODO: poetry install should not be necessary here but it seems like it is sometimes
poetry.lock:
	$(POETRY) add bump2version cruft isort mypy ruff --group dev && \
		$(POETRY) install

.PHONY: add_base_dependencies
add_base_dependencies: ## Add base project and dev dependencies 
add_base_dependencies: create_venv poetry.lock

pyrightconfig.json:
	pyenv pyright $(VENV_NAME)

.PHONY: link_pyright_to_venv
link_pyright_to_venv: ## Create pyrightconfig.json linking pyright to the venv
link_pyright_to_venv: pyenv_pyright pyrightconfig.json

.PHONY: set_up_local_environment
set_up_local_environment: ## Fully set up the local environment
set_up_local_environment: create_venv add_base_dependencies link_pyright_to_venv
	

##@ Clean Targets

.PHONY: clean
clean: ## Clear existing test reports
clean:
	@rm -rf $(TEST_OUTPUT_DIR)
	@mkdir $(TEST_OUTPUT_DIR)


##@ Docker Targets

# TODO: properly tag
.PHONY: docker_build
docker_build: ## build the production docker container
docker_build: set_up_local_environment
	docker build --target production .

.PHONY: docker_test
docker_test: ## run tests in docker
docker_test: set_up_local_environment
	docker build --target test .


##@ Run Targets

.PHONY: run
run: ## Run the project
run: set_up_local_environment
	$(POETRY) run python {{ cookiecutter.__package_name }}/main.py


##@ Test Targets

.PHONY: test
test: ## Run automated tests
test: clean set_up_local_environment
	$(POETRY) run pytest


##@ Linting Targets

ARGS ?= .
.PHONY: format
format: ## Auto-format code with ruff
format: set_up_local_environment
	$(POETRY) run ruff format . $(ARGS)

.PHONY: format_check_only
format_check_only: ## Used by CI. Check if auto-formatter would make changes and fail if so
format_check_only:
	$(POETRY) run ruff format --check .

.PHONY: ruff
ruff: ## Run the ruff linter and automatically fix issues where possible
ruff: set_up_local_environment
	$(POETRY) run ruff check . --fix

.PHONY: ruff_check_only
ruff: ## Used by CI. Check if ruff linter would make changes and fail if so
ruff: set_up_local_environment
	$(POETRY) run ruff check .

.PHONY: mypy
mypy: ## Check type hints with mypy
mypy: set_up_local_environment
	$(POETRY) run mypy .

.PHONY: isort
isort: ## sort imports with isort
isort:
	$(POETRY) run isort .


.PHONY: isort_check_only
isort_check_only: ## Used by CI. Check if isort would make changes and fail if so.
isort_check_only:
	$(POETRY) run isort --check-only .


.PHONY: lint
lint: ## Run all linting and auto-formatting
lint: format isort ruff mypy

.PHONY: lint_check_only
lint_check_only: ## Used by CI. Run all linting and formatting checks without making any changes
lint_check_only: format_check_only isort_check_only ruff_check_only mypy


##@ Versioning Targets

.PHONY: bump
bump: ## Bump version using bump2version
bump: set_up_local_environment
	@read -n 1 -p "Major [M], minor [m], or patch [p]? [M/m/p] " part && \
		case $${part} in \
			M ) \
				$(POETRY) run bump2version major \
			;; \
			m ) \
				$(POETRY) run bump2version minor \
			;; \
			p ) \
				$(POETRY) run bump2version patch \
			;; \
		esac

##@ CI Environment Targets
.PHONY: ci_lint
ci_lint: ## Call check-only linting checks in the CI environment
ci_lint: lint_check_only
