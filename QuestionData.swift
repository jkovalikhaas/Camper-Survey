//
//  QuestionData.swift
//  camperSurvey
//
//  Created by Joe Kovalik-Haas on 6/1/18.
//  Copyright © 2018 Joe Kovalik-Haas. All rights reserved.
//

import Foundation
import os.log

class QuestionData {
	
	static var questionList = [Question]()
	static var count = 0
	
	static var tempChoice = [Int]()
	static var tempOpen = [String]()
	
	static var age = 0
	static var navOffset = 2
	
	@discardableResult
	init() {
		if let saved = loadQuestions() {
			QuestionData.questionList = saved
			QuestionData.count = QuestionData.questionList.count
			QuestionData.initChoice()
		}
	}
	
	/**
	 * initialize choice arrays
	 */
	static func initChoice() {
		for _ in 0...questionList.count - 1 {
			tempChoice.append(0)
			tempOpen.append("")
		}
	}
	
	/**
	 * set choice answer
	 */
	static func setChoice(index: Int, sel: Int) {
		tempChoice[index] = sel
	}
	
	/**
	 * set open answer
	 */
	static func setOpen(index: Int, ans: String) {
		tempOpen[index] = ans
	}
	
	/**
	 * checks if there is more questions in list
	 */
	static func hasNext(index: Int) -> Bool {
		return index < count - 1
	}
	
	/**
	 * check if list is empty
	 */
	static func isEmpty() -> Bool {
		return count == 0
	}
	
	/**
	 * create list based on age
	 */
	static func createList() -> [Question] {
		var list = [Question]()
		
		for question in questionList {
			let a = question.age
			if a == 0 || a == age {
				list.append(question)
			}
		}
		
		return list
	}
	
	/**
	 * update answers
	 */
	static func updateAnswers() {
		Cloud().updateAnswers(questions: questionList, open: tempOpen, multiple: tempChoice, age: age)
		
		for i in 0...count - 1 {
			let q = questionList[i]
			if q.open {
				if tempOpen[i] != "" {
					q.openEnded.append(tempOpen[i])
				}
			} else {
				q.multiple[tempChoice[i]] += 1
				
				if age == 1 {
					q.young[tempChoice[i]] += 1
				} else if age == 2 {
					q.old[tempChoice[i]] += 1
				} else if age == 3 {
					q.cit[tempChoice[i]] += 1
				}
			}
		}
		
		saveQuestions()
	}
	
	/**
	 * returns question in question list
	 */
	static func getQuestion(index: Int) -> Question {
		return QuestionData.questionList[index]
	}
	
	/**
	 * return if open
	 */
	static func isOpen(index: Int) -> Bool {
		return QuestionData.questionList[index].open
	}
	
	
	/**
	 * get count of question list
	 */
	static func getCount() -> Int {
		return questionList.count
	}
	
	/*
	 * get age
	 */
	static func getAge() -> Int {
		return QuestionData.age
	}
	
	/**
	 * set age
	 */
	static func setAge(age: Int) {
		QuestionData.age = age
	}
	
	/**
	 * saves question information to memory
	 */
	private static func saveQuestions() {
		let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(QuestionData.questionList, toFile: Question.ArchiveURL.path)
		if isSuccessfulSave {
			os_log("Questions successfully saved.", log: OSLog.default, type: .debug)
		} else {
			os_log("Failed to save questions...", log: OSLog.default, type: .error)
		}
	}
	
	/**
	 * loads questions from memory
	 */
	private func loadQuestions() -> [Question]?  {
		return NSKeyedUnarchiver.unarchiveObject(withFile: Question.ArchiveURL.path) as? [Question]
	}

}
