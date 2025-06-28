import SharingGRDB
import Foundation
import IssueReporting
import OSLog

private let logger: Logger = .init(
    subsystem: "Chat",
    category: "Database"
)

@Table
public struct Dialog: Hashable, Identifiable {
	@Column(as: UUID.BytesRepresentation.self)
	public let id: UUID
	public var title: String
}

extension Dialog.Draft: Identifiable {}

@Table
public struct Message: Hashable, Identifiable {
	@Column(as: UUID.BytesRepresentation.self)
    public let id: UUID
	@Column(as: UUID.BytesRepresentation.self)
    public var dialogID: Dialog.ID
    public var messageType: MessageType
    public let messageState: MessageState
    public let messageRole: MessageRole
    public var sendAt: Date = Date()
    public var text: String
}

public enum MessageType: Int, Codable, QueryBindable {
    case text = 0
}

public enum MessageRole: Int, Codable, QueryBindable {
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
                "id" BLOB PRIMARY KEY,
                "title" TEXT NOT NULL DEFAULT ''
            ) STRICT
            """
        )
        .execute(db)
        
        try #sql(
            """
            CREATE TABLE "messages" (
                "id" BLOB PRIMARY KEY,
                "dialogID" BLOB NOT NULL REFERENCES "dialogs"("id") ON DELETE CASCADE,
                "messageType" INTEGER NOT NULL DEFAULT 0,
                "messageState" INTEGER NOT NULL DEFAULT 0,
                "messageRole" INTEGER NOT NULL DEFAULT 0,
                "sendAt" TEXT NOT NULL DEFAULT (datetime('now')),
                "text" TEXT NOT NULL DEFAULT ''
            ) STRICT
            """
        )
        .execute(db)
    }
    
    #if DEBUG
    migrator.registerMigration("Seed database") { db in
        try db.seed {
            @Dependency(\.uuid) var uuid
            @Dependency(\.date.now) var now
						let dialog1 = Dialog(id: uuid(), title: "General Chat")
            let dialog2 = Dialog(id: uuid(), title: "Support Inquiry")
            let dialog3 = Dialog(id: uuid(), title: "Fun with Assistant")
            
            dialog1
            dialog2
            dialog3
            
            // 添加一些消息（Message）
            Message(
                id: uuid(),
                dialogID: dialog1.id,
                messageType: .text,
                messageState: .success,
                messageRole: .user,
                sendAt: now.addingTimeInterval(-600),
                text: "Hello! How are you?"
            )
            Message(
                id: uuid(),
                dialogID: dialog1.id,
                messageType: .text,
                messageState: .success,
                messageRole: .assistant,
                sendAt: now.addingTimeInterval(-590),
                text: "I'm doing great! How can I help you today?"
            )
            Message(
                id: uuid(),
                dialogID: dialog2.id,
                messageType: .text,
                messageState: .success,
                messageRole: .user,
                sendAt: now.addingTimeInterval(-1200),
                text: "I have an issue with my subscription."
            )
            Message(
                id: uuid(),
                dialogID: dialog2.id,
                messageType: .text,
                messageState: .success,
                messageRole: .assistant,
                sendAt: now.addingTimeInterval(-1190),
                text: "I'm sorry to hear that. Could you tell me more?"
            )
            Message(
                id: uuid(),
                dialogID: dialog3.id,
                messageType: .text,
                messageState: .success,
                messageRole: .user,
                sendAt: now.addingTimeInterval(-300),
                text: "Tell me a joke!"
            )
            Message(
                id: uuid(),
                dialogID: dialog3.id,
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
