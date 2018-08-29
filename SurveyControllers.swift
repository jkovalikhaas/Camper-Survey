//
//  SurveyControllers.swift
//  camperSurvey
//
//  Created by Joe Kovalik-Haas on 5/16/18.
//  Copyright © 2018 Joe Kovalik-Haas. All rights reserved.
//

import UIKit

class SurveyAgeController: UIViewController {
	
	static var age = 0
	
	var yOffset = Globals.yCenter - Globals.topAlign * 2
	
	let ageRange: UILabel = {
		let label = UILabel()
		
		label.text = "Age Range:"
		label.font = UIFont.boldSystemFont(ofSize: Globals.boldFont)
		label.textColor = .black
		
		return label
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		QuestionData.init()
		
		if QuestionData.isEmpty() {
			navigationController?.popToRootViewController(animated: true)
		}
		
		navigationItem.title = "Age Range"
		navigationController?.navigationBar.tintColor = .white
		
		navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
		navigationItem.hidesBackButton = true
		
		view.backgroundColor = .white
		
		ageRange.frame = CGRect(x: Globals.leftAlign * 2, y: yOffset, width: Globals.width, height: Int(Globals.boldFont) + 20)
		
		rangeButtons()
		
		view.addSubview(ageRange)
	}
	
	/**
	 * draws age range buttons
	 */
	var buttons: [UIButton] = []
	func rangeButtons() {
		let count = 2
		let titles = ["6-11", "12+", "CIT"]
		
		yOffset += Globals.topAlign
		var x = Globals.leftAlign * 2
		let xSize = (Globals.width - Globals.leftAlign * 2) / 4
		
		for i in 0...count {
			buttons.append(UIButton(frame: CGRect(x: x, y: yOffset,
												  width: xSize, height: Int(Globals.font) * 2)))
			x += (xSize * 4) / 3
			
			buttons[i].layer.borderWidth = 2.0
			buttons[i].layer.cornerRadius = 5
			buttons[i].showsTouchWhenHighlighted = true
			
			buttons[i].setTitle("\(titles[i])", for: .normal)
			buttons[i].titleLabel?.text = "\(titles[i])"
			buttons[i].setTitleColor(.black, for: .normal)
			buttons[i].titleLabel?.font = UIFont.boldSystemFont(ofSize: Globals.font)
			
			buttons[i].addTarget(self, action: #selector(selectAge), for: .touchUpInside)
			
			view.addSubview(buttons[i])
		}
	}
	
	@objc func selectAge(_ sender: UIButton) {
		
		for i in 0...buttons.count - 1 {
			if buttons[i] == sender {
				if(buttons[i].backgroundColor != .blue) {
					buttons[i].backgroundColor = .blue
					buttons[i].setTitleColor(.white, for: .normal)

					if QuestionData.createList().count == 0 {
						navigationController?.popToRootViewController(animated: true)
					} else {
						QuestionData.setAge(age: i + 1)
						
						if QuestionData.isOpen(index: 0) {
							let controller = OpenEndedController()
							navigationController?.pushViewController(controller, animated: true)
						} else {
							let controller = QuestionController()
							navigationController?.pushViewController(controller, animated: true)
						}
					}
					
				}
			} else {
				buttons[i].backgroundColor = .white
				buttons[i].setTitleColor(.black, for: .normal)
			}
		}
		
	}
	
}

class ResultsController: UIViewController, UITextFieldDelegate {
	
	var yOffset = Globals.topAlign * 2
	
	let completeLabel: UILabel = {
		let label = UILabel()
		label.text = "Thanks for Completing the Survey!"
		label.textAlignment = .center
		label.font = UIFont.boldSystemFont(ofSize: Globals.boldFont)
		return label
	}()
	
	let pin = "0130"
	let pinText: UITextField = {
		let text = UITextField()
		
		text.placeholder = "Enter Pin"
		
		text.textColor = .black
		text.font = UIFont.systemFont(ofSize: Globals.font)
		
		text.layer.borderColor = UIColor.black.cgColor
		text.layer.borderWidth = 2.0
		text.layer.cornerRadius = 5
		text.textAlignment = .center
		
		text.isSecureTextEntry = true
		text.isHidden = true
		
		text.clearButtonMode = .whileEditing
		text.returnKeyType = .done
		
		return text
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		navigationItem.title = "Complete"
		view.backgroundColor = .white
		
		navigationController?.navigationBar.tintColor = .white
		navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
		navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Home", style: .plain,
														   target: self, action: #selector(self.mainMenu(_:)))
		
		completeLabel.frame = CGRect(x: 0, y: yOffset, width: Globals.width, height: Int(Globals.boldFont) + 20)
		
		let width = Globals.xCenter / 2
		let height = Int(Globals.boldFont)
		pinText.frame = CGRect(x: Globals.xCenter - width / 2, y: Globals.yCenter - height / 2,
							   width: width, height: height)
		
		pinText.delegate = self
		
		view.addSubview(completeLabel)
		view.addSubview(pinText)
	}
	
	/**
	 * returns to root view controller
	 */
	@objc func mainMenu(_ sender: UIBarButtonItem) {
		pinText.isHidden = false
	}
	
	/**
	 *
	 */
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		if(string.last == "\n") {
			if checkPin(string: textField.text!) {
				QuestionData.updateAnswers()
				navigationController?.popToRootViewController(animated: true)
			} else {
				pinText.isHidden = true
			}
			textField.resignFirstResponder()
		}
		return true
	}
	
	func checkPin(string: String) -> Bool {
		if string.count < 3 { return false }
		if string == pin {
			return true
		}
		return false
	}
	
}
