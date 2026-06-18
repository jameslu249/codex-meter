import Foundation

enum MeterStyle: String, CaseIterable, Identifiable {
    case circular
    case horizontal
    case battery

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .circular:
            return "Circular"
        case .horizontal:
            return "Bars"
        case .battery:
            return "Battery"
        }
    }
}
