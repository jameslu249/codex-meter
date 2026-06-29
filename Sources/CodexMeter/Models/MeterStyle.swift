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
            return L10n.text("meter.style.circular")
        case .horizontal:
            return L10n.text("meter.style.bars")
        case .battery:
            return L10n.text("meter.style.battery")
        }
    }
}
