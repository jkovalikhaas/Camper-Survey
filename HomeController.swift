//
//  HomeController.swift
//  camperSurvey
//
//  Created by Joe Kovalik-Haas on 5/14/18.
//  Copyright © 2018 Joe Kovalik-Haas. All rights reserved.
//

/**
 * Home screen for app. At first displays a field to enter a password. If string entered matches
 * with saved password the login view will be hidden to reveal the main menu. This view contains
 * buttons to navigate through the rest of the app.
 */

import UIKit
import os.log

class HomeController: UIViewController, UITextFieldDelegate {
	
	// title label for app's homescreen
	// initially hidden, revealed once correct password is entered
	let menuLabel: UILabel = {
		let label = UILabel()
		
		label.text = "Camper Survey"
		label.font = UIFont.boldSystemFont(ofSize: Globals.boldFont)
		label.textColor = .blue
		label.textAlignment = .center
		label.frame = CGRect(x: 0, y: Globals.topAlign,
							 width: Globals.width, height: Globals.height / 8)
		return label
	}()
	
	// variables for password field, its width and height to help draw it's postion
	// and a temporary password to check the usability of password field
	let tempPW = "yay"
	let pwWidth = Globals.xCenter / 2
	let pwHeight = Int(Globals.boldFont)
	// password field
	// creates a password field which maintains a secured text entry so the entered
	// text will not be visible
	let password: UITextField = {
		let text = UITextField()
		
		text.placeholder = "Password"
		text.textAlignment = .center
		text.textColor = .black
		text.font = UIFont.systemFont(ofSize: Globals.font)
		
		text.layer.borderWidth = 2.0
		text.layer.cornerRadius = 5
		
		text.clearButtonMode = .whileEditing
		text.returnKeyType = .done
		text.isSecureTextEntry = true
		
		return text
	}()
	
	// label for the password login
	let loginLabel: UILabel = {
		let label = UILabel()
		
		label.text = "Login"
		label.font = UIFont.boldSystemFont(ofSize: Globals.boldFont)
		label.textColor = .blue
		label.textAlignment = .center
		
		return label
	}()
	
	// a label which is displayed when the user enters an incorrect password
	// initially hidden
	let incorrectLabel: UILabel = {
		let label = UILabel()
		
		label.text = "Incorrect Password"
		label.font = UIFont.systemFont(ofSize: Globals.font / 2)
		label.textColor = .red
		label.textAlignment = .center
		label.isHidden = true
		
		return label
	}()
	
	var questionList = [Question]()
	
	// loads UIComponents and adds them to the subview as this view controller is loaded
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = .white			// sets background to white
		navigationItem.hidesBackButton = true	// hides back button, nothing to go back to
	
		// places password textfield in the center of the screen
		let x = Globals.xCenter - pwWidth / 2
		let y = Globals.yCenter - pwHeight / 2
		password.frame = CGRect(x: x, y: y, width: pwWidth, height: pwHeight)
		// places login label
		loginLabel.frame = CGRect(x: 0, y: y - Int(Globals.boldFont + Globals.font),
								  width: Globals.width, height: Int(Globals.boldFont + Globals.font))
		// places incorrect label just below password field
		incorrectLabel.frame = CGRect(x: 0, y: y + Int(Globals.boldFont),
									  width: Globals.width, height: Int(Globals.font))
		
		password.delegate = self	// enables textfield for password
		
		// adds components to viewcontroller subview
		view.addSubview(password)
		view.addSubview(loginLabel)
		view.addSubview(incorrectLabel)
		view.addSubview(menuLabel)
		createButtons()
		
		hideAll()	//  hides all but login features
	}
	
	// creates an array of UIButtons to allow uniform and efficient placement of buttons
	// based on an array of strings (labels for buttons)
	var buttons: [UIButton] = []
	func createButtons() {
		let titles = ["Survey", "Data", "Questions"]
		
		// sets uniform width, height, x, and y variables for the buttons
		let width = Globals.width - Int(Globals.width / 4)
		let height = Int(Globals.height / 8)
		let xOffset = Globals.xCenter - (width / 2)
		var yOffset = Globals.height / 4	// will change after each button creation
		
		// creates a buttons for each element of titles array
		for i in 0...titles.count - 1 {
			// placement for current button
			buttons.append(UIButton(frame: CGRect(x: xOffset, y: yOffset, width: width, height: height)))
			yOffset += height + Int(Globals.height / 16)	// increases y
			
			buttons[i].backgroundColor = .blue
			buttons[i].layer.cornerRadius = 10
			buttons[i].showsTouchWhenHighlighted = true
			// set title
			buttons[i].setTitle("\(titles[i])", for: .normal)
			buttons[i].titleLabel?.text = "\(titles[i])"
			buttons[i].titleLabel?.font = UIFont.boldSystemFont(ofSize: Globals.boldFont)
			
			view.addSubview(buttons[i]) // add buttons to subview
		}

		// sets actions for each button
		buttons[0].addTarget(self, action: #selector(self.surveyAction(_:)), for: .touchUpInside)		// survey
		buttons[1].addTarget(self, action: #selector(self.dataAction(_:)), for: .touchUpInside)			// data
		buttons[2].addTarget(self, action: #selector(self.questionsAction(_:)), for: .touchUpInside)	// questions
	}
	
	/**
	 * action for when survey button is pressed
	 * goes to survey controller
	 */
	@objc func surveyAction(_ sender: UIButton) {
		let controller = SurveyAgeController()
		navigationController?.pushViewController(controller, animated: true)
	}
	
	/**
	 * action for when data button is pressed
	 * goes to data controller
	 */
	@objc func dataAction(_ sender: UIButton) {
		let controller = DataViewConrollter()
		navigationController?.pushViewController(controller, animated: true)
	}
	
	/**
	 * action for when questions button is pressed
	 * goes to questions controller (not to be confused with questions in survey)
	 */
	@objc func questionsAction(_ sender: UIButton) {
		let controller = QuestionCreationController()
		navigationController?.pushViewController(controller, animated: true)
	}

	/**
	 * checks each character passed through password textfield
	 */
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		// checks for "\n" character, signifying password entered
		if string.last == "\n" {
			// checks if text entered is the correct password
			if checkPassword(string: textField.text!) {
				// if correct password, hide password associtated components
				password.isHidden = true
				loginLabel.isHidden = true
				incorrectLabel.isHidden = true
				showAll()	// reveal components for main menu
				
				password.resignFirstResponder()
			} else {
				// if incorrect password
				textField.text = ""				// reset password text
				incorrectLabel.isHidden = false	// reveal incorrect password label
			}
		}
		return true
	}
	
	/**
	 * checks if string passed is equal to saved password
	 * if equal returns true, else returns false
	 * does not check if string size is under 3
	 */
	func checkPassword(string: String) -> Bool {
		if string.count < 3 { return false }
		if string == tempPW {
			return true
		}
		return false
	}
	
	/**
	 * hides all components associtated with main menu
	 */
	func hideAll() {
		menuLabel.isHidden = true
		for b in buttons {
			b.isHidden = true
		}
	}
	
	/**
	 * shows all components associtated with main menu
	 */
	func showAll() {
		menuLabel.isHidden = false
		for b in buttons {
			b.isHidden = false
		}
	}
}
