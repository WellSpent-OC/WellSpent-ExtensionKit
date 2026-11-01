import Foundation
#if canImport(SwiftUI)
import SwiftUI
#endif

/// What an extension may read from and write to a person's budget, through
/// the app. Plain values only, so an extension never depends on the app's own
/// types, and the app never depends on an extension's. Ids are the app's ids
/// written as text.
@MainActor
public protocol ExtensionHost: AnyObject {
    /// Today, as the app counts it.
    func today() -> Date
    /// The calendar the app counts months and days with.
    var calendar: Calendar { get }

    /// The groups this extension has claimed, in the app's order.
    func groups(claimedBy extensionID: String) -> [HostGroup]
    /// A new group, claimed by the extension. Nil when it could not be made.
    func addGroup(named name: String, claimedBy extensionID: String) -> String?
    /// The group's budget with this name, made with no limit if it is not
    /// there yet, and made without opening it. Nil when it could not be made.
    func budget(named name: String, in group: String) -> String?

    /// The group's money this period. Nil when the group has no budgets, or
    /// its period has no end.
    func period(of group: String) -> HostPeriod?
    /// Every entry in the group, money in and money out.
    func entries(in group: String) -> [HostEntry]
    /// Adds, changes and removes entries in one step, as an import does.
    func apply(_ batch: HostImport)

    #if canImport(SwiftUI)
    /// The group's small money wheel, as the app draws it on Home. Nil when
    /// the group has no wheel this period.
    func smallWheel(for group: String) -> AnyView?
    #endif
}

/// A group of budgets.
public struct HostGroup: Equatable, Sendable {
    public let id: String
    public let name: String

    public init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}

/// A group's money this period, and where today falls in it.
public struct HostPeriod: Equatable, Sendable {
    /// The currency's code, "USD".
    public let currency: String
    /// What the group has spent this period, in minor units.
    public let moneyOutMinorUnits: Int
    /// Today, counted from 1.
    public let day: Int
    /// The days in the period.
    public let days: Int
    /// The start of the period's first day.
    public let start: Date

    public init(currency: String, moneyOutMinorUnits: Int, day: Int, days: Int, start: Date) {
        self.currency = currency
        self.moneyOutMinorUnits = moneyOutMinorUnits
        self.day = day
        self.days = days
        self.start = start
    }
}

/// An entry already in the budget.
public struct HostEntry: Equatable, Sendable {
    public let id: String
    public let date: Date
    /// Always positive. `isIncome` says which way it goes.
    public let amountMinorUnits: Int
    public let isIncome: Bool
    /// What an import marked the entry with, so the next import knows it.
    public let importFingerprint: String?

    public init(id: String, date: Date, amountMinorUnits: Int, isIncome: Bool, importFingerprint: String?) {
        self.id = id
        self.date = date
        self.amountMinorUnits = amountMinorUnits
        self.isIncome = isIncome
        self.importFingerprint = importFingerprint
    }
}

/// What an import adds, changes and removes.
public struct HostImport: Equatable, Sendable {
    /// A new entry for a budget in a group.
    public struct Add: Equatable, Sendable {
        public let budget: String
        public let group: String
        public let date: Date
        public let merchant: String
        public let note: String
        public let amountMinorUnits: Int
        public let currency: String
        public let isIncome: Bool
        public let importFingerprint: String

        public init(budget: String, group: String, date: Date, merchant: String, note: String,
                    amountMinorUnits: Int, currency: String, isIncome: Bool, importFingerprint: String) {
            self.budget = budget
            self.group = group
            self.date = date
            self.merchant = merchant
            self.note = note
            self.amountMinorUnits = amountMinorUnits
            self.currency = currency
            self.isIncome = isIncome
            self.importFingerprint = importFingerprint
        }
    }

    /// A new amount, date and note for an entry already there.
    public struct Change: Equatable, Sendable {
        public let entry: String
        public let amountMinorUnits: Int
        public let currency: String
        public let date: Date
        public let note: String

        public init(entry: String, amountMinorUnits: Int, currency: String, date: Date, note: String) {
            self.entry = entry
            self.amountMinorUnits = amountMinorUnits
            self.currency = currency
            self.date = date
            self.note = note
        }
    }

    public let add: [Add]
    public let change: [Change]
    /// The ids of entries to remove.
    public let remove: [String]

    public init(add: [Add] = [], change: [Change] = [], remove: [String] = []) {
        self.add = add
        self.change = change
        self.remove = remove
    }

    public var isEmpty: Bool { add.isEmpty && change.isEmpty && remove.isEmpty }
}
