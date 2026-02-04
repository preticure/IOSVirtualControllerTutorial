# バーチャルジョイスティック実装解説

## 全体構成

```
IOSVirtualControllerTutorial/
├── IOSVirtualControllerTutorial.swift  # アプリエントリーポイント
├── ContentView.swift                    # メインビュー（AR + ジョイスティック統合）
├── GameViewModel.swift                  # 状態管理
└── JoystickView.swift                   # ジョイスティックUIコンポーネント
```

---

## 1. GameViewModel.swift（状態管理）

### 役割
アプリ全体の状態を一元管理するクラス。ジョイスティックの入力値とARオブジェクトの参照を保持し、両者を橋渡しする。

### コード解説

```swift
@Observable
class GameViewModel {
    var joystickInput: CGPoint = .zero
    var cubeEntity: Entity?
    private let moveSpeed: Float = 0.02
```

| プロパティ | 説明 |
|-----------|------|
| `@Observable` | SwiftUIのObservationフレームワーク。プロパティ変更時にビューを自動更新 |
| `joystickInput` | ジョイスティックの入力値（x, y共に-1.0〜1.0） |
| `cubeEntity` | RealityKitのEntityへの参照 |
| `moveSpeed` | 1フレームあたりの移動量 |

### 位置更新メソッド

```swift
func updateEntityPosition() {
    guard let entity = cubeEntity else { return }

    let deltaX = Float(joystickInput.x) * moveSpeed
    let deltaZ = Float(-joystickInput.y) * moveSpeed  // Y軸反転

    entity.position.x += deltaX
    entity.position.z += deltaZ
}
```

**座標マッピング**:
- ジョイスティックX軸 → 3D空間X軸（左右移動）
- ジョイスティックY軸 → 3D空間Z軸（前後移動、符号反転）

Y軸を反転する理由: 画面座標系では下が正だが、3D空間では手前が正のZ軸となるため。

---

## 2. JoystickView.swift（UIコンポーネント）

### 構造

```
┌─────────────────────┐
│                     │
│    ┌─────────┐      │  外枠円: 150pt (黒30%透明)
│    │  stick  │      │
│    └─────────┘      │  スティック円: 60pt (白80%)
│                     │
└─────────────────────┘
```

### プロパティ

```swift
@Binding var joystickInput: CGPoint      // 親ビューとの双方向バインディング

private let outerRadius: CGFloat = 75    // 外枠の半径
private let innerRadius: CGFloat = 30    // スティックの半径

@State private var stickPosition: CGPoint = .zero  // スティックの現在位置
```

### ドラッグジェスチャー処理

```swift
.onChanged { value in
    let translation = value.translation
    let distance = sqrt(translation.width * translation.width +
                        translation.height * translation.height)
    let maxDistance = outerRadius - innerRadius
```

1. **距離計算**: ピタゴラスの定理で中心からの距離を算出
2. **最大距離**: スティックが外枠からはみ出ない範囲

### 円形制限（三角関数）

```swift
if distance <= maxDistance {
    stickPosition = CGPoint(x: translation.width, y: translation.height)
} else {
    let angle = atan2(translation.height, translation.width)
    stickPosition = CGPoint(
        x: cos(angle) * maxDistance,
        y: sin(angle) * maxDistance
    )
}
```

最大距離を超えた場合:
1. `atan2`で移動方向の角度を取得
2. `cos`/`sin`で最大距離上の座標を計算
3. 指の方向を維持したまま円周上に制限

```
        指の位置 (範囲外)
           ↗
          /
         / ← この方向を維持
        ●───────── 制限後の位置（円周上）
       /|
      / |
     ●  ← 中心
```

### 入力値の正規化

```swift
joystickInput = CGPoint(
    x: stickPosition.x / maxDistance,
    y: stickPosition.y / maxDistance
)
```

実際のピクセル位置を-1.0〜1.0の範囲に正規化。これにより移動速度の計算が容易になる。

### リリース時のアニメーション

```swift
.onEnded { _ in
    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
        stickPosition = .zero
    }
    joystickInput = .zero
}
```

- `response: 0.3`: アニメーション時間（秒）
- `dampingFraction: 0.6`: 減衰率（1.0未満でバウンス効果）

---

## 3. ContentView.swift（統合ビュー）

### レイアウト構造

```swift
TimelineView(.animation) { timeline in
    ZStack {
        RealityView { ... }      // 背面: ARビュー
        VStack { ... }           // 前面: ジョイスティック
    }
}
```

```
┌────────────────────────────┐
│                            │
│        RealityView         │
│         (ARシーン)          │
│                            │
│                            │
│  ┌──────┐                  │
│  │ 🕹️  │                  │  ← 左下にジョイスティック
│  └──────┘                  │
└────────────────────────────┘
```

### TimelineView（毎フレーム更新）

```swift
TimelineView(.animation) { timeline in
    // ...
    .onChange(of: timeline.date) {
        viewModel.updateEntityPosition()
    }
}
```

| 要素 | 説明 |
|-----|------|
| `TimelineView(.animation)` | ディスプレイのリフレッシュレートに同期（60fps等） |
| `timeline.date` | 各フレームで更新されるタイムスタンプ |
| `onChange` | 日時が変わるたびに位置更新メソッドを呼び出し |

### RealityViewでのEntity保存

```swift
RealityView { content in
    let model = Entity()
    // ... 設定 ...

    viewModel.cubeEntity = model  // ViewModelに参照を保存
}
```

これにより、ジョイスティック入力時にViewModelを通じてEntityを操作可能になる。

---

## 4. 画面回転の固定

### IOSVirtualControllerTutorial.swift

```swift
func application(_ application: UIApplication,
                 supportedInterfaceOrientationsFor window: UIWindow?)
                 -> UIInterfaceOrientationMask {
    return .landscape
}
```

`.landscape`は左右どちらの横向きも許可。片方のみにする場合:
- `.landscapeLeft`: ホームボタン/ジェスチャーバーが左
- `.landscapeRight`: ホームボタン/ジェスチャーバーが右

---

## データフロー図

```
┌─────────────────┐
│  JoystickView   │
│                 │
│  DragGesture    │
│       │         │
│       ▼         │
│  stickPosition  │
│       │         │
└───────┼─────────┘
        │ @Binding
        ▼
┌─────────────────┐
│  GameViewModel  │
│                 │
│  joystickInput ◄┼─── 入力値 (-1.0 ~ 1.0)
│       │         │
│       ▼         │
│  cubeEntity ────┼─── Entity参照
│       │         │
└───────┼─────────┘
        │ updateEntityPosition()
        ▼
┌─────────────────┐
│   RealityKit    │
│                 │
│  Entity.position│ ← 位置更新
│                 │
└─────────────────┘
```

---

## まとめ

| コンポーネント | 責務 |
|--------------|------|
| `JoystickView` | ユーザー入力の検出と視覚的フィードバック |
| `GameViewModel` | 入力値の保持とEntityへの変換・適用 |
| `ContentView` | 各コンポーネントの統合と更新ループの管理 |

この設計により、UIとロジックが分離され、テストや拡張が容易になっている。
