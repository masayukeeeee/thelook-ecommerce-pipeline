# 今後の取り組み TODO

最終更新: 2026-05-09

## 0. このドキュメントの位置付け

`docs/data-modeling.md` がモデリング設計（What / Why）のドキュメントだとすれば、本ファイルは「次にやること（How / When / Done）」のロードマップ。Ubie アナリティクスエンジニア募集要項（`.docs/anen-description.md`）を仮想ターゲットに、学習プロジェクトとしての伸びしろを整理する。

想定読者は将来の自分。各 Stage の Done が満たせたら、対応する完了欄をチェックする。

## 1. 方針

- 学習目的を最優先（業務直結ではなく、業務でやらない領域こそ素振りする）
- すでに業務で経験がある領域は再実装しない
- 個人プロジェクトなので「too much な品質保護」は避ける
- ただし「将来 Ubie の業務で素振りしたい技術」は深く掘る
- ドキュメントの更新を怠らない（`docs/` こそポートフォリオの本体）

## 2. 対象外（やらないこと）

| 項目 | 理由 |
| --- | --- |
| BigQuery 対応 | 業務で日常的に使っているため、ポートフォリオで再演する価値が薄い |
| LookML / Looker | Lightdash の `meta` 経由メトリクス定義で代替する |
| GitHub Actions ベースの CI | 個人プロジェクトでは too much。pre-commit で代替 |

採否判断を明文化することで、面接で「なぜやらなかったか」を即答できる状態にしておく。

## 3. ロードマップ俯瞰

| Stage | テーマ | 募集要項対応 | 工数感 | 完了 |
| --- | --- | --- | --- | :-: |
| 0 | pre-commit 導入（補助） | OTHER ガードレール | 小 | ☐ |
| 1 | L3 ガバナンス強化（PII / contract / masking） | MUST セキュリティ・プライバシー | 中 | ☐ |
| 2 | dbt observability（elementary） | OTHER ガードレール | 中 | ☐ |
| 3 | Dagster 導入 | WANT Python・オーケストレーション | 中〜大 | ☐ |
| 4 | 生成 AI Skills 化 | MUST 生成 AI 活用 | 中 | ☐ |
| 5 | 公開・発信 | OTHER 情報発信 | 小〜中 | ☐ |

依存関係：

- `Stage 0 → Stage 1`：pre-commit に dbt-checkpoint 系 rule（`pii_class` 必須など）を後から追加する形で連動
- `Stage 1 → Stage 2`：observability 上に PII 区分を載せられるよう、先に meta を振る
- `Stage 2 → Stage 3`：dbt 側で品質観測が完結した状態で Dagster の asset check に統合する
- `Stage 3 → Stage 4`：Skills は dbt + Dagster の運用知識を前提に書くと体験が深い
- `Stage 5` は任意のタイミングでも着手可（面接が近いなら Stage 4 → 5 を先に出す選択もあり）

## 4. Stage 0. pre-commit 導入（補助）

### ゴール

手元コミット時の品質を機械的に保護する。CI を入れない代わりの最低ライン。

### 成果物

- `.pre-commit-config.yaml`（リポジトリ ルート）
- `dbt/pyproject.toml` の dev 依存に `pre-commit` を追加
- 初回 `pre-commit run --all-files` が通る状態
- `README.md` に pre-commit のインストール手順を追記

### 入れる Hook

| Hook | 対象 | 採否 |
| --- | --- | :-: |
| `pre-commit-hooks`: trailing-whitespace / end-of-file-fixer / check-merge-conflict / check-added-large-files / check-yaml | 全般 | ◯ |
| `sqlfluff-lint` | `dbt/thelook/**/*.sql`, `bi/lightdash/**/*.sql`（既存 `dbt/thelook/.sqlfluff` を `--config` で流用） | ◯ |
| `ruff-format` / `ruff-check --fix` | `data-source/**/*.py` | ◯ |
| `yamllint` | `dbt/thelook/**/*.yml`, `bi/lightdash/**/*.yml` | ◯ |
| `sqlfluff-fix` | - | ✗（jinja を巻き込んで壊すリスク） |
| `dbt parse` | - | ✗（pre-commit には重い、将来 pre-push に逃がす） |
| `dbt-checkpoint` | - | △（Stage 1 で同時導入） |

