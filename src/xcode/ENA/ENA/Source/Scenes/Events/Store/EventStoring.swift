////
// 🦠 Corona-Warn-App
//

import OpenCombine

enum EventStoringError: Error {
	case database(SQLiteErrorCode)
	case timeout
}

protocol EventStoring {

	typealias IdResult = Result<Int, EventStoringError>
	typealias VoidResult = Result<Void, EventStoringError>

	@discardableResult
	func createEvent(
		// The ID of the event. Note that the ID is generated by the CWA server. It is stored as base64-encoded string of the guid attribute of Protocol Buffer message Event.
		id: String,
		description: String,
		address: String,
		start: Date,
		end: Date,
		defaultCheckInLengthInMinutes: Int,
		// The signature of the event (provided by the CWA server). It is stored as a base64-encoded string of the signature attribute of Protocol Buffer message SignedEvent.
		signature: String
	) -> VoidResult

	@discardableResult
	func deleteEvent(
		id: String
	) -> VoidResult

	// swiftlint:disable function_parameter_count
	@discardableResult
	func createCheckin(
		eventId: String, // The ID of the event. Note that the ID is generated by the CWA server. It is stored as base64-encoded string of the guid attribute of Protocol Buffer message Event.
		eventType: Int,
		eventDescription: String,
		eventAddress: String,
		eventStart: Date,
		eventEnd: Date,
		eventSignature: String, // The signature of the event (provided by the CWA server). It is stored as a base64-encoded string of the signature attribute of Protocol Buffer message SignedEvent.
		checkinStart: Date,
		checkinEnd: Date
	) -> IdResult

	@discardableResult
	func deleteCheckin(
		id: Int
	) -> VoidResult

	@discardableResult
	func updateCheckin(
		id: Int,
		end: Date
	) -> VoidResult
}

protocol EventProviding {
	var eventsPublisher: OpenCombine.CurrentValueSubject<[Event], Never> { get }
	var checkingPublisher: OpenCombine.CurrentValueSubject<[Checkin], Never> { get }
}
