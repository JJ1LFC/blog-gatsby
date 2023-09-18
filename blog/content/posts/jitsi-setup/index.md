---
title: "Jitsi を建てた話"
slug: "jitsi-setup"
date: "2020-05-19"
tags:
  - "Web"
---

**本記事は過去の遺物です**

新型コロナウイルス感染症の感染拡大により，世界的に遠隔会議システムの導入が進んでいます．中でも Zoom, Google Hangout, Microsoft Teams, Cisco Webex などクラウド型のソリューションは組織への導入が容易で無料で利用できるプランもあるため，多くの企業や組織で導入されているようです．反面，一部のサービスでは急増するトラフィックへの対応が十分でなくダウンタイムが増えているケースもあるようです．また，学生団体や趣味サークルなどで IdP への連携やある程度のプロビジョニング機能を使いたいがお金がないケースや，クラウドを介することによるセキュリティへの懸念など，前述のソリューションでは要求を満たせない場合もあります．
そのような課題を解決する一つの方法として，OSS を用いてオンプレミスサーバで遠隔会議システムを構築することが挙げられます．この記事では実際に Jitsi サーバ (Jitsi Meet) を建てた記録をメモ程度に公開します．

## 自分がやったこと

- 個人的に使用する(主に実験とクラウドサービス障害時のバックアップ)ため，Vultr 上に Jitsi サーバを建てて，ホストにはローカル認証を要求しゲストには認証を要求しないポリシーを適用
- 研究室で使用するため，大学データセンタ内のオンプレミスサーバにある仮想マシン (vCenter) 上に Jitsi サーバを建てて，ホスト・ゲストともに LDAP 認証を要求するポリシーを適用

スペック (VPS・仮想マシン) は以下のとおり．

| ホスト             | OS               | CPU   | MEM  | HDD  | 帯域 | 想定最大使用人数 |
| ------------------ | ---------------- | ----- | ---- | ---- | ---- | ---------------- |
| jitsi.jj1lfc.dev.  | Ubuntu 18.04 LTS | 1vCPU | 1GB  | 32GB | 1G   | 8 人             |
| (非公開・研究室用) | Ubuntu 20.04     | 8vCPU | 16GB | 16GB | 1G   | 30 人            |

## 建て方

基本的には公式に従いますが，日本語で書いてる記事がないので改めて日本語で書きます．必要に応じて root 権限で実行してください．

### DNS 的にホスト名を割り与える

権威 DNS サーバの設定を行ってホスト名を割り与えます．Jitsi Meet はデフォルトで IPv6 が有効なので，IPv6 が使えるネットワークの場合は A レコードだけでなく AAAA レコードも設定します．

### ホストの立ち上げ・ネットワーク的な設定をやっておく

詳しくは省略します．L3 ファイアウォールをネットワークで適用する場合は，後述する 3 つないし 4 つのポートを開けます．ホストに個別に割り当てられる IP アドレスがない場合は NAPT などの設定もします．なお，NAPT 下に立てるときはここに書いていない設定が別途必要らしいので公式を参照してください．

### Jisti パッケージのリポジトリを追加する

Canonical (Ubuntu) 公式が提供する apt リポジトリには Jitsi パッケージがないので，ソースリストに Jitsi のリポジトリを追加します．

```shell
echo 'deb https://download.jitsi.org stable/' | sudo tee /etc/apt/sources.list.d/jitsi-stable.list
wget -qO -  https://download.jitsi.org/jitsi-key.gpg.key | sudo apt-key add -
```

### L3 ファイアウォールを設定する

Vultr の場合は WebGUI からファイアウォールポリシーを割り当てられます．オンプレの場合はルータでネットワークレベルで設定したり iptables などでホスト単位で設定したりします．
inbound について，最低限以下のポートで穴が空いてれば大丈夫です．

- 80 TCP
- 443 TCP
- 10000 UDP
- 必要に応じて SSH の穴

### Jitsi Meet をインストールする

```shell
apt install apt-transport-https
apt update
apt install jitsi-meet
```

インストール中にホスト名を聞かれますので，権威 DNS サーバに設定したものと同じ FQDN を与えます．同様に証明書を作らずスキップするかすでにある証明書をインポートするか聞かれますので，特に用意がなければデフォルトのスキップを選択してください．この次に Let's Encrypt 証明書を入れます．

### Let's Encrypt 証明書をインストールする

あってもなくてもいいですが，常識的に考えて LE の証明書くらいはあったほうがいいでしょう．ちなみに，Jitsi はモバイルアプリがありますが，アプリを使うときは TLS 通信が必須なので証明書が必要になります．certbot を別途入れなくても用意されたスクリプトが使えます．

```shell
/usr/share/jitsi-meet/scripts/install-letsencrypt-cert.sh
```

このスクリプトでは HTTP-01 チャレンジタイプを使用して certbot で証明書を取得するので，TCP80 番を通じてインターネットと HTTP 通信できる必要があります．
なお，Ubuntu 20.04 でやったときには certbot の依存性の問題が発生したため，下記のとおり手動で実施しました．

1. PPA とかいろいろ頑張ってとりあえず certbot を導入する．(19.10 以降は PPA 使うなという噂があるが公式ページで 20.04 を選ぶと PPA を案内される)
2. 普通に certbot の設定をする
3. `/etc/nginx/sites-enabled/{your-hostname}.conf` の `ssl_certificate` と `ssl_certificate_key` が自己署名証明書を指しているので，certbot で導入したファイルの path に書き換える．多分それぞれ `/etc/letsencrypt/live/{your-hostname}/fullchain.pem` と `/etc/letsencrypt/live/{your-hostname}/privkey.pem`．拡張子が変わるが，nginx 的にはもちろん，jitsi 的にもちゃんと動く．
4. `systemctl restart nginx`

