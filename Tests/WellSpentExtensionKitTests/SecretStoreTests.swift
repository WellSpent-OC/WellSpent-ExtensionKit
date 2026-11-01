import Testing
import WellSpentExtensionKit

@Suite("Keeping a secret")
struct SecretStoreTests {
    @Test func aSecretKeptInMemoryCanBeReadChangedAndRemoved() throws {
        let store = InMemorySecretStore()
        #expect(store.secret(named: "key") == nil)
        try store.setSecret("one", named: "key")
        #expect(store.secret(named: "key") == "one")
        try store.setSecret("two", named: "key")
        #expect(store.secret(named: "key") == "two")
        store.removeSecret(named: "key")
        #expect(store.secret(named: "key") == nil)
    }

    @Test func anImportWithNothingInItIsEmpty() {
        #expect(HostImport().isEmpty)
        #expect(!HostImport(remove: ["entry"]).isEmpty)
    }
}
