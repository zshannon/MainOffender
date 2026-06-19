#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif
import Foundation
import Synchronization

final class ThreadRunLoop: Sendable {
	private struct RunLoopContext: @unchecked Sendable {
		let pthread: pthread_t
		let runLoop: CFRunLoop
		let source: CFRunLoopSource
	}

	private let context: RunLoopContext
	private let semaphore: DispatchSemaphore

	init(name: String? = nil) {
		let context = Mutex<RunLoopContext?>(nil)
		let semaphore = DispatchSemaphore(value: 0)

		Thread.detachNewThread {
			let thread = Thread.current

			if let name {
				thread.name = name
			}

			guard let loop = CFRunLoopGetCurrent() else {
				fatalError("Unable to create runloop in thread")
			}

			let source = Self.createEmptySource()

			CFRunLoopAddSource(loop, source, CFRunLoopMode.defaultMode)

			context.withLock {
				$0 = RunLoopContext(pthread: pthread_self(), runLoop: loop, source: source)
			}
			semaphore.signal()

			CFRunLoopRun()
		}

		semaphore.wait()
		semaphore.signal() // increment it again for future work

		self.semaphore = semaphore
		self.context = context.withLock { $0! }
	}

	func checkIsolated() {
		guard pthread_equal(pthread_self(), context.pthread) != 0 else {
			fatalError("Incorrect ThreadExecutor isolation")
		}
	}

	static func createEmptySource() -> CFRunLoopSource {
		var sourceContext = CFRunLoopSourceContext(
			version: 0,
			info: nil,
			retain: nil,
			release: nil,
			copyDescription: nil,
			equal: nil,
			hash: nil,
			schedule: { _, _, _ in
			},
			cancel: { _, _, _ in
			},
			perform: { _ in
			}
		)

		return CFRunLoopSourceCreate(kCFAllocatorDefault, 0, &sourceContext)!
	}

	deinit {
		CFRunLoopStop(context.runLoop)
	}

	func perform(_ work: @escaping @Sendable () -> Void) {
		// it does not appear necessary to actually call `CFRunLoopSourceSignal(context.source)`.
		// But, as documented in `CFRunLoopPerformBlock`, the runloop does need to be
		// woken up.

		semaphore.wait()

		CFRunLoopPerformBlock(context.runLoop, CFRunLoopMode.defaultMode.rawValue, work)
		CFRunLoopWakeUp(context.runLoop)

		semaphore.signal()
	}
}



/// A `SerialExecutor` that runs jobs on a private thread with an active CFRunLoop
public final class ThreadExecutor: SerialExecutor {
	private let thread: ThreadRunLoop

	public init(name: String? = nil) {
		self.thread = ThreadRunLoop(name: name)
	}

	public func asUnownedSerialExecutor() -> UnownedSerialExecutor {
		UnownedSerialExecutor(ordinary: self)
	}

	public func enqueue(_ job: UnownedJob) {
		let unownedExecutor = asUnownedSerialExecutor()

		thread.perform {
			job.runSynchronously(on: unownedExecutor)
		}
	}

	public func checkIsolated() {
		thread.checkIsolated()
	}

//	@available(macOS 14.0, *)
//	public func enqueue(_ job: consuming ExecutorJob) {
//		let unownedJob = UnownedJob(job)
//		let unownedExecutor = asUnownedSerialExecutor()
//
//		thread.perform {
//			unownedJob.runSynchronously(on: unownedExecutor)
//		}
//	}
}
