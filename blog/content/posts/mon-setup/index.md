---
title: "死活監視サーバを建てた話"
slug: "mon-setup"
date: "2020-05-19"
tags:
  - "自宅サーバ"
---

**本記事は過去の遺物です**

なんとなく死活監視サーバを建ててみた．mon.jj1lfc.dev だが，一応 status.jj1lfc.dev にアクセスしてもリダイレクトする．

## 使ったもの

- Digital Ocean シンガポール

いつもは Vultr 使ってるけど，監視対象と同じ AS/DC では意味がないので．

- [Statping](https://github.com/statping/statping)

OSS の死活監視ツール．HTTP/TCP/UDP/ICMP/gRPC (ってなんだ?) で監視ができる．まだメジャーバージョンになってないこともありバグ多め/使いにくい．

## 建てる

[いつも](/posts/wiki-setup)のように docker-compose でリバースプロキシと Statping を建てた．
Statping の方の docker-compose は基本的には公式と同じだが一応書いておく．

```yml
version: "2.3"

services:
  statping:
    container_name: statping
    image: statping/statping:latest
    restart: always
    volumes:
      - statping_data:/app
    environment:
      DB_CONN: sqlite
      VIRTUAL_HOST: mon.jj1lfc.dev
      VIRTUAL_PORT: 8080
      LETSENCRYPT_HOST: mon.jj1lfc.dev
      LETSENCRYPT_MAIN: alt@jj1lfc.dev
    expose:
      - 8080
    networks:
      web:

networks:
  web:
    external:
      name: web_nw

volumes:
  statping_data:
```

ありえんシンプル．

`docker-compose up -d` したらブラウザで `mon.jj1lfc.dev/dashboard` にアクセス．設定してもない ID とパスワードを聞かれるが，`admin`/`admin` で入れる．入ったあともこのパスワードは有効なので，すぐ `Users` から admin アカウントのパスワードを変更する．admin アカウントの削除はできないらしい．

おわり．

## 使う

というのは短すぎるので webGUI の設定も書いておく．

### 監視対象の設定

`Services` から監視対象を設定できる．グループを追加/削除して，`Services` を Create する．Services で `No Group` を選択するとうまく保存できない場合があるので先に Group を作っておく．
Service の登録では `Permalink URL` を設定してあげるとわかりやすい．アルファベットとかで `Name` を書くと勝手に入る．

HTTP での監視を選択したときは，`Service endpoint(URL)` は必ず `https://` や `http://` などから始める必要がある．入れないと名前解決できないと怒られる．
TCP/UDP/ICMP での監視を選択したときは，`Service Endpoint (Domain)` は必ず IP アドレスを入れる．Domain と言ってるくせに FQDN を打っても名前解決してくれない．

一番下の `Notify All Changes` は切っておかないとアラートが大変なことになりそう．

### お知らせ掲載機能?

`Announcement` というところからどうやらお知らせが設定できそうな雰囲気があるが，なんぼ試しても動かない．すでに issue と PR が投げてあったので近日中に動くと期待．これが動かないとメンテナンスのお知らせを書く場所がない．

### 死亡/復帰通知

こいつが一番重要．僕は Slack を設定している．Webhook の URL 打つだけでそこそこまともなメッセージをくれる．

![](/assets/2005/mon1.png)

他にもシェルの実行，LINE Notify，Telegram，Webhook，専用モバイルアプリへのプッシュなど通知方法は結構豊富．

### `/dashboard` の使い方

ログイン後にステータスを見るには `/dashboard` を見ることになるが，正直要素がでかすぎて使いづらい．めっちゃスクロールが必要．なのでここはインシデント掲載と Failure の確認のためだけに使い，普通にステータスを見るときにはログインせずに使おうと思う．

インシデント掲載は結構わかりやすく，ポチポチするだけで有名サービスの status ページみたいにインシデント情報が書き込めるのでｶｯｺｲｲ．個人で使う機会があるのかは謎．

![](/assets/2005/mon2.png)

ラベルは `INVESTIGATING`, `UPDATE`, `RESOLVED`と`UNKNOWN` (ラベルなし) が選択できる．予約投稿や投稿時刻の編集機能はないので投稿日時は隠蔽できない．また，一度投稿した内容も削除はできるが編集はできない．

`Failures` は確認に失敗したエラー内容を表示してくれる．エラーを削除することもできる．

`Checkins` は見たところ監視側から定期的にチェックするのではなく監視対象から定期的に何かを送ってもらうことで死活監視する機能らしい?が，よくわからない．

## 残念なところ

- ログインでパスマネを使うとパスワード打ってない扱いになりログインボタンが押せない．適当に一文字打って消すと押せる．
- グラフがおかしい．明らかにそんなデータ存在しないだろっていうデータを描画することがある．あまり信用ならない．
- UDP でのチェックなどは時間が 0μsec になる．なおグラフには数字が入っている模様．あまり信用ならない．

ということで，やはりちゃんと監視するなら zabbix とか elasticsearch とか何でもいいけどまともに設定できるものを使おう．ただ，簡単に立ち上げられてなにかの第一報を知らせてくれるものとしてはいいと思う．特に外部の複数ポイントから監視したいときとか．
