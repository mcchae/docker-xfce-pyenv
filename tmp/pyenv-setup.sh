#!/bin/bash

PYTHON_VERSION=${PYTHON_VERSION:-3.5.3}
git clone --depth 1 https://github.com/yyuu/pyenv.git ~/.pyenv && \
rm -rfv $HOME/.pyenv/.git && \
export PYENV_ROOT="$HOME/.pyenv" && \
export PATH="$PYENV_ROOT/bin:$PATH" && \
export CFLAGS='-O2' && \
eval "$(pyenv init -)" && \
pyenv install $PYTHON_VERSION && \
pyenv global $PYTHON_VERSION && \
pip install --upgrade pip && \
pyenv rehash
