---
title: "Meraki MR シリーズで 2.4GHz Only の SSID を吹く"
slug: "meraki-24"
date: "2020-02-28"
tags:
  - "Wi-Fi"
  - "Network"
---

この記事執筆時点では，Cisco Meraki MR シリーズで 2.4GHz 帯のみを吹く設定ダッシュボード上に存在しません．が，ほぼほぼ裏技のような方法で 2.4GHz 帯のみの SSID を吹く方法を見つけたので紹介します．

## なぜ 2.4 Only を吹くか

2.4GHz 帯は Wi-Fi AP 管理者にとってしばしば悩みの種になります．5GHz 帯が普及してきた現在，管理者によっては 2.4GHz 帯をそもそも吹かないポリシーを持っている方もいらっしゃるのではないでしょうか．
その反面，近年普及してきている IoT 機器には 5GHz 帯に対応していない機器もあります．家庭で言えば Amazon Echo や Google home などのスマートスピーカーや，赤外線リモコンなどが挙げられます．

それらを使いたいが，一つの SSID で 5GHz 帯と 2.4GHz 帯の両方を吹いて 5GHz 帯の高速通信の邪魔になるようなことはしたくない，というときに使われる一つの手法として，「 5GHz 帯専用の SSID と 2.4GHz 帯専用の SSID を分ける」といったことがよく用いられます．家庭用の多くの所謂 Wi-Fi ルータはデフォルトで分けて吹くのが主流です．

## Meraki の現状

MR シリーズが Organization に追加されている状態で Meraki ダッシュボードの `Wireless`-`CONFIGURE`-`Access control` を開き，任意の SSID の `Wireless options`-`Band selection` を見ると，

```
- Dual band operation (2.4 GHz and 5 GHz)
- 5 GHz band only
  5 GHz has more capacity and less interference than 2.4 GHz, but legacy clients are not capable of using it.
  - Dual band operation with Band Steering
    Band Steering detects clients capable of 5 GHz operation and steers them to that frequency, while leaving 2.4 GHz available for legacy clients.
```

といったようなラジオボタンが表示されているかと思います．このままでは 2.4GHz 帯 / 5GHz 帯両方を吹く SSID や 5GHz 帯のみを吹く SSID は設定できますが， 2.4GHz 帯のみを吹く SSID は設定できません．また， RF Profile をいじってもそのような設定はできないようです．

このような状態だと，一部の 5GHz 帯非対応既製 IoT 機器では， 2.4GHz 帯と 5GHz 帯の両方を使う SSID に接続しようとするとうまく行かないことがあります．また，先述のとおり思うようにバンドプラン/フロアプランが構成できない場合もあるかと思います．

# 吹き方

ではどうするのかと言うと，**サポートセンターに裏オプションをお願いします**．と言っても無料です．
私はなるはやに設定を終わらせたかったので電話しましたが，多分メールなどでも対応してもらえると思います．

1. 連絡する前に， Meraki サポートのオペレータが裏から設定をいじれるようにする
   ダッシュボードの `Organization`-`CONFIGURE`-`Settings` の `Meraki Support Access`-`SupportAccess Level` が `Full access` になっていることを確認します．デフォルトでは `Full access` ですが，筆者は一応気にして通常は `Blocked` にしています．
2. カスタマー番号とサポートの電話番号/メールフォームを入手する．
   画面右上の `Help`-`Get help` から Meraki Support Center にアクセスし， `Still need help?` をクリックします．フォームで問い合わせたい場合は `Submit an email case` をクリックします．電話で問い合わせたい場合は `Call the Meraki Support Team` をクリックし `View regional phone numbers` から日本の番号を探してかけます．
3. (電話の場合)電話
   指定された番号にかけると，自動音声で画面にでている番号を打つよう指示されます．打つと人間のオペレータが対応してくれます．口頭で「 MR シリーズで 2.4GHz Only の設定をしたい」と告げると， Organization 名や MAC アドレスなどを聞かれた後，チケットを開くために自分の名前 (スペル) と電話番号 (国番号から) を聞かれ，切らずに数分待つとオペレータが作業してくれます．
   ちなみに，私は Japan の番号にかけましたが (深夜だったからかな?) **オペレータとの会話は英語でした**．
4. 設定する
   しばらく待つとオペレータに「終わったよ」と言われるので， `Wireless`-`CONFIGURE`-`Access control` を開き，任意の SSID の `Wireless options`-`Band selection` を見ると，ちゃんと 2.4GHz band only が追加されています．これを選択して保存すれば設定完了です．
   ![Meraki dashboard](/assets/2002/meraki.png)
   終わった後メールボックスを見てみるとちゃんとサポートチケットが切られていました．

ということで， Meraki MR シリーズでも 2.4GHz 帯のみの SSID が実は吹けるんだよという記事でした．
