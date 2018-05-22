vagrant-oracle12.2
==================

Vagrant + Oracle Linux 7 + Oracle Database 12c Release 2 (12.2.0.1) Enterprise Editionシングル環境の簡易セットアップ。

ダウンロード
------------

Oracle Database 12c Release 2 (12.2.0.1)のソフトウェアを[Oracle Technology Network](http://www.oracle.com/technetwork/database/enterprise-edition/downloads/index.html)からダウンロードし、Vagrantfileと同じディレクトリに展開。展開すると"database"というサブディレクトリになるはず。

* linuxx64_12201_database.zip

Vagrant設定
-----------

プロキシを利用する必要がある場合、まずvagrant-proxyconfをインストールし、vagrant-proxyconf用の環境変数を設定しておく。

### ホストがmacOS or Linuxの場合 ###

```console
export http_proxy=http://proxy.example.com:80
export https_proxy=http://proxy.example.com:80
vagrant plugin install vagrant-proxyconf

export VAGRANT_HTTP_PROXY=http://proxy.example.com:80
export VAGRANT_HTTPS_PROXY=http://proxy.example.com:80
export VAGRANT_FTP_PROXY=http://proxy.example.com:80
export VAGRANT_NO_PROXY=localhost,127.0.0.1
```

### ホストがWindowsの場合 ###

```console
SET http_proxy=http://proxy.example.com:80
SET https_proxy=http://proxy.example.com:80
vagrant plugin install vagrant-proxyconf

SET VAGRANT_HTTP_PROXY=http://proxy.example.com:80
SET VAGRANT_HTTPS_PROXY=http://proxy.example.com:80
SET VAGRANT_FTP_PROXY=http://proxy.example.com:80
SET VAGRANT_NO_PROXY=localhost,127.0.0.1
```

セットアップ
------------

`vagrant up`を実行すると、内部的に以下が動く。

* Oracle Linux 7のダウンロードと起動
* Oracle Preinstallation RPMのインストール
* ディレクトリの作成
* 環境変数の設定
* oracleユーザーのパスワード設定
* Oracle Databaseのインストール
* リスナーの作成
* データベースの作成

```console
vagrant up
```

動作確認
--------

ゲストOSに接続する。

```console
vagrant ssh
```

ルートに接続する。

```console
sudo su - oracle
sqlplus system/oracle
SHOW CON_NAME
```

PDBに接続し、サンプル表を確認する。

```console
sqlplus system/oracle@localhost/pdb1
SHOW CON_NAME
SELECT * FROM hr.employees WHERE rownum <= 10;
```

Author
------

[Shinichi Akiyama](https://github.com/shakiyam)

License
-------

[MIT License](http://www.opensource.org/licenses/mit-license.php)
