---
title: '2024 年度を振り返る & STPR に思うこと'
slug: 'fy24'
date: '2025-03-30'
tags:
  - 'The Internet'
  - 'JPNIC'
  - 'devenv'
  - 'diary'
banner: ./../../../../static/250330-banner.jpg
---

就職してから全然ブログを更新してませんでした．
社会人になるというのは，思ったよりも忙しくなるものですね．
23 年度は実質的なニートだったので，その状態と比較するとより忙しさを大きく感じます．
ということで，今年度を仕事・私生活等総括的に振り返ってみたいと思います．

## 仕事

以前の記事にも書いたとおり，今年度から一般社団法人日本ネットワークインフォメーションセンター (JPNIC) に勤務しています．
職種としてはエンジニア (専門職) ではなく総合職? 配属としては

- (主務) 事務局インターネット推進部基盤企画担当
- (兼務) 事務局技術部

となっています．
とはいえ，そもそも「JPNIC とはそもそも具体的に何をやっているところなのか」というのが，業界でもそこまで深く知れ渡っているわけでもないこともあり，「結局なんの仕事してるの?」と聞かれることも多いです．
まず「JPNIC が全体的にわからん」という方は，ちょうど先日，[ご紹介動画](https://youtu.be/GlRLRqGJ6RM)を広報担当の方が作成してくださいましたので，ぜひご覧ください．
僕自身も「何してるんでしょうねぇ〜」と答えることが多いですが，これは誤魔化しているのではなく単純に業務範囲が広いので一言で説明する方法をまだ思いついていないだけです．

一応，公開できる範囲で「結局お前は何やってんねん」ということを箇条書きでまとめておきます．
主務としての立場なのか，兼務としての立場なのかは正直書類や予算の話でしかないので，あまり意識しないことが多いです．

- (**政策・IG**) **ICANN** を主とした**技術政策情報**を集約・分析し，日本語のブログ媒体や各種報告会等イベントにて周知する
  - 場合によっては，その情報を発信する会議主体に入り込んで意見を出したりもします
  - 派生して? **IGF** 周りでも同様のことを行っています
  - このあたりは，入社前からアルバイトという形で関わり続けているものです
- (**カンファレンスネットワーク**) JPNIC が事務局となり毎年行っている Internet Week というイベントで，ボランティアを含めた **NOC を計画・立案・主導**し，カンファレンスネットワーク提供を行う
- (**技術セミナー**) JPNIC が年 2 回行っている技術セミナーにおいて，**「DNS 基礎」の講座立案・実際のレクチャー**を行う
- (**JP DNS 運用**) 日本の ccTLD である .jp のセカンダリ権威サーバ **b.dns.jp の運用や更改**を行う
- (**認証システム更改**) 主にレジストリシステムで使用されている**ユーザ認証基盤を一新し，導入・運用自動化**などを行う
- (**RPKI 運用**) 日本のインターネットレジストリ (NIR) として，管理している IP アドレス・Prefix に対する **RPKI システムの運用・更改**
  - 要するに，PKI の要素でいう CA 業務
- (**R&D**) 主に **RPKI や DMARC** といったネットワークセキュリティ技術に関して，**調査・研究・開発・アウトリーチ**を行う
  - **IETF** における標準化動向の調査や議論への参加
  - JPNIC の**テストベッド環境 (AS131971) の構築運用**
  - DNSSEC や DMARC **ハンズオン勉強会の環境構築や講師**
- (**アウトリーチ**) 各業務で得られた公開可能な情報を整理し，必要な場所に出向いてプレゼンテーションや文書にて，**読者・聴衆のこれからのネットワーク運用に資する情報を提供**する
  - 国内では **JANOG や IETF/ICANN 報告会，wakamonog** など
  - 国外では **ICANN, IGF や IETF** など
- (**その他技術オペレーション自動化・改修**) 上記認証システムを皮切りに，自分の担当業務外のシステムを含めて，**devops 的な開発・運用の定義・実装**を行っています

こんな感じでしょうか，抜けていたらすみません．
平時から行っているものであったり，ある定期会合を軸に行うもの，中長期的な計画に基づいて行うものなど様々ありますが，今度は時系列に主要なものを少し深堀りしてみます．

### 4 月

就職しました．
貸与 PC は Windows だったのですが，僕には Windows は難しくてわからないので，色々理由をつけて ThinkPad P14s AMD Gen4 を買って Linux をセットアップして使っています．
4 月以降に変更したところもありますが，今業務用 PC で使用している環境を簡単に挙げると

- ハードウェア: Lenovo ThinkPad P14s AMD Gen4
  - CPU AMD Ryzen 7 Pro 7840U, メモリ 32GB, SSD 128GB
- OS: Ubuntu 24.04.2 LTS
  - 購入時点でこの機種は [22.04 LTS の Ubuntu Certified](https://ubuntu.com/certified/202309-32036) 製品でした
  - ブートローダに署名して UEFI の TA に登録し Secure boot を設定し，LUKS でディスク暗号化しています
- ターミナル: Ghostty + tmux + zsh
- メール: aerc (TUI)
- ブラウザ: Floorp
- エディタ: 基本はカスタマイズした Vim，一定ちゃんとした開発のときは VSCode

という感じです．

### 7 月

正規職員としては初めての JANOG に参加してきました．
多分正規職員としては初めての出張．
今後も情報収集やユーザ・関係者の皆様との交流を目的に，JANOG はなるべく毎回現地参加できるようにするつもりです．

それから，R&D 関連でハンズオン勉強会を始めたのもこの時期でした．
昨年度まで使用していた環境を壊して作り直した記憶があります．
内容も少しアップデートしました．

### 8 月

技術セミナー．
なぜか「DNS 基礎」を担当することになりました．
過去の資料もありましたが，一応新しく作り直し，内容もアップデートしているつもりです．

### 9 月

構想としては 6 月くらいから練っていた気がしますが，Internet Week でのカンファレンスネットワーク「IWNOC24」を企画し，[メンバの公募を開始](https://www.nic.ad.jp/ja/topics/2024/20240910-02.html) しました．
IW ではどうやら 2019 年まで技術部の職員や有志で NOC をやっていたようなのですが，2020 年からコロナ禍の影響で IW 自体が完全オンラインに移行．
その後ハイブリッド化しましたが，NOC を担当していた職員がいなくなってしまっており，実質的にゼロから再出発することになりました．

### 11 月

IW 本番．PC や事務局職員としても関わりつつ，NOC 長としてネットワーク運用を主に担当しました．
結果的にはカンファレンスネットワークとしてはまれに見る安定運用を達成できました．
今後も継続的に開催できればと思うので，NOC に関わりたい方は学生・社会人関係なく JPNIC からのお知らせにご注目ください．
できることなら来年度は，もっと早く始動したいと思っているので，メンバ募集も 9 月より早く出すかもしれません．

### 12 月

現地にはいけませんでしたが，[IGF2024 にオンラインで登壇](https://intgovforum.org/en/content/igf-2024-ws-198-advancing-iot-security-quantum-encryption-rpki)しました．
Japan IGF においても海外の友人らを招いて事前セッションを行いましたが，そこでの反省等を活かして，技術者の観点からセキュアな未来のインターネットに向けて議論を行うことができました．

また，平行して，このあたりの時期からひっそりと R&D の一環である RPKI ROV チェックサイト「[rov-check](https://rov-check.nic.ad.jp)」を作成・公開し始めました．
Web サイトとしての開発だけでなく，rov-check 等の検証環境が動いているネットワークは物理サーバや AS レベルで構築しています．

### 1 月

JANOG 京都．
なんかここ 2 年くらいかなり頻繁に京都に行っている気がします．

### 2 月

IETF 等標準化人材育成に向けた国内活動の一環として，初の試みである[ハッカソン](https://jpnic.connpass.com/event/343083/)をハイブリッドで開催しました．
標準化というととてもハードルが高く思えますし，実際に IETF に参加するとしてもメーリスを追い独りで海外に行って提案するというのは実際そう簡単ではありませんが，少しでも身近に感じて手を伸ばすきっかけを作れればという企画です．
IWNOC の方は僕自身よその NOC メンバや NOC 長としての経験が多少ありましたが，ハッカソン運営は初めてのことでした．
至らぬ点も多かったかもしれませんが，皆さんから好意的なフィードバックをいただき，次回以降の企画にも前向きに取り組みたいと思っています．

### 3 月

R&D 関連の報告書など大詰めの時期でしたが，IETF122 に現地参加してきました．
実は独りで海外に行くのは初めてで，就職して海外出張に行くのも初めてでしたが，日本コミュニティの皆さんに支えられてなんとか生きて帰ってきました．
カオマンガイうまかった．
帰国して 1 週間後には隣国ミャンマーの大地震で，現地バンコクでも超周期地震動による被害が大きく出たとのことで驚き心を痛めています．

また，就職後通して参加していた ICANN RSSAC Caucus の Guidelines for Changing IP Addresses WP という，DNS ルートサーバの IP アドレスを変更する際のガイドラインを作成する活動が終了し，[RSSAC061 Guidelines for Changing IP Addresses](https://itp.cdn.icann.org/en/files/root-server-system-advisory-committee-rssac-publications/rssac-061-en-27-03-2025-en.pdf) として成果物が公開されました．
DNS ルートサーバに限らず，インターネットにおける重要インフラの移転で参考にできる技術文書になっており，また RIR からの IP アドレス割り当てポリシなどにも関わってくる多分野総合のガイドラインとなっているので，今後日本国内向けに日本語で解説を予定しています．

## 私生活

なーんか，あまり私生活と呼べるほどの人間らしい生活を送っていた気がしません．
プライベートのカレンダーをみながら箇条書きしてみます．

### 4・5 月

実家の祖母が救急車で運ばれ，一時は持ち直しましたが，2 週間ほどで亡くなってしまいました．
この関係で 1 ヶ月ほど関東と実家を往復する生活をしていた気がします．

### 7 月

無期限活動中止をしていた推しが，業界トップと言って差し支えない事務所である STPR から [STPR BOYS](https://boys.stpr.com) として復帰しました．
目が飛び出ました．
ファンサイトも，もう更新することはないんだろうなと思っていましたが，慌てて全面修正しました．

### 8 月

推しが活動休止していた分として 9 日間連続でフルサイズの「歌ってみた」を 9 曲公開．
全部聴いて解釈するのに数ヶ月かかりました．

### 12・1 月

久しぶりに帰省して年を越しました．
今年は帰省が多かったです．

### 2 月

STPR BOYS として，あくまで事務所所属前という形で活動していた推しが，正式な STPR 所属 5 つめの 2.5 次元アイドルグループ「SneakerStep」メンバとしてデビューすることが公表されました．
目が飛び出ました．

### 3 月

そしてそのデビューは，4/2 から東京ドーム等で開催される [STPR Family Festival](https://fes.stpr.com/2025) にて，デビュー曲「[SneakerStep](https://youtu.be/cEuyhcbwGgM)」で行われることが発表されました．
大変嬉しいのですが，大変困惑しました．

## STPR に思うこと

この流れで二つ目のタイトルである「STPR に思うこと」に入ります．

STPR を箱推ししている既存のユーザはまあ，もともとすとふぇすに行く予定があったから困らないと思います．
困るのは僕のような，STPR とか正直何も分からんけどとにかくらおくんを推していた人間です．
これまでライブといえば数百人規模の箱で，3 ヶ月前には告知されるというのが普通だと思って暮らしていたら「**10 日後に東京ドーム**でライブするから．**先着の通常席は全部売り切れてる**けど機材席は少し余ってるから買ってね」と言われたわけです．

**いやあ STPR さん，いくらなんでも乱暴じゃないですかねぇ? 私は有給もある関東の社会人なのでいいとして，地方の高校生とかどうするんです?**

推しはこれまで地方や年齢，経済的なところもかなり配慮してライブや物販をしていた，むしろ配慮をするあまり何もできないことすらあったと感じていますが，大手の「洗礼」を受けた気がします．

前から言っていますが，**僕は事務所業というのを大変忌み嫌っております**．
が，推しが事務所に所属したこと自体はいちファンとして何か言うことでもないですし，推しが好きなのはこれからも変わりません．
また，僕の運営するファンサイトは，僕の気持ちを書くために運営しているわけではなく，らおくんの情報を少しでも整理公開して，好きになってくれる人・聴いてくれる人・知ってくれる人を増やすために運営しています．
今後事務所がどんな無茶を言おうとも僕は**ファンサイトに一言も苦言を書かない**でしょう．

**だからこそ**，消費者の声をきこうとせず，自分たちが用意したパッケージをアーティストと消費者の両方に，有無を言わさず押しつける事務所業というのが心の底から嫌いなわけです．
**敬愛している推しがこれから一蓮托生する集団として，不安を覚えると言わざるをえません**．
株式公開を行ってファンが事務所の所有権を持てるようにした某 V 事務所がとても羨ましいです．

多少ファンの間で話題になっているようですが，東京ドームでデビュー，つまりグループとしての**初めてのライブが東京ドームである**ということの**良いことも悪いことも我々に押しつけられた**ものであり，我々は**黙ってそれを買うしかない**のです．

ぐちぐち言っていても仕方がないし，STPR の経営に反映されることも全くないと思うので，推しのこれまでの経験や技量を認めて東京ドームというふさわしい舞台を用意してくれたことには感謝しましょう．
我々は**決してその場所に役不足な彼らではない**と既に知っているはずです．

ということで，ここら辺で筆を置きたいと思います．

ちなみに，今年度 (つまり活動復帰後の 9 ヶ月) に推しが公開したフルサイズの「歌ってみた」やオリジナル楽曲動画 (TikTok のアカペラワンコーラスなどを除く) は以下の通りでした．

- 単独: 13 本
- コラボ: 8 本(STPR BOYS 内で名前のついていないグループ分け等を含む)
- グループ: 6 本 (STPR BOYS 内で名前のついていた期間限定グループ等を含む)
- 合計: **27 本**

均すと**月 3 本**ペースになります．
気になる方はぜひファンサイト「raokun.fan」の[歌動画一覧](https://raokun.fan/songs) をご覧ください．
これからも変わらず応援を続けます．
