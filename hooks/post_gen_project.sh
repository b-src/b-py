#!/bin/bash -eu

if ! [[ -d .git ]]; then
	git init
fi
