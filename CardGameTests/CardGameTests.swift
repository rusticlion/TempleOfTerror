//
//  CardGameTests.swift
//  CardGameTests
//
//  Created by Russell Leon Bates IV on 5/28/25.
//

import XCTest
@testable import CardGame

final class CardGameTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    func testRemoveActionConsequence() throws {
        // Set up a simple game state with one interactable
        let vm = GameViewModel()
        let nodeID = UUID()
        let action1 = ActionOption(name: "Open",
                                   actionType: "Skirmish",
                                   position: .risky,
                                   effect: .standard)
        let action2 = ActionOption(name: "Look",
                                   actionType: "Survey",
                                   position: .risky,
                                   effect: .standard)
        let interactable = Interactable(id: "test",
                                        title: "Test",
                                        description: "Test",
                                        availableActions: [action1, action2])
        let node = MapNode(id: nodeID,
                           name: "Room",
                           soundProfile: "",
                           interactables: [interactable],
                           connections: [])
        vm.gameState.dungeon = DungeonMap(nodes: [nodeID.uuidString: node],
                                          startingNodeID: nodeID)

        var character = Character(id: UUID(),
                                  name: "Hero",
                                  characterClass: "Rogue",
                                  stress: 0,
                                  harm: HarmState(),
                                  actions: ["Skirmish": 1, "Survey": 1],
                                  treasures: [],
                                  modifiers: [])
        vm.gameState.party = [character]
        vm.gameState.characterLocations[character.id.uuidString] = nodeID

        let removeCon = Consequence.removeAction(name: "Open", fromInteractable: "self")
        let dummyAction = ActionOption(name: "Trigger",
                                       actionType: "Skirmish",
                                       position: .risky,
                                       effect: .standard,
                                       requiresTest: false,
                                       outcomes: [.success: [removeCon]])

        _ = vm.performFreeAction(for: dummyAction, with: character, interactableID: "test")

        let remaining = vm.gameState.dungeon?.nodes[nodeID.uuidString]?.interactables.first?.availableActions.map { $0.name }
        XCTAssertEqual(remaining, ["Look"])
    }

    func testAddActionConsequence() throws {
        let vm = GameViewModel()
        let nodeID = UUID()
        let action1 = ActionOption(name: "Look",
                                   actionType: "Survey",
                                   position: .risky,
                                   effect: .standard)
        let interactable = Interactable(id: "test",
                                        title: "Test",
                                        description: "Test",
                                        availableActions: [action1])
        let node = MapNode(id: nodeID,
                           name: "Room",
                           soundProfile: "",
                           interactables: [interactable],
                           connections: [])
        vm.gameState.dungeon = DungeonMap(nodes: [nodeID.uuidString: node],
                                          startingNodeID: nodeID)

        var character = Character(id: UUID(),
                                  name: "Hero",
                                  characterClass: "Rogue",
                                  stress: 0,
                                  harm: HarmState(),
                                  actions: ["Skirmish": 1, "Survey": 1],
                                  treasures: [],
                                  modifiers: [])
        vm.gameState.party = [character]
        vm.gameState.characterLocations[character.id.uuidString] = nodeID

        let newAct = ActionOption(name: "Open",
                                  actionType: "Skirmish",
                                  position: .risky,
                                  effect: .standard)
        let addCon = Consequence.addAction(newAct, toInteractable: "self")
        let dummy = ActionOption(name: "Trigger",
                                 actionType: "Skirmish",
                                 position: .risky,
                                 effect: .standard,
                                 requiresTest: false,
                                 outcomes: [.success: [addCon]])

        _ = vm.performFreeAction(for: dummy, with: character, interactableID: "test")

        let names = vm.gameState.dungeon?.nodes[nodeID.uuidString]?.interactables.first?.availableActions.map { $0.name }
        XCTAssertEqual(Set(names ?? []), Set(["Look", "Open"]))
    }

}
