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


    /// The group's money this period. Nil when the group has no budgets, or
    /// its period has no end.
    func period(of group: String) -> HostPeriod?
    /// Every entry in the group, money in and money out.
    func entries(in group: String) -> [HostEntry]
    /// Adds, changes and removes entries in one step, as an import does.
    func apply(_ batch: HostImport)

    #if canImport(SwiftUI)
    /// A wheel drawn from these values, at this size.
    func wheel(_ values: HostWheel, size: HostWheelSize) -> AnyView?
    /// The app's locked card for one of this extension's records, such as a
    /// house, when the person's plan has locked it. The extension draws it in
    /// place of the record's page. Nil when the record is open.
    func lockedPage(for record: String) -> AnyView?
    #endif

    // MARK: - The whole group, with an extension's own records

    /// Goes up whenever something the host answers may have changed, from a
    /// sync or from an edit on this device. Read it while drawing to redraw.
    var revision: Int { get }
    /// Every group this person is in, in the app's order.
    func groups() -> [HostGroup]
    /// A new plain group, with no budgets. Nil when it could not be made.
    func addGroup(named name: String) -> String?
    /// The group's budgets, with their limits.
    func budgets(in group: String) -> [HostBudget]
    /// This extension's live records of one kind in a group.
    func records(kind: String, _ visibility: HostRecord.Visibility, in group: String,
                 extensionID: String) -> [HostRecord]
    /// Saves one of this extension's records and gives back its id. With a
    /// source key, the same key in the same group is the same record. Saved
    /// again with nothing changed, it sends nothing. Nil when it could not be
    /// saved, as for someone below Manage level.
    @discardableResult
    func saveRecord(kind: String, _ visibility: HostRecord.Visibility, sourceKey: String?, id: String?, body: String,
                    in group: String, extensionID: String) -> String?
    /// Removes one of this extension's records.
    func removeRecord(_ id: String, _ visibility: HostRecord.Visibility)
    /// Opens the normal entry sheet to add a bill in the group, with this
    /// record filled in as what it is for, or left to choose when nil.
    func newEntry(linkedTo record: String?, in group: String)
    /// Opens the normal entry sheet on an entry already there.
    func openEntry(_ id: String)
}

/// What an extension adds to the app's own screens. The app asks, and an
/// extension with nothing to add answers nil, so the app draws nothing.
@MainActor
public protocol ExtensionSlots: AnyObject {
    /// What the entry sheet offers to link an entry to in this group.
    func linkChoices(in group: String) -> HostLinkChoices?
    /// The line at the top of a group's page on the iPhone, which scrolls to
    /// the extension's section.
    func groupPageTopLine(for group: String) -> HostTopLine?
    /// The records in these groups that count toward the person's plan, such
    /// as houses, by id and name, for the plan's pick screen and plan card.
    /// Empty for an extension whose records the plan doesn't count.
    func planRecords(in groups: Set<String>) -> [HostLinkChoices.Choice]
    #if canImport(SwiftUI)
    /// The extension's section of a group's page. Its first row carries
    /// `HostScrollID.groupPageSection`.
    func groupPageSection(for group: String) -> AnyView?
    #endif
}

/// The line at the top of a group's page: the words on one side, the amount
/// on the other, so a narrow phone never wraps in the middle of the amount.
public struct HostTopLine: Equatable, Sendable {
    public let text: String
    public let amount: String
    /// Whether the amount shows in the warning colour.
    public let isWarning: Bool

    public init(text: String, amount: String, isWarning: Bool) {
        self.text = text
        self.amount = amount
        self.isWarning = isWarning
    }
}

/// Where a group page's top line scrolls to.
public enum HostScrollID {
    public static let groupPageSection = "extension.group-page-section"
}

/// A budget in a group.
public struct HostBudget: Equatable, Sendable {
    public let id: String
    public let name: String
    public let limitMinorUnits: Int
    /// The currency's code, "USD".
    public let currency: String

