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
# shellcheck disable=SC1091
os_version=$(. /etc/os-release; echo "$VERSION")
case ${os_version%%.*} in
  6)
    yum -y localinstall https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm
    ;;
esac
yum -y install rlwrap

# Install Oracle Preinstallation RPM
yum -y install oracle-database-server-12cR2-preinstall

# Create directories
mkdir -p /u01/app/
chown -R oracle:oinstall /u01/app/
chmod -R 775 /u01/app/

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
/u01/app/oraInventory/orainstRoot.sh
/u01/app/oracle/product/12.2.0.1/dbhome_1/root.sh

# Create listener using netca
su - oracle -c "netca -silent -responseFile \
  /u01/app/oracle/product/12.2.0.1/dbhome_1/assistants/netca/netca.rsp"

# Create database
/usr/local/bin/mo "$script_dir"/dbca.rsp.mo >"$script_dir"/dbca.rsp
su - oracle -c "dbca -silent -createDatabase -responseFile $script_dir/dbca.rsp"

# Shutdown database
#echo "shutdown immediate" | su - oracle -c 'sqlplus "/ as sysdba"'

# Stop listener
#su - oracle -c "lsnrctl stop"
