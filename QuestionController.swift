//
//  ViewController.swift
//  camperSurvey
//
//  Created by Joe Kovalik-Haas on 5/9/18.
//  Copyright © 2018 Joe Kovalik-Haas. All rights reserved.
//

import UIKit
import os.log

/**
 * creates controller for questions
 */
class QuestionController: UITableViewController {

	let cellId = "cellId"
	let headerId = "headerId"

	let questionList = QuestionData.createList()
	var navOffset = QuestionData.navOffset
	let age = QuestionData.age
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		navigationItem.title = "Question"
		
		navigationController?.navigationBar.tintColor = .white
		navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)

		// seperator goes edge to edge
		tableView.layoutMargins = UIEdgeInsets.zero
		tableView.separatorInset = UIEdgeInsets.zero
		
		tableView.register(AnswerCell.self, forCellReuseIdentifier: cellId)
		tableView.register(QuestionHeader.self, forHeaderFooterViewReuseIdentifier: headerId)
		
		tableView.sectionHeaderHeight = CGFloat(Globals.height / 8)
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
		if let index = navigationController?.viewControllers.index(of: self) {
			let question = questionList[index - navOffset]
			return question.answers.count
		}
		return 0
	}
	
	/**
	 * sets answer cells in table view
	 */
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
			as! AnswerCell
		
		if let index = navigationController?.viewControllers.index(of: self) {
			let question = questionList[index - navOffset]
			cell.nameLabel.text = question.answers[indexPath.row]
		}
		
		return cell
	}
	
	/**
	 * sets header
	 */
	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerId)
			as! QuestionHeader
		
		if let index = navigationController?.viewControllers.index(of: self) {
			let question = questionList[index - navOffset]
			header.nameLabel.text = question.question
		}

		return header
	}
	
	/**
	 * tracks selection of answers
	 */
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if let index = navigationController?.viewControllers.index(of: self) {
			QuestionData.tempChoice[questionList[index - navOffset].index] = indexPath.row
		}
		pushNext()
	}
	
	/**
	 * push to next view controller
	 */
	func pushNext() {
		if let index = navigationController?.viewControllers.index(of: self) {
			if index - navOffset < questionList.count - 1 {
				// next question (if more questions are left)
				if questionList[index - 1].open {
					let controller = OpenEndedController()
					navigationController?.pushViewController(controller, animated: true)
				} else {
					let controller = QuestionController()
					navigationController?.pushViewController(controller, animated: true)
				}
			} else {
				// complete
				let controller = ResultsController()
				navigationController?.pushViewController(controller, animated: true)
			}
		}
	}
	
}

class QuestionHeader: UITableViewHeaderFooterView {
	
	override init(reuseIdentifier: String?) {
		super.init(reuseIdentifier: reuseIdentifier)
		setupViews()
	}
	
	let nameLabel: UILabel = {
		let label = UILabel()
		label.text = "Question"
		label.font = UIFont.boldSystemFont(ofSize: Globals.boldFont)
		label.textAlignment = .center
		label.adjustsFontSizeToFitWidth = true
		label.numberOfLines = 3
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	func setupViews() {
		addSubview(nameLabel)
		
		// fill horizontal
		addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[v0]-8-|", options: NSLayoutFormatOptions(),
													  metrics: nil, views: ["v0": nameLabel]))
		// fill vertical
		addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-4-[v0]-4-|", options: NSLayoutFormatOptions(),
													  metrics: nil, views: ["v0": nameLabel]))
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

class OpenEndedController: UIViewController, UITextViewDelegate {
	
	let questionList = QuestionData.createList()
	var navOffset = QuestionData.navOffset
	let age = QuestionData.age
	
	let questionLabel: UILabel = {
		let label = UILabel()
		
		label.textColor = .black
		// color of tablview header
		label.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
		
		label.font = UIFont.boldSystemFont(ofSize: Globals.boldFont)
		label.textAlignment = .center
		
		label.adjustsFontSizeToFitWidth = true
		label.numberOfLines = 3
		
		return label
	}()
	
