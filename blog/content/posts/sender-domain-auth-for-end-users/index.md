---
title: "送信ドメイン認証をユーザレベルまで落とすのってどうなの?"
slug: "sender-domain-auth-for-end-users"
date: "2021-05-18"
tags:
  - "email"
  - "trust"
---

最近 (?)，送信ドメイン認証の結果を MTA レベルで処理せず，ユーザに GUI で表示する人たちが増えているみたいです．例えば．．．

- Yahoo! メール (Yahoo! Japan): [ブランドアイコン](https://announcemail.yahoo.co.jp/brandicon_list/index.html)
- ドコモメール (NTT docomo): [ドコモメール公式アカウント](https://www.nttdocomo.co.jp/info/spam_mail/official_account/)

私は「フツーは，送信ドメイン認証では受信 MTA が検証者で，その検証結果に基づくアクションも受信 MTA が行うんじゃないの?」と解釈していたのですが，このように検証結果に基づくアクションをユーザレベルに落とすのはアリなんでしょうか．

関連記事: [ドコモメール公式アカウントについて考えたこと](https://blog.jj1lfc.dev/posts/docomo-mail/)

# RFC を読んでみる

公式ページを読む限り，Yahoo! メールでは DKIM を，ドコモメールでは SPF をそれぞれ単体で使用しているようです．では，DKIM と SPF の IETF RFC ではこのような使い方を想定しているのでしょうか?

## DKIM

[IETF RFC 6376](https://datatracker.ietf.org/doc/html/rfc6376) では，署名の検証者について 2.2 で以下のように定義しています．

> Elements in the mail system that verify signatures are referred to as
> Verifiers. These may be MTAs, Mail Delivery Agents (MDAs), or MUAs.
> In most cases, it is expected that Verifiers will be close to an end
> user (reader) of the message or some consuming agent such as a
> mailing list exploder.

検証者としては MUA までとされており，Email の読者にちかい立場が一般的なケースだと想定されています．
なお，検証者 (Verifier) とはあくまで署名検証を行う立場であって，必ずしも結果に基づいてアクションを行う立場と同一ではありません．

また，6.2 では `INFORMATIVE ADVICE to MUA filter writers` として以下のような記述があることから，一定の条件下で MUA がユーザに認証結果を伝えることを想定していると考えられます．

> Patterns intended to
> search for results header fields to visibly mark authenticated
> mail for end users should verify that such a header field was
> added by the appropriate verifying domain and that the verified
> identity matches the author identity that will be displayed by the
> MUA.

ただし，6.3 では以下のように記述されており，この RFC はあくまで誰がどのようなアクションをするか定義するものではないことがわかります．

> It is beyond the scope of this specification to describe what actions
> an Identity Assessor can make

## SPF

[IETF RFC 7208](https://datatracker.ietf.org/doc/html/rfc7208) では，2.2 で検証者について必ずしも受信 MTA に限らないと読める記述があります．

> An SPF check tests the authorization of a client host
> to emit mail with a given identity. Typically, such checks are done
> by a receiving MTA, but can be performed elsewhere in the mail
> processing chain so long as the required information is available and
> reliable.

なお，検証結果によって取りうるアクションの主体については記述を見つけられませんでした．
(考えられるアクション例については 8 で記述があります．)

以上 2 つの RFC の総括として，認証結果を MUA に表示させユーザに判断を任せることは否定してはいないものの，推奨しているわけでもなく，あまり厳密に定義したくないというように見えます．

## DMARC

なお，参考までに，DKIM や SPF を前提技術としている [IETF RFC 7489](https://datatracker.ietf.org/doc/html/rfc7489) (DMARC) では，6.7 で以下のように記述しています．

> Final disposition of a message is always a matter of local policy.

結局の所，認証結果に基づくアクションは組織の性質や Email フローなどによって一概に定めることが難しく，状況によって管理者が判断しましょうというのが RFC authers の立場のようです．

# 他の標準での考え方を見てみる

では，ほかの標準等ではどのように扱われているのでしょうか．特に運用視点で書かれているものを探ってみました．

## NIST SP800-177

[NIST SP800-177](https://www.nist.gov/publications/trustworthy-email-0) は Trustworthy Email について記述された NIST Special Publication で，主に米国政府機関の標準に近い文書として扱われます．

4.2 では，送信ドメイン認証の技術は MTA を念頭に置いて設計されており，特にエンドユーザに直接見せるという考えは基本的にはないとしつつも，それらの結果をアイコンや文字色でユーザに伝える MUA の存在にも言及しています．

> As mentioned above, the domain-based authentication protocols discussed in this section were
> designed with MTAs in mind. There was thought to be no need for information passed to the end
> recipient of the email.The results of SPF and DKIM checks are not normally visible in MUA
> components unless the end user views the message headers directly (and knows how to interpret
> them).

> Some MUAs make use of this information to provide visual cues (an icon,
> text color, etc.) to end users that this message passed the MTAs checks and was deemed valid.

その上で，当然のことながら，この目印は必ずしも信頼できるということを示さないとしています．

> This does not explicitly mean that the email contents are authentic or valid, just that the email
> passed the various domain-based checks performed by the receiving MTA.

また，「管理者はユーザに対し，それぞれの結果がなにを意味するのかだけでなく，良い結果が表示されていることが完全にセキュアであることを示すわけではない，ということを教育すべきだ」としています．

> Email administrators should educate end
> users about what the results mean when evaluating potential phishing/spam email as well as not
> assuming positive results means they have a completely secure channel.

## M3AAWG の立場

[M3AAWG](https://www.m3aawg.org/published-documents) の発行している文書群では，送信ドメイン認証の検証主体について記述しているものは見つけられませんでした．

ほかに参照すべき文書・サイト等をご存知の方はご教授いただけると幸いです．

# Yahoo! メールとドコモメールのケースを考える

では，今回例に上げた Yahoo! メールとドコモメールのケースをそれぞれ考えてみます．

## NIST SP800-177 の観点

まず，彼らはエンドユーザに対して十分な教育をしているでしょうか．

### Yahoo! メール

[Yahoo! メール](https://announcemail.yahoo.co.jp/brandicon_corp/index.html)ではブランドアイコンの説明で，以下のように正反対のアピールをしています．

> ブランドアイコンが表示されることで、送信元が保証された安心・安全なメールであることがお客様に一目で伝わります。

> 公式からの本物のメールだと証明できる

### ドコモメール

[ドコモメール](https://www.nttdocomo.co.jp/info/spam_mail/official_account/)ではドコモメール公式アカウントの説明で，以下のように正反対のアピールをしています．

> お客さまは一目で公式アカウントからのメールであることがわかるので、あんしんしてメールの内容をご確認になれます。

反面，以下のように免責についても言及しています．

> 本サービスは送信ドメイン認証に成功したお申込み企業さまのメールに対してドコモメール上で公式アカウントであることを明示する機能であり、弊社がメールの内容を保証するものではありません。

以上より，どちらも NIST SP800-177 に推奨されるような教育とは真逆の宣伝を行っていることがわかります．
なお，NIST SP シリーズは日本の私企業に対して強制力のある文書ではなく，従う必要はありませんが，多くのケースでベストプラクティスとして参照されます．

## 技術的信頼性の観点

[以前の記事](https://blog.jj1lfc.dev/posts/docomo-mail/)でも述べていますが．．．

現代の Email で SPF/DKIM 単体である Email が不正な送信者によるものかを判定するのは困難です．特に，不正な送信者からでない Email を信頼できる送信者からの Email であると，SPF/DKIM 単体を用いて正確に判定するのは著しく困難です．
それは，SPF/DKIM のプロトコルに内包されている誤判定のリスクを許容する必要があり，DMARC や ARC などのその誤判定をなるべく制御できるようにしたプロトコルの恩恵を受けられないからです．

## ユーザ層の観点

Yahoo! メールやドコモメールはいずれも広く一般のユーザに対して Email サービスを提供しており，運用者としてはユーザの Email セキュリティに関する知識レベルは著しく低いことを前提とすべきです．
そのユーザがブランドアイコンやチェックマークを見て，正しくその意味を解釈することができるでしょうか?
ましてや，ユーザを管理する立場にある管理者が上記のとおり現実とは真逆の宣伝をしている状況です．

# 私見まとめ

Email 受信ポリシは個別の Email フローに応じて柔軟に設定されるべきです．
その上で，ユーザに対し十分に教育できる環境がないのであれば，送信ドメイン認証の結果に基づく判断をユーザに任せるのは単なる責任放棄であり，推奨されるポリシではないと私は考えます．
十分に教育できる環境があったとして (十分な教育が行われるかは別問題ですが)，そもそも受信 MTA で自動で判断ができるプロトコルで多種多様なユーザの判断に任せるのは，管理不行き届きによる問題を引き起こす可能性があり，なるべく管理者のポリシが徹底できる受信 MTA でアクションを行うべきだと考えます．

なお，自動で判定・アクションまで行った場合に不正ではない Email が不正な Email と判定 (false positive) することによって起きる損害を懸念するケースがあると思います．
しかし，SPF・DKIM・DMARC ではそれぞれの署名者 (ないし送信者) が DNS レコードでプロトコル対応状況や判定条件を示す機構があり，いずれのプロトコルでも受信者は (少なくとも) それよりも安全側に倒して考えることが IETF RFC で推奨されています．
そのため，IETF RFC に従って受信者がアクションを規定する場合，false positive の原因は受信 MTA (検証者) の管理者ではなく送信 MTA (署名者・ポリシ発行者) の管理者にあると考えます．

したがって，送信ドメイン認証の結果に基づくアクションをユーザに任せるか管理者が行うかは，ユーザからの苦情等対応のコストとユーザを保護することのバランスでも考えることができます．
その場合，管理者はユーザを保護することを捨ててでも苦情等対応のコストを優先すべきでしょうか?

また，これらの取り組みの本来の目的は「不正な送信者による Email にユーザが惑わされないようにする」ことだと思いますが，実際にやっていることは「信頼できる (のか ?) Email をユーザから信頼されやすいようにする」ことだけです．
これでは目的を達することができません．
この目的のために (技術的信頼性は置いておいて) 行うべきなのは，送信ドメイン認証に失敗した Email に「信頼できない可能性がある」と表示することではないでしょうか．

よって，私見としては，少なくともこれら二つのケースにおいて判定をユーザレベルに落とすのはユーザに責任を押し付けているにすぎず，冒頭の問題提起については「ナシ」だと考えます．

最後に，念の為書いておきますが，私個人は，受信者による送信ドメイン認証の実施は普及させるべきだと思っています．
しかし，当たり前のことながら，ほかのすべての技術と全く同じように，正しい使い方を考えて使わねば足元を掬われます．
技術者が本当に理解してその技術を使っているのか，本当に理解したときにその使い方が合理的であると言えるのか，という点については，毎日のように (自分のこととして) 考えさせられるところです．