### Done

- すべての Hook が `--all-files` で通過する
- README にインストール手順がある
- 1 度コミットして `.git/hooks/pre-commit` が機能していることを確認

## 5. Stage 1. L3 ガバナンス強化（PII / contract / masking）

### ゴール

「ガバナンスを宣言できる dbt 基盤」になる。Mart に PII を入れない原則を機械的に強制し、ヘルステックの語彙で語れるようにする。

### なぜここから

- Stage 2 の observability で `meta.pii_class` を可視化したいので、先に meta を振る
- Stage 0 の pre-commit に dbt-checkpoint 系 rule を「後乗せ」する形にすると、ガバナンス ルールがリリース時点で機械チェックされる

### 成果物

- `docs/governance.md` を新設
  - PII 取り扱いポリシー（`none / low / high` の 3 段階）
  - Mart に PII を持ち込まない原則と例外プロセス
  - data contract の運用ルール（破壊的変更時の手順）
  - email を staging で落として `email_domain` のみ Mart に通す方針の明文化
- 全モデルの yml に `meta.pii_class` を付与
- Mart 層に `contract: enforced: true` を全モデル適用
- `dim_users_masked` のような masking view の例を 1 つ実装（DuckDB / MotherDuck で動くサンプル）
- Stage 0 の pre-commit に `dbt-checkpoint` を追加
  - `check-model-has-meta-keys`（`pii_class` を必須化）
  - `check-model-has-description`
  - `check-model-columns-have-desc`

### Done

- PR レビュー時に「PII high が Mart に入っていないか」が機械チェックできる
- `docs/governance.md` を見れば PII 例外プロセスが説明できる
- 試しに contract 違反を起こしたとき `dbt build` が error で止まることを確認
- `meta.pii_class` 抜けが pre-commit で error になる

## 6. Stage 2. dbt observability（elementary）

### ゴール

データ品質の事後検知と運用ダッシュボードを持つ。「品質を引いた事実」だけでなく「品質を観測している事実」を提示できる。

### 成果物

- `packages.yml` に `elementary-data` を追加
- elementary 用スキーマの分離（dev=DuckDB / prod=MotherDuck の両 target で動くこと）
- `_staging__sources.yml` に `freshness` 宣言
  - `generate-new-records` の頻度を前提に `warn_after` / `error_after` を設定
- anomaly test を 1〜2 本
  - 候補：`fct_orders` の日次件数 / `fct_pageviews` の日次件数
- `edr` CLI でレポート HTML を生成し、`docs/observability/` に格納
- `docs/observability.md` に観測指標の一覧と運用フローを書く

### Done

- `dbt build` の度に run results / test results が永続化される
- elementary レポートで anomaly が検知できる事例を 1 つ作る（generate-new-records を異常値で投入してみる）
- レポートに `meta.pii_class` のサマリが載っていることを確認（Stage 1 との連動）

## 7. Stage 3. Dagster 導入

### ゴール

dbt を「手元で `dbt build` を叩く」から「asset graph として継続稼働する基盤」に昇格させる。

### 成果物

- `data-infra/dagster/` 配下に Dagster プロジェクト
- `dagster-dbt` で `manifest.json` から asset graph を自動生成
- `data-source/generate-new-records/main.py` を Dagster の `@op` 化（毎時スケジュール）
- source freshness sensor を入れて Stage 2 の freshness 宣言と連動
- elementary の test 失敗を Dagster の asset check に伝播
- README に運用図（mermaid）を追加

### Done

- `dagster dev` を立ち上げると asset lineage が可視化できる
- 1 時間スケジュールで「raw 追加 → dbt build → freshness check」が自動で回る
- asset check が test 失敗を表示する
- 障害シナリオ 1 つを再現できる（例：raw を更新止めて freshness が error になる）

## 8. Stage 4. 生成 AI Skills 化（MUST 直撃）

### ゴール

Cursor Skills として 4 つのデータエンジニアリング向け Skill を実装し、`docs/data-modeling.md §7` と `docs/governance.md` を AI 用の仕様書に昇格させる。MUST「生成 AI 活用での業務効率化」直撃のポートフォリオにする。

