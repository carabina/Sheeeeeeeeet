//
//  DefaultActionSheetPresenter.swift
//  Sheeeeeeeeet
//
//  Created by Daniel Saidi on 2017-11-27.
//  Copyright © 2017 Daniel Saidi. All rights reserved.
//

/*
 
 This presenter will present action sheets as regular action
 sheets, just as regular UIAlertControllers are displayed on
 the iPhone.
 
 Whenever used on an iPad, this presenter will fallback to a
 PopoverActionSheetPresenter. You can change this default by
 injecting another iPad presenter in the initializer, or set
 the iPad presenter to nil to use the default presenter.
 
 */

import UIKit

open class DefaultActionSheetPresenter: ActionSheetPresenter {
    
    
    // MARK: - Initialization
    
    public convenience init() {
        let color = UIColor.black.withAlphaComponent(0.3)
        self.init(backgroundColor: color)
    }
    
    public convenience init(backgroundColor: UIColor) {
        let popover = PopoverActionSheetPresenter()
        self.init(backgroundColor: backgroundColor, iPadPresenter: popover)
    }
    
    public init(backgroundColor: UIColor, iPadPresenter: ActionSheetPresenter?) {
        self.backgroundColor = backgroundColor
        self.iPadPresenter = iPadPresenter
    }
    
    deinit { print("\(type(of: self)) deinit") }
    
    
    // MARK: - Properties
    
    fileprivate var backgroundColor: UIColor?
    
    fileprivate var actionSheetView: UIView?
    fileprivate var backgroundView: UIView?
    
    fileprivate var iPadPresenter: ActionSheetPresenter?
    
    fileprivate var shouldUseiPadPresenter: Bool {
        let ipad = UIDevice.current.userInterfaceIdiom == .pad
        return ipad && iPadPresenter != nil
    }
    
    
    // MARK: - ActionSheetPresenter
    
    open func dismiss(sheet: ActionSheet) {
        shouldUseiPadPresenter ?
            iPadPresenter?.dismiss(sheet: sheet) :
            dismissActionSheet()
    }
    
    open func pop(sheet: ActionSheet, in vc: UIViewController, from view: UIView?) {
        shouldUseiPadPresenter ?
            iPadPresenter?.present(sheet: sheet, in: vc, from: view) :
            addActionSheet(sheet, to: vc.view, fromBottom: false)
    }
    
    open func present(sheet: ActionSheet, in vc: UIViewController, from view: UIView?) {
        shouldUseiPadPresenter ?
            iPadPresenter?.present(sheet: sheet, in: vc, from: view) :
            addActionSheet(sheet, to: vc.view, fromBottom: true)
    }
}


// MARK: - Actions

@objc extension DefaultActionSheetPresenter {
    
    func dismissActionSheet() {
        removeActionSheetView()
        removeBackgroundView()
    }
}


// MARK: - Private Functions

fileprivate extension DefaultActionSheetPresenter {
    
    func bottomMargin(for sheet: ActionSheet, in view: UIView) -> CGFloat {
        if #available(iOS 11.0, *) {
            return view.safeAreaInsets.bottom
        } else {
            return sheet.appearance.contentInset
        }
    }
    
    func getFrame(for sheet: ActionSheet, in view: UIView) -> CGRect {
        var targetFrame = view.frame
        let inset = sheet.appearance.contentInset
        targetFrame = targetFrame.insetBy(dx: inset, dy: inset)
        targetFrame.size.height = sheet.contentHeight
        targetFrame.origin.y = view.frame.height - sheet.contentHeight
        targetFrame.origin.y -= bottomMargin(for: sheet, in: view)
        return targetFrame
    }
    
    func addActionSheet(_ sheet: ActionSheet, to view: UIView, fromBottom: Bool = true) {
        guard let actionSheetView = sheet.view else { return }
        addBackgroundView(to: view)
        actionSheetView.frame.size.height = sheet.contentHeight
        actionSheetView.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        let frame = getFrame(for: sheet, in: view)
        if fromBottom {
            actionSheetView.frame = frame
            actionSheetView.frame.origin.y += 100
        }
        view.addSubview(actionSheetView)
        animate({ actionSheetView.frame = frame })
        self.actionSheetView = actionSheetView
    }
    
    func animate(
        _ animation: @escaping () -> (),
        completion: (() -> ())? = nil) {
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: [.curveEaseOut],
            animations: animation) { _ in completion?() }
    }
    
    func addBackgroundView(to view: UIView) {
        let backgroundView = UIView(frame: view.frame)
        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundView.backgroundColor = backgroundColor
        backgroundView.alpha = 0
        addDismissTap(to: backgroundView)
        view.addSubview(backgroundView)
        animate({ backgroundView.alpha = 1 })
        self.backgroundView = backgroundView
    }
    
    func addDismissTap(to view: UIView) {
        view.isUserInteractionEnabled = true
        let action = #selector(dismissActionSheet)
        let tap = UITapGestureRecognizer(target: self, action: action)
        view.addGestureRecognizer(tap)
    }
    
    func removeActionSheetView() {
        guard let view = actionSheetView else { return }
        var frame = view.frame
        frame.origin.y += frame.height + 100
        animate({ view.frame = frame }) { view.removeFromSuperview() }
    }
    
    func removeBackgroundView() {
        guard let view = backgroundView else { return }
        animate({ view.alpha = 0 }) { view.removeFromSuperview() }
    }
}
