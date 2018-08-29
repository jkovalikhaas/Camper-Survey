//
//  NewQuestionController.swift
//  camperSurvey
//
//  Created by Joe Kovalik-Haas on 5/18/18.
//  Copyright © 2018 Joe Kovalik-Haas. All rights reserved.
//

import UIKit
import os.log

class NewQuestionController: UIViewController, UITextFieldDelegate {
	
	var questionList = [Question]()
	var info = Question(question: "", answers: [""], age: 0, open: false,
						index: 0, multiple: [], young: [], old: [], cit: [], openEnded: [])!
	var index = -1
	var clear = false
	
	// question label
	let questionLabel: UILabel = {
		let label = UILabel()
		label.text = "Question:"
		label.textColor = .black
		label.font = UIFont.boldSystemFont(ofSize: Globals.font)
		return label
	}()
	// question text field
	let questionText: UITextField = {
		let text = UITextField()
		
		text.placeholder = "Question:"
		text.textColor = .black
		text.font = UIFont.systemFont(ofSize: Globals.font)
		
		text.layer.borderWidth = 2.0
		text.layer.cornerRadius = 5
		
		text.clearButtonMode = .whileEditing
		text.returnKeyType = .done
		return text
	}()
	
	// catagories label
	let catagoryLabel: UILabel = {
		let label = UILabel()
		label.text = "Catagories:"
		label.textColor = .black
		label.font = UIFont.boldSystemFont(ofSize: Globals.font)
		return label
	}()
	
	// open ended label
	let openLabel: UILabel = {
		let label = UILabel()
		label.text = "Open Ended"
		label.textColor = .blue
		label.font = UIFont.italicSystemFont(ofSize: Globals.font)
		return label
	}()
	let openButton: UIButton = {
		let button = UIButton()
		
		button.layer.borderWidth = 2.0
		button.layer.cornerRadius = 10
		button.showsTouchWhenHighlighted = true
		
		button.addTarget(self, action: #selector(isOpen(_:)), for: .touchUpInside)
		
		return button
	}()
	
	// answers label
	let answerLabel: UILabel = {
		let label = UILabel()
		label.text = "Answers:"
		label.textColor = .black
		label.font = UIFont.boldSystemFont(ofSize: Globals.font)
		return label
	}()
	// add answer button
	// reveals another text field to add answers too
	let addAnswer: UIButton = {
		let button = UIButton()
		
		button.showsTouchWhenHighlighted = true
		button.setTitle("+", for: .normal)
		button.titleLabel?.text = "+"
		button.titleLabel?.font = UIFont.boldSystemFont(ofSize: Globals.boldFont)
		button.setTitleColor(.black, for: .normal)
		
		return button
	}()
	// remove answer button
	// removes answer textfield
	let removeAnswer: UIButton = {
		let button = UIButton()
		
		button.showsTouchWhenHighlighted = true
		button.setTitle("-", for: .normal)
		button.titleLabel?.text = "-"
		button.titleLabel?.font = UIFont.boldSystemFont(ofSize: Globals.boldFont)
		button.setTitleColor(.black, for: .normal)
		
		return button
	}()
	
	// clear answers data button
	let clearButton: UIButton = {
		let button = UIButton()
		
		button.backgroundColor = .white
		button.layer.borderWidth = 2.0
		button.layer.cornerRadius = 10
		button.showsTouchWhenHighlighted = true
		
		button.setTitle("Clear Data", for: .normal)
		button.titleLabel?.text = "Clear Data"
		button.titleLabel?.font = UIFont.boldSystemFont(ofSize: Globals.font)
		button.setTitleColor(.black, for: .normal)
		
		button.isHidden = true
		button.addTarget(self, action: #selector(clear(_:)), for: .touchUpInside)
		
		return button
	}()
	// delete button
	let delete: UIButton = {
		let button = UIButton()
		
		button.backgroundColor = .red
		
		button.layer.borderWidth = 2.0
		button.layer.cornerRadius = 10
		button.showsTouchWhenHighlighted = true
		
		button.setTitle("Delete", for: .normal)
		button.titleLabel?.text = "Delete"
		button.titleLabel?.font = UIFont.systemFont(ofSize: Globals.font)
		button.setTitleColor(.white, for: .normal)
		
		button.addTarget(self, action: #selector(deleteQuestion(_:)), for: .touchUpInside)
		button.isHidden = true
		
		return button
	}()
	
	var scrollView: UIScrollView!
	
	var yOffset = Globals.topAlign - Int(Globals.font * 2)
	let width = Int(Globals.width - Globals.leftAlign * 2)
	let xPad = Globals.width / 64
	
	var answers: [UITextField] = []
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if let saved = loadQuestions() {
			questionList = saved
		}
		
		if index >= 0 {
			info = questionList[index]
		}
		
		navigationItem.title = "New Question"
		view.backgroundColor = .white

		navigationController?.navigationBar.tintColor = .white
		navigationItem.backBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.cancel(_:)))
		
		navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(self.save(_:)))
		
