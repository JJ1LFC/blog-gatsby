---
title: "GPG 鍵の使い方"
slug: "gpg"
date: "2020-05-23"
tags:
  - "Security"
  - "GPG"
---

たまにしか使わないからよく忘れる．
自分が使うものだけを書いたので，これ以外にもいろんな機能はあるしやり方もこれだけじゃない．

## 前提

- GnuPG でのコマンドライン操作．
- 各コマンドで出力する鍵や暗号はバイナリになる．ASCII で出力するときは `-a`(`--armor`) オプションをつける．
- 他者の公開鍵は対面での指紋確認など何らかの方法で信頼できるものとする．
- ファイルが出力される系はたいてい `-o {path_to_new_file}` で出力先とファイル名を指定できる．

# 公開鍵をいじる

## 公開鍵のインポート

```shell
gpg --import {path_to_pub_key}
```

表示される鍵指紋で真正性を確認する

## 公開鍵のエクスポート

```shell
gpg --export {name}
```

## インポート済み公開鍵の確認

```shell
gpg -k {query}
```

`{query}` を抜くとすべて表示される

## 公開鍵の鍵サーバへの送信

```shell
gpg --keyserver {server_FQDN} --send-keys {fingerprint}
```

## 公開鍵の鍵サーバからの取得

```shell
gpg --keyserver {server_FQDN} --recv-keys {fingerprint}
```

指紋は当人から信頼できる方法で取り寄せよう

## 公開鍵に署名する

署名するときは必ず鍵の真正性を確認する

```shell
gpg --sign-key {name}
```

署名していることを公にしない場合は以下を使う

```shell
gpg --lsign-key {name}
```

# 秘密鍵をいじる

## 秘密鍵のインポート

```shell
gpg --import {path_to_sec_key}
```

公開鍵と同じコマンド

## 秘密鍵をエクスポートする

```shell
gpg --export-secret-keys {name}
```

## インポート済み秘密鍵の確認

```shell
gpg -K {name}
```

`{user_id}`を抜くとすべて表示される

## パスワードの変更

```shell
gpg --passwd {name}
```

# ファイル操作

## ファイルの暗号化

```shell
gpg -e -r {recipient_name} {path_to_file}
```

バイナリは `.gpg`，ASCII は `.asc` で出てくる．`-o {file_name}` で出力されるファイル名を変えることもできる．

## ファイルの復号

```shell
gpg -d {path_to_file}
```

## ファイルの署名 (別ファイル)

```shell
gpg -b {path_to_file}
```

## ファイルの署名 (同一ファイルに埋め込み)

```shell
gpg -s {path_to_file}
```

## ファイルの署名と暗号化

```shell
gpg -r {recipirnt_name} -se {path_to_file}
```

## 署名の検証

```shell
gpg -d {path_to_file}
```

復号と同じコマンドで署名もしくは署名が含まれたファイルを読み込ませる．
