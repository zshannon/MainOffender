extension MainActor {
	/// A version of `assumeIsolated` that does not require a `Sendable` result.
	///
	/// It is not possible for the result to cross an isolation boundary, because if the calling isolation was different, the function causes a fatal error.
	@_unavailableFromAsync
	static func relaxedAssumeIsolated<Output, Argument, Failure: Error>(
		_ argument: Argument,
		_ operation: @MainActor (Argument) throws(Failure) -> Output,
		file: StaticString = #fileID,
		line: UInt = #line
	) rethrows -> Output {
		nonisolated(unsafe) var output: Output? = nil
		nonisolated(unsafe) let input = argument

		try assumeIsolated(
			{ output = try operation(input) },
			file: file,
			line: line
		)

		return output!
	}

	/// A version of `assumeIsolated` that does not require a `Sendable` result.
	///
	/// It is not possible for the result to cross an isolation boundary, because if the calling isolation was different, the function causes a fatal error.
	@_unavailableFromAsync
	static func relaxedAssumeIsolated<Output, Failure: Error>(
		_ operation: @MainActor () throws(Failure) -> Output,
		file: StaticString = #fileID,
		line: UInt = #line
	) rethrows -> Output {
		nonisolated(unsafe) var output: Output? = nil

		try assumeIsolated(
			{ output = try operation() },
			file: file,
			line: line
		)

		return output!
	}
}
