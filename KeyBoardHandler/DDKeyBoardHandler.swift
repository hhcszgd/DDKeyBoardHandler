//
//  DDKeyBoardHandler.swift
//  Project
//
//  Created by WY on 2018/4/28.
//  Copyright © 2018年 HHCSZGD. All rights reserved.
//

import UIKit

class DDKeyBoardHandler: NSObject {
    private weak var containerView : UIView?
    private weak var inPutView : UIView?
    private var originalFrame : CGRect = CGRect.zero
    static let share = { () -> DDKeyBoardHandler in
        let temp = DDKeyBoardHandler()
        temp.prepare()
        return temp
    }()
    
    /// setViewToBeDeal , invoke this method after setting inputView's frame and inputViewContainer's frame
    ///
    /// - Parameters:
    ///   - containerView: inputView's container , it will be move while keyboard hide or show
    ///   - inPutView: inPutView
    /// for example :
    /*
     func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
     DDKeyBoardHandler.share.setViewToBeDealt(containerView: getCashContainer, inPutView: textField)
     return true
     }
     */
    func setViewToBeDealt(containerView:UIView , inPutView : UIView) {
        if inPutView.frame == CGRect.zero {
            self.containerView = nil
            self.inPutView = nil
            originalFrame = CGRect.zero
            return
        }
        self.inPutView = inPutView
        guard  let  tempContainerView = self.containerView , tempContainerView == containerView else{
            self.containerView = containerView
            originalFrame = containerView.frame
            return
        }
    }
    private func getInputViewFrameInWindow()  -> CGRect{
        if let window = UIApplication.shared.delegate?.window  , let input = self.inPutView{
            let rect =  input.convert(input.bounds, to: window)
            return rect
        }
        return CGRect.zero
    }
    private func prepare()  {
        NotificationCenter.default.addObserver(forName: .UIKeyboardWillShow, object: nil  , queue: OperationQueue.main) { (notification) in
            if self.containerView != nil {
                let keyboardFrame = self.getKeyboardFrameFromNotification(notification: notification)
                let viewFrame = self.getInputViewFrameInWindow()
                if viewFrame.maxY > keyboardFrame.minY {
                    UIView.animate(withDuration: 0.25, animations: {
                        let cha = viewFrame.maxY - keyboardFrame.minY
                        self.containerView!.frame.origin.y -= cha
                    })
                }
            }
        }
        NotificationCenter.default.addObserver(forName: .UIKeyboardWillHide, object: nil  , queue: OperationQueue.main) { (notification) in
            if self.containerView != nil {
                UIView.animate(withDuration: 0.25, animations: {
                    self.containerView!.frame = self.originalFrame
                })
            }
        }
    }
    
    private func getKeyboardFrameFromNotification(notification : Notification) -> CGRect {
        if let rect = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect{
            return rect
        }
        return CGRect.zero
    }
    
}

