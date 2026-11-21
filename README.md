# 隐私政策部署包

两个文件，自包含、无外部依赖，可直接静态托管。

- `index.html` — 英文版（主页面，目标市场是美/加/英/澳）
- `zh.html` — 中文版（页面内有互跳链接）

## 部署（任选其一，都免费）

### GitHub Pages
1. 建一个 **public** 仓库，例如 `inkbase-privacy`
2. 把 `index.html` 和 `zh.html` 传到仓库根目录
3. 仓库 Settings → Pages → Source 选 `main` / `root` → Save
4. 等 1–2 分钟，地址是：
   `https://<你的GitHub用户名>.github.io/inkbase-privacy/`

### Cloudflare Pages
1. 登录 Cloudflare → Workers & Pages → Create → Pages → Upload assets
2. 把整个 `privacy-site/` 文件夹拖进去
3. 部署后得到 `https://<项目名>.pages.dev/`

## 填到 App Store Connect

```
App 信息 → 隐私政策 URL：  https://.../          （英文版）
```

如果 ASC 支持多语言，简体中文填 `https://.../zh.html`。

## 内容口径（重要，别改回去）

这份政策在 2026-11-21 修正了两处**与实现不符**的陈述：

1. 原文写「本应用未启用云同步」—— 实际有 iCloud 同步（默认关闭、订阅后可选、
   审计本永不上传）。这是审核会问、且属于陈述不实的法律风险。
2. 原文开头写「全部只保存在你自己的设备上」—— 开启 iCloud 同步后会离开设备。

现在改成「默认本地 + iCloud 可选（默认关闭）+ 审计本永不上传」，
与 `Encryption.swift` 的 `DataFlowDisclosure` 和 `AboutLegalView` 完全一致。
