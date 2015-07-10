#!/bin/sh

export HOME="/home/vagrant"
cd /vagrant
unison -batch . /home/vagrant/exmemtest -ignore 'Regex .*\.sw.' -ignore 'Regex \.git.*' -ignore 'Regex _build.*' -ignore 'Regex node_modules.*' -ignore 'Regex deps.*' -ignore 'Regex rel/.*' -repeat 1 -silent
