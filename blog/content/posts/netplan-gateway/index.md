---
title: "gateway4/gateway6 なんてもうない"
slug: "netplan-gateway"
date: "2023-03-09"
tags:
  - "Network"
  - "自宅サーバ"
---

最近の netplan ではデフォゲの書き方が変わったらしい．

## 昔の netplan

今まではデフォゲはこんな感じで書いてた．

```yaml
network:
  version: 2
  ethernets:
    eth0:
      addresses:
        - 192.0.2.2/24
        - "2001:db8::2/64"
      gateway4: 192.0.2.1
      gateway6: "2001:db8::1"
```

`gateway4` `gateway6` という独立したラベルがあった．

## 今の netplan

netplan の詳しいバージョンはわからないが，少なくとも Ubuntu では 22.04 から上記の書き方は deprecated になりこのような書き方になる．

```yaml
network:
  version: 2
  ethernets:
    eth0:
      addresses:
        - 192.0.2.2/24
        - "2001:db8::2/64"
      routes:
        - to: default
          via: 192.0.2.1
        - to: "::/"
          via: "2001:db8::1"
```

`routes` ラベルの下に書くようになった．こう書かないと `netplan apply` したときに怒られる．

経路を (デフォゲに限らず) まとめて書けるようになったのはわかりやすいが v6 の疎外感どうにかならんものか．．．

## 参考

- [https://netplan.io/examples](https://netplan.io/examples)
