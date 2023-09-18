---
title: "ICTSC2021 夏の陣 write-up"
slug: "ictsc2021s"
date: "2021-09-03"
tags:
  - "writeup"
---

[ICTSC2021 夏の陣](https://icttoracon.net/archives/8808) に参加してきました．
ICTSC への参加は今年で 3 回目となります．
一応，ICTSC のメインストリーム? 自体は昨年で[休止となった](https://icttoracon.net/archives/8799)のですが，運営有志で開催していただいたとのことです．

今回のチーム「味処まるたか」は後輩 2 人が新たに加わった新メンバ構成でしたが，彼らの日頃の運用力のおかげで [2 位になることができました](https://twitter.com/icttoracon/status/1431907650988433415)．

さて，write-up ですが，私は都合の良い人間なので解けた問題だけ書いていきます．

# 対向につながらな。。

複数のルータを直列に接続し，それぞれのルータ間で L3 ネットワークが切ってある環境で，端っこから端っこまでの到達性がないというトラブルです．
この問題ではルータ間の経路広告に OSPF を使用しており，中間のルータで必要な経路が広告されていないことがトラブルの原因でした．
以下，弊チームの解答です．

```markdown
お世話になっております．味処まるたかです．

この問題では，tky-R1 から tky-R2 にむけて，172.16.1.2/31 の経路が OSPF 広告されていなかったことにより，問題文の図で tky-R2 より左側と tky-R1 より右側の疎通がとれていないことが原因でした．

## 現状確認

> user@tky-R1:~$ show configuration
> ~~
> protocols {
> ~~
> ospf {
> area 0 {
> network 172.30.254.1/32
> network 172.30.253.2/31
> network 172.30.0.0/24
> }
> ~~
> }

area 0 に 172.16.1.2/31 が含まれていません．

## 解決

area 0 に 172.16.1.2/31 を追加し，ospfd (frr) を再起動することにより解決しました．

> user@tky-R1# set protocols ospf area 0 network 172.16.1.2/31
> [edit]
> user@tky-R1# commit
> [ protocols ospf ]
> For this router-id change to take effect, save config and restart ospfd
>
> [edit]
> user@tky-R1# save
> Saving configuration to '/config/config.boot'...
> Done
> [edit]
> user@tky-R1# exit
> exit
> user@tky-R1:~$ restart frr
> WARNING: This is a potentially unsafe function! You may lose the connection to the router or active configuration after running this command. Use it at your own risk! Continue? [y/N]: y

## 確認

tky-Host より 172.20.0.1 に対し ping が飛びました．

> user@tky-Host:~$ ping 172.20.0.1
> PING 172.20.0.1 (172.20.0.1) 56(84) bytes of data.
> 64 bytes from 172.20.0.1: icmp_seq=1 ttl=62 time=1.44 ms
> 64 bytes from 172.20.0.1: icmp_seq=2 ttl=62 time=0.600 ms
> ^C
> --- 172.20.0.1 ping statistics ---
> 2 packets transmitted, 2 received, 0% packet loss, time 1001ms
> rtt min/avg/max/mdev = 0.600/1.018/1.436/0.418 ms
```

# キャッシュサーバ立てたけど．．．

`gethostbyname()`を使って A レコードの名前解決をする C のプログラムを用いて名前解決をしたが，どうも systemd-resolved のキャッシュを参照してくれないというトラブルで，
ソースコードや `/etc/resolv.conf` をいじらずに systemd-resolved のキャッシュを参照するようにせよ，という問題です．
正直，Linux における名前解決やスタブリゾルバの実装などは全然知らなかったので，この問題をきっかけに NSS の存在を知りました．

まず与えられたプログラムのソースを読んでいくつか名前解決をさせるとよくセグフォを起こしていることがわかりました．
特に，問題文中に例示されている `hoge.hoge` というドメイン名を渡すと背黒を起こしていたので，最初は「ソースコードに手を加えずセグフォを起こさないようにせよ」という問題かと思ってしまいました．
私はエンジニアではないのでコードなんてかけないし，C なんて触ったこともない (というと嘘ですが) ので，詳しそうな[ｷﾉｰﾏｰｰくん](https://twitter.com/kino___ma)に渡しました．
するとさすがにｷﾉｰﾏｰｰくんは「いやそうじゃないでしょ」ということに気付いてくれたので，再び私に差し戻されとりあえずこの挙動を無視して解くことに．

次に，条件として `/etc/resolv.conf` を書き換えてはいけないことが挙げられていましたが，「俺は書き換えてねえぞ」という精神の元 NetworkManager の設定をいじり `systemctl restart NetworkManager` する解答を提出しました．
NetworkManager くんは設定によっては自分で `/etc/resolv.conf` を書き換えてくれます．
当然 0 点でした．

そこから色々調べて NSSwitch なるものの存在を知り，以下に示す 2 回目の解答で問題を終了しました．

```markdown
お疲れ様です．味処まるたかです．

今回の問題は，NSS の設定で DNS キャッシュサーバとして systemd-resolved が指定されていなかったことで，`gethostbyname()` が systemd-resolved のキャッシュを参照しなかったことが原因です．

## 現状確認

`/etc/nsswitch.conf` が以下のとおりとなっていました．

> ~~
> hosts: files dns
> ~~

## 問題解決

`/etc/nsswitch.conf` の当該行を以下のように書き換えました．

> hosts: resolve

## 解決確認

これにより，問題文の終了状態を満たしました．なお，`~/resolver` に `hoge.hoge` を解決させたり，そのドメイン名ないし CNAME された本名のドメイン名に A レコードを持たないドメイン名を解決させたりするとセグメント違反を起こすため，別の A レコードを持つドメイン名を解決しています．

> [user@Host-A ~]$ resolvectl statistics
> DNSSEC supported by current servers: yes
>
> Transactions
> Current Transactions: 0
> Total Transactions: 18
>
> Cache
> Current Cache Size: 14
> Cache Hits: 3
> Cache Misses: 13
>
> DNSSEC Verdicts
> Secure: 11
> Insecure: 7
> Bogus: 0
> Indeterminate: 0
> [user@Host-A ~]$ ./resolver ns2.jj1lfc.dev.
> genelic hostname = ns2.jj1lfc.dev
> IP address(0) = 45.76.100.215
> [user@Host-A ~]$ ./resolver ns2.jj1lfc.dev. # キャッシュヒットさせるため意図的に 2 回実行．
> genelic hostname = ns2.jj1lfc.dev
> IP address(0) = 45.76.100.215
> [user@Host-A ~]$ resolvectl statistics
> DNSSEC supported by current servers: yes
>
> Transactions
> Current Transactions: 0
> Total Transactions: 21
>
> Cache
> Current Cache Size: 15
> Cache Hits: 5 # キャッシュヒット数が増えていることから，キャッシュが参照できている．
> Cache Misses: 14
>
> DNSSEC Verdicts
> Secure: 12
> Insecure: 7
> Bogus: 0
> Indeterminate: 0

また，`/etc/resolv.conf` への変更が加えられていないことも確認しています．

> # This file is managed by man:systemd-resolved(8). Do not edit.
>
> #
>
> # This is a dynamic resolv.conf file for connecting local clients to the
>
> # internal DNS stub resolver of systemd-resolved. This file lists all
>
> # configured search domains.
>
> #
>
> # Run "resolvectl status" to see details about the uplink DNS servers
>
> # currently in use.
>
> #
>
> # Third party programs must not access this file directly, but only through the
>
> # symlink at /etc/resolv.conf. To manage man:resolv.conf(5) in a different way,
>
> # replace this symlink by a static file or a different symlink.
>
> #
>
> # See man:systemd-resolved.service(8) for details about the supported modes of
>
> # operation for /etc/resolv.conf.
>
> nameserver 133.242.0.3
```

# ンジンエックス

NGINX で Web サーバを建てたが，HTTP2 で GET しても返事をもらえないというトラブルです．
この問題環境では自力でコンパイルした NGINX を使用していましたが，コンパイル時のオプションにより HTTP2 のサポートが無効化されていました．
以下，弊チームの解答です．

```markdown
お世話になっております．味処まるたかです．

この問題は，主に nginx のコンパイル時に http_v2_module を含めていなかったことが原因です．

## 問題確認

> user@web-server:~$ sudo /usr/local/nginx/sbin/nginx
> nginx: [emerg] the "http2" parameter requires ngx_http_v2_module in /usr/local/nginx/conf/nginx.conf:36

## 解決

`~/nginx-1.21.1` 以下にソースがあったため，再設定の上コンパイルし直しました．

> user@web-server:~/nginx-1.21.1$ ./configure --with-http_v2_module
> (出力省略)
> user@web-server:~/nginx-1.21.1$ sudo make
> (出力省略)

その後，`/usr/local/nginx/conf/nginx.conf` の 36 行目から `http2` の記述を削除しました．

## 解決確認

nginx を起動し，

> user@web-server:~$ sudo /usr/local/nginx/sbin/nginx

curl で終了状態を満たしていることを確認しました．
```

---

簡単ですが write-up でした．
他の問題を含めて，個人的な貢献はたしか 550pt でした．

私には DNS と SMTP くらいしか学がなく，今回から新たにメンバに加わった後輩に任せた問題もかなり多かったのですが，普段触れない技術にも触れることができる良い機会になりました．
後輩各位には次回以降の健闘も期待したいです．