		// scroll view
		scrollView = UIScrollView(frame: view.bounds)
		scrollView.bounces = true
		scrollView.contentSize = CGSize(width: Globals.width, height: Globals.height + (yOffset / 2))
		
		// question label frame
		questionLabel.frame = CGRect(x: Globals.leftAlign, y: yOffset,
							 width: Int(Globals.width), height: Int(Globals.font))
		yOffset += Int(Globals.boldFont)
		// question text field frame
		questionText.frame = CGRect(x: Globals.leftAlign, y: yOffset,
									width: width, height: Int(Globals.font) * 2)
		let pad = UIView(frame: CGRect(x: 0, y: 0, width: xPad, height: Int(questionText.frame.height)))
		questionText.leftView = pad
		questionText.leftViewMode = UITextFieldViewMode.always
		if info.question != "" {
			questionText.text = info.question
		}

		yOffset += Globals.topAlign
		// catagories label
		catagoryLabel.frame = CGRect(x: Globals.leftAlign, y: yOffset,
									 width: Int(Globals.width), height: Int(Globals.font) + 4)
		
		openLabel.frame = CGRect(x: Globals.xCenter / 2 + Int(Globals.font), y: yOffset,
										 width: Int(Globals.width), height: Int(Globals.font) + 4)
		openButton.frame = CGRect(x: Globals.xCenter, y: yOffset + Int(Globals.font / 4),
								  width: Int(Globals.boldFont / 2), height: Int(Globals.boldFont / 2))
		catagoryButtons()
		
		yOffset += Globals.topAlign - Int(Globals.font)
		
		// answer label frame
		answerLabel.frame = CGRect(x: Globals.leftAlign, y: yOffset,
									width: Int(Globals.xCenter), height: Int(Globals.font))
		
		// answer text field frame
		for i in info.answers {
			drawAnswers(text: i)
		}
		
		// clear button
		clearButton.frame = CGRect(x: Globals.xCenter - Int(Globals.xCenter / 4),
								   y: yOffset + (Globals.topAlign * 2) - Int(Globals.boldFont),
								   width: Int(Globals.xCenter / 2), height: Int(Globals.boldFont) - 10)
		// delete button
		delete.frame = CGRect(x: Globals.xCenter - Int(Globals.width / 12), y: yOffset + (Globals.topAlign * 2),
							  width: Int(Globals.width / 6), height: Int(Globals.boldFont))
		
		for i in answers {
			i.resignFirstResponder()
		}
		
		if info.open {
			openButton.backgroundColor = .blue
			hideThings()
		}
		
		scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
		
		questionText.delegate = self
		
		scrollView.addSubview(questionLabel)
		scrollView.addSubview(questionText)
		scrollView.addSubview(catagoryLabel)
		scrollView.addSubview(openLabel)
		scrollView.addSubview(openButton)
		scrollView.addSubview(answerLabel)
		scrollView.addSubview(clearButton)
		scrollView.addSubview(delete)
		
