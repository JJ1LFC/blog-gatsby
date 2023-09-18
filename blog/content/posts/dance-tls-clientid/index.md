---
title: "IETF116 直前なので「IETF ダンス」について振り返る: 3-tls-clientid"
slug: "dance-tls-clientid"
date: "2023-03-24"
tags:
  - "DNS"
  - "Security"
  - "trust"
---

## IETF ダンスとは

DANCE とは **DANE Authentication for Network Clients Everywhere** のことであり，現在 IETF で DANCE WG が組織されています．「IETF ダンス」なる踊りはありません．タイトル詐欺でごめんなさい．

一連のブログポストで DANCE について書いていきます．

第 1 回: [https://blog.jj1lfc.dev/posts/dance-charter/](https://blog.jj1lfc.dev/posts/dance-charter/)

第 2 回: [https://blog.jj1lfc.dev/posts/dance-arch/](https://blog.jj1lfc.dev/posts/dance-arch/)

## draft-ietf-dance-tls-clientid-01 を読む

本記事では DANCE の根本となる **draft-ietf-dance-tld-clientid-01** を読んでいきます．タイトルは「`TLS Extension for DANE Client Identity`」となっています．原文は[こちら](https://datatracker.ietf.org/doc/draft-ietf-dance-tls-clientid/) をご参照ください．本記事はお気持ち翻訳であり，一部はしょっています．

本文書は執筆時点で Active Internet-Draft となっており，最終更新は 2022 年 11 月 8 日です．

### Abstract

本ドキュメントでは DANE Client Identity を TLS もしくは DTLS サーバに伝えるための TLS/DTLS 拡張について定義します．

### Introduction

本拡張を空欄にすることで「クライアントは DANE レコードを持っておりサーバは証明書から抽出した ID を使ってクライアントの DANE 認証を行うことができる」とサーバに伝えます．もしくは，DANE TLSA レコードを持つ DNS ドメイン名の形をとった完全な Client Identity とすることもできます．

本拡張は TLS と DTLS の双方をサポートし，このドキュメントでは双方を指して「TLS」と呼びます．

### Overview

TLS クライアントが x.509 証明書か DANE TLSA レコードに格納された生の公開鍵を使うとき，本拡張は DANE で認証されるという意思，もしくは完全な DANE identity そのものをサーバに伝えるのに役立ちます．

X.509 証明書の場合，TLS サーバはクライアントの identity を証明書の `Subject Alternative Name` (SAN) から知ることができます．しかし，本拡張のようなメカニズムがない場合，TLS サーバはクライアントが TLSA レコードを持っているのか先んじて知ることができず，よってクライアントがレコードを持っていない場合でもハンドシェイクの度に不必要な DANE TLSA クエリを投げることになります．証明書で複数の identity がある場合，クライアントは本拡張でどの identity を使うのか示さなければなりません．本拡張が役に立つ他の例としては，証明書を提供するクライアントだけに対して TLS サーバが選択的にクレデンシャルをプロンプトするようなケースがあります．

TLS の生の公開鍵がクライアント認証に使われる場合，クライアントはサーバに対して，本拡張で identity がなんなのかを明示的に示します．これは，X.509 のように identity を示す方法がないからです．

詳細は draft-huque-dane-client-cert-04 に示されます．

### DANE Client Identity Extension

`dane_clientid` の拡張型は値を持ち，IANA の TLS 拡張レジストリに登録されることになります．空白でない場合のデータはこのようなフォーマットになります．

```
opaque ClientName<1..2^8-1>;
```

`ClientName` フィールドはクライアントの単一のドメイン名をテキストで含みます．RFC1035 で示すとおり，最後のドットは含みません．

本拡張を実装する TLS サーバは空白の `dane_clientid` を送信し，本拡張を理解できること，DANE クライアント認証ができることを示さなければなりません．TLS1.2 では ServerHello メッセージで，TLS1.3 では CertificateRequest メッセージで送信されます．

本拡張を実装する TLS クライアントは `dane_clientid` を送信すべきです．クライアントが単に「DANE レコードがあり identity は証明書から抽出できる」ということを示したいだけならば，値をからにして送ることができます．クライアントが自分の identity を送信するときは，`extension_data` フィールフォに必ずドメイン名の `ClientName` データを含む必要があります．

クライアントからの本拡張の送信は，TLS1.2 では ClientHello メッセージで，TLS1.3 では Certificate メッセージで行われます．さらに，TLS1.3 ではサーバから CertificateRequest で空白の本拡張メッセージが受信できたときにのみクライアントがこれを送信できます．

### Security Considerations

TLS1.3 では暗号化された CertificateRequest 及び Certificate メッセージにて送信されます．

TLS1.2 では暗号化はされません．不必要なプライバシー情報 (クライアントの平文の名前) のリークを防ぐため，本拡張を実装する TLS クライアントでは DANE 認証を行うサーバに対してのみ本拡張を送信するよう設定すべきです．

---

気付いたらほぼお気持ち全訳になっていました．多分残る 1 文書もそんな感じになると思います．
