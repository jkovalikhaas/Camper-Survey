//
//  OpenEndedData.swift
//  camperSurvey
//
//  Created by Joe Kovalik-Haas on 6/6/18.
//  Copyright © 2018 Joe Kovalik-Haas. All rights reserved.
//

import UIKit

class OpenEndedDataController: UITableViewController {
	
	let cellId = "cellId"
	var question = Question(question: "", answers: [""], age: 0, open: false,
											   index: 0, multiple: [], young: [], old: [], cit: [], openEnded: [])!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		navigationItem.title = question.question
		view.backgroundColor = .white
		
		navigationController?.navigationBar.tintColor = .white
		navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
		
		tableView.layoutMargins = UIEdgeInsets.zero
		tableView.separatorInset = UIEdgeInsets.zero
		
		tableView.register(QuestionCell.self, forCellReuseIdentifier: cellId)
		
		tableView.tableFooterView = UIView()
	}
	
	/**
	 * dispose of any resources that can be recreated.
	 */
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	/**
	 * sets number of rows per question based on number of answers in array
	 */
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return question.openEnded.count
	}
	
	/**
	 * sets answer cells in table view
	 */
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
			as! QuestionCell
		let name = "\(question.openEnded[indexPath.row])"
		cell.nameLabel.text = name
		return cell
	}
	
	func setQuestion(question: Question) {
		self.question = question
	}
	
}
