import SwiftUI

struct WidgetTint {
    let name: String
    let primary: Color
    let secondary: Color
    let glow: Color

    static let all: [WidgetTint] = [
        WidgetTint(
            name: "Aurora",
            primary: Color(red: 0.25, green: 0.76, blue: 0.91),
            secondary: Color(red: 0.92, green: 0.38, blue: 0.72),
            glow: Color(red: 0.39, green: 0.59, blue: 1.0)
        ),
        WidgetTint(
            name: "Moss",
            primary: Color(red: 0.43, green: 0.78, blue: 0.52),
            secondary: Color(red: 0.96, green: 0.75, blue: 0.35),
            glow: Color(red: 0.53, green: 0.86, blue: 0.72)
        ),
        WidgetTint(
            name: "Cinder",
            primary: Color(red: 1.0, green: 0.42, blue: 0.35),
            secondary: Color(red: 0.95, green: 0.77, blue: 0.48),
            glow: Color(red: 1.0, green: 0.53, blue: 0.40)
        )
    ]
}
