//
//  QuestionCreation.swift
//  camperSurvey
//
//  Created by Joe Kovalik-Haas on 5/18/18.
//  Copyright © 2018 Joe Kovalik-Haas. All rights reserved.
//

import UIKit
import os.log

class QuestionCreationController: UITableViewController {
	
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
		navigationItem.rightBarButtonItem = UIBarButtonItem(title: "+", style: .plain, target: self, action: #selector(self.newQuestion(_:)))
		
		tableView.isEditing = true
		tableView.allowsSelectionDuringEditing = true
		
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
		if let local = loadQuestions() {
			questionList = local
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
	 * tracks selection of answers
	 */
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		// edit question
		let controller = NewQuestionController()
		controller.setIndex(index: indexPath.row)
		navigationController?.pushViewController(controller, animated: true)
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
	 * controls cell movement
	 */
	override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
		let moved = self.questionList[sourceIndexPath.row]
		questionList.remove(at: sourceIndexPath.row)
		questionList.insert(moved, at: destinationIndexPath.row)
		
		if questionList.count > 0 {
			for i in 0...questionList.count - 1 {
				questionList[i].index = i
			}
		}
		
		for i in questionList {
			Cloud().saveToCloud(question: i, index: i.index)
		}
		
		saveQuestions()
		tableView.reloadData()
	}
	
	/**
	 * disables editing buttons
	 */
	override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
		return .none
	}
	override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
		return false
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
	 * goes to new question controller
	 */
	@IBAction func newQuestion(_ sender: UIBarButtonItem) {
		let controller = NewQuestionController()
		navigationController?.pushViewController(controller, animated: true)
	}

	/**
	 * loads questions from memory
	 */
	private func loadQuestions() -> [Question]?  {
		return NSKeyedUnarchiver.unarchiveObject(withFile: Question.ArchiveURL.path) as? [Question]
	}
	
}

class QuestionCell: UITableViewCell {
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupViews()
	}
	
	let nameLabel: UILabel = {
		let label = UILabel()
		label.text = "Hello There"
		label.font = UIFont.boldSystemFont(ofSize: Globals.font)
		label.numberOfLines = 0
		
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	func setupViews() { 
		addSubview(nameLabel)
		// fill horizontal
		addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[v0]|", options: NSLayoutFormatOptions(),
													  metrics: nil, views: ["v0": nameLabel]))
		// fill vertical
		addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[v0]-4-|", options: NSLayoutFormatOptions(),
													  metrics: nil, views: ["v0": nameLabel]))
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
