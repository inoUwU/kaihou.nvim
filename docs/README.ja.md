[English](README.md)

# kaihou.nvim

> [!WARNING]
> **⚠️ このプロジェクトはまだ作成中でテストされていません。使用は自己責任でお願いします。⚠️**

`kaihou.nvim` は、Neovimから直接Defenderの除外パスを管理することで、現在のプロジェクトをWindows Defenderのリアルタイムスキャンから「解放」するのに役立ちます。

## 特徴

- Windows専用のセーフティガード
- `vim.system()` を介した非同期、ノンブロッキングのPowerShell実行
- スマートなフォールバックを備えた `vim.fs.root()` を使用したプロジェクトルート検出
- レジストリ直接参照による除外設定の読み取り（確認・一覧に管理者権限は不要）
- Defenderの変更前に管理者権限をチェック（トグルのみ）
- シンプルなコマンド:
  - `:DefenderCheck` / `:KaihouCheck`
  - `:DefenderToggle` / `:KaihouToggle`
  - `:DefenderList` / `:KaihouList`
- 外部依存なし
- Lazy.nvim互換

## 要件

- Neovim 0.10+
- Windows
- Windows Defenderが利用可能であること

## インストール (lazy.nvim)

```lua
{
  "inoUwU/kaihou.nvim",
}
```

## コマンド

- `:DefenderCheck` / `:KaihouCheck`
  - 現在のプロジェクトルートが既にDefenderの除外設定に含まれているか確認します。
  - Windowsレジストリを直接参照するため、管理者権限は不要です。
- `:DefenderToggle` / `:KaihouToggle`
  - 現在のプロジェクトルートをDefenderの除外設定に追加/削除します。
  - レジストリを変更するため管理者権限が必要です。
- `:DefenderList` / `:KaihouList`
  - `vim.ui.select` を使用して、現在のDefenderの除外パスを一覧表示します。
  - Windowsレジストリを直接参照するため、管理者権限は不要です。

## プロジェクトルートの検出

`kaihou.nvim` は以下のマーカーを使用してプロジェクトルートを解決します:

- `.git`
- `package.json`
- `Cargo.toml`
- `pyproject.toml`

マーカーが見つからない場合は、現在の作業ディレクトリにフォールバックします。

## 注意事項

- Windows以外のシステムでは、コマンドは警告とともに安全にスキップされます。
- 確認・一覧操作はレジストリを直接参照するため、管理者権限は不要です。
- トグル（追加/削除）操作はレジストリを変更するため、管理者権限が必要です。
- すべての操作は非同期であり、UIをブロックしません。

## ライセンス

MIT
