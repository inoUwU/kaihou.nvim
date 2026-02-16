[English](README.md)

# kaihou.nvim

`kaihou.nvim` は、Neovimから直接Defenderの除外パスを管理することで、現在のプロジェクトをWindows Defenderのリアルタイムスキャンから「解放」するのに役立ちます。

## 特徴

- Windows専用のセーフティガード
- `vim.system()` を介した非同期、ノンブロッキングのPowerShell実行
- スマートなフォールバックを備えた `vim.fs.root()` を使用したプロジェクトルート検出
- Defenderの変更前に管理者権限をチェック
- シンプルなコマンド:
  - `:DefenderCheck`
  - `:DefenderToggle`
  - `:DefenderList`
- `VimEnter` でのオプショナルな自動チェック
- 外部依存なし
- Lazy.nvim互換

## 要件

- Neovim 0.10+
- Windows
- Windows Defenderが利用可能であること (`Get-MpPreference`, `Add-MpPreference`, `Remove-MpPreference`)

## インストール (lazy.nvim)

```lua
{
  "inoUwU/kaihou.nvim",
  config = function()
    require("kaihou").setup({
      auto_check = true,
    })
  end,
}
```

## セットアップ

```lua
require("kaihou").setup({
  auto_check = true,
})
```

### オプション

- `auto_check` (boolean, デフォルト: `true`)
  - 有効にすると、`VimEnter` 時に自動的に `:DefenderCheck` のロジックを実行します。

## コマンド

- `:DefenderCheck`
  - 現在のプロジェクトルートが既にDefenderの除外設定に含まれているか確認します。
- `:DefenderToggle`
  - 現在のプロジェクトルートをDefenderの除外設定に追加/削除します。
  - Defenderの設定を変更するには管理者権限が必要です。
- `:DefenderList`
  - `vim.ui.select` を使用して、現在のDefenderの除外パスを一覧表示します。

## プロジェクトルートの検出

`kaihou.nvim` は以下のマーカーを使用してプロジェクトルートを解決します:

- `.git`
- `package.json`
- `Cargo.toml`
- `pyproject.toml`

マーカーが見つからない場合は、現在の作業ディレクトリにフォールバックします。

## 注意事項

- Windows以外のシステムでは、コマンドは警告とともに安全にスキップされます。
- Neovimが管理者権限で実行されていない場合、Defenderの変更はスキップされます。
- すべての操作は非同期であり、UIをブロックしません。

## ライセンス

MIT
