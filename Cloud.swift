//
//  Cloud.swift
//  camperSurvey
//
//  Created by Joe Kovalik-Haas on 7/24/18.
//  Copyright © 2018 Sarah Heinz House. All rights reserved.
//

import UIKit
import CloudKit

class Cloud {
	
	// save to icloud
	
	func saveToCloud(question: Question, index: Int) {
		let database = CKContainer.default().privateCloudDatabase // private database
		let recordID = CKRecordID(recordName: String(question.index))
		var newQuestion = CKRecord(recordType: "Question", recordID: recordID)
		
		let query = CKQuery(recordType: "Question", predicate: NSPredicate(value: true))
		// sort questions by index
		query.sortDescriptors = [NSSortDescriptor(key: "index", ascending: true)]
		
		database.perform(query, inZoneWith: nil) { (record, error) in
			if let error = error {
				print(error)
			} else if let record = record {
				if index >= 0 {
					newQuestion = record[index]
				}
			}
			newQuestion["question"] = question.question as NSString
			newQuestion["answers"]  = question.answers  as NSArray
			newQuestion["age"]      = question.age      as NSNumber
			
			if question.open {
				newQuestion["open"] = 1 as NSNumber
			} else {
				newQuestion["open"] = 0 as NSNumber
			}
			
			newQuestion["index"]    = question.index    as NSNumber
			newQuestion["multiple"] = question.multiple as NSArray
			newQuestion["young"]    = question.young    as NSArray
			newQuestion["old"]      = question.old      as NSArray
			newQuestion["cit"]      = question.cit      as NSArray
			
			newQuestion["openEnded"] = question.openEnded as NSArray
			
			database.save(newQuestion) { (record, error) in
				guard record != nil else { return }
			}
		}
	}
	
	func updateAnswers(questions: [Question], open: [String], multiple: [Int], age: Int) {
		let database = CKContainer.default().privateCloudDatabase // private database
		
		let query = CKQuery(recordType: "Question", predicate: NSPredicate(value: true))
		// sort questions by index
		query.sortDescriptors = [NSSortDescriptor(key: "index", ascending: true)]
		
		database.perform(query, inZoneWith: nil) { (record, error) in
			if let error = error {
				print(error)
			} else if let record = record {
				for i in 0...record.count - 1 {
					let q = questions[i]
					var mul = record[i].object(forKey: "multiple") as! [Int]
					var yng = record[i].object(forKey: "young") as! [Int]
					var old = record[i].object(forKey: "old") as! [Int]
					var cit = record[i].object(forKey: "cit") as! [Int]
					var opn = record[i].object(forKey: "openEnded") as! [String]
					
					if q.open {
						if open[i] != "" {
							opn.append(open[i])
						}
					} else {
						mul[multiple[i]] += 1
						
						if age == 1 {
							yng[multiple[i]] += 1
						} else if age == 2 {
							old[multiple[i]] += 1
						} else if age == 3 {
							cit[multiple[i]] += 1
						}
					}
					
					record[i]["multiple"]  = mul as NSArray
					record[i]["young"]     = yng as NSArray
					record[i]["old"]       = old as NSArray
					record[i]["cit"]       = cit as NSArray
					record[i]["openEnded"] = opn as NSArray
					
					database.save(record[i]) { (record, error) in
						guard record != nil else { return }
					}
				}
			}
		}
	}
	
	func deleteFromCloud(question: Question) {
		let index = question.index
		let database = CKContainer.default().privateCloudDatabase // private database
		
		let query = CKQuery(recordType: "Question", predicate: NSPredicate(value: true))
		// sort questions by index
		query.sortDescriptors = [NSSortDescriptor(key: "index", ascending: true)]
		
		database.perform(query, inZoneWith: nil) { (record, error) in
			if let error = error {
				print(error)
				self.didError = true
			} else if let record = record {
				let toDelete = record[index]
				database.delete(withRecordID: toDelete.recordID, completionHandler: { (record, error) -> Void in
					if error != nil {
						print(error!)
					}
				})
			}
		}
		
	}
	
	// fetch data from icloud
	var questionList = [CKRecord]()
	var didError = false
	
	func fetchData() -> [Question]? {
		let database = CKContainer.default().privateCloudDatabase // private database
		let query = CKQuery(recordType: "Question", predicate: NSPredicate(value: true))
		
		let semaphore = DispatchSemaphore(value: 0)
		
		// sort questions by index
		query.sortDescriptors = [NSSortDescriptor(key: "index", ascending: true)]
		
		// perfrom query
		database.perform(query, inZoneWith: nil) { (record, error) in
			semaphore.signal()
				// keep indented
				if let error = error {
					print(error)
					self.didError = true
				} else if let record = record {
					for i in record {
						self.questionList.append(i)
					}
				}
		}
		semaphore.wait()

		print("")		// ****PLEASE KEEP***** doesnt work without print statment
		if didError {
			return nil
		}
		return setQuestionList(data: questionList)
	}
	
	func setQuestionList(data: [CKRecord]) -> [Question] {
		var list = [Question]()
		
		for i in data {
			list.append(appendQuestion(info: i))
		}
		return list
	}
	
	func appendQuestion(info: CKRecord) -> Question {
		var open = false
		let temp = info.object(forKey: "open") as! Int
		if temp == 1 {
			open = true
		}
		
		let question = Question(question: info.object(forKey: "question") as! String,
								answers: info.object(forKey: "answers") as! [String],
								age: info.object(forKey: "age") as! Int,
								open: open,
								index: info.object(forKey: "index") as! Int,
								multiple: info.object(forKey: "multiple") as! [Int],
								young: info.object(forKey: "young") as! [Int],
								old: info.object(forKey: "old") as! [Int],
								cit: info.object(forKey: "cit") as! [Int],
								openEnded: info.object(forKey: "openEnded") as! [String])
		
		return question!
	}
	
}

extension UIViewController {
	
	func cloudAlert() {
		let title = "Unable to connect to ICloud"
		let message = "using local data"
		
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let ok = UIAlertAction(title: "OK", style: .default)
		
		alert.addAction(ok)
		self.present(alert, animated: true, completion: nil)
	}
	
}
