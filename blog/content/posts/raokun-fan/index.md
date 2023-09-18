---
title: "推しのファンサイトを作ってみた"
slug: "raokun-fan"
date: "2023-02-19"
tags:
  - "Web"
---

久方ぶりの投稿ですが，今回は推しのファンサイトを作ってみたのでその話を書きます．

# 先に軽くまとめ

使った技術スタック: Gatsby.js (React.js), Tailwind CSS, Docker, Cloudflare Pages, Cloudflare Access

できたもの: [raokun.fan](https://raokun.fan/)

パッケージ等 (package.json コピペ)

```json
{
  "name": "raokun-fan",
  "private": true,
  "description": "Gatsby files and docker dev environment for raokun.fan",
  "version": "1.0.0",
  "author": "Wataru Ohgai <alt@jj1lfc.dev>",
  "dependencies": {
    "@fontsource/sawarabi-gothic": "^4.5.9",
    "@fontsource/train-one": "^4.5.10",
    "autoprefixer": "^10.4.7",
    "d": "^1.0.1",
    "gatsby": "^4.24.4",
    "gatsby-plugin-image": "^2.24.0",
    "gatsby-plugin-manifest": "^4.24.0",
    "gatsby-plugin-nprogress": "^4.25.0",
    "gatsby-plugin-offline": "^5.24.0",
    "gatsby-plugin-postcss": "^5.24.0",
    "gatsby-plugin-purgecss": "^6.1.2",
    "gatsby-plugin-sharp": "^4.24.0",
    "gatsby-plugin-sitemap": "^5.25.0",
    "gatsby-remark-classes": "^1.0.2",
    "gatsby-source-filesystem": "^4.24.0",
    "gatsby-transformer-json": "^4.25.0",
    "gatsby-transformer-remark": "^5.25.1",
    "gatsby-transformer-sharp": "^4.24.0",
    "postcss": "^8.4.14",
    "prop-types": "^15.7.2",
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-responsive-carousel": "^3.2.23",
    "react-reveal": "^1.2.2"
  },
  "devDependencies": {
    "prettier": "^2.8.4",
    "tailwindcss": "^3.2.6"
  },
  "tags": ["gatsby"],
  "license": "MIT",
  "scripts": {
    "build": "gatsby build",
    "develop": "gatsby develop",
    "format": "prettier --write \"**/*.{js,jsx,json,md}\"",
    "start": "npm run develop",
    "serve": "gatsby serve",
    "clean": "gatsby clean",
    "test": "echo \"Write tests! -> https://gatsby.dev/unit-testing\" && exit 1"
  },
  "repository": {
    "type": "git",
    "url": "https://github.com/JJ1LFC/raokun-fan"
  },
  "bugs": {
    "url": "https://github.com/JJ1LFC/raokun-fan/issues"
  }
}
```

なお，もろもろの事情で git レポジトリは private です．

# 初めてできたこと

- フロントのフレームワーク (React, Gatsby) を使う
- 自分でデザインを考えてスタイルを当てる
- CF Pages を使う
- CF Access を使う
  - 公開前には公開用ホスト名と開発用ホスト名へのアクセス，公開後には開発用ホスト名へのアクセスに制限をかけています

# 仕掛けの簡単な解説

## 全体

- Gatsby のデフォルト starter から作っていますが，ほとんどのコンポーネントや配置等は自作です．たまによそから持ってきたものもあります．デザイン詳しい人から見ると統一感がなく見えるかもしれません．背景は [https://fffuel.co](https://fffuel.co/) で生成しました．
- Gatsby なので，ページ内リンクに限り viewport に入ったものは low-priority で prefetch し，カーソルが乗ったら priority をあげて prefetch しています．そのため，ページ内の移動は高速 (だと思いたい) です．
- react-reveal を使って，ほとんどの要素がふわっと浮き出るようになっています．けどちょっと微妙ので今後やめたり調整したりするかもしれません．
- レスポンシブ対応しています．Tailwind CSS 様々．
- PWA 対応しています．折角 PWA にしているので，一度 PWA で閲覧すると (らおくんの話題各記事ページ以外は) オフラインでも閲覧できるようになっています．推しがアプリになったみたいで楽しいのでリスナーさんは是非 PWA 使ってください．詳細は [about](https://raokun.fan/about) に書いています．

## トップページ

react-responsive-carousel を使って表示する立ち絵を数秒おきに変えています．フリックすると動きます．

## 歌動画一覧

後述しますが，データソースとなる json があり，ビルド時にそれを GraphQL で引いてきて map でカードコンポーネントをたくさん並べています．

カード左の YouTube アイコンもしくはニコニコアイコンを押すとそれぞれのサイトが別タブで開き動画を見ることができます．この UI 分かりづらいようだったら今後もう少し変えます．

## らおくんの話題

ここはブログに似た形式で今後もコンテンツを積極的に追加していきたいところです．新しいページをたくさん作ることが予想されるので，この中身は Markdown でかけるようにしています．特定のディレクトリに Markdown をおいておくと，ビルド時に gatsby-transformer-remark が HTML に変換し，Gatsby の createPage API で各ページを作成します．一覧ページはビルド時に存在するページを日付順に GraphQL で引いてきて生成しています．

# 楽しかったところ

## 推しのことを自由に表現できる

男性歌い手の男性ファン，というのはなかなかレアな生き物で，周りにそれ関係の友だちもいませんし，逆にリスナー界隈でも人によっては気持ち悪がったり「本当は推しのこと好きじゃないのに推しに集まる女の子を目当てに接触しに行く」タイプの人と勘違いされないかなということで，結構ぼっちです．そんな状況で自分が推しのためにできることとして一つ動かせたのはとても嬉しいです．

## フロントたのちい

フロントはデザインも含めてからっきし分からない人間ですが，少なくとも Gatsby.js みたいな SSG と Tailwind CSS みたいな直感的なフレームワークを使っていると，書いたコードがばこばこ Web に現れていってそれがどんどん変化していって，Web 楽しいなぁ (小並感) という感じです．

# 突っかかったところ・難しかったところ

## 使用素材のライセンス関係

僕の推しは個人で活動しており事務所等に所属していません．なので，イラスト等の厳密な利用申請のルートがありませんでした．結果として，推しの配信内で「ファンサイトを作ること」「掲載内容の予定」について伝えて，それに対する口頭での許可を取りました．細かい点は言ってしまえばグレーなのですが，NG な素材を使ってしまったり内容を掲載してしまったときにすぐ対処できるよう，それ用の Google Forms を整備しました．

また，動画サイトなどのアイコンを使っているのですが，特に YouTube のブランドルールが厳しいうえに申告制になっており，一度の審査に数週間かかります．デザインの知識もまともにない中作ったモックを跳ねられて再提出を求められたこともありました．結果として OK をもらってアイコンを使用しています．

推しを応援するためのサイトなのに，非公式なこのサイトがここら辺でしくってしまって本人にも飛び火したら元も子もないですからね．

## CF Pages のビルド環境が古い

Gatsby.js の最新バージョン 5 系では node.js 18 以上に依存していますが，CF Pages のビルド環境は node 17 までしか対応していません．この点は [GH](https://github.com/cloudflare/pages-build-image/discussions/1#) でも話題に上がっています．諦めて GH Actions でビルドしてから wrangler で CF Pages に持って行っている人もいるようです．悩みましたが，面倒くさいのでとりあえず今は node.js 16 上で Gatsby 4 系を使用しています．なのでいろいろ依存性が古いです．node16 ももう EOL なのではやく 18 のビルドイメージをください．

## 過去の歌動画のデータ化

[https://raokun.fan/songs](https://raokun.fan/songs) ではこれまでにアップされた歌動画を全てリストアップしているんですが，中身の仕掛けとしては全部のデータを集めた json があり，Gatsby がビルド時に GraphQL でそのデータをとってきて曲のカードのコンポーネントを生成し，それを並べています．下に json の例 (最新曲の「メルト」) を示します．

```json
[
  {
    "title": "メルト",
    "link": "https://youtu.be/zggVBmG4q0Y",
    "original": "ryo",
    "platform": "YouTube",
    "singer": "らお",
    "style": "グループ",
    "date": "2023/02/12"
  },
  ...
]
```

で，この json なのですが，手作業で全部打ちました．推しは以前名前を変更していたり，メインの場所をニコニコから YouTube に移していたり，他のチャンネルの動画にコラボとしてアップされているものもあったり，そもそも動画のタイトルや概要欄などのフォーマットも全ては統一されていないため，API でガッととってきて文字列を切って．．．みたいなことができませんでした．推しの過去を振り返る意味も込めて全曲を聴きながら探して手で json 化しました．すごい疲れたけど楽しかったです．なお，これからも新しい歌みた動画が出る度に手で追記することになります．．．

## デザイン分からん

わからん．感性も実装力もない．

## CSS 完全に理解した

CSS 完全に理解した．

---

最後に，アドバイスをくれたり実装が分からないところを教えてくれたりした抹茶鯖の皆様と友人に感謝申し上げます．

ということで，何かあれば[お問い合わせ](https://forms.gle/iZ1N9aSNmK6fbFMK7)よりフィードバックいただければと思います．
