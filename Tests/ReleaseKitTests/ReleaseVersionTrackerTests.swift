import Foundation
import Testing
@testable import ReleaseKit

@Suite(.serialized)
struct ReleaseVersionTrackerTests {
    private let keyPrefix = "test.releasekit"
    private var lastShownVersionKey: String { "\(self.keyPrefix).release.lastShownVersion" }
    private var hasLaunchedBeforeKey: String { "\(self.keyPrefix).hasLaunchedBefore" }

    private func makeUserDefaults() -> UserDefaults {
        UserDefaults(suiteName: UUID().uuidString)!
    }

    @Test
    func freshInstallDoesNotShowRelease() {
        let userDefaults = self.makeUserDefaults()
        let tracker = ReleaseVersionTracker(
            userDefaults: userDefaults,
            keyPrefix: self.keyPrefix,
            currentVersion: "1.7.0")

        #expect(tracker.shouldShowRelease() == false)
    }

    @Test
    func freshInstallSetsHasLaunchedBefore() {
        let userDefaults = self.makeUserDefaults()
        let tracker = ReleaseVersionTracker(
            userDefaults: userDefaults,
            keyPrefix: self.keyPrefix,
            currentVersion: "1.7.0")

        _ = tracker.shouldShowRelease()

        #expect(userDefaults.bool(forKey: self.hasLaunchedBeforeKey) == true)
    }

    @Test
    func freshInstallSetsLastShownVersion() {
        let userDefaults = self.makeUserDefaults()
        let tracker = ReleaseVersionTracker(
            userDefaults: userDefaults,
            keyPrefix: self.keyPrefix,
            currentVersion: "1.7.0")

        _ = tracker.shouldShowRelease()

        #expect(userDefaults.string(forKey: self.lastShownVersionKey) == "1.7.0")
    }

    @Test
    func existingUserSameVersionDoesNotShowRelease() {
        let userDefaults = self.makeUserDefaults()
        userDefaults.set(true, forKey: self.hasLaunchedBeforeKey)
        userDefaults.set("1.7.0", forKey: self.lastShownVersionKey)

        let tracker = ReleaseVersionTracker(
            userDefaults: userDefaults,
            keyPrefix: self.keyPrefix,
            currentVersion: "1.7.0")

        #expect(tracker.shouldShowRelease() == false)
    }

    @Test
    func existingUserNewVersionShowsRelease() {
        let userDefaults = self.makeUserDefaults()
        userDefaults.set(true, forKey: self.hasLaunchedBeforeKey)
        userDefaults.set("1.6.0", forKey: self.lastShownVersionKey)

        let tracker = ReleaseVersionTracker(
            userDefaults: userDefaults,
            keyPrefix: self.keyPrefix,
            currentVersion: "1.7.0")

        #expect(tracker.shouldShowRelease() == true)
    }

    @Test
    func existingUserNoLastVersionShowsRelease() {
        let userDefaults = self.makeUserDefaults()
        userDefaults.set(true, forKey: self.hasLaunchedBeforeKey)

        let tracker = ReleaseVersionTracker(
            userDefaults: userDefaults,
            keyPrefix: self.keyPrefix,
            currentVersion: "1.7.0")

        #expect(tracker.shouldShowRelease() == true)
    }

    @Test
    func markAsShownUpdatesLastShownVersion() {
        let userDefaults = self.makeUserDefaults()
        let tracker = ReleaseVersionTracker(
            userDefaults: userDefaults,
            keyPrefix: self.keyPrefix,
            currentVersion: "1.8.0")

        tracker.markAsShown()

        #expect(userDefaults.string(forKey: self.lastShownVersionKey) == "1.8.0")
    }

    @Test
    func afterMarkAsShownDoesNotShowRelease() {
        let userDefaults = self.makeUserDefaults()
        userDefaults.set(true, forKey: self.hasLaunchedBeforeKey)
        userDefaults.set("1.6.0", forKey: self.lastShownVersionKey)

        let tracker = ReleaseVersionTracker(
            userDefaults: userDefaults,
            keyPrefix: self.keyPrefix,
            currentVersion: "1.7.0")

        #expect(tracker.shouldShowRelease() == true)

        tracker.markAsShown()

        #expect(tracker.shouldShowRelease() == false)
    }

    @Test
    func versionUpgradePath() {
        let userDefaults = self.makeUserDefaults()
        userDefaults.set(true, forKey: self.hasLaunchedBeforeKey)
        userDefaults.set("1.5.0", forKey: self.lastShownVersionKey)

        let tracker160 = ReleaseVersionTracker(
            userDefaults: userDefaults,
            keyPrefix: self.keyPrefix,
            currentVersion: "1.6.0")
        #expect(tracker160.shouldShowRelease() == true)
        tracker160.markAsShown()

        let tracker170 = ReleaseVersionTracker(
            userDefaults: userDefaults,
            keyPrefix: self.keyPrefix,
            currentVersion: "1.7.0")
        #expect(tracker170.shouldShowRelease() == true)
        tracker170.markAsShown()

        let tracker170Again = ReleaseVersionTracker(
            userDefaults: userDefaults,
            keyPrefix: self.keyPrefix,
            currentVersion: "1.7.0")
        #expect(tracker170Again.shouldShowRelease() == false)

        let tracker180 = ReleaseVersionTracker(
            userDefaults: userDefaults,
            keyPrefix: self.keyPrefix,
            currentVersion: "1.8.0")
        #expect(tracker180.shouldShowRelease() == true)
    }

    @Test
    func keyPrefixIsolation() {
        let userDefaults = self.makeUserDefaults()
        let appA = ReleaseVersionTracker(
            userDefaults: userDefaults,
            keyPrefix: "com.example.appA",
            currentVersion: "1.0.0")
        let appB = ReleaseVersionTracker(
            userDefaults: userDefaults,
            keyPrefix: "com.example.appB",
            currentVersion: "2.0.0")

        _ = appA.shouldShowRelease()
        appA.markAsShown()

        #expect(appB.shouldShowRelease() == false)
    }
}
