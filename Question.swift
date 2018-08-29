//
//  CreateQuestions.swift
//  camperSurvey
//
//  Created by Joe Kovalik-Haas on 5/11/18.
//  Copyright © 2018 Joe Kovalik-Haas. All rights reserved.
//

/**
 * Reads survey questions from file and then outputs an array
 * in the specified format
 **/
import Foundation
import os.log

class Question: NSObject, NSCoding {
	
	var question: String
	var answers: [String]
	var age: Int
	var open: Bool
	var index: Int
	
	var multiple: [Int]
	var young: [Int]
	var old: [Int]
	var cit: [Int]
	
	var openEnded: [String]
	
	struct PropertyKey {
		static let question = "question"
		static let answers = "answers"
		static let age = "age"
		static let open = "open"
		static let index = "index"
		
		static let multiple = "multiple"
		static let young = "young"
		static let old = "old"
		static let cit = "cit"
		
		static let openEnded = "openEnded"
	}
	
	// Archiving Paths
	static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
	static let ArchiveURL = DocumentsDirectory.appendingPathComponent("questions")
	
	init?(question: String, answers: [String], age: Int, open: Bool, index: Int,
		  multiple: [Int], young: [Int], old: [Int], cit: [Int], openEnded: [String]) {
		// Initialize stored properties.
		self.question = question
		self.answers = answers
		self.age = age
		self.open = open
		self.index = index
		
		self.multiple = multiple
		self.young = young
		self.old = old
		self.cit = cit
		
		self.openEnded = openEnded
	}
	
	func encode(with aCoder: NSCoder) {
		aCoder.encode(question, forKey: PropertyKey.question)
		aCoder.encode(answers, forKey: PropertyKey.answers)
		aCoder.encode(age, forKey: PropertyKey.age)
		aCoder.encode(open, forKey: PropertyKey.open)
		aCoder.encode(index, forKey: PropertyKey.index)
		
		aCoder.encode(multiple, forKey: PropertyKey.multiple)
		aCoder.encode(young, forKey: PropertyKey.young)
		aCoder.encode(old, forKey: PropertyKey.old)
		aCoder.encode(cit, forKey: PropertyKey.cit)
		
		aCoder.encode(openEnded, forKey: PropertyKey.openEnded)
	}
	
	required convenience init?(coder aDecoder: NSCoder) {
		// The question is required. If we cannot decode a question string, the initializer should fail.
		guard let question = aDecoder.decodeObject(forKey: PropertyKey.question) as? String else {
			os_log("Unable to decode the name for a Question object.", log: OSLog.default, type: .debug)
			return nil
		}
		let answers = aDecoder.decodeObject(forKey: PropertyKey.answers) as? [String]
		let age = aDecoder.decodeInteger(forKey: PropertyKey.age)
		let open = aDecoder.decodeBool(forKey: PropertyKey.open)
		let index = aDecoder.decodeInteger(forKey: PropertyKey.index)
		
		let multiple = aDecoder.decodeObject(forKey: PropertyKey.multiple) as? [Int]
		let young = aDecoder.decodeObject(forKey: PropertyKey.young) as? [Int]
		let old = aDecoder.decodeObject(forKey: PropertyKey.old) as? [Int]
		let cit = aDecoder.decodeObject(forKey: PropertyKey.cit) as? [Int]
		
		let openEnded = aDecoder.decodeObject(forKey: PropertyKey.openEnded) as? [String]
		
		self.init(question: question, answers: answers!, age: age, open: open,
				  index: index, multiple: multiple!, young: young!, old: old!, cit: cit!, openEnded: openEnded!)
	}
	
}
