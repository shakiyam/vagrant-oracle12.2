vagrant-oracle12.2
==================

Vagrant + Oracle Linux 7.3 + Oracle Database 12c Release 2 (12.2.0.1) Enterprise Edition シングル環境の簡易セットアップ。

## ダウンロード

Oracle Database 12c Release 2 (12.2.0.1)のソフトウェアを以下からダウンロードし、Vagrantfileと同じディレクトリに展開。展開すると"database"というサブディレクトリになるはず。

http://www.oracle.com/technetwork/database/enterprise-edition/downloads/index.html

* linuxx64_12201_database.zip

## Vagrant設定

プロキシを利用する必要がある場合、まずvagrant-proxyconfをインストールし、vagrant-proxyconf用の環境変数を設定しておく。

ホストがmacOS or Linuxの場合:
```
export http_proxy=http://proxy.example.com:80
export https_proxy=http://proxy.example.com:80
vagrant plugin install vagrant-proxyconf

export VAGRANT_HTTP_PROXY=http://proxy.example.com:80
export VAGRANT_HTTPS_PROXY=http://proxy.example.com:80
export VAGRANT_FTP_PROXY=http://proxy.example.com:80
export VAGRANT_NO_PROXY=localhost,127.0.0.1
```

ホストがWindowsの場合:
```
SET http_proxy=http://proxy.example.com:80
SET https_proxy=http://proxy.example.com:80
vagrant plugin install vagrant-proxyconf

SET VAGRANT_HTTP_PROXY=http://proxy.example.com:80
SET VAGRANT_HTTPS_PROXY=http://proxy.example.com:80
SET VAGRANT_FTP_PROXY=http://proxy.example.com:80
SET VAGRANT_NO_PROXY=localhost,127.0.0.1
```

## セットアップ

`vagrant up`を実行すると、内部的に以下が動く。

* Oracle Linux 7.3のダウンロードと起動
* Oracle Preinstallation RPMのインストール
* グループの作成
* ディレクトリの作成
* 環境変数の設定
* oracleユーザーのパスワード設定
* Oracle Databaseのインストール
* リスナーの作成
* データベースの作成

```
vagrant up
```

## 動作確認

ゲストOSに接続する。

```
vagrant ssh
```

ルートに接続する。(OSユーザーoracleのパスワードはoracle)

```
su - oracle
sqlplus system/oracle
SHOW CON_NAME
```

PDBに接続し、サンプル表を確認する。

```
sqlplus system/oracle@localhost/pdb1
SHOW CON_NAME
SELECT * FROM hr.employees WHERE rownum <= 10;
```

## Known Issues ##

Windows, Vagrant 1.9.2, Virtualbox 5.1.16という組み合わせで /sbin/mount.vboxsf: mounting failed with the error: No such file or directory というエラーが出る人は、VirtualBoxを5.1.14にダウングレードするか、C:\HashiCorp\Vagrant\embedded\gems\gems\vagrant-1.9.2\lib\vagrant\util\platform.rb の206行目を `"\\?\" + path.gsub("/", "\")` から  `path.gsub("/", "\")` に変更することで回避できます。

参考: [Windows UNC path is crashing with \\\\?\\ prefix · Issue #8352 · mitchellh/vagrant](https://github.com/mitchellh/vagrant/issues/8352)

## Author ##

[Shinichi Akiyama](https://github.com/shakiyam)

## License ##

[MIT License](http://www.opensource.org/licenses/mit-license.php)
