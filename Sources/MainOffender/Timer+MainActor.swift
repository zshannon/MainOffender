import Foundation

extension Timer {
	@MainActor
	public static func scheduledMainActorTimer(
		interval: TimeInterval,
		repeats: Bool,
		block: @escaping @MainActor (Timer) -> Void
	) -> Timer {
		Timer.scheduledTimer(withTimeInterval: interval, repeats: repeats) { timer in
			nonisolated(unsafe) let unsafeTimer = timer

			MainActor.assumeIsolated { block(unsafeTimer) }
		}
	}
}
