import XCTest
import MainOffender

actor ThreadActor {
	private let executor = ThreadExecutor(name: "my thread")

	nonisolated var unownedExecutor: UnownedSerialExecutor {
		executor.asUnownedSerialExecutor()
	}

	func assumedThreadHashValue() -> Int {
		assumeIsolated { isolatedSelf in
			isolatedSelf.threadhHashValue
		}
	}

	func checkIsolation() {
		executor.checkIsolated()
	}

	var threadhHashValue: Int {
		Thread.current.hashValue
	}
}

final class ThreadExecutorTests: XCTestCase {
	func testAssumeIsolatedOnExecutorThread() async {
		let actor = ThreadActor()
		let assumed = await actor.assumedThreadHashValue()
		let direct = await actor.threadhHashValue

		XCTAssertEqual(assumed, direct)
	}

	func testCheckIsolatedOnExecutorThread() async {
		let actor = ThreadActor()

		await actor.checkIsolation()
	}

	func testConsistentThread() async {
		let actor = ThreadActor()
		let initial = await actor.threadhHashValue

		XCTAssertNotEqual(initial, Thread.current.hashValue)

		for _ in 0..<1000 {
			let value = await actor.threadhHashValue

			XCTAssertEqual(value, initial)
		}
	}
}
