#!/bin/bash
set -eu -o pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly SCRIPT_DIR

# load environment variables from .env
set -a
if [ -e "$SCRIPT_DIR"/.env ]; then
  # shellcheck disable=SC1091
  . "$SCRIPT_DIR"/.env
else
  echo 'Environment file .env not found. Therefore, dotenv.sample will be used.'
  # shellcheck disable=SC1091
  . "$SCRIPT_DIR"/dotenv.sample
fi
set +a

# Install Oracle Preinstallation RPM
yum -y install oracle-database-server-12cR2-preinstall

# Create directories
mkdir -p "$ORACLE_BASE"/..
chown -R oracle:oinstall "$ORACLE_BASE"/..
chmod -R 775 "$ORACLE_BASE"/..

# Set environment variables
cat <<EOT >>/home/oracle/.bash_profile
export ORACLE_BASE=$ORACLE_BASE
export ORACLE_HOME=$ORACLE_HOME
export ORACLE_SID=$ORACLE_SID
export PATH=\$PATH:\$ORACLE_HOME/bin:\$ORACLE_HOME/jdk/bin
EOT

# Install rlwrap and set alias
# shellcheck disable=SC1091
OS_VERSION=$(. /etc/os-release && echo "$VERSION")
readonly OS_VERSION
case ${OS_VERSION%%.*} in
  7)
    yum -y --enablerepo=ol7_developer_EPEL install rlwrap
    cat <<EOT >>/home/oracle/.bashrc
alias sqlplus='rlwrap sqlplus'
EOT
    ;;
esac

# Set oracle password
echo oracle:"$ORACLE_PASSWORD" | chpasswd

TEMP_DIR=$(mktemp -d)
readonly TEMP_DIR
chmod 755 "$TEMP_DIR"

# Install Mo (https://github.com/tests-always-included/mo)
curl -sSL https://git.io/get-mo -o /usr/local/bin/mo
chmod +x /usr/local/bin/mo

# Install Oracle Database
/usr/local/bin/mo "$SCRIPT_DIR"/db_install.rsp.mustache >"$TEMP_DIR"/db_install.rsp
su - oracle -c "$SCRIPT_DIR/database/runInstaller -silent -showProgress \
  -ignorePrereq -waitforcompletion -responseFile $TEMP_DIR/db_install.rsp"
"$ORACLE_BASE"/../oraInventory/orainstRoot.sh
"$ORACLE_HOME"/root.sh

# Create a listener using netca
su - oracle -c "netca -silent -responseFile $ORACLE_HOME/assistants/netca/netca.rsp"

# Create a database
/usr/local/bin/mo "$SCRIPT_DIR"/dbca.rsp.mustache >"$TEMP_DIR"/dbca.rsp
su - oracle -c "dbca -silent -createDatabase -responseFile $TEMP_DIR/dbca.rsp"

rm -rf "$TEMP_DIR"
