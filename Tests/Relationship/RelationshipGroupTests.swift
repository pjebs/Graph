/*
 * Copyright (C) 2015 - 2018, Daniel Dahan and CosmicMind, Inc. <http://cosmicmind.com>.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *	*	Redistributions of source code must retain the above copyright notice, this
 *		list of conditions and the following disclaimer.
 *
 *	*	Redistributions in binary form must reproduce the above copyright notice,
 *		this list of conditions and the following disclaimer in the documentation
 *		and/or other materials provided with the distribution.
 *
 *	*	Neither the name of CosmicMind nor the names of its
 *		contributors may be used to endorse or promote products derived from
 *		this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import XCTest
@testable import Graph

class RelationshipGroupTests: XCTestCase, GraphRelationshipDelegate {
  var saveExpectation: XCTestExpectation?
  
  var tagAddExpception: XCTestExpectation?
  var tagUpdateExpception: XCTestExpectation?
  var tagRemoveExpception: XCTestExpectation?
  
  func testMemberOfUsingCondition() {
    let entity = Entity("G")
    entity.add(to: "G1", "G2", "G3")
    
    /// .and condition
    XCTAssertTrue(entity.member(of: ["G1", "G2", "G3"], using: .and))
    XCTAssertFalse(entity.member(of: ["G1", "G2", "G3", "G4"], using: .and))
    
    /// .or condition
    XCTAssertTrue(entity.member(of: ["G3", "G4", "G5", "G6"], using: .or))
    XCTAssertFalse(entity.member(of: ["G4", "G5", "G6", "G7"], using: .or))
  }
  
  func testGroupAdd() {
    saveExpectation = expectation(description: "[RelationshipTests Error: Graph save test failed.]")
    tagAddExpception = expectation(description: "[RelationshipTests Error: Group add test failed.]")
    
    let graph = Graph()
    let watch = Watch<Relationship>(graph: graph).where(.type("T") || .member(of: "G1"))
    watch.delegate = self
    
    let relationship = Relationship("T")
    relationship.add(to: "G1")
    
    XCTAssertTrue(relationship.member(of: "G1"))
    
    graph.async { [weak self] (success, error) in
      XCTAssertTrue(success)
      XCTAssertNil(error)
      self?.saveExpectation?.fulfill()
    }
    
    waitForExpectations(timeout: 5, handler: nil)
  }
  
  func testGroupUpdate() {
    saveExpectation = expectation(description: "[RelationshipTests Error: Graph save test failed.]")
    
    let graph = Graph()
    
    let relationship = Relationship("T")
    relationship.add(to: "G2")
    
    graph.async { [weak self] (success, error) in
      XCTAssertTrue(success)
      XCTAssertNil(error)
      self?.saveExpectation?.fulfill()
    }
    
    waitForExpectations(timeout: 5, handler: nil)
    
    saveExpectation = expectation(description: "[RelationshipTests Error: Graph save test failed.]")
    tagAddExpception = expectation(description: "[RelationshipTests Error: Group add test failed.]")
    tagRemoveExpception = expectation(description: "[RelationshipTests Error: Group remove test failed.]")
    
    let watch = Watch<Relationship>(graph: graph).where(.member(of: "G1", "G2"))
    watch.delegate = self
    
    relationship.toggle(groups: "G1", "G2")
    
    XCTAssertTrue(relationship.member(of: "G1"))
    XCTAssertFalse(relationship.member(of: "G2"))
    
    graph.async { [weak self] (success, error) in
      XCTAssertTrue(success)
      XCTAssertNil(error)
      self?.saveExpectation?.fulfill()
    }
    
    waitForExpectations(timeout: 5, handler: nil)
  }
  
  func testGroupDelete() {
    saveExpectation = expectation(description: "[RelationshipTests Error: Graph save test failed.]")
    
    let graph = Graph()
    
    let relationship = Relationship("T")
    relationship.add(to: "G2")
    
    XCTAssertTrue(relationship.member(of: "G2"))
    
    graph.async { [weak self] (success, error) in
      XCTAssertTrue(success)
      XCTAssertNil(error)
      self?.saveExpectation?.fulfill()
    }
    
    waitForExpectations(timeout: 5, handler: nil)
    
    saveExpectation = expectation(description: "[RelationshipTests Error: Graph save test failed.]")
    tagRemoveExpception = expectation(description: "[RelationshipTests Error: Group remove test failed.]")
    
    let watch = Watch<Relationship>(graph: graph).where(.member(of: "G2"))
    watch.delegate = self
    
    relationship.remove(from: "G2")
    
    XCTAssertFalse(relationship.member(of: "G2"))
    
    graph.async { [weak self] (success, error) in
      XCTAssertTrue(success)
      XCTAssertNil(error)
      self?.saveExpectation?.fulfill()
    }
    
    waitForExpectations(timeout: 5, handler: nil)
  }
  
  func graph(_ graph: Graph, relationship: Relationship, addedTo group: String, source: GraphSource) {
    XCTAssertTrue("T" == relationship.type)
    XCTAssertTrue(0 < relationship.id.count)
    XCTAssertEqual("G1", group)
    XCTAssertTrue(relationship.member(of: group))
    XCTAssertEqual(1, relationship.groups.count)
    XCTAssertTrue(relationship.groups.contains(group))
    
    tagAddExpception?.fulfill()
  }
  
  func graph(_ graph: Graph, relationship: Relationship, removedFrom group: String, source: GraphSource) {
    XCTAssertTrue("T" == relationship.type)
    XCTAssertTrue(0 < relationship.id.count)
    XCTAssertEqual("G2", group)
    XCTAssertFalse(relationship.member(of: group))
    
    tagRemoveExpception?.fulfill()
  }
}
