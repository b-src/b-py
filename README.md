# b-py

b-py is a python project template built with cookiecutter[https://github.com/cookiecutter/cookiecutter] and cruft[https://github.com/cruft].

cookiecutter is a tool that lets you create a project from a template. cruft allows you to sync your project to a cookiecutter template and easily apply updates.

for a high level overview of how I think about python development see here[https://brettgleason.xyz/python.html]

for a more in-depth breakdown of why certain choices were made, see here[https://brettgleason.xyz/b-py.html]


## Features

 - containerized application
 - tools chosen with compatibility with pyproject.toml in mind
 - a CLI for project tasks built with make
 - poetry for dependency management
 - auto-formatting with black
 - linting with flakeheaven (a pyproject.toml-compatible fork of flake8)
 - type hint checking with mypy
 - a CI pipeline configuration for github actions that:
   + runs formatting and linting checks
   + runs the automated test suite
   + builds the app container
 - MIT license


## Requirements

b-py requires the following programs to be installed in the local environment
 - cruft
 - cookiecutter
 - pyenv
 - pyenv-virtualenv
 - pyenv-pyright
 - poetry
 - make

## Usage

### Creating a new project from the template

```
 $ cruft create https://github.com/b-src/b-py/
```

after this you will be prompted for the project variables stored in `cookiecutter.json`. a new project directory will be created with the expanded template and a git repository.

### Adding the template to an existing project

```
 $ cruft link https://github.com/b-src/b-py/
```

### Updating a project with the latest version of the template

```
 $ cruft update
```

### See what has changed in your project compared to the template

```
 $ cruft diff
```

## Contributing

this template represents the way I like to develop. changes will only be merged in if they align with my workflow and support my existing projects that rely on this template.

## Roadmap

 - allow license to be selectable, including an option for no license for private projects
 - update makefile template to set up local environment
 - update makefile template to set up initial dev dependencies
 - consider adding import sorts with isort
 - consider adding version management with bump2version
 - pin version of poetry within the project, refactor poetry commands to use project specific poetry instead of system poetry
 - update dockerfile to make testing easier
 - improve CI pipeline
   + add static analysis/credential/dependency vulnerability scan
   + make environment setup modular so jobs can be broken up without having to run expensive setup multiple times
   + longer term - support automated deployment

## License

b-py is licensed under the MIT license
