import Preferences
import UIKit
import Foundation

@objc(TimeColorController)
final class TimeColorController: PSViewController, UIColorPickerViewControllerDelegate {
    private let defaults = UserDefaults(suiteName: "com.now.moonerprefs")
    private let colorKey = "timeTextColor"
    private let fallbackColor = UIColor.white
    private let picker = UIColorPickerViewController()

    override init(forContentSize contentSize: CGSize) {
        super.init(forContentSize: contentSize)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Time Color"
        view.backgroundColor = UIColor.systemBackground

        picker.delegate = self
        picker.supportsAlpha = true
        picker.selectedColor = loadColor()

        addChild(picker)
        view.addSubview(picker.view)
        picker.view.translatesAutoresizingMaskIntoConstraints = false
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            picker.view.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            picker.view.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            picker.view.topAnchor.constraint(equalTo: guide.topAnchor),
            picker.view.bottomAnchor.constraint(equalTo: guide.bottomAnchor)
        ])
        picker.didMove(toParent: self)
    }

    func colorPickerViewControllerDidSelectColor(
        _ viewController: UIColorPickerViewController
    ) {
        saveColor(viewController.selectedColor)
    }

    func colorPickerViewControllerDidFinish(
        _ viewController: UIColorPickerViewController
    ) {
        saveColor(viewController.selectedColor)
    }

    private func loadColor() -> UIColor {
        guard let hexString = defaults?.string(forKey: colorKey) else {
            return fallbackColor
        }
        return colorFromHex(hexString) ?? fallbackColor
    }

    private func saveColor(_ color: UIColor) {
        defaults?.setValue(hexString(from: color), forKey: colorKey)
    }

    private func colorFromHex(_ hex: String) -> UIColor? {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        guard Scanner(string: cleaned).scanHexInt64(&value) else {
            return nil
        }

        let r, g, b, a: UInt64
        switch cleaned.count {
        case 6:
            (r, g, b, a) = (value >> 16 & 0xFF, value >> 8 & 0xFF, value & 0xFF, 0xFF)
        case 8:
            (r, g, b, a) = (value >> 24 & 0xFF, value >> 16 & 0xFF, value >> 8 & 0xFF, value & 0xFF)
        default:
            return nil
        }

        return UIColor(
            red: CGFloat(r) / 255.0,
            green: CGFloat(g) / 255.0,
            blue: CGFloat(b) / 255.0,
            alpha: CGFloat(a) / 255.0
        )
    }

    private func hexString(from color: UIColor) -> String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        return String(
            format: "#%02X%02X%02X%02X",
            Int(red * 255.0),
            Int(green * 255.0),
            Int(blue * 255.0),
            Int(alpha * 255.0)
        )
    }
}