### 使えるようになったけど

これで使えるようになりました．ブラウザからアクセスするとすぐに会議を始めることができます．
しかし，このままでは誰でも会議を開始してサーバリソースを使うことができてしまうので，基本的には最低限ホストを制限します．
以下，ローカル認証と LDAP 認証の例をそれぞれ書きます．組み合わせてできるのかはやったことないので知りません．

### ローカル認証をかける

- ホストするための認証を有効にする

設定対象: `/etc/prosody/conf.avail/{your-hostname}.cfg.lua`

```lua
VirtualHost "{your-hostname}"
  authentication = "internal_plain"
```

- ゲストにも認証を有効にする (必要に応じて追加)

設定対象: `/etc/prosody/conf.avail/{your-hostname}.cfg.lua`

```lua
VirtualHost "guest.{your-hostname}"
  authentication = "anonymous"
  c2s_require_encryption = false
```

※guest サブドメインは内部的に使用しているものなので，DNS 的に存在しなくて大丈夫です．

設定対象: `/etc/jitsi/meet/{your-hostname}-config.js`

```lua
var config = {
  hosts: {
    domain: '{your-hostname}',
    anonymousdomain: 'guest.{your-hostname}',
    ...
  },
...
}
```

- jicofo に認証要求の設定を入れる

設定対象: `/etc/jitsi/jicofo/sip-communicator.properties`

```
org.jitsi.jicofo.auth.URL=XMPP:{your-hostname}
```

- ローカルのユーザを作成する

```shell
prosodyctl register {username} {your-hostname} {password}
```

- デーモンリスタート

```shell
systemctl restart prosody
systemctl restart jicofo
```

これで完了です．

### LDAP 認証をかける

LDAP2 で行う方法と saslauthd で行う方法がありますが，楽なので前者でやりました．これだけだとホストもゲストも LDAP 認証が必要になるので，ゲストには認証なしにしたい場合は上記ローカル認証のセクションで書いている「ゲストにも認証を有効にする (必要に応じて追加)」以降のすべての設定を，以下の LDAP 設定を行った上で追加で行う必要があります．

- 必要なパッケージを入れる

```shell
apt-get install prosody-modules lua-ldap
```

- prosody に LDAP の設定をする

設定対象: `/etc/prosody/conf.avail/ldap.cfg.lua`

```lua
-- https://modules.prosody.im/mod_lib_ldap.html
-- https://modules.prosody.im/mod_auth_ldap2.html
authentication = 'ldap2'

ldap = {
  hostname = '{ldap_server_hostname}',
  bind_dn = '{ldap_admin_dn}',
  bind_password = '{ldap_admin_password}',
  use_tls = true,
  user = {
    usernamefield = 'uid',
    basedn = '{ldap_user_dn}',
    namefield = 'cn',
  },
}
```

- シンボリックリンクをはる

```shell
ln -sf /etc/prosody/conf.avail/ldap.cfg.lua /etc/prosody/conf.d/
```

- bosh の設定をする

設定対象: `/etc/prosody/prosody.cfg.lua` の最下部 `include` の直前

```lua
consider_bosh_secure = true
```

- prosody で認証に LDAP を使わせる

設定対象: `/etc/prosody/conf.avail/{your-hostname}.cfg.lua`

```lua
VirtualHost "{your-hostname}"
    authentication = "ldap2
```

- デーモンリスタート

```shell
sysytemctl restart prosody
```

## その他メモ

リソース的にはメモリはあまり使用せず，CPU をめちゃくちゃ食うようです．CPU 盛りましょう．
大人数で会議をする場合や運用当初などは htop などで監視しましょう．ちなみに研究室のサーバは別に立っている ElasticSearch サーバにテレメトリを投げて Kibana で監視できるようになっているので大変見やすいです．
Jitsi 的に走るデーモンは主に 4 つなので，なんかおかしかったらとりあえずこいつらを systemctl や service で restart しておけばなんとかなります．

- nginx (ないし apache)
- prosody
- jicofo
- jitsi-videobridge2

LDAP のところは公式の案内が数日サイクルで頻繁に書き換わっているようなので，この内容がすぐ古くなるかもしれません．

なんとなく覚えていることを書き出しただけなので，間違い等あればお知らせください．

## 使った感じ

国内の人だけならめちゃくちゃいい．E2E の遅延は速くて 20-50msec 程度．
LDAP を設定しても実はフロントに見える username に uid が勝手に設定されるわけじゃないので，最初は参加者が手動で設定しなきゃいけないのが少しめんどい．英語のコミュニティを見るとやはり同じことを考えている人が何人かいるようだが，執筆時点でソリューションは見つかっていないようだ．
カメラ ON/OFF で使用するリソース量がかなり変わる．表に示した想定最大使用人数は全員カメラ ON の前提なので，しゃべる人だけカメラ ON の前提なら多分 2 倍くらいは入るんじゃないかな．
自分で建立したサーバで大手クラウド障害時のバックアップとして実用的なサービスを動かしていると思うとｷﾓﾁｲｲ．

## 参考文献

- [Jitsi Meet quick install](https://github.com/jitsi/jitsi-meet/blob/master/doc/quick-install.md)
- [Secure Domain](https://github.com/jitsi/jicofo#secure-domain)
- [LDAP Authentication](https://github.com/jitsi/jitsi-meet/wiki/LDAP-Authentication)