	let textField: UITextView = {
		let text = UITextView()
		
		text.textColor = .black
		text.font = UIFont.systemFont(ofSize: Globals.font)
		
		text.layer.borderWidth = 2.0
		text.layer.cornerRadius = 5
		
		text.returnKeyType = .done
		
		return text
	}()
	
	let nextButton: UIButton = {
		let button = UIButton()
		
		button.layer.borderWidth = 2.0
		button.layer.borderColor = UIColor.gray.cgColor
		
		button.layer.cornerRadius = 10
		button.showsTouchWhenHighlighted = true
		
		button.setTitle("Click to Continue ->", for: .normal)
		button.titleLabel?.text = "Click to Continue ->"
		button.titleLabel?.font = UIFont.systemFont(ofSize: Globals.font)
		button.setTitleColor(.gray, for: .normal)
		
		button.isEnabled = false
		
		button.addTarget(self, action: #selector(next(_:)), for: .touchUpInside)
		
		return button
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		navigationItem.title = "Question"
		
		view.backgroundColor = .white
		navigationController?.navigationBar.tintColor = .white
		navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
		
		if let index = navigationController?.viewControllers.index(of: self) {
			questionLabel.text = questionList[index - navOffset].question
		}
		
		questionLabel.frame = CGRect(x: 0, y: Globals.topAlign - Int(Globals.font),
									 width: Globals.width, height: Globals.height / 8)
		
		textField.frame = CGRect(x: Globals.leftAlign, y: Globals.topAlign * 2 + Globals.height / 8,
								 width: Globals.width - Globals.leftAlign * 2, height: Globals.height / 2)

		nextButton.frame = CGRect(x: Globals.xCenter / 2, y: Globals.height - Globals.topAlign,
								  width: Globals.xCenter, height: Int(Globals.boldFont))
		
		textField.delegate = self
		
		view.addSubview(textField)
		view.addSubview(questionLabel)
		view.addSubview(nextButton)
	}
	
	func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
		nextButton.setTitleColor(.black, for: .normal)
		nextButton.layer.borderColor = UIColor.black.cgColor
		nextButton.isEnabled = true
		
		if text.last == "\n" {
			textView.resignFirstResponder()
		}
		return true
	}
	
	@objc func next(_ sender: UIButton) {
		if let index = navigationController?.viewControllers.index(of: self) {
			var agePost = "    - "
			switch age {
			case 1 :
				agePost += "(6-11)"
				break
			case 2:
				agePost += "(12+)"
				break
			case 3:
				agePost += "(CIT)"
				break
			default:
				break
			}
			
			if textField.text != "" {
				textField.text! += agePost
			}
			
			QuestionData.tempOpen[questionList[index - navOffset].index] = textField.text

			if index - navOffset < questionList.count - 1 {
				// next question (if more questions are left)
				if questionList[index - 1].open {
					let controller = OpenEndedController()
					navigationController?.pushViewController(controller, animated: true)
				} else {
					let controller = QuestionController()
					navigationController?.pushViewController(controller, animated: true)
				}
			} else {
				// complete
				let controller = ResultsController()
				navigationController?.pushViewController(controller, animated: true)
			}
			
		}
	}
	
}

class AnswerCell: UITableViewCell {
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupViews()
	}
	
	let nameLabel: UILabel = {
		let label = UILabel()
		label.text = "Hello There"
		label.font = UIFont.systemFont(ofSize: Globals.font)
		
		label.numberOfLines = 1
	    label.frame = CGRect(x: Globals.leftAlign / 2, y: 1, width: Globals.width -  Globals.leftAlign / 2, height: Globals.yCenter / 16)
		
		return label
	}()
	
	func setupViews() {
		addSubview(nameLabel)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
