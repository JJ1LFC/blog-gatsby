---
title: "Cisco Catalyst 初期設定"
slug: "catalyst-setup"
date: "2020-04-11"
tags:
  - "Cisco"
  - "Network"
---

本記事はネットワーク/インフラエンジニアになったけど結局 Cisco 機器のセットアップは毎回ググってしまう人たちが，最低限のセットアップをすすめるための手順書です．あまり解説はしてません．
[ORF-NOC](https://orf-noc.sfc.wide.ad.jp) の[初期設定祭り](https://orf-noc.sfc.wide.ad.jp/hotstage-day1/)の記憶をもとに書いている部分が多いので，誤り等ありましたらご指摘ください．
基本設定，SSH 設定を行います．また，上流からは tagged VLAN(trunk) で受けて各ポートには access や trunk で出す設定も書いていきます．デフォルト VLAN は使用しません．
セキュリティについては個々人や組織のポリシーに従ってください．特にログイン周りの設定は上流の ACL 等でインターナルの通信しか流れない前提で書いてます．
念の為，コマンドはフルで書いてます．実際打つときは適宜省略してももちろん大丈夫です．
最後におまけでリセット方法も書いてます．

## 必要なもの

- Catalyst (IOS のバージョンは 12 以上を想定・ISR シリーズルータとかスタンドアロンの Aironet でも実質同じ)
- PC (macOS か Linux 推奨・Windows の人はｽｰﾊﾟｰﾊｶｰだから説明いらないよね)
- シリアルコンソールケーブル (RJ45 か 9pin かは機器に合わせる・よく消えるので 3 本くらい持っておく)

## 接続

1. PC にコンソールケーブルを刺す
2. `ls /dev/tty.*` を実行し，USBserial っぽいもののフルパスをコピー
3. `sudo screen {さっきのパス}` を実行
4. 機器の電源を入れる
5. Console ポートにコンソールケーブルを刺す
6. しばらくイメージ，ライセンスの確認や POST が終了するまで待つ
7. 終わった雰囲気を感じたら適宜 Return おしてみて `Switch>` のプロンプトが出ることを確認する
8. リセット後の初回起動の場合，対話形式でセットアップするかを聞かれるが面倒なので `no` にする．

## 基本設定

ここからは適宜 `write memory` してください．コマンド部分にプロンプトも書いていくので，それでモードを判別してください．当然ですが，特権 EXEC モード (プロンプトが `#`) とかコンフィギュレーションモード (プロンプトが `(config)#` とか) だと write memory できないので，`end` してユーザー EXEC モードに移ってください．
※`exit` だとモードが一つ降りますが `end` だとどこからでもユーザー EXEC モードになります．

### ホスト名の設定

1.ユーザー EXEC モードから特権 EXEC モードに移ります．

```
> enable
```

2.特権 EXEC モードからグローバルコンフィギュレーションモードに移ります．

```
# configure terminal
```

3.ホスト名を設定します．

```
(config)# hostname {hostname}
```

### SSH・ユーザ設定

1.SSH ログインに使うユーザ設定をします．

```
(config)# username {username} privilege 15 secret {password}
```

`privilege 15` はログイン時の権限設定で，最高の 15 にしておくとログイン時いきなり特権 EXEC モードになります．`secret` はパスワード指定のフレーズで，`secret` にしておくとハッシュされますが `password` とうつとハッシュされずに保存されます．

2.ユーザー EXEC モードから特権 EXEC モードに移行するときのパスワードを指定します．

```
(config)# enable secret {password}
```

上記で `privilege 15` している場合はコンソールケーブルで繋いだりしない限り二度と使わないです．

3.ドメイン名を設定します．正直なにに使ってるか知らない．

```
(config)# ip domain name {domain}
```

4.vty セッションを有効化します．

```
(config)# line vty 0 4
(config-line)# login local
```

2 つめのコマンドは，さっき設定したローカルのクレデンシャルを使用するという意味なので，RADIUS 等を使う場合は適宜その設定にしてください．

5.SSH 接続に必要な鍵を生成します．

```
(config)# crypto key generate rsa
```

たしか ECDSA と RSA が選べた気がします．ECDSA の場合はコマンドの `rsa` を `ec` に置き換えてください．

6.鍵長を聞かれるので十分に長い鍵長を設定しましょう．たまにデフォルトで RSA512bit を勧めてくるやつもいるので適当に return しないほうがいいです．また，一部の環境では RSA512bit などの短い鍵では SSH デーモンが走らないことがあります．ちなみに筆者は RSA4096bit で設定することが多いです (Linux サーバはもっと堅いの使いますが)．return すると機器のおつむによってしばらく待たされます．

7.SSH デーモンを起動します．

```
(config)# ip ssh version 2
```

### その他の設定

IOS ではコマンドと認識できない単語から始まる文字列を入力するとホスト名として解釈して勝手に名前解決を始めます．コマンドの 1 単語目を typo するとこれが発生しイライラするのでこのサーチを切ります．

```
(config)# no ip domain lookup
```

## VLAN 設定

### VLAN 定義・VLAN interface 作成

上流からは VLAN200, 300, 400, 500 を Ge0/1 に，trunk で受けます．VLAN500 をマネジメントと想定し，IP アドレスを持つことにします．
以下の手順は VLAN ごとに繰り返すことになります．

1.VLAN を定義します．

```
(config)# vlan {VLAN ID}
(conig-vlan)# name {VLAN name}
```

2.VLAN interface を作成します．

```
(config)# interface vlan {VLAN ID}
(config-if)# description {DESC}
```

description は面倒ですが書かないと後々ややこしくなるので必ず書きます．

3.VLAN interface にアドレスをつけます．状況にもよりますが，今回の場合最低 VLAN500 だけ設定してあればいいです．というのも，ネットワーク機器を設定するためのマネジメント VLAN なので，そこだけ L3 で会話できればことはすみます．
静的アドレスを固定する場合は以下のように書きます．

```
(config-if)# ip address {IPv4 address} {subnet mask}
(config-if)# ipv6 address {IPv6 address/hoge}
```

v6 の場合はアドレスに続けて `/64` とか書いて問題ないですが，v4 はアドレスのあとにスペースを開けてサブネットマスクを記載します．

v4 を DHCP で，v6 を RA でそれぞれ動的に設定する場合は以下のように書きます．

```
(config-if)# ip address dhcp
(config-if)# ipv6 address autoconfig default
```

当然 v4 と v6 の設定は独立しているので，上記を組み合わせて一方を静的，もう一方を動的に割り振ることも可能です．

### 物理 Interface 設定

1.まず上流を流すポートに trunk で全部の VLAN を通します．

```
(config)# interface GigabitEthernet 0/1
(config-if)# switchport mode trunk
(config-if)# switchport trunk allowed vlan 200,300,400,500
```

~~安い機器だと~~ 3 つめのコマンドでデフォルト VLAN たちを絶対通すように求められます．その場合は仕方ないので通します．また，各 vlan の記載はスペースを開けないでください．連番の場合は `200-201` のような記述が可能です．

2.次に各ポート (今回は Ge0/2-12) に access で 300 を出すことにします．

```
(config)# interface range GigabitEthernt 0/2-12
(config-if-range)# switchport mode access
(config-if-range)# switchport access vlan 300
```

## 確認

1.最後に (と言うより適宜) 投入した設定が正しいか確認します．

```
# show running-config
```

return を押すごとに 1 行ずつ，space を押すごとに数行ずつ進んでいきます．途中で辞めたければ `q` を押します．

2.VLAN の設定は config に書いてありません．`vlan.dat` に書いてあるので，そっちを参照します．

```
# show vlan
```

3.インターフェースの状況も確認しておきます．

```
# show ip interface brief
# show ipv6 interface brief
```

もし使用するはずのインターフェースが `shutdown` になっていたら，`no shutdown` する必要があります．

```
(config)# interface {interface}
(config-if)# no shutdown
```

4.設定に問題がなければ保存・永続化します．

```
# write memory
```

## 終わり

とりあえず基本の基本，スイッチとして動くようになりました．あとは手動なり自動化ツールなりでお好きなように設定してください．
深夜の思いつきで書いたので間違いや抜けがあるかもしれません．その際はお気軽にコメントください．

## おまけ -初期化

様々な理由で初期化が必要な際に実行するコマンドです．なお，揮発性メモリの中身すべてを消去してしまうとファームウェアも消去されてしまい，バックアップがないと文鎮になりますので，以下のとおりに設定のみ消してあげます．

1.不揮発性メモリに書いてある config を消します．揮発性メモリに書いてある config は再起動すれば勝手に吹き飛ぶので無視します．

```
# erase startup-config
```

2.一部 (というか多く) の機種では VLAN の設定は config には書いておらず，vlan.dat という別ファイルに保存されているため，vlan.dat を消去します．

```
# delete flash:vlan.dat
```

3.最後に再起動します．

```
# reload
```

### バックアップを取るには

初期化の前に本体内に config のバックアップを取っておきたいときには，現在の config を別ファイルとして保存します．ファイル名や拡張子は自分がわかれば何でもいいです．

```
# copy startup-config flash:{backup}
```

バックアップを復元するには，逆のコマンドを打ってやります．

```
# copy flash:{backup} startup-config
```

バックアップしたファイルが不要になったら消去します．

```
# delete flash:{backup}
```
