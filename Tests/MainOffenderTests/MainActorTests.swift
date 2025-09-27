import Testing
import MainOffender

struct MainActorTests {
	class NonSendable {
	}

	nonisolated func removeIsolation(_ body: @escaping @Sendable () -> Void) {
		body()
	}

	@Test @MainActor
	func relaxedAssumeIsolatedWithOptional() async throws {
		removeIsolation {
			let value: NonSendable? = MainActor.relaxedAssumeIsolated {
				NonSendable()
			}

			#expect(value != nil)
		}
	}
}
