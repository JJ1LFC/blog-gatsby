---
title: "旧 Wiki などの建て方"
slug: "wiki-setup"
date: "2020-01-10"
tags:
  - "Web"
---

**この記事は過去の遺物です**

**この記事は [SFC-RG アドベントカレンダー 2019](https://qiita.com/advent-calendar/2019/sfc-rg) 21 日目の記事です**

メモ管理に疲れたので，サーバに CodiMD と wiki.js を建ててみました．せっかくなので建てた wiki で記事を公開しました．間違い等あったら教えてください．

# 建てる

個人的に以下の要件を満たしたいお気持ちがありました．

- 安い VPS で建てたい
- 死んだときにすぐに別鯖などで復帰できるようにしたい
- 当然 HTTPS で通信したい
- 生で建てると面倒なのでコンテナで建てたい

そこで，AWS Lightsail 上に docker-compose を用いて建てることにしました．HTTPS 通信/リバースプロキシに関しては negineri 先生に教えてもらい docker-letsencrypt-nginx-proxy-companion を用いることにしました．

## VPS 自体の用意

> Lightsail は v6 接続性がないので，今は全部 vultr に移動しました

AWS にログインし Lightsail に行きます．「インスタンスの作成」から，新しいインスタンスを建てます．今回は東京リージョンに慣れ親しんだ Ubuntu18.04 LTS で，プランは 2 つのサービスを持つのに最低限な $5 のプランで建てました．一番下の「インスタンスの作成」を押して数分まつだけで上がってきてくれます．

Lightsail トップに戻り，作成したインスタンスを選択，「ネットワーキング」から静的 IP アドレスのアタッチをしておきます．次に「スナップショット」に移り，自動スナップショットを有効化しておきます．

スナップショットは，サーバの状態をまるまる保存しておくというもので，自動を ON にしておくと日に一回勝手に保存してくれます．GB 単位で料金が発生しますが，そこまで高くないですし，自動スナップショットでとったものは 1 週間保存された後に自動で消えてくれるので，あまり気にしていません．
また，スナップショットを取っておくと，サーバが壊れた際やスケールアップしなければならないとき (※Lightsail は一度作ったインスタンスのサイズを変えられない) にスナップショットからインスタンスを作成することで，ボタン 1 つで復帰できます．さらに，静的 IP アドレスをもとのインスタンスからデタッチし，新しいインスタンスにアタッチすることで，同じ IP アドレスをそのまま使えます．

次に，同じく「ネットワーキング」からファイアーウォールを設定しておきます．443 の inbound を開けておきます．~~80 は運用時は閉じてしまっても差し支えありません．~~ 閉じると Let's Encrypt の証明書更新ができなくなるのであけておいてください

## VPS の設定

このままではデフォルトユーザ (ubuntu) しかユーザがないので，自分のユーザをお好みで作ります．ssh した後

```shell
sudo -i                                       # superuser になる
adduser {user_name}                           # 対話形式でユーザ作成
gpasswd -a {user_name} sudo                   # sudo グループに追加
mkdir /home/{usen_name}/.ssh
vim /home/{user_name}/.ssh/authorized_keys    # ここに公開鍵をペースト
```

で新規ユーザを作成します．exit して作ったユーザで再度ログイン．

```shell
sudo apt update
sudo apt upgrade -y
sudo apt install -y git docker docker-compose    # 本当は docker 社のリポジトリを追加してからやるのが正しいけど，これで構築しちゃったのでとりあえずこう書いておく
```

## docker-letsencrypt-nginx-proxy-companion の設定

今回は HTTPS 通信を行うために Let's Encrypt から証明書を取得します．また，その設定とリバースプロキシを同時に，docker-compose で行うため，docker-letsencrypt-nginx-proxy-companion を使います．
使い方としては，まず docker で companion 用のネットワークを作成したあとに companion を立ち上げ，ひたすら走らせ続けます．あとは Web サービスを docker-compose で立ち上げるときに必要な設定を数行入れて同じネットワークに参加させるようにして立ち上げれば，自動で証明書の取得からやってくれます．めっちゃ便利．

```shell
docker network create web_nw      # 今回は web_nw という名前のネットワークに全て入れる
mkdir /opt/proxy
cd /opt/proxy
vim docker-compose.yml            # ここに以下の設定を入れる
```

docker-compose の作り方は[公式の解説](https://github.com/JrCs/docker-letsencrypt-nginx-proxy-companion/wiki/Docker-Compose)を読んでほしいのですが，私のものを以下に貼っておきます．

設定対象: `/opt/proxy/docker-compose.yml`

```yaml
version: "3"
services:
  proxy:
    image: jwilder/nginx-proxy:latest
    labels:
      com.github.jrcs.letsencrypt_nginx_proxy_companion.nginx_proxy: "true"
    volumes:
      - /var/run/docker.sock:/tmp/docker.sock:ro
      - certs:/etc/nginx/certs:ro
      - dhparam:/etc/nginx/dhparam
      - vhost:/etc/nginx/vhost.d
      - html:/usr/share/nginx/html
      - conf:/etc/nginx/conf.d
    ports:
      - "80:80"
      - "443:443"
    restart: always
    privileged: true
    container_name: "reverse-proxy_"

  letsencrypt:
    image: jrcs/letsencrypt-nginx-proxy-companion
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - certs:/etc/nginx/certs:rw
      - dhparam:/etc/nginx/dhparam
      - vhost:/etc/nginx/vhost.d
      - html:/usr/share/nginx/html
      - conf:/etc/nginx/conf.d
    restart: always
    privileged: true
    container_name: "reverse-proxy_letsencrypt_"

networks:
  default:
    external:
      name: web_nw

volumes:
  conf:
  vhost:
  html:
  dhparam:
  certs:
```

書き終わったら立ち上げます．

設定対象: `/opt/proxy`

```shell
docker-compse up -d
```

lightsail に割り当てた静的 IP アドレスにアクセスし，nginx のページが見えていれば成功です．

## CodiMD の設定

次に CodiMD をたてます．同じく docker-compose です．

```shell
mkdir /opt/hackmd
cd /opt/hackmd
vim docker-compose.yml
```

ここも[公式の解説](https://github.com/hackmdio/docker-hackmd/blob/master/docker-compose.yml)を読んでほしいのですが，自分のを以下に貼り付けます．companion との関係で複数設定を変更している点も記述します．

設定対象: `/opt/hackmd/docker-compose.yml`

```yaml
version: "3"
services:
  database:
    image: postgres:11.6-alpine
    environment:
      - POSTGRES_USER: codimd
      - POSTGRES_PASSWORD: change_password
      - POSTGRES_DB: codimd
    volumes:
      - "database-data:/var/lib/postgresql/data"
    restart: always
    networks:
      md-backend:
  codimd:
    image: nabo.codimd.dev/hackmdio/hackmd:2.0.1
    environment:
      - CMD_DB_URL: postgres://codimd:change_password@database/codimd
      - CMD_USECDN: false
      - CMD_DOMAIN: md.jj1lfc.dev            # ドメイン名
      - CMD_PORT: 3100
      - CMD_ALLOW_ANONYMOUS_EDITS: true      # 一定条件で第三者の編集を許可 (ページごとにパーミッション指定可能に)
      - CMD_DEFAULT_PERMISSION: private      # フェイルセーフでデフォルトは一番硬く
      - CMD_ALLOW_GRAVATAR: true
      - CMD_ALLOW_FREEURL: true              # ログインしてページを作りたい URL にアクセスするだけでその URL でページを作れる
      - CMD_ALLOW_PDF_EXPORT: true
      - CMD_IMAGE_UPLOAD_TYPE: filesystem    # 画像は内部に
      - CMD_EMAIL: true
      - CMD_ALLOW_EMAIL_REGISTER: false      # 勝手に登録されないように
      - CMD_PROTOCOL_USESSL: true            # これを明示しないと mixed-content で CSS が読み込まれない
      - VIRTUAL_HOST: md.jj1lfc.dev          # proxy 用ドメイン名
      - VIRTUAL_PORT: 3100                   # proxy 用ポート
      - LETSENCRYPT_HOST: md.jj1lfc.dev
      - LETSENCRYPT_MAIL: alt@jj1lfc.dev
    depends_on:
      - database
    expose:
      - 3100                              # 公式では ports だけど expose で十分
    volumes:
      - upload-data:/home/hackmd/app/public/uploads
    restart: always

networks:
  web:
    md-backend:

networks:
  md-backend:
  web:
    external:
      name: web_nw

volumes:
  database-data: {}
  upload-data: {}
```

書き終わったら同じく `docker-compose up -d` で建てます．なお，最初に建てるときはこのままだとユーザ登録ができないので，`CMD_ALLOW_ANONYMOUS: false` を一度コメントアウトしてから建てて，ブラウザでユーザ登録をしてから再度コメントアウトを外して `docker-compose down` `docker-compose up -d` を行います．

## wiki.js の設定

次に wiki.js をたてます．同じく docker-compose です．

```shell
mkdir /opt/wiki
cd /opt/wiki
vim docker-compose.yml
```

ここも[公式の解説](https://docs.requarks.io/install/docker#using-docker-compose)を読んでください．一応自分のを以下に貼り付けます．companion との関係で複数設定を変更している点も記述します．

設定対象: `/opt/wiki/docker-compose.yml`

```yaml
version: "3"

services:
  db:
    image: postgres:11-alpine
    environment:
      - POSTGRES_DB: wiki
      - POSTGRES_PASSWORD: hogehoge
      - POSTGRES_USER: wikijs
    logging:
      driver: "none"
    restart: unless-stopped
    networks:
      wiki-backend:
    volumes:
      - db-data:/var/lib/postgresql/data

  wiki:
    image: requarks/wiki:2
    depends_on:
      - db
    environment:
      - DB_TYPE: postgres
      - DB_HOST: db
      - DB_PORT: 5432
      - DB_USER: wikijs
      - DB_PASS: hogehoge
      - DB_NAME: wiki
      - VIRTUAL_HOST: wiki.jj1lfc.dev # 自分のドメイン名に設定
      - VIRTUAL_PORT: 3000
      - LETSENCRYPT_HOST: wiki.jj1lfc.dev # 自分のドメイン名に設定
      - LETSENCRYPT_MAIL: alt@jj1lfc.dev # 自分のメアドに設定
    restart: unless-stopped
    expose:
      - 3000
    networks:
      web:
      wiki-backend:

networks:
  wiki-backend:
  web:
    external:
      name: web_nw

volumes:
  db-data:
```

書き終わったら同じく `docker-compose up -d` で建てます．

以上．wiki.js は多分 WebGUI で設定することのほうが多いですが，見りゃわかると思います．DB の内容を Local や S3，Github に dump できる設定もあるため，自分は Lightsail が立っているのと違うリージョンの S3 と Github にバックアップしています．バックアップ間隔が 5 分から設定変更できないのはバグっぽいです．
