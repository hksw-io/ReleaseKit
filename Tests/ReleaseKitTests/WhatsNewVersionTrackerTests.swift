import Foundation
import Testing
@testable import ReleaseKit

@Suite(.serialized)
struct WhatsNewVersionTrackerTests {
    private let keyPrefix = "test.whatsnewkit"
    private var lastShownVersionKey: String { "\(self.keyPrefix).whatsNew.lastShownVersion" }
    private var hasLaunchedBeforeKey: String { "\(self.keyPrefix).hasLaunchedBefore" }

    private func makeUserDefaults() -> UserDefaults {
        UserDefaults(suiteName: UUID().uuidString)!
    }

    @Test
    func freshInstallDoesNotShowWhatsNew() {
        let userDefaults = self.makeUserDefaults()
        let tracker = WhatsNewVersionTracker(
            userDefaults: userDefaults,
            keyPrefix: self.keyPrefix,
            currentVersion: "1.7.0")

        #expect(tracker.shouldShowWhatsNew() == false)
    }

    @Test
    func freshInstallSetsHasLaunchedBefore() {
        let userDefaults = self.makeUserDefaults()
        let tracker = WhatsNewVersionTracker(
            userDefaults: userDefaults,
            keyPrefix: self.keyPrefix,
            currentVersion: "1.7.0")

        _ = tracker.shouldShowWhatsNew()

        #expect(userDefaults.bool(forKey: self.hasLaunchedBeforeKey) == true)
    }

    @Test
    func freshInstallSetsLastShownVersion() {
        let userDefaults = self.makeUserDefaults()
        let tracker = WhatsNewVersionTracker(
            userDefaults: userDefaults,
            keyPrefix: self.keyPrefix,
            currentVersion: "1.7.0")

        _ = tracker.shouldShowWhatsNew()

        #expect(userDefaults.string(forKey: self.lastShownVersionKey) == "1.7.0")
    }

    @Test
    func existingUserSameVersionDoesNotShowWhatsNew() {
        let userDefaults = self.makeUserDefaults()
        userDefaults.set(true, forKey: self.hasLaunchedBeforeKey)
        userDefaults.set("1.7.0", forKey: self.lastShownVersionKey)

        let tracker = WhatsNewVersionTracker(
            userDefaults: userDefaults,
            keyPrefix: self.keyPrefix,
            currentVersion: "1.7.0")

        #expect(tracker.shouldShowWhatsNew() == false)
    }

    @Test
    func existingUserNewVersionShowsWhatsNew() {
        let userDefaults = self.makeUserDefaults()
        userDefaults.set(true, forKey: self.hasLaunchedBeforeKey)
        userDefaults.set("1.6.0", forKey: self.lastShownVersionKey)

        let tracker = WhatsNewVersionTracker(
            userDefaults: userDefaults,
            keyPrefix: self.keyPrefix,
            currentVersion: "1.7.0")

        #expect(tracker.shouldShowWhatsNew() == true)
    }

    @Test
    func existingUserNoLastVersionShowsWhatsNew() {
        let userDefaults = self.makeUserDefaults()
        userDefaults.set(true, forKey: self.hasLaunchedBeforeKey)

        let tracker = WhatsNewVersionTracker(
            userDefaults: userDefaults,
            keyPrefix: self.keyPrefix,
            currentVersion: "1.7.0")

        #expect(tracker.shouldShowWhatsNew() == true)
    }

    @Test
    func markAsShownUpdatesLastShownVersion() {
        let userDefaults = self.makeUserDefaults()
        let tracker = WhatsNewVersionTracker(
            userDefaults: userDefaults,
            keyPrefix: self.keyPrefix,
            currentVersion: "1.8.0")

        tracker.markAsShown()

        #expect(userDefaults.string(forKey: self.lastShownVersionKey) == "1.8.0")
    }

    @Test
    func afterMarkAsShownDoesNotShowWhatsNew() {
        let userDefaults = self.makeUserDefaults()
        userDefaults.set(true, forKey: self.hasLaunchedBeforeKey)
        userDefaults.set("1.6.0", forKey: self.lastShownVersionKey)

        let tracker = WhatsNewVersionTracker(
            userDefaults: userDefaults,
            keyPrefix: self.keyPrefix,
            currentVersion: "1.7.0")

        #expect(tracker.shouldShowWhatsNew() == true)

        tracker.markAsShown()

        #expect(tracker.shouldShowWhatsNew() == false)
    }

    @Test
    func versionUpgradePath() {
        let userDefaults = self.makeUserDefaults()
        userDefaults.set(true, forKey: self.hasLaunchedBeforeKey)
        userDefaults.set("1.5.0", forKey: self.lastShownVersionKey)

        let tracker160 = WhatsNewVersionTracker(
            userDefaults: userDefaults,
            keyPrefix: self.keyPrefix,
            currentVersion: "1.6.0")
        #expect(tracker160.shouldShowWhatsNew() == true)
        tracker160.markAsShown()

        let tracker170 = WhatsNewVersionTracker(
            userDefaults: userDefaults,
            keyPrefix: self.keyPrefix,
            currentVersion: "1.7.0")
        #expect(tracker170.shouldShowWhatsNew() == true)
        tracker170.markAsShown()

        let tracker170Again = WhatsNewVersionTracker(
            userDefaults: userDefaults,
            keyPrefix: self.keyPrefix,
            currentVersion: "1.7.0")
        #expect(tracker170Again.shouldShowWhatsNew() == false)

        let tracker180 = WhatsNewVersionTracker(
            userDefaults: userDefaults,
            keyPrefix: self.keyPrefix,
            currentVersion: "1.8.0")
        #expect(tracker180.shouldShowWhatsNew() == true)
    }

    @Test
    func keyPrefixIsolation() {
        let userDefaults = self.makeUserDefaults()
        let appA = WhatsNewVersionTracker(
            userDefaults: userDefaults,
            keyPrefix: "com.example.appA",
            currentVersion: "1.0.0")
        let appB = WhatsNewVersionTracker(
            userDefaults: userDefaults,
            keyPrefix: "com.example.appB",
            currentVersion: "2.0.0")

        _ = appA.shouldShowWhatsNew()
        appA.markAsShown()

        #expect(appB.shouldShowWhatsNew() == false)
    }
}