### 成果物

- `.cursor/skills/` 配下に以下 4 つの `SKILL.md`
  - `dbt-yml-updator/SKILL.md`
  - `dbt-runner/SKILL.md`
  - `dbt-tester/SKILL.md`
  - `dbt-governance-reviewer/SKILL.md`
- 各 Skill の参照仕様として `docs/data-modeling.md §7` と `docs/governance.md` を共通化
- `docs/skills.md` に 4 Skill のスコープと使い方を記載

### Skill 仕様（概要）

| Skill | 起動タイミング | 入力 | 成果物 | 主に参照する仕様 |
| --- | --- | --- | --- | --- |
| **dbt-yml-updator** | `models/**/*.sql` を変更したとき | 変更 SQL の SELECT 列＋既存 yml | `_*__models.yml` の `columns:` 差分提案。description は §4.2 命名規約と §A 用語集に従う | data-modeling §4.2 / §A |
| **dbt-runner** | 自然言語指示（"fct_orders 周辺だけ rebuild して" 等） | チャット指示＋manifest | `dbt run -s +<model>+` / `dbt build -s state:modified+` 等の組み立て＆実行、依存の説明 | data-modeling §3 |
| **dbt-tester** | モデル新規追加・派生列追加時 | SQL の派生ロジック＋既存 yml | 不足テストの提案（`expression_is_true` / `relationships` / `accepted_values` / singular test）。テンプレ集を `tests/_templates/` に同梱 | data-modeling §7.10 / §7.11 / §7.7 |
| **dbt-governance-reviewer** | PR レビュー時 | 変更ファイル全体 | PII 流入 / contract 破壊 / `meta.pii_class` 抜け / Mart に raw 列が残っていないかのレビュー | governance.md |

### Done

- 各 Skill が独立して起動し、期待した提案を出す
- 自分の dbt 開発フローでこれらを 1 週間使い、1 つ以上の改善エピソードを得る（記事のネタにする）
- `docs/skills.md` を見ればスキルのスコープと使い方が初見でわかる

## 9. Stage 5. 公開・発信

### ゴール

ポートフォリオを面接で「リポジトリ URL を渡せば伝わる」状態にする。Ubie の発信文化との相性を示す。

### 成果物

- GitHub リポジトリを Public 化
- `README.md` の冒頭に「狙い」「学習対象」「あえてやらなかったこと」の 3 段落を追加
- 記事 1 本以上を公開
- 任意：LT または社内勉強会の登壇枠

### 記事候補

| 候補 | 主な題材 | 効き目 |
| --- | --- | --- |
| Inferred Member / Unknown Member を dbt + DuckDB で実装した話 | data-modeling §7.9 | Kimball 流の処方箋を素直に実装した経験談 |
| `expression_is_true` で派生フラグのレグレッションを止めた話（M8 事例） | data-modeling §7.10 | ガードレール設計のリアル |
| `days_in_stock` を `current_date` で計算してはいけない、3 つの理由 | data-modeling §7.1.1 | 再現性の重要性 |
| Lightdash の `meta` 経由で dbt yml をメトリクスの SSOT にする | meta + fct_weekly_user_growth | BI と dbt の SSOT 統合の実践 |
| Cursor Skills で dbt 運用に生成 AI を組み込む | Stage 4 の成果物 | MUST 直撃ネタ |

### Done

- リポジトリ URL を共有して、初見の人が 5 分で全体像を把握できる
- 記事を 1 本公開済み

## 10. 振り返り欄

各 Stage 完了時に追記する。

| Stage | 着手日 | 完了日 | 詰まった点 / トレードオフ | 面接で語る素材 |
| --- | --- | --- | --- | --- |
| 0 |  |  |  |  |
| 1 |  |  |  |  |
| 2 |  |  |  |  |
| 3 |  |  |  |  |
| 4 |  |  |  |  |
| 5 |  |  |  |  |

## 11. 参考

- 募集要項：`.docs/anen-description.md`（gitignore 済み）
- 想定面接質問リスト：`.docs/interview-questions.tsv`（gitignore 済み）
- モデリング設計：`docs/data-modeling.md`
