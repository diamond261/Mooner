import SwiftUI
import Foundation
import MoonerC

class BatteryLevelDetector: ObservableObject {
    @Published var batteryLevel: Int = 0
    @Published var isScreenLocked = false
    init() {
        UIDevice.current.isBatteryMonitoringEnabled = true
        self.batteryLevel = Int(UIDevice.current.batteryLevel * 100)
        // Notification Observer
        NotificationCenter.default.addObserver(self, selector: #selector(batteryLevelDidChange(notification:)), name: UIDevice.batteryLevelDidChangeNotification, object: nil)
    }
    @objc func batteryLevelDidChange(notification: Notification) {
        self.batteryLevel = Int(UIDevice.current.batteryLevel * 100)
    }
}

func formatDate(pointInTime: Date) -> (LongDate: String, Time: String, AMPM: String) {
    // LongDate
    let longDateFormatter = DateFormatter()
    longDateFormatter.dateFormat = userDateFormat
    let LongDate: String = longDateFormatter.string(from: pointInTime)
    // Time
    let timeFormatter = DateFormatter()
    timeFormatter.dateFormat = userTimeFormat
    let Time: String = timeFormatter.string(from: pointInTime)
    // AM/PM
    var ampmFormat = "a"
    if isShowAMPMEnabled == false {
        ampmFormat = ""
    }
    let ampmFormatter = DateFormatter()
    ampmFormatter.dateFormat = ampmFormat
    let AMPM: String = ampmFormatter.string(from: pointInTime)

    return (LongDate, Time, AMPM)
}

func colorFromHex(_ hex: String) -> Color {
    let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
    var value: UInt64 = 0
    guard Scanner(string: cleaned).scanHexInt64(&value) else {
        return Color.white
    }

    let r, g, b, a: UInt64
    switch cleaned.count {
    case 6:
        (r, g, b, a) = (value >> 16 & 0xFF, value >> 8 & 0xFF, value & 0xFF, 0xFF)
    case 8:
        (r, g, b, a) = (value >> 24 & 0xFF, value >> 16 & 0xFF, value >> 8 & 0xFF, value & 0xFF)
    default:
        return Color.white
    }

    return Color(
        .sRGB,
        red: Double(r) / 255.0,
        green: Double(g) / 255.0,
        blue: Double(b) / 255.0,
        opacity: Double(a) / 255.0
    )
}

private func preferenceString(forKey key: String) -> String? {
    let suite = "com.now.moonerprefs" as CFString
    CFPreferencesAppSynchronize(suite)
    if let value = CFPreferencesCopyAppValue(key as CFString, suite) as? String {
        return value
    }

    let plistPath = "/var/mobile/Library/Preferences/com.now.moonerprefs.plist"
    if let dict = NSDictionary(contentsOfFile: plistPath),
       let value = dict[key] as? String {
        return value
    }

    return nil
}

struct RootTimelineView: View {
    var body: some View {
        VStack {
            TimelineView<(PeriodicTimelineSchedule), TimeView>(.periodic(from: .now, by: 1.0)) { context in
                TimeView(date: context.date) 
            }
        }
    }
}

struct TimeView: View {
    let date: Date
    @ObservedObject var batteryLevelDetector = BatteryLevelDetector()
    let secondaryColor = Color(red:0.85, green:0.85, blue:0.85)
    let secondaryOpacity = 0.9
    let secondaryBlur: Material = .thickMaterial
    @State var islsMainView = isLSMainView

    var body: some View {
        if islsMainView == true {
            let (LongDate, Time, AMPM) = formatDate(pointInTime: date)
            let lsAlignment: HorizontalAlignment = {
                if lockscreenAlignment == 0 {
                    return .leading
                } else if lockscreenAlignment == 1 {
                    return .center
                } else {
                    return .trailing
                }
            }()
            let scaleAnchor: UnitPoint = {
                if lockscreenAlignment == 0 {
                    return .topLeading
                } else if lockscreenAlignment == 1 {
                    return .top
                } else {
                    return .topTrailing
                }
            }()
            let timeScale = CGFloat(lockscreenScale ?? 1.0)
            let timeColorHex = preferenceString(forKey: "timeTextColor")
                ?? userTimeColorHex
                ?? "#FFFFFFFF"
            let dateColorHex = preferenceString(forKey: "dateTextColor")
                ?? userDateColorHex
                ?? timeColorHex
            let batteryColorHex = preferenceString(forKey: "batteryTextColor")
                ?? userBatteryColorHex
                ?? "#D9D9D9FF"
            let timeColor = colorFromHex(timeColorHex)
            let dateColor = colorFromHex(dateColorHex)
            let batteryColor = colorFromHex(batteryColorHex)

            HStack {
                if lockscreenAlignment == 2 {
                    Spacer()
                }
                VStack(alignment: lsAlignment) {
                    if isDayNightIconEnabled == false {
                        Text("\(LongDate)")
                            .font(.system(size: 25, weight: .semibold, design: .rounded))
                            .opacity(secondaryOpacity)
                            .foregroundColor(dateColor)
                            .foregroundStyle(secondaryBlur)
                    } else if lockscreenAlignment != 2 {
                        Text("\(LongDate) \(Image(systemName: "sun.max.fill"))")
                            .font(.system(size: 25, weight: .semibold, design: .rounded))
                            .opacity(secondaryOpacity)
                            .foregroundColor(dateColor)
                            .foregroundStyle(secondaryBlur)
                    } else {
                        Text("\(Image(systemName: "sun.max.fill")) \(LongDate)")
                        .font(.system(size: 25, weight: .semibold, design: .rounded))
                        .opacity(secondaryOpacity)
                        .foregroundColor(dateColor)
                        .foregroundStyle(secondaryBlur)
                    }
                    HStack(alignment: .lastTextBaseline) {
                        if lockscreenAlignment != 2 {
                            Text("\(Time)")
                                .font(.system(size: 60, weight: .bold, design: .rounded))
                                .foregroundColor(timeColor)
                        }
                        Text("\(AMPM)")
                            .font(.system(size: 35, weight: .semibold, design: .rounded))
                            .opacity(secondaryOpacity)
                            .foregroundColor(secondaryColor)
                            .foregroundStyle(secondaryBlur)
                        if lockscreenAlignment == 2 {
                            Text("\(Time)")
                                .font(.system(size: 60, weight: .bold, design: .rounded))
                                .foregroundColor(timeColor)
                        }
                        
                    }
                    Text("Battery Percentage: \(batteryLevelDetector.batteryLevel)%")
                        .font(.system(size: 25, weight: .semibold, design: .rounded))
                        .opacity(secondaryOpacity)
                        .foregroundColor(batteryColor)
                        .foregroundStyle(secondaryBlur)
                    Spacer()
                }
                .padding(.top, 30)
                .padding(.horizontal, 15)
                .scaleEffect(timeScale, anchor: scaleAnchor)
                if lockscreenAlignment == 0 {
                    Spacer()
                }
            }
            .environment(\.layoutDirection, .leftToRight)
        }
    }
}
