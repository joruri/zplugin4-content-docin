# Zplugin::Content::Docin

記事コンテンツにCSVデータをインポートするプラグインのサンプルです。

## 想定環境

* Joruri CMS 2020 Release 0+

## インストール

プラグイン用ディレクトリを作成し、プラグインのソースをダウンロードします。

    $ cd /var/www/joruri
    $ mkdir vendor/plugins
    $ cd /var/www/joruri/vendor/plugins
    $ git clone -b master git@github.com:joruri/zplugin3-content-docin

Gemfileを手動で作成し、ダウンロードしたプラグインソースのパスを指定します。

    $ cd /var/www/joruri/vendor/plugins
    $ vi Gemfile
```
gem 'zplugin3-content-docin', path: 'vendor/plugins/zplugin3-content-docin'
```
bundle installを実行します。

    $ cd /var/www/joruri
    $ bundle install

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
