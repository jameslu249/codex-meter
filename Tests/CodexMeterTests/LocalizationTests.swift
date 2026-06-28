import XCTest
@testable import CodexMeter

final class LocalizationTests: XCTestCase {
    func testLoadsSupportedCJKLocalizations() {
        XCTAssertEqual(L10n.text("settings.smartAlerts", languageCode: "zh-Hans"), "智能提醒")
        XCTAssertEqual(L10n.text("settings.smartAlerts", languageCode: "ja"), "スマート通知")
        XCTAssertEqual(L10n.text("settings.smartAlerts", languageCode: "ko"), "스마트 알림")
    }

    func testFormatsLocalizedStringsWithArguments() {
        XCTAssertEqual(L10n.text("notification.threshold.title", languageCode: "zh-Hans", 20), "Codex 容量低于 20%")
        XCTAssertEqual(L10n.text("statusItem.remaining.hoursMinutes", languageCode: "ja", 2, 14), "2時間14分")
        XCTAssertEqual(L10n.text("usage.percentRemaining", languageCode: "ko", 67), "67% 남음")
    }

    func testStaticPercentStringsUseSinglePercentSigns() {
        XCTAssertEqual(L10n.text("settings.warnBelow20", languageCode: "en"), "Warn below 20%")
        XCTAssertEqual(L10n.text("statusItem.preview.primaryAndWeekly", languageCode: "zh-Hans"), "5小时 83% · 周 71%")
    }

    func testMissingLocalizationFallsBackToKey() {
        XCTAssertEqual(L10n.text("missing.localization.key", languageCode: "zh-Hans"), "missing.localization.key")
    }
}
