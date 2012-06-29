#!/bin/bash
git config --global user.name "joaquinferrero"
git config --global user.email explorer+git@joaquinferrero.com
git config --global push.default "tracking"
git config --global pack.threads "0"
git config --global core.autocrlf false
git config --global apply.whitespace nowarn
git config --global color.ui "auto"
git config --global core.excludesfile "~/.gitignore"
git config --global alias.up "pull --rebase"
