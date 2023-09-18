---
title: "Folding@home を Ubuntu Server ではじめよう"
slug: "fah"
date: "2020-04-01"
tags:
  - "自宅サーバ"
---

Folding@home を Ubuntu Server (CLI のみの環境) で設定する日本語記事が見当たらなかったので，ログも兼ねて書いておきます．
Windows での使い方は研究室の仲間が[ここ](https://qiita.com/H-Kz/items/20a38b8f7d2b55dc7ac1)に書いてます．

## Folding@home とは

詳しいことは端折りますが，ワシントン大学中心となって行っている，分散コンピューティングによるウイルス (?) 解析プロジェクトです．コンピュータウイルスじゃなく生物学的な方です．CPU または GPU リソース (ラップトップ PC でも可) を持っている人なら誰でも，このプロジェクトに対してそのリソースを提供することができます．最近では COVID-19 の解析のために始める人が多いようです．

## ユーザ登録をする

しなくてもできますが，するとなんかいいことがあるらしいです．詳しくはしりません．[ここ](https://apps.foldingathome.org/getpasskey)からメールアドレスを登録してしばらくすると，passkey が送られてきます．passkey はあとでつかいます (なくてもできます，念の為)．

## Ubuntu サーバを建てる

まずは Ubuntu サーバを建てます．僕は自宅のラックマウントサーバに ESXi を入れているので，WebGUI でぽちぽち建てました．今の所 4vCPU，RAM1GB，ストレージ 16GB の構成ですが，今動かしてるプロジェクトが終わったら 8vCPU まで上げてみるつもりです．
メモリは解析にはほとんど使わないため，1GB あれば十分です．

## クライアントを入れる

次に，解析を行うクライアントを入れます．deb パッケージで[ここ](https://foldingathome.org/start-folding/)に落ちている `fahclient` と言うやつを入れます．執筆時点の最新版を入れるには

```bash
curl https://download.foldingathome.org/releases/public/release/fahclient/debian-stable-64bit/v7.5/fahclient_7.5.1_amd64.deb -o fahclient.deb
apt install ./fahclient.deb
```

を root 権限で実行します (というか apt の実行に sudo すればそれでいいです)．
apt のインストール中にいくつか聞かれることがあるので入力します．

1. ユーザ名: 適当でいいです．ランキング表とかに表示されます．
2. team ID: チームを組んでランキングを競うときの ID です．SFC 関係者には KeioSFC チームが非公式に[存在しており](https://sfcclip.net/2020/03/49664/)，ITC なんかも[「ちょっとだけ」協力してくれてみたいです](https://twitter.com/sfc_itc/status/1243445257695424512)．チームを組まないときはデフォルトの 0 で大丈夫です．
3. passkey: ユーザ登録した際は，メールで送られてきた passkey を貼り付けます．ここは空白で進んでも大丈夫です．
4. どれくらいリソースを使うか: 私は専用の VM を建てているので `Full` を選びました．CPU 使用率 100% です．
   ![](/assets/2004/fah.png)
5. 起動時に自動実行するか: 私は専用の VM(ry デフォルトの `yes` です．

これでしばらくすると勝手に起動します．

再起動時などにエラーが出ている場合:

- `journalctl -xe` で「既に起動してるよ」と言われるようなら動いているプロセスを落とします．もしくは，`/etc/init.d/FAHClient stop` します．
- なにも起動していない，なにもしていないのに落ちた場合はよく分かりません．2 回ほど遭遇したので `/etc/init.d/FAHClient` を弄って実行ユーザを `fahclient` (デフォルト) から `root` に変更して動きましたが，おすすめしません．

## リモートコントロールの設定をする

PC でやるときはブラウザ上で動くウェブクライアントから localhost に向かって通信しモニタや設定を行うのですが，Ubuntu Server は当然 GUI などありません．そのため，リモートアクセスの設定をして外からたたけるようにします．

1. `/etc/fahclient/config.xml` を root 権限で編集
2. ファイル末尾に以下のような記述を追加．

```xml
  <allow>127.0.0.1 リモートアクセス元のIPアドレス</allow>
    <web-allow>127.0.0.1 リモートアクセス元のIPアドレス</web-allow>
```

フォーマットは気にしなくていいです．IP アドレスは CIDER 表記でも書けます (例: `192.168.0.0/16`)．v6 はすみません，未検証です． 3. サービスの再起動 ~~sudo service FAHClient restart~~ `sudo /etc/init.d/FAHClient restart` ※公式ドキュメントによると systemctl や service コマンドは使わず直接スクリプトを起動するらしいです

再起動すると勝手にコンフィグが整形されます．

## Let's fold!

あとはアクセスを許可した (`config.xml` に追加した) IP アドレスからブラウザで`サーバの IP アドレス:7396` にアクセスすると，ステータスの確認やストップができます．Chrome を使っている場合，無限リロードが発生することがありますが，[相性問題らしい](https://www.reddit.com/r/Folding/comments/674i9j/web_client_constanty_reloading/)ので諦めて firefox とか使ってください．
また，DNS を設定して FQDN をふっても WebGUI には IP アドレスでアクセスする必要があるみたいです．

KeioSFC チームのボード: [https://stats.foldingathome.org/team/253284](https://stats.foldingathome.org/team/253284)
