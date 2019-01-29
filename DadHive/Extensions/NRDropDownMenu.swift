//
//  NRDropDownMenu.swift
//  CheftHandedOwner
//
//  Created by Michael Westbrooks on 11/22/18.
//  Copyright © 2018 NuraCode. All rights reserved.
//

import Foundation
import UIKit

protocol NRDropDownMenuDelegate {
    func didSelect(atIndex index: Int)
}

final class NRDropDownConfiguration {
    
    var cellHeight: CGFloat!
    
    var cellBackgroundColor: UIColor?
    var cellTextLabelColor: UIColor?
    var selectedCellTextLabelColor: UIColor?
    var cellSelectionColor: UIColor?
    var arrowTintColor: UIColor?
    
    var cellTextLabelFont: UIFont!
    
    var cellTextLabelAlignment: NSTextAlignment!
    
    var shouldKeepSelectedCellColor: Bool!
    var shouldChangeTitleText: Bool!
    
    var arrowImage: UIImage!
    var checkMarkImage: UIImage!
    
    var animationDuration: TimeInterval!
    
    init() {
        self.setDefaultValues()
    }
    
    func setDefaultValues() {
        
        self.cellHeight = 50
        
        self.cellBackgroundColor = UIColor.white
        self.cellTextLabelColor = UIColor.darkGray
        self.selectedCellTextLabelColor = UIColor.darkGray
        self.cellSelectionColor = UIColor.lightGray
        
        self.cellTextLabelFont = UIFont(name: "HelveticaNeue-Bold",
                                        size: 17)
        
        self.cellTextLabelAlignment = NSTextAlignment.left
       
        self.shouldKeepSelectedCellColor = false
        self.animationDuration = 0.5
        self.shouldChangeTitleText = true
        
        //  Todo:- Provide images on selection/unselection
        //  self.checkMarkImage = UIImage(contentsOfFile: checkMarkImagePath!)
        //  self.arrowImage = UIImage(contentsOfFile: arrowImagePath!)
        //  self.arrowTintColor = UIColor.white
        
    }
}

class NRDropDownMenu: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    // The height of the cell. Default is 50
    open var cellHeight: NSNumber! {
        get {
            return self.configuration.cellHeight as NSNumber!
        }
        set(value) {
            self.configuration.cellHeight = CGFloat(truncating: value)
        }
    }
    
    // The color of the cell background. Default is whiteColor()
    open var cellBackgroundColor: UIColor! {
        get {
            return self.configuration.cellBackgroundColor
        }
        set(color) {
            self.configuration.cellBackgroundColor = color
        }
    }
    
    // The color of the text inside cell. Default is darkGrayColor()
    open var cellTextLabelColor: UIColor! {
        get {
            return self.configuration.cellTextLabelColor
        }
        set(value) {
            self.configuration.cellTextLabelColor = value
        }
    }
    
    // The color of the text inside a selected cell. Default is darkGrayColor()
    open var selectedCellTextLabelColor: UIColor! {
        get {
            return self.configuration.selectedCellTextLabelColor
        }
        set(value) {
            self.configuration.selectedCellTextLabelColor = value
        }
    }
    
    // The font of the text inside cell. Default is HelveticaNeue-Bold, size 17
    open var cellTextLabelFont: UIFont! {
        get {
            return self.configuration.cellTextLabelFont
        }
        set(value) {
            self.configuration.cellTextLabelFont = value
        }
    }
    
    // The alignment of the text inside cell. Default is .Left
    open var cellTextLabelAlignment: NSTextAlignment! {
        get {
            return self.configuration.cellTextLabelAlignment
        }
        set(value) {
            self.configuration.cellTextLabelAlignment = value
        }
    }
    
    // The color of the cell when the cell is selected. Default is lightGrayColor()
    open var cellSelectionColor: UIColor! {
        get {
            return self.configuration.cellSelectionColor
        }
        set(value) {
            self.configuration.cellSelectionColor = value
        }
    }
    
    // The boolean value that decides if selected color of cell is visible when the menu is shown. Default is false
    open var shouldKeepSelectedCellColor: Bool! {
        get {
            return self.configuration.shouldKeepSelectedCellColor
        }
        set(value) {
            self.configuration.shouldKeepSelectedCellColor = value
        }
    }
    
    // The animation duration of showing/hiding menu. Default is 0.3
    open var animationDuration: TimeInterval! {
        get {
            return self.configuration.animationDuration
        }
        set(value) {
            self.configuration.animationDuration = value
        }
    }

    // The boolean value that decides if you want to change the title text when a cell is selected. Default is true
    open var shouldChangeTitleText: Bool! {
        get {
            return self.configuration.shouldChangeTitleText
        }
        set(value) {
            self.configuration.shouldChangeTitleText = value
        }
    }
    
    var tblMenu: UITableView!
    var parent: UIViewController!
    var configuration = NRDropDownConfiguration()
    var container: UIView!
    var data: [String]!
    var selectedIndexPath: Int?
    var delegate: NRDropDownMenuDelegate?
    var isShown = false
    
    init(parent: UIViewController,
         container: UIView,
         data: [String],
         delegate: NRDropDownMenuDelegate?) {
        super.init()
        self.parent = parent
        self.container = container
        self.data = data
        self.delegate = delegate
        let tblHeight = self.configuration.cellHeight * CGFloat(data.count)
        self.tblMenu = UITableView(frame: CGRect(x: container.frame.origin.x,
                                                 y: container.frame.maxY,
                                                 width: container.bounds.width,
                                                 height: (tblHeight >= 150.0) ? 150.0 : tblHeight
        ))
        self.tblMenu.dataSource = self
        self.tblMenu.delegate = self
        self.tblMenu.backgroundColor = .white
        self.tblMenu.separatorStyle = .none
        self.tblMenu.autoresizingMask = UIViewAutoresizing.flexibleWidth
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.contentView.backgroundColor = self.configuration.cellBackgroundColor
        cell.selectionStyle = .gray
        cell.textLabel?.textColor = self.configuration.cellTextLabelColor
        cell.textLabel?.font = self.configuration.cellTextLabelFont
        cell.textLabel?.textAlignment = self.configuration.cellTextLabelAlignment
        let item = data[indexPath.row]
        cell.textLabel?.text = item
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if self.configuration.shouldKeepSelectedCellColor == true {
            cell.backgroundColor = self.configuration.cellBackgroundColor
            cell.contentView.backgroundColor = ((indexPath as NSIndexPath).row == selectedIndexPath) ? self.configuration.cellSelectionColor : self.configuration.cellBackgroundColor
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedIndexPath = indexPath.row
        self.delegate?.didSelect(atIndex: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.configuration.cellHeight
    }
    
    
    func toggleMenu() {
        if self.isShown {
            self.isShown = false
            self.tblMenu.removeFromSuperview()
        } else {
            self.isShown = true
            self.tblMenu.reloadData()
            parent.view.addSubview(self.tblMenu)
        }
    }
}
