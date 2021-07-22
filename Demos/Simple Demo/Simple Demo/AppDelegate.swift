//
//  AppDelegate.swift
//  Simple Demo
//
//  Created by Darren Ford on 22/7/21.
//

import Cocoa
import DSFQuickActionBar

@main
class AppDelegate: NSObject, NSApplicationDelegate {

	@IBOutlet var window: NSWindow!

	@IBOutlet weak var resultLabel: NSTextField!

	var currentSearch = ""

	lazy var quickActionBar: DSFQuickActionBar = {
		let b = DSFQuickActionBar()
		b.delegate = self
		return b
	}()

	private let allMountains: [Mountain] = mountainsRawData.components(separatedBy: .newlines).map { line in
		 let name = line.components(separatedBy: ",")[0]
		 return Mountain(name: name)
	}

	func applicationDidFinishLaunching(_ aNotification: Notification) {
		// Insert code here to initialize your application
		resultLabel.stringValue = ""
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}

	func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
		return true
	}

	@IBAction func showQuickActions(_ sender: Any) {
		resultLabel.stringValue = ""
		self.quickActionBar.present(
			in: self.window,
			placeholderText: "Search Mountains",
			searchImage: NSImage(named: "mountain-template")!)
	}

	@IBAction func showGlobalQuickActions(_ sender: Any) {
		resultLabel.stringValue = ""
		self.quickActionBar.presentOnMainScreen(
			placeholderText: "Search Mountains Globally",
			width: 800)
	}
}

class Mountain {
	let identifier = DSFQuickActionBar.ItemIdentifier()
	let name: String
	public init(name: String) {
		self.name = name
	}
}



extension AppDelegate: DSFQuickActionBarDelegate {

	func quickActionBar(_ quickActionBar: DSFQuickActionBar, itemsForSearchTerm term: String) -> [DSFQuickActionBar.ItemIdentifier] {

//		// Display ALL items when there's no search term
//		if term.isEmpty {
//			return allMountains.map { $0.identifier }
//		}

		self.currentSearch = term

		if term.isEmpty {
			return []
		}

		/// Return the item identifiers for the matching mountains
		let matches = allMountains
			.filter { $0.name.localizedCaseInsensitiveContains(term) }
			.sorted(by: { a, b in a.name < b.name } )
			.prefix(100)
			.map { $0.identifier }

		return [DSFQuickActionBar.ItemIdentifier](matches)
	}

	func quickActionBar(_ quickActionBar: DSFQuickActionBar, viewForIdentifier identifier: DSFQuickActionBar.ItemIdentifier) -> NSView? {

		// Find the item with the specified item identifier
		guard let mountain = allMountains.filter({ $0.identifier == identifier }).first else {
			return nil
		}

		let item = MountainCellQuickView()

		let searchText = currentSearch.lowercased()
		let attName = NSMutableAttributedString(string: mountain.name)

		if currentSearch.count > 0,
			let r = mountain.name.lowercased().range(of: searchText)
		{
			let ran = NSRange(r, in: mountain.name)
			attName.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: ran)
			attName.addAttribute(.font, value: NSFont.systemFont(ofSize: item.actionName.font?.pointSize ?? 23,
																 weight: .bold), range: ran)
			item.actionName.attributedStringValue = attName
			
		}

		item.actionDescription.stringValue = "\(mountain.name) description"

		return item
	}
	
	func quickActionBar(_ quickActionBar: DSFQuickActionBar, didSelectIdentifier item: DSFQuickActionBar.ItemIdentifier) {
		guard let mountain = allMountains.filter({ $0.identifier == item }).first else {
			fatalError()
		}
		resultLabel.stringValue = "Quick Action Bar selected '\(mountain.name)'"
	}

	func quickActionBarDidCancel(_ quickActionBar: DSFQuickActionBar) {
		resultLabel.stringValue = "Quick Action Bar cancelled"
	}

}
