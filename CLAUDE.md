# Korekiteプロジェクト情報

## プロジェクト概要
Korekiteはクローゼットの服を管理するiOSアプリケーションです。ユーザーは服の登録、編集、削除や、カテゴリー管理、着用履歴の記録ができます。

## 開発環境
- 対象OS: iOS 18.5以上（最新バージョンに追従）
- 開発ツール: Xcode 16.4以上（最新バージョンに追従）
- 対応デバイス: iPhone, iPad (TARGETED_DEVICE_FAMILY = "1,2")
- 使用フレームワーク: SwiftUI, CoreData, PhotosUI
- デプロイメント計画: App Store公開の予定なし（個人利用目的）

## コマンド
- ビルド: `xcodebuild -project Korekite.xcodeproj -scheme Korekite -configuration Debug build`
- テスト: `xcodebuild -project Korekite.xcodeproj -scheme Korekite -configuration Debug test`

## 主要なファイル
- `ContentView.swift`: メインビュー
- `ClothingDetailView.swift`: 服の詳細表示、編集画面
- `AddClothingView.swift`: 新しい服の登録画面
- `ClothingListView.swift`: 服の一覧表示と検索機能
- `CategorySettingsView.swift`: カテゴリーの管理画面
- `StorageManager.swift`: データの永続化管理
- `ClothingItem.swift`: 服のデータモデル

## データモデル
- `ClothingItem`: id, name, category, memo, wearHistory, imageData
- 現状はUserDefaultsを使用してJSONエンコードしたデータを保存
- CoreDataモデルは定義されているが実際には使用されていない
- 注: UserDefaultsの使用に特別な理由はなく、CoreDataへの移行も可能
- 画像データの方針: 1枚あたり数MB程度に抑える（画像圧縮またはリサイズ処理の実装が望ましい）

## テスト状況
- KorekiteTests: 基本テンプレートのみで実装なし
- KorekiteUITests: 基本テンプレートのみで実装なし

## 主要な問題点
1. UserDefaultsで画像データを保存しているパフォーマンス問題
2. カテゴリ設定の永続化不足
3. 服の名前入力がない問題（UUIDを使用）
4. エラーハンドリングの改善

## 改善計画
1. 画像データのFileManagerへの移行および圧縮機能の実装
   - UserDefaultsから画像参照のみを保存する形式に変更
   - 画像保存時の圧縮・リサイズ処理の追加
2. カテゴリ設定の永続化実装
   - CategoryManagerの状態を保存する機能追加
   - カテゴリ削除時の関連アイテム処理
3. エラーハンドリングの改善
   - try?ではなくdo-catchを使用した詳細なエラー処理
   - ユーザーへのエラー表示機能