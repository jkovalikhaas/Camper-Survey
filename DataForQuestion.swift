//
//  DataForQuestion.swift
//  camperSurvey
//
//  Created by Joe Kovalik-Haas on 6/5/18.
//  Copyright © 2018 Joe Kovalik-Haas. All rights reserved.
//

import UIKit

class DataForQuestionController: UIViewController {
	
	var scrollView: UIScrollView!
	
	var question = Question(question: "", answers: [""], age: 0, open: false,
							index: 0, multiple: [], young: [], old: [], cit: [], openEnded: [])!

	var currentArray: [Int] = []
	var interval: Int = 0
	
	let questionLabel: UILabel = {
		let label = UILabel()
		
		label.textColor = .black
		
		label.font = UIFont.boldSystemFont(ofSize: Globals.boldFont)
		label.textAlignment = .center

		label.numberOfLines = 3
		
		return label
	}()
	
	var yOffset = Globals.topAlign / 4
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		navigationItem.title = "Data"
		view.backgroundColor = .white
		
		navigationController?.navigationBar.tintColor = .white
		navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
		
		switch question.age {
		case 0:
			currentArray = question.multiple
			break
		case 1:
			currentArray = question.young
			break
		case 2:
			currentArray = question.old
			break
		case 3:
			currentArray = question.cit
			break
		default:
			currentArray = question.multiple
			break
		}
		interval = getInterval()
		
		// scroll view
		scrollView = UIScrollView(frame: view.bounds)
		scrollView.bounces = true
		scrollView.contentSize = CGSize(width: Globals.width, height: Globals.height + (yOffset / 2))
		
		questionLabel.frame = CGRect(x: 0, y: yOffset,
									 width: Globals.width, height: Globals.height / 8)
		questionLabel.text = question.question
		yOffset += Int(questionLabel.frame.height)
		
		// draw catagory buttons
		drawButtons()
		yOffset += Int(Globals.boldFont * 2)
		
		drawGraphBase()
		drawGraphData()
		drawAnswers()
		
		scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
		
