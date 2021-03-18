#!/bin/bash
set -eu -o pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"

# load environment variables from .env
set -a
if [ -e "$script_dir"/.env ]; then
  # shellcheck disable=SC1090
  . "$script_dir"/.env
else
  echo 'Environment file .env not found. Therefore, dotenv.sample will be used.'
  # shellcheck disable=SC1090
  . "$script_dir"/dotenv.sample
fi
set +a

# Install Mo
curl -sSL https://git.io/get-mo -o /usr/local/bin/mo
chmod +x /usr/local/bin/mo

# Install rlwrap
yum -y --enablerepo=ol7_developer_EPEL install rlwrap

# Install Oracle Preinstallation RPM
yum -y install oracle-database-server-12cR2-preinstall

# Create directories
mkdir -p "$ORACLE_BASE"/..
chown -R oracle:oinstall "$ORACLE_BASE"/..
chmod -R 775 "$ORACLE_BASE"/..

# Set environment variables
cat <<EOT >> /home/oracle/.bash_profile
export ORACLE_BASE=$ORACLE_BASE
export ORACLE_HOME=$ORACLE_HOME
export ORACLE_SID=$ORACLE_SID
export PATH=\$PATH:\$ORACLE_HOME/bin:\$ORACLE_HOME/jdk/bin
EOT

# Set alias
cat <<EOT >> /home/oracle/.bashrc
alias sqlplus='rlwrap sqlplus'
EOT

# Set oracle password
echo oracle:"$ORACLE_PASSWORD" | chpasswd

# Install database
/usr/local/bin/mo "$script_dir"/db_install.rsp.mo >"$script_dir"/db_install.rsp
su - oracle -c "$script_dir/database/runInstaller -silent -showProgress \
  -ignorePrereq  -waitforcompletion -responseFile $script_dir/db_install.rsp"
"$ORACLE_BASE"/../oraInventory/orainstRoot.sh
"$ORACLE_HOME"/root.sh

# Create listener using netca
su - oracle -c "netca -silent -responseFile \
  $ORACLE_HOME/assistants/netca/netca.rsp"

# Create database
/usr/local/bin/mo "$script_dir"/dbca.rsp.mo >"$script_dir"/dbca.rsp
su - oracle -c "dbca -silent -createDatabase -responseFile $script_dir/dbca.rsp"

# Shutdown database
#echo "shutdown immediate" | su - oracle -c 'sqlplus "/ as sysdba"'

# Stop listener
#su - oracle -c "lsnrctl stop"
