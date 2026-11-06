import Foundation
import Testing
@testable import WellSpentExtensionKit
@Suite("Extension host")
@MainActor
struct ExtensionHostTests {
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
