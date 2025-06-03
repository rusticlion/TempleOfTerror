Extend the System
Task 3.1: Add New Consequence Types
swiftcase modifyDice(amount: Int, duration: String) // "next roll", "scene", etc.
case createChoice(options: [ChoiceOption])
case triggerEvent(eventId: String)
Task 3.2: Implement Consequence Chains
Allow consequences to trigger other consequences:
swiftcase triggerConsequences([Consequence])