import Foundation
import IssueReporting
import OSLog
import SharingGRDB
import FoundationModels

private let logger: Logger = .init(
	subsystem: "Chat",
	category: "Database"
)

@Table
public struct Dialog: Identifiable, Sendable, Equatable, Codable {
	public let id: UUID
	public var title: String
	
	public init(id: UUID, title: String) {
		self.id = id
		self.title = title
	}
}

extension Dialog.Draft: Identifiable {}

@Table
public struct Message: Identifiable, Sendable, Equatable, Codable {
	public let id: UUID
	public var dialogID: Dialog.ID
	public var messageType: MessageType
	public let messageState: MessageState
	public let messageRole: MessageRole
	public var sendAt: Date
	public var text: String
	
	public init(
		id: UUID,
		dialogID: UUID,
		messageType: MessageType,
		messageState: MessageState,
		messageRole: MessageRole,
		sendAt: Date = .now,
		text: String
	) {
		self.id = id
		self.dialogID = dialogID
		self.messageType = messageType
		self.messageState = messageState
		self.messageRole = messageRole
		self.sendAt = sendAt
		self.text = text
	}
}

public enum MessageType: Int, Codable, QueryBindable {
	case text = 0
}

extension Message.Draft: Equatable {}

@Generable
public enum MessageRole: Int, Codable, QueryBindable, Hashable {
	case user = 0
	case assistant
	case system
}

public enum MessageState: Int, Codable, QueryBindable {
	case idle = 0
	case thinking
	case streaming
	case failed
	case success
	case cancelled
}

@Generable
public struct MessageGenerable {
	
	@Guide(description: "The role of the user who sent the message")
	public let role: MessageRole
	
	@Guide(description: "The content of the message")
	public let content: String
	
	public init(role: MessageRole, content: String) {
		self.role = role
		self.content = content
	}

	nonisolated public struct PartiallyGenerated: Identifiable, ConvertibleFromGeneratedContent {
			public var id: GenerationID
			public var role: MessageRole.PartiallyGenerated?
			public var content: String.PartiallyGenerated?
			nonisolated public init(_ content: FoundationModels.GeneratedContent) throws {
					self.id = content.id ?? GenerationID()
					self.role = try content.value(forProperty: "role")
					self.content = try content.value(forProperty: "content")
			}
	}
}

extension Message.Draft: Identifiable {}

public func chatDatabase() throws -> any DatabaseWriter {
	@Dependency(\.context) var context
    
	let database: any DatabaseWriter
    
	var configuration = Configuration()
	configuration.foreignKeysEnabled = true
	configuration.prepareDatabase { db in
		#if DEBUG
		db.trace(options: .profile) {
			if context == .preview {
				print($0.expandedDescription)
			} else {
				logger.debug("\($0.expandedDescription)")
			}
		}
		#endif
	}
    
	switch context {
	case .live:
		let path = URL.documentsDirectory.appending(component: "db.sqlite").path()
		logger.info("open \(path)")
		database = try DatabasePool(path: path, configuration: configuration)
	case .preview, .test:
		database = try DatabaseQueue(configuration: configuration)
	}
	var migrator = DatabaseMigrator()
	#if DEBUG
	migrator.eraseDatabaseOnSchemaChange = true
	#endif
	migrator.registerMigration("Create tables") { db in
		try #sql(
			"""
			CREATE TABLE "dialogs" (
			    "id" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE,
			    "title" TEXT NOT NULL DEFAULT ''
			) STRICT
			"""
		)
		.execute(db)
        
		try #sql(
			"""
			CREATE TABLE "messages" (
			    "id" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE,
			    "dialogID" TEXT NOT NULL,
			    "messageType" INTEGER NOT NULL DEFAULT 0,
			    "messageState" INTEGER NOT NULL DEFAULT 0,
			    "messageRole" INTEGER NOT NULL DEFAULT 0,
			    "sendAt" TEXT NOT NULL DEFAULT (datetime('now')),
			    "text" TEXT NOT NULL DEFAULT '', FOREIGN KEY("dialogID") REFERENCES "dialogs"("id") ON DELETE CASCADE
			) STRICT
			"""
		)
		.execute(db)
	}
    
	#if DEBUG
	migrator.registerMigration("Seed database") { db in
		try db.seed {
			@Dependency(\.date.now) var now
            let dialogsIDs = (0...2).map { _ in UUID() }
			Dialog(id: dialogsIDs[0], title: "General Chat")
			Dialog(id: dialogsIDs[1], title: "Support Inquiry")
			Dialog(id: dialogsIDs[2], title: "Fun with Assistant")
            
			// 添加一些消息（Message）
			Message(
				id: UUID(),
				dialogID: dialogsIDs[0],
				messageType: .text,
				messageState: .success,
				messageRole: .user,
				sendAt: now.addingTimeInterval(-600),
				text: "Hello! How are you?"
			)
			Message(
				id: UUID(),
				dialogID: dialogsIDs[0],
				messageType: .text,
				messageState: .success,
				messageRole: .assistant,
				sendAt: now.addingTimeInterval(-590),
				text: "I'm doing great! How can I help you today?"
			)
			Message(
				id: UUID(),
				dialogID: dialogsIDs[1],
				messageType: .text,
				messageState: .success,
				messageRole: .user,
				sendAt: now.addingTimeInterval(-1200),
				text: "I have an issue with my subscription."
			)
			Message(
				id: UUID(),
				dialogID: dialogsIDs[1],
				messageType: .text,
				messageState: .success,
				messageRole: .assistant,
				sendAt: now.addingTimeInterval(-1190),
				text: "I'm sorry to hear that. Could you tell me more?"
			)
			Message(
				id: UUID(),
				dialogID: dialogsIDs[2],
				messageType: .text,
				messageState: .success,
				messageRole: .user,
				sendAt: now.addingTimeInterval(-300),
				text: "Tell me a joke!"
			)
			Message(
				id: UUID(),
				dialogID: dialogsIDs[2],
				messageType: .text,
				messageState: .streaming,
				messageRole: .assistant,
				sendAt: now.addingTimeInterval(-295),
				text: "Why did the Swift developer go broke? Because they used optionals for all their money 💸"
			)
		}
	}
	#endif
    
	try migrator.migrate(database)
	return database
}
