---
title: "dotfiles を GitHub で管理し始めてみた話"
slug: "dotfiles"
date: "2020-08-15"
tags:
  - "devenv"
---

※執筆時点の話なので，最新は GitHub のソースを読んでほしい．

## dotfiles とは

`~/` とか `~/.config/` とかに転がっている，ドットで始まる隠しファイルになっている設定ファイル群のふわっとした総称

## 経緯

新しいサーバを建てたときとか，いちいちほしいパッケージ入れたり vim や shell の設定をしていたけど大変面倒．
そんなとき某 Discord で dotfiles を git 管理するという文化を知りやってみたくなった．
どうせなら GitHub で公開して，更にはリバースプロキシで短いワンライナーでことが済むようにしようと思った．

## 従前のサーバセットアップ

アカウントや時刻設定などは手動．
研究室の web サーバに vimrc をおいてるので，たくさんファイル編集する必要があるならそれを curl していた．
shell は無加工 bash でも生きていけないことはないのでそれで生きていた．

## 結果

[ここ](https://github.com/JJ1LFC/dotfiles)にある．
Ubuntu 18.04LTS と 20.04LTS でしか動作検証してないけど，多分 debian でも動く．それ以外は知らない．
~~Google domains のリバースプロキシを設定したので，Google を信頼する限り~~サーバセットアップ後に root 権限で `curl -L https://oru.to/install | sudo bash` ってやれば全部終わる．
もしくはスタートアップスクリプトを設定できる VPS サービスやカスタム ISO なら，

```
!/bin/sh
curl -L https://oru.to/install | sudo bash
```

を実行するようにすれば良い．

## しくみ

oru.to/install は GitHub の dotfiles リポジトリ内の `/startup.sh` に転送される．
`/startup.sh` では

- apt の更新
- どこにいてもほしいパッケージの追加
- タイムゾーンの設定
- `alt` ユーザがいなければ掘る
- 最低限の ssh サーバのセキュリティ設定
- dotfiles 群のデプロイ (`/install.sh` の実行・シンボリックリンク)

をやっている．
ここで `alt` ユーザを掘った場合 (メッセージが出る)，`altユーザ`でログインしたときにパスワードの設定が求められる．

dotfiles で管理しているのは以下の設定

- zsh
- fish
- vim
- git
- ssh の authorized_keys

dotfiles を更新したときに間違って公開しちゃいけないファイルを公開しないようにするため，`/.gitignore` で必要なファイルだけ allowlisting しているが，とてもダサいので打開策がほしい．

## あわせてやったこと

vimrc は某氏からの貰い物を流用していたので，いるものいらないもの，追加したいものを洗い出して自分で書き直した．
手元ではいつも shell に fish を使っているが，サーバで POSIX 非準拠の shell を login shell とするのはいかがなものかというお気持ちがあったので，fish の設定を簡素化した zshrc を書いて zsh を採用することにした．正直お気持ちドリブンだし dotfiles に fish の設定も含めているので，fish 入れれば使える．

## これからやりたいこと

yubikey に ssh 秘密鍵を入れて，GPG agent で ssh できる設定に~~したい~~しました．確か多段 ssh するときに手元の GPG agent から認証させて〜みたいなことができたはずなので，それをやると秘密鍵は完全に yubikey (とオフラインのバックアップデバイス) の中に閉じ込めておくことができる．
zshrc はとりあえずという感じなので充実させたい．特にプロンプトがガバい．
デスクトップ環境向けにもうちょっと dotfiles で管理できることがあるはずなのでやる．