		view.addSubview(scrollView)
	}

	/**
	 * draws catagory buttons
	 */
	var buttons: [UIButton] = []
	func catagoryButtons() {
		let count = 3
		let titles = ["ALL", "6-11", "12+", "CIT"]
		
		yOffset += Int(Globals.boldFont)
		var x = Globals.leftAlign
		let xSize = (Globals.width - Globals.leftAlign * 2) / 6
		
		for i in 0...count {
			buttons.append(UIButton(frame: CGRect(x: x, y: yOffset,
												  width: xSize, height: Int(Globals.font))))
			x += (xSize * 5) / 3
			
			buttons[i].layer.borderWidth = 2.0
			buttons[i].layer.cornerRadius = 5
			buttons[i].showsTouchWhenHighlighted = true
			
			buttons[i].setTitle("\(titles[i])", for: .normal)
			buttons[i].titleLabel?.text = "\(titles[i])"
			buttons[i].titleLabel?.font = UIFont.boldSystemFont(ofSize: Globals.font / 2)
			
			if i == info.age {
				buttons[i].backgroundColor = .blue
				buttons[i].setTitleColor(.white, for: .normal)
			} else {
				buttons[i].setTitleColor(.black, for: .normal)
			}
			
			buttons[i].addTarget(self, action: #selector(selectCatagory), for: .touchUpInside)
			
			scrollView.addSubview(buttons[i])
		}
	}
	
	/**
	 * adds an answer text field
	 */
	var shouldScroll = false	// if screen should scroll
	func drawAnswers(text: String) {
		if answers.count == 0 {
			yOffset += Int(Globals.boldFont)
		} else {
			yOffset += Int(Globals.boldFont * 1.5)
		}
		
		let answerWidth = width - Globals.leftAlign

		answers.append(UITextField(frame: CGRect(x: Globals.leftAlign, y: yOffset,
												 width: answerWidth, height: Int(Globals.font) * 2)))

		answers.last?.placeholder = "Answer \(answers.count):"
		if text != "" {
			answers.last?.text = text
		}
		
		answers.last?.textColor = .black
		answers.last?.font = UIFont.systemFont(ofSize: Globals.font)
		
		answers.last?.layer.borderWidth = 2.0
		answers.last?.layer.cornerRadius = 5
		
		// padding for text
		let pad = UIView(frame: CGRect(x: 0, y: 0, width: xPad, height: Int((answers.last?.frame.height)!)))
		answers.last?.leftView = pad
		answers.last?.leftViewMode = UITextFieldViewMode.always
		
		answers.last?.clearButtonMode = .whileEditing
		answers.last?.returnKeyType = .continue
		
		if answers.count > 1 {
			answers.last?.becomeFirstResponder()
		}
		
		drawBottom()
		
		answers.last?.delegate = self
		
		scrollView.addSubview(answers.last!)
	}
	
	/**
	 *
	 */
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		if(string.last == "\n") {
			if Int(textField.frame.width) < width {
				if (answers.last?.isEditing)! {
					if (answers.last?.text == "") {
						textField.resignFirstResponder()
					} else {
						drawAnswers(text: "")
					}
				} else {
					for i in 0...answers.count - 1 {
						if(answers[i].isEditing) {
							answers[i + 1].becomeFirstResponder()
							break
						}
					}
				}
			} else {
				textField.resignFirstResponder()
			}
		}
		return true
	}
	
	/**
	 * highlights selected catagory button
	 */
	@objc func selectCatagory(_ sender: UIButton) {
		for i in 0...buttons.count - 1 {
			if buttons[i] == sender {
				if(buttons[i].backgroundColor == .blue) {
					buttons[i].backgroundColor = .white
					buttons[i].setTitleColor(.black, for: .normal)
				} else {
					info.age = i
					buttons[i].backgroundColor = .blue
					buttons[i].setTitleColor(.white, for: .normal)
				}
			} else {
				buttons[i].backgroundColor = .white
				buttons[i].setTitleColor(.black, for: .normal)
			}
		}
	}
	
	/**
	 * displays answers based on "add answer" button presses
	 */
	@objc func displayAnswer(_ sender: UIButton) {
		if answers.last?.text != "" {
			drawAnswers(text: "")
		}
	}
	
	/**
	 * removes answer label from end of array
	 */
	@objc func removeAnswerButton(_ sender: UIButton) {
		if answers.count > 1 {
			answers.last?.isHidden = true
			answers.last?.text = ""
			answers.remove(at: answers.count - 1)
			yOffset -= Int(Globals.boldFont * 1.5)
			
			drawBottom()
		}
	}
	
	/**
	 * draws bottom of view
	 */
	func drawBottom() {
		// add addAnswer
		addAnswer.frame = CGRect(x: Globals.rightAlign - Int(Globals.font / 2), y: yOffset,
								 width: Int(Globals.boldFont), height: Int(Globals.boldFont))
		addAnswer.addTarget(self, action: #selector(displayAnswer(_:)), for: .touchUpInside)
		addAnswer.isEnabled = true
		
		removeAnswer.frame = CGRect(x: Globals.rightAlign + Int(Globals.font) + 2, y: yOffset,
									width: Int(Globals.boldFont), height: Int(Globals.boldFont))
		removeAnswer.addTarget(self, action: #selector(removeAnswerButton(_:)), for: .touchUpInside)
		
		clearButton.frame = CGRect(x: Globals.xCenter - Int(Globals.xCenter / 4),
								   y: yOffset + (Globals.topAlign * 2) - Int(Globals.boldFont),
								   width: Int(Globals.xCenter / 2), height: Int(Globals.boldFont) - 10)
		delete.frame = CGRect(x: Globals.xCenter - Int(Globals.width / 12), y: yOffset + (Globals.topAlign * 2),
							  width: Int(Globals.width / 6), height: Int(Globals.boldFont))
		
		scrollView.contentSize = CGSize(width: Globals.width, height: Globals.height + (yOffset / 2))
		if(yOffset > Int(Globals.height / 2) || shouldScroll) {
			shouldScroll = true
			let val = scrollView.contentSize.height - scrollView.bounds.size.height
			scrollView.setContentOffset(CGPoint(x: 0, y: val), animated: true)
		}
		
		scrollView.addSubview(addAnswer)
		scrollView.addSubview(removeAnswer)
	}
	
	/**
	 * cancels question creation and returns to questions
	 */
	@IBAction func cancel(_ sender: UIBarButtonItem) {
		dismiss(animated: true, completion: nil)
	}
	
	/**
	 * cancels question creation and returns to questions
	 */
	@IBAction func save(_ sender: UIBarButtonItem) {
		info.question = questionText.text!

		var count = info.answers.count
		for i in 0...answers.count - 1 {
			if answers[i].text != "" {
				if index < 0 || i >= count {
					info.multiple.append(0)
					info.young.append(0)
					info.old.append(0)
					info.cit.append(0)
				} else if clear {
					info.multiple[i] = 0
					info.young[i] = 0
					info.old[i] = 0
					info.cit[i] = 0
				}

				if i < count {
					info.answers[i] = answers[i].text!
				} else {
					info.answers.append(answers[i].text!)
				}
			}
		}
		
		while count > answers.count {
			let top = info.answers.count - 1
			info.answers.remove(at: top)
			info.multiple.remove(at: top)
			info.young.remove(at: top)
			info.old.remove(at: top)
			info.cit.remove(at: top)
			
			count -= 1
		}

		if clear && info.open {
			info.openEnded = []
		}
		
		if index < 0 {
			questionList.append(info)
		} else {
			questionList[index] = info
		}
		
		saveQuestions()
	}
	
	/**
	 * removes question from memory
	 */
	@IBAction func deleteQuestion(_ sender: UIBarButtonItem) {
		let alert = UIAlertController(title: "Are you sure you want to delete this question?"
			, message: "", preferredStyle: .alert)
		
		let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
		let confirm = UIAlertAction(title: "Yes", style: .default) { (_) in
			Cloud().deleteFromCloud(question: self.info)
			
			self.questionList.remove(at: self.index)
			self.saveQuestions()
		}
		
		alert.addAction(confirm)
		alert.addAction(cancel)
		present(alert, animated: true, completion: nil)
	}
	
	/**
	 * hides things if open is true
	 */
	@IBAction func isOpen(_ sender: UIButton) {
		if sender.backgroundColor == .blue {
			info.open = false
			sender.backgroundColor = .white
			showThings()
		} else {
			info.open = true
			sender.backgroundColor = .blue
			hideThings()
		}
	}
	
	/**
	 *
	 */
	@objc func clear(_ sender: UIButton) {
		if clear {
			clear = false
			clearButton.backgroundColor = .white
			clearButton.setTitleColor(.black, for: .normal)
		} else {
			clear = true
			clearButton.backgroundColor = .blue
			clearButton.setTitleColor(.white, for: .normal)
		}
	}
	
	/**
	 * hides things if open is true
	 */
	func hideThings() {
		answerLabel.isHidden = true
		for a in answers {
			a.isHidden = true
		}
		addAnswer.isHidden = true
		removeAnswer.isHidden = true
	}
	
	/**
	 * shows things if open is true
	 */
	func showThings() {
		answerLabel.isHidden = false
		for a in answers {
			a.isHidden = false
		}
		addAnswer.isHidden = false
		removeAnswer.isHidden = false
	}
	
	/**
	 * sets index
	 */
	func setIndex(index: Int) {
		self.index = index
		clearButton.isHidden = false
		delete.isHidden = false
	}
	
	/**
	 * saves question information to memory
	 * then pops navigation stack
	 */
	private func saveQuestions() {
		if questionList.count > 0 {
			for i in 0...questionList.count - 1 {
				questionList[i].index = i
			}
		}
		
		let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(questionList, toFile: Question.ArchiveURL.path)
		if isSuccessfulSave {
			os_log("Questions successfully saved.", log: OSLog.default, type: .debug)
		} else {
			os_log("Failed to save questions...", log: OSLog.default, type: .error)
		}

		Cloud().saveToCloud(question: info, index: index)
		
		navigationController?.popViewController(animated: true)
	}
	
	/**
	 * loads questions from memory
	 */
	private func loadQuestions() -> [Question]?  {
		return NSKeyedUnarchiver.unarchiveObject(withFile: Question.ArchiveURL.path) as? [Question]
	}
}