    public init(id: String, name: String, limitMinorUnits: Int, currency: String) {
        self.id = id
        self.name = name
        self.limitMinorUnits = limitMinorUnits
        self.currency = currency
    }
}

/// A record that belongs to an extension. The app stores and syncs it, and
/// only the extension reads `body`.
public struct HostRecord: Equatable, Sendable {
    /// Who sees it.
    public enum Visibility: Equatable, Sendable {
        case everyMember
        /// As a transaction: a member who joined "from now on" sees only later ones.
        case followsHistory
    }

    public let id: String
    public let group: String
    public let kind: String
    public let sourceKey: String?
    public let body: String
    /// Who saved it last, by the name they gave the group. Nil when it was this
    /// person, or when it hasn't synced.
    public let savedBy: String?
    /// When it was saved last.
    public let savedAt: Date?

    public init(id: String, group: String, kind: String, sourceKey: String?, body: String,
                savedBy: String? = nil, savedAt: Date? = nil) {
        self.id = id
        self.group = group
        self.kind = kind
        self.sourceKey = sourceKey
        self.body = body
        self.savedBy = savedBy
        self.savedAt = savedAt
    }
}

/// What a person can link an entry to.
public struct HostLinkChoices: Equatable, Sendable {
    public struct Choice: Equatable, Sendable {
        public let id: String
        public let name: String

        public init(id: String, name: String) {
            self.id = id
            self.name = name
        }
    }

    /// The row's title, such as "House". The app has no word of its own for it.
    public let label: String
    public let choices: [Choice]

    public init(label: String, choices: [Choice]) {
        self.label = label
        self.choices = choices
    }
}

/// How big a wheel is drawn.
public enum HostWheelSize: Equatable, Sendable {
    case homeCard
    case budgetPage
    case budgetPhone
}

/// What a wheel shows: what is planned, and what covers it.
public struct HostWheel: Equatable, Sendable {
    /// The currency's code, "USD".
    public let currency: String
    public let plannedMinorUnits: Int
    public let coversMinorUnits: Int

    public init(currency: String, plannedMinorUnits: Int, coversMinorUnits: Int) {
        self.currency = currency
        self.plannedMinorUnits = plannedMinorUnits
        self.coversMinorUnits = coversMinorUnits
    }
}

/// A group of budgets.
public struct HostGroup: Equatable, Sendable {
    public let id: String
    public let name: String
    /// Whether this person may change the group: Manage level or higher.
    public let canManage: Bool
    /// Whether this person may add entries to the group.
    public let canAddEntries: Bool
    /// Who else is in it, as the app words it. Nil for a group of one.
    public let sharingLine: String?

    public init(id: String, name: String, canManage: Bool = false, canAddEntries: Bool = false,
                sharingLine: String? = nil) {
        self.id = id
        self.name = name
        self.canManage = canManage
        self.canAddEntries = canAddEntries
        self.sharingLine = sharingLine
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
    /// The budget it sits in.
    public let budget: String?
    /// The record it is linked to, such as a house.
    public let link: String?
    /// The amount with its sign: negative is money out, so a refund is positive.
    public let signedMinorUnits: Int
    /// Whether it counts against a budget: spending or a refund.
    public let isSpendingOrRefund: Bool
    public let merchant: String
    /// Who added it, as the app words it, such as "you" or a member's name.
    public let addedBy: String?

    public init(id: String, date: Date, amountMinorUnits: Int, isIncome: Bool, importFingerprint: String?,
                budget: String? = nil, link: String? = nil, signedMinorUnits: Int? = nil,
                isSpendingOrRefund: Bool = false, merchant: String = "", addedBy: String? = nil) {
        self.id = id
        self.date = date
        self.amountMinorUnits = amountMinorUnits
        self.isIncome = isIncome
        self.importFingerprint = importFingerprint
        self.budget = budget
        self.link = link
        self.signedMinorUnits = signedMinorUnits ?? (isIncome ? amountMinorUnits : -amountMinorUnits)
        self.isSpendingOrRefund = isSpendingOrRefund
        self.merchant = merchant
        self.addedBy = addedBy
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
