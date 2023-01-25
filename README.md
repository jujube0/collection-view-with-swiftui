# collection-view-with-swiftui
<img src="https://user-images.githubusercontent.com/60654009/214536721-79d7f9d3-6465-4350-aad9-0c30aaef29cd.png" width=40%>


# SwiftUI in cells (iOS 16.0+)

- Collection View나 Table View에서 이용하는 방법
- `register(AnyClass?, forCellWithReuseIdentifier: String)` 대신 [UICollectionView.CellRegistration](https://developer.apple.com/documentation/uikit/uicollectionview/cellregistration)을 이용하여 cell의 등록과 configuration을 진행한다.
- `UIHostingConfiguration` 은 그 중에서도 SwiftUI의 ViewBuilder를 통해 초기화되는 cell configuration 방법이다.

```swift
// Building a custom cell using SwiftUI with UIHostingConfiguration

cell.contentConfiguration = UIHostingConfiguration {
    VStack(alignment: .leading) {
        HeartRateTitleView()
        Spacer()
        HeartRateBPMView()
    }
}

struct HeartRateBPMView: View {
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("90")
                .font(.system(.title, weight: .semibold))
            Text("BPM")
                .foregroundStyle(.secondary)
                .font(.system(.subheadline, weight: .bold))
        }
    }
}
```

- cell registration은 data source의 cell provider 내에서 `dequeueConfiguredReusableCell(using:for:item:)` 의 parameter로 이용된다. (cell provider 클로져 내에서 cell registration을 생성하면 cell reuse를 막거나 에러가 발생(iOS15+)한다. )

```swift
dataSource = UICollectionViewDiffableDataSource<Section, Int>(collectionView: collectionView) {
    (collectionView: UICollectionView, indexPath: IndexPath, itemIdentifier: Int) -> UICollectionViewCell? in

    return collectionView.dequeueConfiguredReusableCell(using: cellRegistration,
                                                        for: indexPath,
                                                        item: itemIdentifier)
}
```

- Incoporate UIKit cell states

```swift
// Incorporating UIKit cell states
cell.configurationUpdateHandler = { cell, state in
    cell.contentConfiguration = UIHostingConfiguration {
      HStack {
        HealthCategoryView()
            Spacer()
            if state.isSelected {
                Image(systemName: "checkmark")
            }
        }
    }
}
```


# Bridging data

- UIKit에서 SwiftUI로 데이터를 가져오는 방법
- `@State` , `@StateObject` → data owned by swiftUI View / 하지만 SwiftUI 밖으로부터 data를 가져오므로 두 프로퍼티를 사용할 수 없다.
- 방법 1) (raw) data를 그대로 전달하는 방법
    - `HeartRateView` 는 value type이기 때문에 `update()` 가 호출될 때마다 변경된 정보를 가지고 있는 새로운 `HeartRateView` 를 생성해서 `HostingController` 의 `rootView` 를 교체해준다.

```swift
// Passing data to SwiftUI with manual UIHostingController updates
struct HeartRateView: View {
    var beatsPerMinute: Int

    var body: some View {
        Text("\(beatsPerMinute) BPM")
    }
}

class HeartRateViewController: UIViewController {
    let hostingController: UIHostingController< HeartRateView >
    var beatsPerMinute: Int {
        didSet { update() }
    }

    func update() {
        hostingController.rootView = HeartRateView(beatsPerMinute: beatsPerMinute)
    }
}
```

- 방법 2) `@ObservedObject` 또는 `@EnvironmentObject` 를 이용한다.
    - 해당 property wrapper를 이용하면 값이 바뀔 때마다 이를 SwiftUI가 자동으로 이를 반영해준다.
    - `data` 가 변경되면 자동으로 이가 반영된다.

```swift
// Passing an ObservableObject to automatically update SwiftUI views
class HeartData: ObservableObject {
    @Published var beatsPerMinute: Int

    init(beatsPerMinute: Int) {
       self.beatsPerMinute = beatsPerMinute
    }
}

struct HeartRateView: View {
    @ObservedObject var data: HeartData

    var body: some View {
        Text("\(data.beatsPerMinute) BPM")
    }
}

// Passing an ObservableObject to automatically update SwiftUI views

class HeartRateViewController: UIViewController {
    let data: HeartData
    let hostingController: UIHostingController<HeartRateView>  

    init(data: HeartData) {
        self.data = data
        let heartRateView = HeartRateView(data: data)
        self.hostingController = UIHostingController(rootView: heartRateView)
    }
}
```

# Data flow for cells

- 역시 diffable data source를 이용해서 data collection을 collection view에 적용할 수 있다.
    
    UIKit으로만 이루어진 view에서는, (insertion, deletion, move 가 아닌) data model에 변경이 있을 경우 `reconfigureItems()` 를 이용해서 snapshot에 이를 반영하고 apply 해야하지만,
    SwiftUI에서는 `@ObservableObject` 를 통해 이를 대신할 수 있다.
    
     → `@ObservableObject` 내의 published property가 변경되면 (diffable data source나 snapshot을 거치지 않고) 자동으로 SwiftUI View를 포함하고 있는 cell이 변경된다.
    
- 추가로 iOS16 부터는 UIHostingConfiguration을 이용한 cell의  SwiftUI content가 변경될 경우 cell이 자동으로 resizing 된다.

**SwiftUI에서 UIKit으로 data를 전달하는 방법**

- 역시 `@ObservableObject` 를 이용하여 two-way binding을 적용할 수 있다.
- TextField를 이용하면, 내용이 변경되면 observable object에 자동으로 이를 반영해준다.

```swift
// Creating a two-way binding to data in SwiftUI

class MedicalCondition: Identifiable, ObservableObject {
    let id: UUID
   
    @Published var text: String
}

struct MedicalConditionView: View {
    @ObservedObject var condition: MedicalCondition

    var body: some View {
        HStack {
						TextField("Condition", text: $condition.text)
            Spacer()
        }
    }
}
```
