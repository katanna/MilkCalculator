//
//  AboutViewController.swift
//  MilkCalculator
//
//  Created by Matthew Kelling on 5/6/23.
//

import UIKit

class AboutViewController: UIViewController {
	
	@IBOutlet var aboutTitleText: UILabel!
	@IBOutlet var aboutText: UILabel!
	@IBOutlet var disclaimerText: UILabel!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		aboutText.text = "This is the about text. Read about stuff here. Maybe email me?"
		
		disclaimerText.text = "Don't sue me."
	}
}
