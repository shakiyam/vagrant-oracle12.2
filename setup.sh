#!/bin/sh

script_dir="$(cd "$(dirname "$0")" && pwd)"

# Install rlwrap
yum -y localinstall https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum -y install rlwrap

# Install Oracle Preinstallation RPM
yum -y install oracle-database-server-12cR2-preinstall

# Create Operating System Privileges Groups
groupadd -g 54324 backupdba
groupadd -g 54325 dgdba
groupadd -g 54326 kmdba
groupadd -g 54327 racdba
usermod  -G dba,backupdba,dgdba,kmdba,racdba oracle

# Create directories
mkdir -p /u01/app/
chown -R oracle:oinstall /u01/app/
chmod -R 775 /u01/app/

# Set environment variables
cat <<EOT >> /home/oracle/.bash_profile
export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=/u01/app/oracle/product/12.2.0.1/dbhome_1
export ORACLE_SID=orcl
export PATH=\$PATH:\$ORACLE_HOME/bin
EOT

# Set alias
cat <<EOT >> /home/oracle/.bashrc
alias sqlplus='rlwrap sqlplus'
EOT

# Set oracle password
echo oracle:oracle | chpasswd

# Install database
su - oracle -c "$script_dir/database/runInstaller -silent -showProgress \
 -ignorePrereq  -waitforcompletion -responseFile $script_dir/db_install.rsp"
/u01/app/oraInventory/orainstRoot.sh
/u01/app/oracle/product/12.2.0.1/dbhome_1/root.sh

# Create listener using netca
su - oracle -c "netca -silent -responseFile \
 /u01/app/oracle/product/12.2.0.1/dbhome_1/assistants/netca/netca.rsp"

# Create database
su - oracle -c "dbca -silent -createDatabase -responseFile $script_dir/dbca.rsp"

# Shutdown database
#echo "shutdown immediate" | su - oracle -c 'sqlplus "/ as sysdba"'

# Stop listener
#su - oracle -c "lsnrctl stop"
