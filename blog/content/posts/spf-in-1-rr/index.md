---
title: "SPF のレコードは増やさないでください"
slug: "spf-in-1-rr"
date: "2021-09-16"
tags:
  - "email"
---

早速ですが問題です．
以下の 2 つのケースの SPF のレコードのうち，以下の情報のみで誤っていると言えるのはどちらでしょう?

- A

```
example.com.  3600 IN TXT "v=spf1 mx include:_spf.example.com ~all"
```

- B

```
example.com.  3600 IN TXT "v=spf1 mx ~all"
example.com.  3600 IN TXT "v=spf1 include:_spf.example.com ~all"
```

正解 (誤っている方) は B です．
本稿ではこれについて記述します．

# ことの発端

2021 年 6 月 5 日，[こんな](https://twitter.com/xplntr/status/1401139723540656131) tweet が目にとまりました．
当時のログを取り忘れていたので[こちら](https://twitter.com/xplntr/status/1401156550392107008/photo/1)からの引用となりますが，`amazon.com.` ドメイン名の SPF のレコードが下記のようになっていました．

```
amazon.com.  900 IN TXT "v=spf1 include: amazon.com include:spf1.amazon.com include:spf2.amazon.com include:amazonses.com -all"
amazon.com.  900 IN TXT "v=spf1 include:spf1.amazon.com include:spf2.amazon.com include:amazonses.com -all"
```

同一のドメイン名に対して 2 つの SPF (TXT) レコードがあり，よく見ると一方は片方に `include: amazon.com` を付け加えたものとなっています．

## 何がダメ?

この件に関しては大きく 2 点ダメな点があります．

1 点目はダメな点と言うより謎な点ですが，`amazon.com` 自身が `amazon.com` を `include` しており，無限ループが発生している点です．
`include` は別のドメイン名に記載した spf レコードをそのまま取り入れる形で利用したい場合に使うもので，
そのドメイン名自身を include する意味はありません．
なお，`include: ` のうしろにスペースが入っているのも余分です．

2 点目が本題ですが，SPF を記載した TXT レコードが 2 件あることです．
[IETF RFC 7208 Section 3.2](https://datatracker.ietf.org/doc/html/rfc7208#section-3.2) では複数の DNS レコードについて以下のように標準化しています．

> A domain name MUST NOT have multiple records that would cause an
> authorization check to select more than one record. See Section 4.5
> for the selection rules.

ということで，**一つのドメイン名に対して複数の選択可能な (検証者から選択されうる) SPF のレコードを書いてはなりません．**

さらに，[同 Section 4.5](https://datatracker.ietf.org/doc/html/rfc7208#section-4.5) では，そのような場合の取り扱いについて以下のように標準化しています．

> If the resultant record set includes
> more than one record, check_host() produces the "permerror" result.

ということで，仮に一つのドメイン名に対して複数の SPF のレコードを設定した場合，検証者側は permerror 判定を行います．
そのため，このケースでは `amazon.com.` ドメイン名を差出人とするメールは受信者 (検証者) に不正なメールとして取り扱われる可能性があります．

なお，当然このレコードは既に修正されています．

# またか!

それから 3 ヶ月が過ぎた 2021 年 9 月 16 日，また同様の事案が，今度は `docomo.ne.jp.` ドメイン名について発生しました．
こちらは手元の dig 返答を残しておいたので抜き出して掲載します．

```
docomo.ne.jp.           86400 IN TXT "v=spf1 +ip4:203.138.203.0/24 +ip4:210.153.87.192/29 +ip4:210.153.87.224/29 ~all"
docomo.ne.jp.           86400 IN TXT "google-site-verification=W-sgAStguIHHMRLOQPhcwO3q2NKki__JbEkYZZUQRcY"
docomo.ne.jp.           86400 IN TXT "facebook-domain-verification=yxhymjv3d8lra7pfo85sytrd80c0m1"
docomo.ne.jp.           86400 IN TXT "v=spf1 include:aspmx.pardot.com ~all"
```

今回も SPF のレコードが 2 件登録されています．
しかも，今度は TTL が 24 時間と長いので，一度検証者側の DNS キャッシュサーバでキャッシュしてしまうと，修正しても最大 24 時間は影響が残ることになります．

私が見ている限りだと今回は 16 時半過ぎに[最初に発見報告](https://twitter.com/xplntr/status/1438406689837891592)が tweet されており，21 時半前ごろには修正されたようです．

# 実際の影響

私個人で管理している MTA での結果を書ければいいのですが，あいにくどちらも発生時間帯にいい感じのメールを受信していませんでした．
しかし，大手のメールプロバイダさんは受信者としていろんなふるまいを見せていたようです．
もちろん，参照している SPF のレコードがいつクエリされたものなのか知るよしもないため一概には言えませんが．．．．

- 参考 1 (amazon): https://twitter.com/xplntr/status/1401385910126612487
- 参考 2 (docomo): https://twitter.com/smbd/status/1438461457658564613
- 参考 3 (docomo): https://twitter.com/ka0com/status/1438472516981309440

大手のメールプロバイダさんだと，明らかな設定ミスにより受信できない場合は忖度して，最終的な受信者である自分の顧客の QOL を保護するという選択がされるケースがもしかしたらあるのかもしれません．

---

ということで，SPF のレコードは一つだけ書こう，分かち書きしたいなら `include` を使おう，というお話でした．
