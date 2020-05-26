# AMSwiftComponents

A collection of small modules to help development

## UIWrappers

A collection of Wrapping Types to handle differences in an element's origin.

### Example Usage

#### `ImageType`

```swift
let image = ImageType.url(URL(string:"http://place.com/myImageUrl.png")!)
let image = ImageType.image(myImage)
let image = ImageType.resource("myResouceImageName")
let image = ImageType.system("pencil")
let image = ImageType.urlOrPlaceholder(from: "http://place.com/myImageUrl.png")

myImageView.setImage(with: image)

myButton.setImage(with: image, for: .normal)
```

#### `ColorType`

```swift

let myColor = ColorType.color(UIColor.white)
let myColor = ColorType.resource("myColorResourceName")
let myColor = ColorType.hex("#fff")
let myColor = ColorType.hex("fff")
let myColor = ColorType.hex("#00FFaaaa")

self.view.backgroundColor = myColor.color
```

## EntityUtilities

Set of protocol and basic implementations to ease database development.

Only CoreData is currently available as the basic implementation. To use:

### Example Usage

```swift

//`CDStack`
static let appCDStack = CDStack(settings: .init(databaseModelName: "MyName", shouldSeed: true, databaseBundle: Bundle.main))
let myCoreDataModel: MyCDModelType = appCDStack.context.findObject(for: "123e4567-e89b-12d3-a456-426614174000")
func findObject<T: CoreDataEntity>(for identifier: T.ID?) throws -> T {

// `CDStack.Settings` Documentation
    /// The default database name. Used for tracking the sqlite file, write ahead log, seed database, and Xcode model file (xcdatamodeld). The title must match for all these files.
    databaseModelName: String
    /// On first load, which to seed the database. Requires a {databaseModelName}.sqlite file in the bundle.
    shouldSeed: Bool
    /// The Bundle where the database momd is found
    databaseBundle: Bundle
    /// If we cannot migrate the database on model changes, then this completely deletes the old database and starts from scratch
    deleteDatabaseOnMigrationFailure: Bool
}
```

## EZShare

A set of Types to make sharing simpler to deal with.

### Deep Links

Create a `struct EZDeepLink<T: DeepLinkable>` with a web or custom Scheme URL to generate your `DeepLinkable` Type.

#### Example Usage

```swift
enum AppDeepLink: DeepLinkable {
    case book(Book)
    case chapter(Chapter)

    private enum Path: String {
        case book
        case chapter
    }

    private enum Query: String {
        case id
    }

    init?(from pathComponents: [String], and queryItems: [(String, String?)]) {
        guard let pathParam = pathComponents.first, let queryItem = queryItems.first else {
            return nil
        }
        guard let path = Path(rawValue: pathParam), Query(rawValue: queryItem.0) == .id, let value = queryItem.1 else {
            return nil
        }
        self.init(path: path, id: value)
    }

    init(path: Path, id: String) {
        switch path {
            case .book: self == .book(database.getBook(for: id))
            case .chapter: self == .chapter(database.getChapter(for: id))
        }
    }
}

func handleDeepLink(_ url: URL) {
    let deepLink: AppDeepLink? = EZDeepLink<AppDeepLink>(url: url).generateItem()
    // do any navigation/setup needed
}
```

### EZShareable

Easily create a basic sharing item that implements UIActivityItemProvider or make your existing Types Shareable.

#### Example Usage

```swift
// share a basic item
let shareItem = EZShareData(shareType: .link(URL(string: "http://www.acts.media")!), text: "Acts Media Website")
let activityVC = UIActivityViewController(activityItems: [EZShareProvider(shareItem: shareItem)], applicationActivities: nil)
present(activityVC, animated: true)

// Make your Type convertable
struct Book {
    let name: String
    let url: URL
}

extension Bool: EZShareable {
    var shareItem: EZShareItem { .init(shareType: .link(url), text: name) }
}

func shareBook(book: Book) {
    let activityVC = UIActivityViewController(activityItems: [EZShareProvider(shareableItem: book)], applicationActivities: nil)
    present(activityVC, animated: true)
}

// EZTextShareable. More easily format text for both plain text and HTML (for email)

extension Bool: EZShareable {
    var shareItem: EZShareItem {
        EZTextShareable(subject: "Look at this Book",
                        preItemsText: .init("I found this book\n\n", "<html><body>I found this book\n<br/>\n<br/>"),
                        items: [.init("\(name): \(url.absolutePath)", "<a href=\"\(url.absolutePath)\">\(name)</a>")],
                        postItemsText: .init("Check it out in My App: www.myApp.com", "Check it out in <a href=\"www.myApp.com\">My App</a></body></html>"))
            .shareItem
    }
}
```
