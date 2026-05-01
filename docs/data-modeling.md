# TheLook eCommerce データモデリング設計

## 1. アーキテクチャ

本プロジェクトでは、dbtを利用して生データ（Raw）から分析用のスタースキーマ（Marts）への変換を行う。
データ構造は Fact / Dimension に分割してモデリングする。

## 2. テーブル分類

### Dimension

主に「誰が・何を・どこで」を表すマスター。

* **`dim_users`**: 顧客の属性情報（生データ: `users.csv`）
* **`dim_products`**: 商品のカタログ情報（生データ: `products.csv`）
* **`dim_distribution_centers`**: 物流センターの情報（生データ: `distribution_centers.csv`）

### Fact（ファクト→トランザクション）

イベント種類、注文の集計、注文詳細を表す時系列データ。

* **`fct_orders`**: 注文単位のサマリデータ（生データ: `orders.csv`）
* **`fct_order_items`**: 注文内の明細（商品）単位のデータ。売上分析の最小単位（生データ: `order_items.csv`, `inventory_items.csv`）
* **`fct_events`**: ユーザーのWebサイト上での行動ログ（生データ: `events.csv`）

---

## 3. レイヤー構成

本プロジェクトでは dbt の標準的な3層構成を採用する。

| レイヤー | ディレクトリ | 役割 | マテリアライゼーション |
| --- | --- | --- | --- |
| Source | （`_staging__sources.yml` で参照） | raw CSV を dbt の source として宣言する層 | - |
| Staging | `models/staging/` | 1 raw テーブル ⇄ 1 stg モデルで、軽微なクレンジングのみ行う | view |
| Mart | `models/marts/` | dim / fct に再構成し、分析に直接使える形にする | table |

後述の ER 図はあくまで Mart 層の論理モデルであり、Staging 層は raw を扱いやすく整えただけの中間層と位置づける。

---

## 4. Staging 層の方針

Staging 層は raw と原則 1:1 という関係にする。

### 4.1 責務（やること / やらないこと）

#### やること

* カラムのリネーム（`id` → `<entity>_id` など、Mart 層と整合する命名へ）
* 型のキャスト（特にタイムスタンプ）
* 軽微なクレンジング（trim、表記ゆれ正規化、明らかな NULL 補完）
* 重複排除（自然キー単位で最新行を残す）
* 分析に不要な列のドロップ（PII・冗長列など）

#### やらないこと

* テーブル間の JOIN（→ Mart 層）
* 集計・サマリ作成（→ Mart 層）
* ビジネスロジック・KPI 計算（→ Mart 層）

### 4.2 命名規約

* モデル名: `stg_<table>`（raw テーブル名と 1:1 対応）
* 主キー: `id` → `<entity>_id` にリネーム（例: `users.id` → `user_id`）
* タイムスタンプ列: `_at` サフィックスを付ける（例: `created_at`）

### 4.5 テスト方針（`_staging__models.yml`）

最低限、各 stg モデルの主キーに以下の dbt test を付与する。

* `unique`
* `not_null`

加えて、自然キー（例: `users.email`）にも `unique` を付与する。
同一メールアドレスで登録しているユーザーは最新のアカウントを優先する。
この処理については議論の余地あり。

---

## 5. Mart 層の ER 図

以下の図は、Marts層におけるスタースキーマの論理リレーションをまとめた図。
dbtを用いて、このモデルに従ってデータを変換したうえで、BIツールでダッシュボードを構築する。

```mermaid
erDiagram
    %% Dimensions
    dim_users ||--o{ fct_orders : "1:N (発注)"
    dim_users ||--o{ fct_events : "1:N (行動)"
    
    dim_products ||--o{ fct_order_items : "1:N (購買)"
    dim_products }o--|| dim_distribution_centers : "N:1 (保管)"

    %% Facts (中心となるトランザクション)
    fct_orders ||--o{ fct_order_items : "1:N (明細)"

    dim_users {
        int user_id PK "ユーザーID"
        string email "メールアドレス"
        string country "国"
    }

    dim_products {
        int product_id PK "商品ID"
        string name "商品名"
        string category "カテゴリ"
        int distribution_center_id FK "センターID"
    }

    dim_distribution_centers {
        int distribution_center_id PK "センターID"
        string name "センター名"
    }

    fct_orders {
        int order_id PK "注文ID"
        int user_id FK "ユーザーID"
        string status "ステータス"
        timestamp created_at "注文日時"
    }

    fct_order_items {
        int order_item_id PK "明細ID"
        int order_id FK "注文ID"
        int product_id FK "商品ID"
        float sale_price "販売価格"
    }
    
    fct_events {
        int event_id PK "イベントID"
        int user_id FK "ユーザーID"
        string event_type "イベント種別"
        timestamp created_at "発生日時"
    }
