//
//  ActionSheetOkButton.swift
//  Sheeeeeeeeet
//
//  Created by Daniel Saidi on 2017-11-26.
//  Copyright © 2017 Daniel Saidi. All rights reserved.
//

/*
 
 OK buttons have no special behavior, but can be used when a
 user should apply action sheet changes by tapping an button.
 
 The value of an OK button is `true` by default.
 
 */

import UIKit

public class ActionSheetOkButton: ActionSheetButton {
    
    
    // MARK: - Initialization
    
    public init(title: String) {
        super.init(title: title, value: true)
    }
    
    
    // MARK: - Functions
    
    open override func applyAppearance(_ appearance: ActionSheetAppearance) {
        self.appearance = ActionSheetOkButtonAppearance(copy: appearance.okButton)
    }
}
