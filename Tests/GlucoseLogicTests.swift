import XCTest

/// Locks parity with the range thresholds and the API JSON shape (docs/API.md).
/// If these fail after a backend change, update the widget to match (see GlucoseRange.swift).
final class GlucoseLogicTests: XCTestCase {

    func testRangeThresholds() {
        XCTAssertEqual(GlucoseRange.from(value: 54, stale: false), .red)
        XCTAssertEqual(GlucoseRange.from(value: 55, stale: false), .yellow)
        XCTAssertEqual(GlucoseRange.from(value: 69, stale: false), .yellow)
        XCTAssertEqual(GlucoseRange.from(value: 70, stale: false), .green)
        XCTAssertEqual(GlucoseRange.from(value: 180, stale: false), .green)
        XCTAssertEqual(GlucoseRange.from(value: 181, stale: false), .yellow)
        XCTAssertEqual(GlucoseRange.from(value: 250, stale: false), .yellow)
        XCTAssertEqual(GlucoseRange.from(value: 251, stale: false), .red)
        XCTAssertEqual(GlucoseRange.from(value: nil, stale: false), .gray)
    }

    func testStaleOverridesToGray() {
        // Even an in-range value renders gray when stale.
        XCTAssertEqual(GlucoseRange.from(value: 120, stale: true), .gray)
    }

    func testTrendSymbols() {
        XCTAssertEqual(TrendArrow.symbols(trend: 1), ["arrow.up", "arrow.up"])
        XCTAssertEqual(TrendArrow.symbols(trend: 2), ["arrow.up"])
        XCTAssertEqual(TrendArrow.symbols(trend: 3), ["arrow.up.right"])
        XCTAssertEqual(TrendArrow.symbols(trend: 4), ["arrow.right"])
        XCTAssertEqual(TrendArrow.symbols(trend: 5), ["arrow.down.right"])
        XCTAssertEqual(TrendArrow.symbols(trend: 6), ["arrow.down"])
        XCTAssertEqual(TrendArrow.symbols(trend: 7), ["arrow.down", "arrow.down"])
        XCTAssertTrue(TrendArrow.symbols(trend: 0).isEmpty)
        XCTAssertTrue(TrendArrow.symbols(trend: nil).isEmpty)
    }

    func testDecodeAvailableReading() throws {
        let json = """
        {"available":true,"value":283,"mmol_l":15.7,"trend":4,
         "trend_direction":"Flat","trend_description":"steady","trend_arrow":"→",
         "minutes_ago":5,"stale":false,"reading_time":"2026-07-09T16:28:56-04:00"}
        """.data(using: .utf8)!
        let r = try JSONDecoder().decode(GlucoseReading.self, from: json)
        XCTAssertTrue(r.available)
        XCTAssertEqual(r.value, 283)
        XCTAssertEqual(r.mmolL, 15.7)
        XCTAssertEqual(r.trend, 4)
        XCTAssertEqual(r.trendDescription, "steady")
        XCTAssertEqual(r.trendArrow, "→")
        XCTAssertEqual(r.minutesAgo, 5)
        XCTAssertEqual(r.stale, false)
    }

    func testDecodeUnavailableReading() throws {
        let json = #"{"available":false,"message":"Waiting for first reading…"}"#
            .data(using: .utf8)!
        let r = try JSONDecoder().decode(GlucoseReading.self, from: json)
        XCTAssertFalse(r.available)
        XCTAssertNil(r.value)
        XCTAssertEqual(r.message, "Waiting for first reading…")
    }
}
