//
//  Globals.swift
//  camperSurvey
//
//  Created by Joe Kovalik-Haas on 5/16/18.
//  Copyright © 2018 Joe Kovalik-Haas. All rights reserved.
//

/**
 * Sets variable to be easily accesible throughout the app
 * helps keep the UI more uniform throughout the app
 */

import UIKit

class Globals {
	
	static let size = UIScreen.main.bounds	// gets size of screen
	static let width = Int(size.width)		// width of screen
	static let height = Int(size.height)	// height of screen
	
	static let xCenter = width / 2			// center of screen width
	static let yCenter = height / 2			// center of screen height
	
	// variables to help align viewcontrollers components
	static let topAlign = height / 12
	static let leftAlign = width / 16
	static let rightAlign = width - (width / 10)
	
	// size of fonts
	static let boldFont = CGFloat(xCenter / 10)
	static let font = CGFloat(xCenter / 15)
}