		scrollView.addSubview(questionLabel)
		view.addSubview(scrollView)
	}
	
	func setQuestion(question: Question) {
		self.question = question
	}
	
	var buttons: [UIButton] = []
	func drawButtons() {
		let count = 3
		let titles = ["ALL", "6-11", "12+", "CIT"]
	
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
			
			if i == question.age {
				buttons[i].backgroundColor = .blue
				buttons[i].setTitleColor(.white, for: .normal)
			} else {
				if question.age == 0 {
					buttons[i].setTitleColor(.black, for: .normal)
				} else {
					buttons[i].setTitleColor(.gray, for: .normal)
					buttons[i].layer.borderColor = UIColor.gray.cgColor
				}
			}
			
			if question.age == 0 {
				buttons[i].addTarget(self, action: #selector(switchView(_:)), for: .touchUpInside)
			}
			
			scrollView.addSubview(buttons[i])
		}
	}
	
	// graph base components
	let graphBase: UILabel = {
		let label = UILabel()
		
		label.layer.borderWidth = 2.0
		label.layer.borderColor = UIColor.black.cgColor
		
		return label
	}()
	
	let baseWidth = Globals.width - (Globals.leftAlign * 4)
	var baseHeight = 0
	
	func drawGraphBase() {
		baseHeight = ((baseWidth * 5) / 6)
		baseHeight += 5 - (baseHeight % 5)

		graphBase.frame = CGRect(x: Globals.leftAlign * 2, y: yOffset,
								 width: baseWidth, height: baseHeight)
		// draw lines
		let numLines = 3
		let section = baseWidth / 6
		var yLine = yOffset + section
		var lines: [UILabel] = []
		
		for i in 0...numLines {
			lines.append(UILabel(frame: CGRect(x: Globals.leftAlign * 2, y: yLine,
											   width: baseWidth, height: 2)))
			yLine += section
			
			lines[i].layer.borderWidth = 2.0
			lines[i].layer.borderColor = UIColor.black.cgColor
			
			scrollView.addSubview(lines[i])
		}
		
		// draw numbers
		let numNums = 5
		var yNum = yOffset - Int(Globals.font / 2)
		var nums: [UILabel] = []
		var ns: [Int] = [5, 4, 3, 2, 1, 0]
		
		for i in 0...numNums {
			nums.append(UILabel(frame: CGRect(x: (Globals.leftAlign * 3) / 2, y: yNum,
											  width: Int(Globals.font), height: Int(Globals.font))))
			yNum += section
			
			nums[i].text = "\(ns[i] * interval)"
			
			scrollView.addSubview(nums[i])
		}
		
		scrollView.addSubview(graphBase)
	}
	
	/**
	 * draws the graph data
	 */
	var bars: [UILabel] = []
	func drawGraphData() {
		let count = currentArray.count
		let gap = (count * 2) + 1
		
		let x = Int(baseWidth / gap)
		var xOffset = x + Globals.leftAlign * 2
		yOffset += baseHeight
		
		var height = 0
		if interval != 0 {
			height = -(baseHeight / (5 * interval))
		}

		for i in 0...count - 1 {
			let currentHeight = currentArray[i] * height

			bars.append(UILabel(frame: CGRect(x: xOffset, y: yOffset, width: x, height: currentHeight)))
			xOffset += x * 2
			
			bars[i].backgroundColor = .blue
			
			scrollView.addSubview(bars[i])
		}
	}
	
	/**
	 * draws ansers and their frequency
	 */
	var answers: [UILabel] = []
	var answerData: [UILabel] = []
	var nextAnswer = Int(Globals.boldFont * 1.5)
	
	var totalLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
	var meanLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
	
	func drawAnswers() {
		yOffset += nextAnswer
		
		let total = getTotal()
		let left = Globals.leftAlign * 2
		
		totalLabel = UILabel(frame: CGRect(x: left, y: yOffset, width: Globals.width, height: nextAnswer))
		totalLabel.text = "Total: \(total)"
		totalLabel.font = UIFont.boldSystemFont(ofSize: Globals.font)
		totalLabel.textColor = .black
		
		let mean = divideRound(x: total, y: question.answers.count) / 100
		meanLabel = UILabel(frame: CGRect(x: Globals.xCenter, y: yOffset, width: Globals.xCenter, height: nextAnswer))
		meanLabel.text = "Mean: \(mean)"
		meanLabel.font = UIFont.boldSystemFont(ofSize: Globals.font)
		meanLabel.textColor = .black
		
		scrollView.addSubview(meanLabel)
		scrollView.addSubview(totalLabel)
		
		for i in 0...question.answers.count - 1 {
			yOffset += nextAnswer
			
			answers.append(UILabel(frame: CGRect(x: left, y: yOffset,
												 width: Globals.width, height: nextAnswer)))
			answerData.append(UILabel(frame: CGRect(x: Globals.xCenter, y: yOffset,
												 width: Globals.xCenter, height: nextAnswer)))
			
			let answer = question.answers[i]
			answers[i].text = "\(answer):"
			
			answers[i].font = UIFont.boldSystemFont(ofSize: Globals.font)
			answers[i].textColor = .black
			
			let ansCount = currentArray[i]
			let percent = divideRound(x: currentArray[i], y: total)
			answerData[i].text = "\(ansCount)   \(percent)%"
			
			answerData[i].font = UIFont.boldSystemFont(ofSize: Globals.font)
			answerData[i].textColor = .black

			scrollView.addSubview(answers[i])
			scrollView.addSubview(answerData[i])
		}
		
		scrollView.contentSize = CGSize(width: Globals.width, height: Globals.height + (yOffset / 2))
	}
	
	/**
	 * switches to selected array for graph
	 */
	@objc func switchView(_ sender: UIButton) {
		for i in 0...buttons.count - 1 {
			if buttons[i] == sender {
				if sender.backgroundColor != .blue {
					buttons[i].backgroundColor = .blue
					buttons[i].setTitleColor(.white, for: .normal)
					
					switch i {
					case 0:
						currentArray = question.multiple
						break
					case 1:
						currentArray = question.young
						break
					case 2:
						currentArray = question.old
					case 3:
						currentArray = question.cit
					default:
						currentArray = question.multiple
						break
					}
					
					// reset data
					totalLabel.text = ""
					meanLabel.text = ""
					
					for b in bars {
						b.isHidden = true
					}
					bars = []
					
					for a in answers {
						a.isHidden = true
						yOffset -= nextAnswer
					}
					answers = []
					
					yOffset -= baseHeight + nextAnswer
					
					drawGraphData()
					drawAnswers()
				}
			} else {
				buttons[i].backgroundColor = .white
				buttons[i].setTitleColor(.black, for: .normal)
			}
		}
	}
	
	/**
	 * get interval for graph
	 */
	func getInterval() -> Int {
		let max = currentArray.max()!
		
		var buff = (5 - (max % 5))
		if buff == 5 { buff = 0 }
		let i = (max + buff) / 5
		
		return i
	}
	
	/**
	 * gets total "votes" in current array
	 */
	func getTotal() -> Int {
		var total = 0
		for i in 0...currentArray.count - 1 {
			total += currentArray[i]
		}
		return total
	}
	
	/**
	 * divides and rounds to nearest tenth
	 */
	func divideRound(x: Int, y: Int) -> Double {
		return round(Double(x) * 100 / Double(y) * 100) / 100
	}
	
}
