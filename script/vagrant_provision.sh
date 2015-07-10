set -e -x

POSTGRES_VERSION=9.4
ERLANG_VERSION="1:18.0"
ELIXIR_VERSION="1.0.5-1"
PHOENIX=/home/vagrant/exmemtest

sudo usermod -a -G sudo vagrant
cat << EOF | sudo tee /etc/sudoers.d/vagrant
vagrant ALL=(ALL) NOPASSWD: ALL
EOF

rm -fr /home/vagrant/{cleanup.sh,base.sh,cleanup-virtualbox.sh,vagrant.sh,virtualbox.sh,zerodisk.sh,vagrant.sh}

sudo su -c 'echo "deb     http://apt.postgresql.org/pub/repos/apt jessie-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'
sudo su -c 'echo "deb http://packages.erlang-solutions.com/debian jessie contrib" >> /etc/apt/sources.list.d/erlang.list'
sudo su -c 'echo "deb http://ftp.de.debian.org/debian/ jessie-backports main" >> /etc/apt/sources.list.d/backports.list'

cat << EOF | sudo tee /etc/apt/preferences.d/erlang.pref
Package: esl-erlang
Pin: version $ERLANG_VERSION
Pin-Priority: 1000

Package: erlang-*
Pin: version $ERLANG_VERSION
Pin-Priority: 1000
EOF

wget -q http://packages.erlang-solutions.com/debian/erlang_solutions.asc -O- | sudo su -c 'apt-key add -'
sudo apt-get update
sudo apt-get install runit git-core build-essential postgresql-$POSTGRES_VERSION postgresql-server-dev-$POSTGRES_VERSION postgresql-contrib-$POSTGRES_VERSION tmux unison imagemagick zsh inotify-tools vim -y --force-yes

sudo -u postgres createuser -d -s exmemtest_web
sudo -u postgres createdb -E UTF8 exmemtest_dev -l en_US.UTF-8 -T template0 -O exmemtest_web

cat << EOF | sudo tee /etc/postgresql/$POSTGRES_VERSION/main/postgresql.conf
data_directory = '/var/lib/postgresql/$POSTGRES_VERSION/main'
hba_file = '/etc/postgresql/$POSTGRES_VERSION/main/pg_hba.conf'
ident_file = '/etc/postgresql/$POSTGRES_VERSION/main/pg_ident.conf'
external_pid_file = '/var/run/postgresql/$POSTGRES_VERSION-main.pid'
listen_addresses = '*'
port = 5432
max_connections = 100
unix_socket_directories = '/var/run/postgresql'
ssl = false
shared_buffers = 512MB
dynamic_shared_memory_type = posix
log_line_prefix = '%t [%p-%l] %q%u@%d '
log_timezone = 'UTC'
stats_temp_directory = '/var/run/postgresql/$POSTGRES_VERSION-main.pg_stat_tmp'
datestyle = 'iso, mdy'
synchronous_commit = on
fsync = on
checkpoint_segments = 64
checkpoint_completion_target = 0.9
checkpoint_timeout = 300
timezone = 'UTC'
lc_messages = 'en_US.UTF-8'
lc_monetary = 'en_US.UTF-8'
lc_numeric = 'en_US.UTF-8'
lc_time = 'en_US.UTF-8'
default_text_search_config = 'pg_catalog.english'
shared_preload_libraries = ''
log_min_duration_statement = 200
EOF

cat << 'EOF' | sudo tee /etc/postgresql/$POSTGRES_VERSION/main/pg_hba.conf
local all all trust
host all all ::1/128 trust
host all all 0.0.0.0/0 trust
EOF

sudo /etc/init.d/postgresql restart

sudo apt-get install erlang-base-hipe erlang-xmerl erlang-ssh vim elixir=$ELIXIR_VERSION erlang-dev -y --force-yes

sudo service postgresql restart

git clone --recursive https://github.com/sorin-ionescu/prezto.git /home/vagrant/.zprezto
cd /home/vagrant/.zprezto/runcoms
for rcfile in `ls *`; do ln -s /home/vagrant/.zprezto/runcoms/$rcfile /home/vagrant/.$rcfile; done
echo "vagrant" | chsh -s /usr/bin/zsh

echo 'export PATH=$PATH:./node_modules/.bin' >> ~/.zshrc
echo 'export PGUSER="exmemtest_web"' >> ~/.zshrc
echo 'export PGDATABASE="exmemtest_dev"' >> ~/.zshrc
echo 'test -d /home/vagrant/exmemtest && cd /home/vagrant/exmemtest' >> ~/.zshrc

cat << EOF | tee /home/vagrant/.zpreztorc
zstyle ':prezto:*:*' color 'yes'
zstyle ':prezto:load' pmodule \
  'environment' \
  'terminal' \
  'editor' \
  'history' \
  'directory' \
  'spectrum' \
  'utility' \
  'completion' \
  'prompt' \
  'history-substring-search'

zstyle ':prezto:module:editor' key-bindings 'vi'
zstyle ':prezto:module:prompt' theme 'sorin'
EOF

cat << EOF | tee /home/vagrant/.tmux.conf
set-window-option -g mode-keys vi
bind-key -t vi-copy 'v' begin-selection
bind-key -t vi-copy 'y' copy-selection
bind p paste-buffer
set -g status-bg colour232
set -g status-fg white
EOF

sudo mkdir -p /etc/sv/vagrant_sync/log/main
cat << EOF | sudo tee /etc/sv/vagrant_sync/run
#!/bin/sh
exec 2>&1
exec chpst -u vagrant -U vagrant /vagrant/script/vagrant_sync.sh
EOF

cat << EOF | sudo tee /etc/sv/vagrant_sync/log/run
#!/bin/sh
exec svlogd -tt ./main
EOF

sudo chmod +x /etc/sv/vagrant_sync/run
sudo chmod +x /etc/sv/vagrant_sync/log/run
sudo ln -s /etc/sv/vagrant_sync /etc/service

sleep 10

cat << EOF | tee /home/vagrant/.ssh/config
HOST *
  StrictHostKeyChecking no
EOF
