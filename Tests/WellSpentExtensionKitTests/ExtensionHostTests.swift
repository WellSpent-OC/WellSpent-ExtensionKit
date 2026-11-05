import Foundation
import Testing
@testable import WellSpentExtensionKit
#if canImport(SwiftUI)
import SwiftUI
#endif

/// A host that answers only the old calls, as a test double may until the
/// Houses screens move off them.
@MainActor
private final class OldHost: ExtensionHost {
    func today() -> Date { Date(timeIntervalSince1970: 0) }
    var calendar: Calendar { Calendar(identifier: .gregorian) }
    func groups(claimedBy extensionID: String) -> [HostGroup] { [] }
    func addGroup(named name: String, claimedBy extensionID: String) -> String? { nil }
    func budget(named name: String, in group: String) -> String? { nil }
    func period(of group: String) -> HostPeriod? { nil }
    func entries(in group: String) -> [HostEntry] { [] }
    func apply(_ batch: HostImport) {}
    #if canImport(SwiftUI)
    func smallWheel(for group: String) -> AnyView? { nil }
    #endif
}

@Suite("Extension host")
@MainActor
struct ExtensionHostTests {
    @Test func aHostWithOnlyTheOldCallsAnswersTheNewOnesWithNothing() {
        let host = OldHost()
        #expect(host.revision == 0)
        #expect(host.groups().isEmpty)
        #expect(host.addGroup(named: "Home") == nil)
        #expect(host.budgets(in: "g").isEmpty)
        #expect(host.records(kind: "house", .everyMember, in: "g", extensionID: "e").isEmpty)
        #expect(host.saveRecord(kind: "house", .everyMember, sourceKey: "1", id: nil, body: "{}", in: "g",
                                extensionID: "e") == nil)
    }

    /// An entry written the old way still says which way the money went.
    @Test func anEntrysSignFollowsItsKindUnlessGiven() {
        let bill = HostEntry(id: "a", date: Date(), amountMinorUnits: 500, isIncome: false, importFingerprint: nil)
        let income = HostEntry(id: "b", date: Date(), amountMinorUnits: 500, isIncome: true, importFingerprint: nil)
        let refund = HostEntry(id: "c", date: Date(), amountMinorUnits: 500, isIncome: false, importFingerprint: nil,
                               signedMinorUnits: 500, isSpendingOrRefund: true)
        #expect(bill.signedMinorUnits == -500)
        #expect(income.signedMinorUnits == 500)
        #expect(refund.signedMinorUnits == 500)
    }

    @Test func aGroupCannotBeManagedUnlessSaid() {
        #expect(!HostGroup(id: "g", name: "Home").canManage)
    }
}
