import Preferences
import UIKit

final class ColorsListController: PSListController {
    override var specifiers: NSMutableArray? {
        get {
            if let specifiers = value(forKey: "_specifiers") as? NSMutableArray {
                return specifiers
            }
            let specifiers = loadSpecifiers(fromPlistName: "Colors", target: self)
            setValue(specifiers, forKey: "_specifiers")
            return specifiers
        }
        set {
            super.specifiers = newValue
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Colors"
    }
}
