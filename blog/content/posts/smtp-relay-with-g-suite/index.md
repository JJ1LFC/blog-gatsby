---
title: "G Suite で SMTP Relay を使う"
slug: "smtp-relay-with-g-suite"
date: "2020-05-19"
tags:
  - "email"
  - "G suite"
---

G Suite で Google のメールサーバを使って自分のサーバなどからメールを送信するときの SMTP Relay の設定方法をよく忘れるので，メモ代わりに書いておきます．

## 確認すること

- 送信元の IP アドレス

## G Suite admin の設定

Admin console の[ここ](https://admin.google.com/AdminHome?subtab=filters&pli=1&fral=1#ServiceSettings/service=email&subtab=filters) (アプリ →G Suite→Gmail の設定 → 詳細設定) に行く．
`転送`の`SMTP リレーサービス`にマウスオーバーして右に現れる`追加`または`他にも追加`を選択．
必須事項を入力．
![](/assets/2005/g-suite.png)

- 説明を入力
- `許可する送信者`は`ドメイン内の登録済み Apps ユーザのみ`もしくは`ドメイン内のアドレスのみ`を選択．何も考えずにサーバで名乗るためには後者．
- `認証`は，固定 IP アドレスを持っているサーバであればなるべく狭いレンジで IP アドレスを`指定した IP アドレスからのみメールを受信する`に設定．可能であれば`SMTP 認証を求める`も選択 (後述)．
- `暗号化`は `TLS 暗号化を必須とする`を選択．

`設定を追加`を押して，画面下部の`保存`を押して反映させる．

## アプリパスワードの設定 (SMTP Auth)

上記で `SMTP 認証を求める`を選択しておくと，送信のたびに SMTP Auth が必須となる．しかし，Google アカウントには当然 2FA を設定しているのでパスワードだけでは認証できない．ということで，2FA をバイパスできるアプリパスワードを設定する．
[ここ](https://myaccount.google.com/apppasswords) (Google アカウント → セキュリティ → アプリパスワード)から設定する．
表示される 16 文字のアプリパスワードは再表示できないので，その場で設定を済ませる．
なお，SMTP Auth に使うユーザ名は，そのアプリパスワードを発行した Google アカウントのメールアドレスになる．GAS 関数で送るときとは違い，Gmail の設定をしなくても From は自由に書き換えられる．
