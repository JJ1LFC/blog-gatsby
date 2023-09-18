---
title: "firefox のアドレスバー検索で DuckDuckGo POST 検索を使う"
slug: "ddg-post-firefox"
date: "2020-08-20"
tags:
  - "Web"
  - "privacy"
---

最近 Google 検索が使いこなせなくなってきたのでサーチエンジンを DuckDuckGo に変えました．
DuckDuckGo はプライバシーへの配慮が大きいサーチエンジンで，サーチクエリを外から覗かれるのを防ぐため，[HTTP POST で検索](https://duckduckgo.com/settings#privacy)することができます ．

しかし，firefox の検索エンジン設定でデフォルトを DuckDuckGo にしただけでは，アドレスバーや検索バーから検索した時は GET での検索になります．
本稿では firefox の add-on を使って，アドレスバーからでも POST で検索できるようにします．

## add-on をいれる

まずは add-on を使い，POST が投げられる検索設定を作成します．
なんでも良いと思うんですが，今回は[これ](https://addons.mozilla.org/en-US/firefox/addon/add-custom-search-engine/)を使用しました．サードパーティですが，執筆時点で 4,561 ユーザが使用しているらしいです．

信頼できるかどうかはご自身でご判断ください．

## DuckDuckGo のクエリパラメータを調べる

設定を自分で作るので，どのようにクエリを送っているのかを調べる必要があります．
`duckduckgo.com` を開き，開発者ツールから Network を表示した状態で `test` など適当な文字列を調べます．
(この時点で [duckduckgo 側の設定](https://duckduckgo.com/settings#privacy)では POST にしてあるものとします．)

![](/assets/2008/ddg-post-firefox.png)

一件 POST リクエストが見えるので，詳細を見てみると，`q=test` というペイロードが見えますので，このような形でクエリすれば良いことがわかります．
なお，他のペイロードが載っていることがありますが，なくても動いたので作成する設定では除外して問題ないでしょう．
多分これをやりたい人は余計なデータはなるべく送りたくない人だと思うので．

## add-on の設定をする

先程入れた add-on の設定を開くと，設定作成画面が現れます．
上記で調べたことを元に，下記のとおり入力します．

| 項目       | 値                                               |
| ---------- | ------------------------------------------------ |
| Name       | 適当 (`DuckDuckGo-POST` など)                    |
| Search URL | `https://duckduckgo.com`                         |
| Icon       | 適当 (`https://duckduckgo.com/favicon.ico` など) |

ここまで来たら `Show advanced options` にチェックを入れます．

| 項目                                 | 値                             |
| ------------------------------------ | ------------------------------ |
| Use POST query parameters (Optional) | チェックして `q={searchTerms}` |

これで `Add custom search engine` ボタンを押します．
アドレスバーのあたりで別の add ボタンを押すよう指示されるので，押します．

## デフォルトの設定を変更する

最後に，firefox デフォルトの検索エンジンを設定します．
設定画面 (`about:preferences#search`) の Default Search Engine を先ほど作成した検索エンジン設定にします．

これで，firefox でいきなりアドレスバーに検索ワードを打って検索しても DuckDuckGo に POST でクエリされるようになりました．
