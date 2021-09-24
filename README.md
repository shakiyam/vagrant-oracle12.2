vagrant-oracle12.2
==================

Vagrant + Oracle Linux 7 + Oracle Database 12c Release 2 (12.2.0.1) | Simple setup of a single instance database.

Download
--------

Download the Oracle Database 12c Release 2 (12.2.0.1) software from [Oracle Software Delivery Cloud](https://edelivery.oracle.com/) and extract it to the same directory as the Vagrantfile. It should be a subdirectory named `database`.

* V839960-01.zip

Configuration
-------------

Copy the file `dotenv.sample` to a file named `.env` and rewrite the contents as needed.

```shell
ORACLE_BASE=/u01/app/oracle
ORACLE_CHARACTERSET=AL32UTF8
ORACLE_EDITION=EE
ORACLE_HOME=/u01/app/oracle/product/12.2.0.1/dbhome_1
ORACLE_PASSWORD=oracle
ORACLE_PDB=pdb1
ORACLE_SAMPLESCHEMA=TRUE
ORACLE_SID=orcl
```

Vagrant up
----------

When you run `vagrant up`, the following will work internally.

* Download and boot Oracle Linux 7
* Install Oracle Preinstallation RPM
* Create directories
* Set environment variables
* Set password for oracle user
* Install Oracle Database
* Create a listener
* Create a database

```console
vagrant up
```

Example of use
--------------

Connect to the guest OS.

```console
vagrant ssh
```

Connect to CDB root and confirm the connection.

```console
sudo su - oracle
sqlplus system/oracle
SHOW CON_NAME
```

Connect to PDB and confirm the connection. If you have sample schemas installed, browse to the sample table.

```console
sqlplus system/oracle@localhost/pdb1
SHOW CON_NAME
-- If you have sample schemas installed
SELECT * FROM hr.employees WHERE rownum <= 10;
```

Author
------

[Shinichi Akiyama](https://github.com/shakiyam)

License
-------

[MIT License](https://opensource.org/licenses/MIT)
