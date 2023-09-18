---
title: "IETF116 直前なので「IETF ダンス」について振り返る: 4-client-auth"
slug: "dance-client-auth"
date: "2023-03-25"
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

第 3 回: [https://blog.jj1lfc.dev/posts/dance-tls-clientid/](https://blog.jj1lfc.dev/posts/dance-tls-clientid/)

## draft-ietf-dance-tls-clientid-01 を読む

本記事では DANCE の根本となる **draft-ietf-dance-client-auth-01** を読んでいきます．タイトルは「`TLS Client Authentication via DANE TLSA records`」となっています．原文は[こちら](https://datatracker.ietf.org/doc/draft-ietf-dance-client-auth/) をご参照ください．本記事はお気持ち翻訳であり，一部はしょっています．

本文書は執筆時点で Active Internet-Draft となっており，最終更新は 2022 年 11 月 8 日です．

### Abstract

本ドキュメントでは RFC6698 と RFC7671 (DANE TLSA) をアップデートし，どのようにクライアント証明書もしくは公開鍵を TLSA レコードで公開するかを定義します．また，TLS と使用する際のルールや考慮事項も記述します．

### Introduction and Motivation

TLS ではオプションとして X.509 証明書か生の公開鍵を用いてクライアントを認証することができます．DANE 認証を行う TLS アプリケーションでも，特にクライアントの identity がドメイン名である場合はクライアント認証を行いたいこともあるでしょう．広大なネットワークで物理デバイスを DNS 名で識別するような，この類の認証を利用する IoT のデザインパターンでは，中央集権的なデバイス管理プラットフォームで TLS を用いた認証をしたいかもしれません．

本文書では，TLS とは TLS と DTLS の双方を指します．

### Associating Client Identities in TLSA Records

アプリケーションごとにドメイン名によるクライアントの命名はかなり異なるでしょう．本ドキュメントでは一つのフォーマットに拘らず，広範に適用できる事例を挙げます．

2.1 では Service specific client identity について，2.2 では DevId: IOT Device Identity について紹介しています．

### Authentication Model

本ドキュメントで想定する認証モデルは次のとおりです．

クライアントはドメイン名に対応した identity を割り当てられます．このドメイン名は必ずしもネットワーク層のアドレスに紐づいている必要はありません．クライアントは往々にして動的もしくは予期できないアドレスを持ち，ネットワーク内を動き回るかもしれません．そのため，一般にはそれぞれの identity とネットワークアドレスを紐づけることはあまり賢賢いとはいえません．

クライアントは秘密鍵と公開鍵のペアを生成します．クライアント証明書が使われるときは，この公開鍵と名前を紐付けた証明書を使います．証明書もしくは生の公開鍵は対応した TLSA レコードを DNS 常に持ちます．これにより DNS から直接認証したり，証明書がパブリック CA から発行されている場合は CA システムで認証したりできます．

### Client Identifiers in X.509 certificates

TLS DANE Client Idendity 拡張が用いられていない場合，クライアント証明書は Subject Alternative Name (SAN) 拡張に dNSName 型でクライアントの DNS 名を入れなければなりません．

### Signaling the Client’s DANE Identity in TLS

クライアントは DANE identity がある事を明示的に送信すべきです．その最大の理由は，サーバ側で不必要な DNS クエリを避けるためです．

このために DANE Client Identity TLS extension が用いられます．この拡張はドメイン名などのサーバが認証しようとするクライアント identity そのものも伝達できます．また，生の公開鍵での認証が行われる場合，クライアント証明書から DNS identity を読み出せないため必要となります．クライアント証明書に複数の identity があり，そのうち一つだけが DANE レコードに紐付いている場合にも役立ちます．

その他このようなシグナリングが有用な例としては、DANE クライアント認証がオプショナルであり，TLS サーバから Certificate Request メッセージを受診しても graceful に応答しないバグのあるクライアントが存在する場合があります．この拡張で TLS サーバはこの拡張を送信したクライアントにのみ選択的に Certificate Request メッセージを送信することで，このような状況に対応することができます．

### Example TLSA records for clients

この章では Service Specific Client Identity と DevID の TLSA レコードの例を示しています．

#### Service Specific Client Identity

```
_smtp-client.device1.example.com. IN TLSA (
   3 1 1 d2abde240d7cd3ee6b4b28c54df034b9
         7983a1d16e8a410e4561cb106618e971 )
```

#### DevID

```
sensor7._device.example.com. IN TLSA (
   3 1 2 0f8b48ff5fd94117f21b6550aaee89c8
         d8adbc3f433c8e587a85a14e54667b25
         f4dcd8c4ae6162121ea9166984831b57
         b408534451fd1b9702f8de0532ecd03c )
```

### Changes to Client and Server behavior

適合する TLS クライアントはその DNS めいと X.509 証明書もしくは生の公開鍵と対応する署名済の DNS TLSA レコードを公開しなければなりません．クライアントはサーバに対して，TLS ハンドシェイクの時にこの証明書か公開鍵を提示します．クライアントは証明書や公開鍵に適合しないサイファースイートを提示すべきではありません．クライアント証明書が DANE-EE 以外の DANE レコードと紐付いている場合，提示された証明書の SAN に dNSName としてクライアントの DNS 名が明示されていなければなりません．

さらに，生の公開鍵で認証する際は，クライアントは Client Hello メッセージ中で TLS DANE Client Identity extension を送信しなければなりません．X.509 証明書の場合も，この拡張を送信すべきです．

本仕様を実装する TLS サーバは次のステップを踏みます:

- TLS ハンドシェイク (Client Certificate Request メッセージ) でクライアント証明書を要求する．これは無条件に要求することも，TLS DANE Client Identity extension をクライアントから受け取ったときのみに要求することもできる．
- クライアントが空白以外の DANE Client Identity extension を送信した場合，そこからクライアントのドメイン名を取得する．そうでなければ，SAN の dNSName から取得する．
- 対応する TLSA レコードの DNS クエリを生成する．TLS DANE client identity extension がある場合は，その名前を使うべきである．そうでなければ，証明書の名前が使われる．
- DNS で TLSA レコードを検索する．応答は DNSSEC を使って暗号学的に検証されなければならない．サーバは DNSSEC 検証を自身で行うこともできる．または，安全な接続をしている DNSSEC 検証リゾルバの応答を信頼するよう設定できる．
- TLSA レコードから RDATA を展開し，DANE TLS プロトコルに則って提示されたクライアント証明書との一致検証をする．一致すれば，クライアントは認証され TLS セッションを続行できる．一致しなければ，サーバはクライアントを認証されていないとみなさなければならない (セッションを中断するか，認証されていない一般ユーザとしてリソースへのアクセスを許可するなど)．
- 複数の TLSA レコードがあった場合，(実装されているべきである) RFC7671 により一つでも一致検証に成功すればクライアントは認証される．

DANE Client Identity extension が提示されなかった場合で，提示されたクライアント証明書が複数の identifier 型 (dNSName と rfc822Name など) を持っていた場合，本仕様に則り DANE 認証を行う TLS サーバは dNSName のみを検証・認証すべきです．

提示されたクライアント証明書に複数の dNSName がある場合，クライアントは TLS DANE client identity extension を使って一意に名前を提示しなければなりません．

特定のアプリケーションでは追加の検証ステップが必要かもしれません．例えば，サーバはクライアントの IP アドレスが一定のルールで証明書と紐付いている (セキュアな DNS 逆引き結果が同じドメイン名を示す，または証明書に iPAddress コンポーネントを含ませる) ことを検証したいかもしれません．そのような詳細は本ドキュメントのスコープ外であり，他の特定のアプリケーションのドキュメントに記されるべきです．

サーバはホワイトリスティングや受け付ける証明書の認証ルールを設定したいかもしれません．例えば，TLS サーバが特定のドメイン名やドメイン名群の証明書を持つクライアントからの TLS セッションのみを受け付ける場合などです．

### Raw Public Keys

生の公開鍵を TLS で使う場合，本仕様では TLS DANE Client Identity extension の仕様を必要とします．紐付く DANE TLSA レコードは RFC7671 にあるとおり usage 3 (DANE-EE) のみで selector 1 (SPKI) となります．
