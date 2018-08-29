//
//  DataView.swift
//  camperSurvey
//
//  Created by Joe Kovalik-Haas on 6/5/18.
//  Copyright © 2018 Joe Kovalik-Haas. All rights reserved.
//

import UIKit
import os.log

class DataViewConrollter: UITableViewController {
	
	let cellId = "cellId"
	var questionList = [Question]()
	var refresher: UIRefreshControl!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if let local = loadQuestions() {
			questionList = local
		}
		
		navigationItem.title = "Questions"
		view.backgroundColor = .white
		
		navigationController?.navigationBar.tintColor = .white
		navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
		navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Export", style: .plain, target: self, action: #selector(export(_:)))
		
		tableView.layoutMargins = UIEdgeInsets.zero
		tableView.separatorInset = UIEdgeInsets.zero
		
		tableView.register(QuestionCell.self, forCellReuseIdentifier: cellId)
		
		refresher = UIRefreshControl()
		refresher.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
		tableView.addSubview(refresher)
		
		tableView.tableFooterView = UIView()
	}
	
	/**
	 * dispose of any resources that can be recreated.
	 */
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	/**
	 * updates data when view appears
	 */
	override func viewWillAppear(_ animated: Bool) {
		if let saved = loadQuestions() {
			questionList = saved
		}
		tableView.reloadData()
	}
	
	/**
	 * sets number of rows per question based on number of answers in array
	 */
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return questionList.count
	}
	
	/**
	 * tracks selection of answers
	 */
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if questionList[indexPath.row].open {
			let controller = OpenEndedDataController()
			controller.setQuestion(question: questionList[indexPath.row])
			navigationController?.pushViewController(controller, animated: true)
		} else {
			let controller = DataForQuestionController()
			controller.setQuestion(question: questionList[indexPath.row])
			navigationController?.pushViewController(controller, animated: true)
		}
	}
	
	/**
	 * sets answer cells in table view
	 */
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
			as! QuestionCell
		let name = "\(indexPath.row + 1):  \(questionList[indexPath.row].question)"
		cell.nameLabel.text = name
		return cell
	}
	
	/**
	 * exports question data to text file
	 */
	@objc func export(_ sender: UIBarButtonItem) {
		
	}
	
	/**
	 * update action for pull down action
	 */
	@objc func refresh(_ sender: UIRefreshControl) {
		let saved = Cloud().fetchData()
		if saved != nil {
			questionList = saved!
			saveQuestions()
		} else {
			if let local = loadQuestions() {
				questionList = local
			}
			cloudAlert()
		}
	
		tableView.reloadData()
		sender.endRefreshing()
	}
	
	/**
	 * saves question information to memory
	 */
	private func saveQuestions() {
		let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(questionList, toFile: Question.ArchiveURL.path)
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
