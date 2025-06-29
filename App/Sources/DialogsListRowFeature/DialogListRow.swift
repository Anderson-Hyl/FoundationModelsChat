import SwiftUI
import SharingGRDB
import Schema

@Selection
public struct DialogListRow: Equatable, Sendable, Identifiable {
	public let dialog: Dialog
	public let lastMessage: Message?
	public init(dialog: Dialog, lastMessage: Message?) {
		self.dialog = dialog
		self.lastMessage = lastMessage
	}
	public var id: UUID {
		dialog.id
	}
}

public struct DialogListRowView: View {
	let row: DialogListRow
	public init(row: DialogListRow) {
		self.row = row
	}
	public var body: some View {
		HStack {
			Image(systemName: "person.crop.circle")
				.resizable()
				.frame(width: 54, height: 54)
			VStack(alignment: .leading, spacing: 4) {
				Text(row.dialog.title)
					.font(.title2)
					.fontWeight(.medium)
					.fontDesign(.rounded)
				if let lastMessage = row.lastMessage {
					HStack {
						Text(lastMessage.text)
							.font(.body)
							.foregroundStyle(Color.secondary.gradient)
						Spacer()
						Text(lastMessage.sendAt, style: .time)
							.foregroundStyle(Color.secondary.opacity(0.6))
					}
				}
			}
		}
		.padding()
		.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
	}
}

#Preview {
	@Previewable @State var row: DialogListRow = DialogListRow(
		dialog: Dialog(
			id: UUID(0),
			title: "Let's have a dialog"
		),
		lastMessage: Message(
			id: UUID(10),
			dialogID: UUID(0),
			messageType: .text,
			messageState: .success,
			messageRole: .assistant,
			sendAt: Date(),
			text: "Good morning"
		)
	)
	
	DialogListRowView(row: row)
}
