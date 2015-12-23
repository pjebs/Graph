//
// Copyright (C) 2015 CosmicMind, Inc. <http://cosmicmind.io>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program located at the root of the software package
// in a file called LICENSE.  If not, see <http://www.gnu.org/licenses/>.
//

import XCTest
@testable import GraphKit

class ActionStringTests : XCTestCase, GraphDelegate {
	
	private var graph: Graph!
	
	var saveExpectation: XCTestExpectation?
	var insertExpectation: XCTestExpectation?
	var insertPropertyExpectation: XCTestExpectation?
	var insertGroupExpectation: XCTestExpectation?
	var updatePropertyExpectation: XCTestExpectation?
	var deleteExpectation: XCTestExpectation?
	var deletePropertyExpectation: XCTestExpectation?
	var deleteGroupExpectation: XCTestExpectation?
	
	override func setUp() {
		super.setUp()
		graph = Graph()
		graph.delegate = self
		graph.watch(action: ["T"], group: ["G"], property: ["P"])
	}
	
	override func tearDown() {
		graph = nil
		super.tearDown()
	}
	
	func testAll() {
		let n: Action = Action(type: "T")
		n["P"] = "A"
		n.addGroup("G")
		
		saveExpectation = expectationWithDescription("Test: Save did not pass.")
		insertExpectation = expectationWithDescription("Test: Insert did not pass.")
		insertPropertyExpectation = expectationWithDescription("Test: Insert property did not pass.")
		insertGroupExpectation = expectationWithDescription("Test: Insert group did not pass.")
		
		graph.save { [unowned self] (success: Bool, error: NSError?) in
			XCTAssertTrue(success, "Cannot save the Graph: \(error)")
			self.saveExpectation?.fulfill()
		}
		
		waitForExpectationsWithTimeout(10, handler: nil)
		
		n["P"] = "B"
		
		saveExpectation = expectationWithDescription("Test: Save did not pass.")
		updatePropertyExpectation = expectationWithDescription("Test: Update did not pass.")
		
		graph.save { [unowned self] (success: Bool, error: NSError?) in
			XCTAssertTrue(success, "Cannot save the Graph: \(error)")
			self.saveExpectation?.fulfill()
		}
		
		waitForExpectationsWithTimeout(10, handler: nil)
		
		n.delete()
		
		saveExpectation = expectationWithDescription("Test: Save did not pass.")
		deleteExpectation = expectationWithDescription("Test: Delete did not pass.")
		deletePropertyExpectation = expectationWithDescription("Test: Delete property did not pass.")
		deleteGroupExpectation = expectationWithDescription("Test: Delete group did not pass.")
		
		graph.save { [unowned self] (success: Bool, error: NSError?) in
			XCTAssertTrue(success, "Cannot save the Graph: \(error)")
			self.saveExpectation?.fulfill()
		}
		
		waitForExpectationsWithTimeout(10, handler: nil)
	}
	
	func graphDidInsertAction(graph: Graph, action: Action) {
		XCTAssertTrue("T" == action.type)
		XCTAssertTrue(action["P"] as? String == "A")
		XCTAssertTrue(action.hasGroup("G"))
		insertExpectation?.fulfill()
	}
	
	func graphDidInsertActionProperty(graph: Graph, action: Action, property: String, value: AnyObject) {
		XCTAssertTrue("T" == action.type)
		XCTAssertTrue("P" == property)
		XCTAssertTrue("A" == value as? String)
		XCTAssertTrue(action[property] as? String == value as? String)
		insertPropertyExpectation?.fulfill()
	}
	
	func graphDidInsertActionGroup(graph: Graph, action: Action, group: String) {
		XCTAssertTrue("T" == action.type)
		XCTAssertTrue("G" == group)
		insertGroupExpectation?.fulfill()
	}
	
	func graphDidUpdateActionProperty(graph: Graph, action: Action, property: String, value: AnyObject) {
		XCTAssertTrue("T" == action.type)
		XCTAssertTrue("P" == property)
		XCTAssertTrue("B" == value as? String)
		XCTAssertTrue(action[property] as? String == value as? String)
		updatePropertyExpectation?.fulfill()
	}
	
	func graphDidDeleteAction(graph: Graph, action: Action) {
		XCTAssertTrue("T" == action.type)
		deleteExpectation?.fulfill()
	}
	
	func graphDidDeleteActionProperty(graph: Graph, action: Action, property: String, value: AnyObject) {
		XCTAssertTrue("T" == action.type)
		XCTAssertTrue("P" == property)
		XCTAssertTrue("B" == value as? String)
		deletePropertyExpectation?.fulfill()
	}
	
	func graphDidDeleteActionGroup(graph: Graph, action: Action, group: String) {
		XCTAssertTrue("T" == action.type)
		XCTAssertTrue("G" == group)
		deleteGroupExpectation?.fulfill()
	}
	
	func testPerformance() {
		self.measureBlock() {}
	}
}
