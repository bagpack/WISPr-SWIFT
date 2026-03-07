# WISPrSwift

[![CI](https://github.com/bagpack/WISPr-SWIFT/actions/workflows/ci.yml/badge.svg?branch=master)](https://github.com/bagpack/WISPr-SWIFT/actions/workflows/ci.yml)
[![SPM compatible](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)

WISPrSwift は、WISPr認証ネットワーク向けのSwiftライブラリです。

## 要件

- Swift 6
- Xcode（最新推奨）
- iOS 13 以降

## プライバシーマニフェスト

本ライブラリは `PrivacyInfo.xcprivacy` を同梱しています。
ファイルは [PrivacyInfo.xcprivacy](Sources/WISPrSwift/PrivacyInfo.xcprivacy) にあり、Swift Package の `WISPrSwift` ターゲットへリソースとして組み込まれます。

### Required Reason API について

現行実装（`Sources/WISPrSwift`）では、Apple の Required Reason API カテゴリに該当するAPI利用は確認されていません。
そのため `NSPrivacyAccessedAPITypes` は空配列としています。

## インストール（Swift Package Manager）

`Package.swift` に依存を追加してください。

```swift
.package(url: "https://github.com/bagpack/WISPr-SWIFT.git", from: "0.2.0")
```

利用側ターゲットの dependency に `WISPrSwift` を追加します。

## 使い方

```swift
import WISPrSwift

WISPrClient().login(
    username: "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxxxx@xxxxx@xxx",
    password: "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx"
) { result in
    switch result {
    case .success(let payload):
        print(payload)
    case .failure(let error):
        print(error)
    }
}
```

## 開発用コマンド

```bash
swift package reset
swift build -Xswiftc -warnings-as-errors
swift test -Xswiftc -warnings-as-errors
```

カバレッジは GitHub Actions の Job Summary で確認できます。

## ディレクトリ構成

```text
Sources/
  WISPrSwift/
Tests/
  WISPrSwiftTests/
  Fixtures/
```
