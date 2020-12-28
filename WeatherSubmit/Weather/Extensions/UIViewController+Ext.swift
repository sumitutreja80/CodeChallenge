//
//  UIViewController+Ext.swift
//  weather
//
//  Created by Utreja, Sumit on 21/12/20.
//  Copyright © 2020 Utreja, Sumit. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func add(child: UIViewController, container: UIView, configure: (_ childView: UIView) -> Void = { _ in }) {
        addChild(child)
        container.addSubview(child.view)
        configure(child.view)
        child.didMove(toParent: self)
    }

    func addLeftBackButton(_ selector: Selector) {
        let button = UIButton(type: .custom)
        button.frame =  CGRect(x: 0, y: 0, width: 180, height: 40)
        
        // Search icon
        button.setImage(UIImage(named: "Back"), for: .normal)
        button.adjustsImageWhenHighlighted = false
        button.contentHorizontalAlignment = .left
        button.isAccessibilityElement = true
        button.accessibilityIdentifier = "BackButton"
        // Click handler
        button.addTarget(self, action: selector, for: .touchUpInside)

        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
    }
    
    func addLeftBarButtonItemsForSearch(_ selector: Selector) {
        
        // Left bar item contains Search icon along with a title text
        let searchBtnView = UIView(frame: CGRect(x: 0, y: 0, width: 180, height: 40))
        let button = UIButton(type: .custom)
        button.frame =  CGRect(x: 0, y: 0, width: 180, height: 40)
        
        // Search icon
        button.setImage(UIImage(named: "SearchIcon"), for: .normal)
        button.adjustsImageWhenHighlighted = false
        button.contentHorizontalAlignment = .left
        button.isAccessibilityElement = true
        button.accessibilityIdentifier = "SearchIcon"
        
        // Title
        let attributes = [
            NSAttributedString.Key.foregroundColor: UIColor.black,
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: CGFloat(12))
        ]
        let attributedText = NSAttributedString(string: "Search", attributes:attributes)
        button.setAttributedTitle(attributedText, for: .normal)
        button.titleLabel?.lineBreakMode = .byTruncatingTail
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        
        // Click handler
        button.addTarget(self, action: selector, for: .touchUpInside)
        
        searchBtnView.addSubview(button)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: searchBtnView)
    }

    func addRightBarButtonItems(_ selector: Selector) {
        // Assistant Image, no click handler now
        let assistantImageView = UIView(frame: CGRect(x: 0, y: 0, width: 110, height: 40))
        let button = UIButton(type: .custom)
        button.frame =  CGRect(x: 0, y: 0, width: 110, height: 40)
        button.setImage(UIImage(named: "Plus"), for: .normal)
        button.contentHorizontalAlignment = .right
        // Click handler
        button.addTarget(self, action: selector, for: .touchUpInside)
        assistantImageView.addSubview(button)
        let barButtonItem = UIBarButtonItem(customView: assistantImageView)
        barButtonItem.isEnabled = true
        self.navigationItem.rightBarButtonItem = barButtonItem
    }

    func formattedTemperature(_ str: String) -> String {
        return str.replacingOccurrences(of: "&deg", with: "°C", options: .literal, range: nil)
    }

}

extension UIViewController {

      func displayalert(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction((UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in

            alert.dismiss(animated: true, completion: nil)

        })))

        self.present(alert, animated: true, completion: nil)


      }
}
