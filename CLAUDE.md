# Korekiteプロジェクト情報

## プロジェクト概要
Korekiteは高機能なワードローブ管理iOSアプリケーションです。コーディネートの登録・管理、天気情報に基づく推奨機能、着用履歴の分析、アイテム名の管理など、総合的なファッション管理機能を提供します。

## 開発環境
- 対象OS: iOS 18.5以上（最新バージョンに追従）
- 開発ツール: Xcode 16.4以上（最新バージョンに追従）
- 対応デバイス: iPhone, iPad (TARGETED_DEVICE_FAMILY = "1,2")
- 使用フレームワーク: SwiftUI, CoreData, PhotosUI, AVFoundation, CoreLocation
- 外部API: OpenWeatherMap API（天気情報取得）
- デプロイメント計画: App Store公開の予定なし（個人利用目的）
- 環境制約: カメラ機能は実機でのテスト推奨（シミュレーターでは制限あり）

## コマンド
- ビルド: `xcodebuild -project Korekite.xcodeproj -scheme Korekite -configuration Debug build`
- シミュレーター用ビルド: `xcodebuild -project Korekite.xcodeproj -scheme Korekite -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build`
- テスト: `xcodebuild -project Korekite.xcodeproj -scheme Korekite -configuration Debug test`

## 主要なファイル構成

### メインアプリケーション
- `KorekiteApp.swift`: アプリケーションエントリーポイント
- `ContentView.swift`: メインビュー（天気情報・推奨・一覧表示）
- `AddOutfitView.swift`: 新規コーディネート登録画面
- `OutfitDetailView.swift`: コーディネート詳細・編集画面
- `OutfitListView.swift`: コーディネート一覧・検索画面
- `AnalyticsView.swift`: 着用履歴分析画面

### データ管理
- `Models/Outfit.swift`: メインデータモデル（旧ClothingItem）
- `StorageManager.swift`: データ永続化管理
- `ImageStorageManager.swift`: 画像ファイル管理
- `CategoryManager.swift`: カテゴリー管理
- `ItemNameManager.swift`: アイテム名管理・提案機能

### 外部サービス連携
- `WeatherService.swift`: 天気情報取得・推奨機能
- `LocationManager.swift`: 位置情報管理
- `AnalyticsManager.swift`: 着用分析・統計機能
- `SearchManager.swift`: 検索・フィルタリング機能

### UI・UX
- `DesignSystem.swift`: デザインシステム（色・フォント・スタイル定義）
- `Components/`: 再利用可能UIコンポーネント
- `CameraImagePicker.swift`: カメラ撮影・権限管理
- `ImageUtils.swift`: 画像処理・圧縮機能

### 設定・ユーティリティ
- `CategorySettingsView.swift`: カテゴリー設定画面
- `ItemListEditorView.swift`: アイテム名一括編集
- `ErrorManager.swift`: エラーハンドリング
- `Config.plist`: API設定ファイル

## データモデル（重要な変更）

### Outfit構造体（旧ClothingItem）
```swift
struct Outfit: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String                    // コーディネート名
    var category: String               // カテゴリー
    var memo: String                   // メモ
    var wearHistory: [Date]           // 着用履歴
    var imageData: Data?              // 旧形式（互換性維持）
    var imageFilename: String?        // 新形式（ファイル参照）
    var itemNames: [String]           // 個別アイテム名
    var isFavorite: Bool             // お気に入り機能
}
```

### ストレージ実装
- **画像**: FileManager使用（性能向上済）
- **データ**: UserDefaults（JSON形式）
- **画像処理**: 自動圧縮・リサイズ（512x512px）
- **キャッシュ**: 画像キャッシュ機能実装済

## 主要機能

### ✅ 実装済み機能
1. **コーディネート管理**
   - 写真撮影・編集・削除
   - カテゴリー分類
   - 着用履歴記録
   - お気に入り機能

2. **天気連携機能**
   - 現在地の天気情報取得
   - 気温に基づくカテゴリー推奨
   - 位置情報サービス

3. **分析・統計機能**
   - 着用頻度分析
   - 季節別統計
   - 未使用アイテム検出
   - 全体統計表示

4. **検索・フィルタ機能**
   - 高速検索（キャッシュ最適化）
   - カテゴリーフィルタ
   - 複数条件検索

5. **アイテム名管理**
   - 使用頻度に基づく提案
   - 履歴管理
   - 一括編集機能

6. **カメラ機能**
   - 権限管理（修正済）
   - 自動正方形トリミング
   - フォトライブラリフォールバック

7. **UI/UXデザイン**
   - モダンなデザインシステム
   - 2カラムグリッドレイアウト
   - プレミアムな視覚効果

## テスト状況
- **実装済テスト**: StorageManagerTests, CategoryManagerTests, ItemNameManagerTests, LocationManagerTests, WeatherServiceTests
- **テストフレームワーク**: Swift Testing
- **カバレッジ**: 主要機能は網羅済み

## 設定ファイル
- `Config.plist`: OpenWeatherMap APIキー設定
- カメラ使用許可: "服の写真を撮影するためにカメラへのアクセスが必要です"
- 位置情報許可: 天気情報取得のため

## パフォーマンス最適化
- 画像キャッシュシステム
- 遅延保存（デバウンス）
- 非同期検索処理
- メモリ効率的な画像処理

## 既知の制約事項
- シミュレーターではカメラ機能に制限あり（実機推奨）
- OpenWeatherMap APIの利用制限あり
- CoreDataモデルは定義済みだが未使用（将来の移行可能）

## 最近の主要更新
- a44bbf7: 一覧画面の背景見切れ問題修正
- bb2b04b: アイテム名入力、画像ストレージ改善、検索・分析機能実装
- 32c0249: カメラ撮影機能とUI改善
- 81fcd16: アイテム名選択機能実装
- 80f5166: デザインシステム導入とレイアウト品質向上
- カメラ権限処理の修正（2025年6月29日）