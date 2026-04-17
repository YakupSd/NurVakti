//
//  Router.swift
//  SmartCampusApp
//
//  Created by Yakup Suda on 17.04.2024.
//

import UIKit
import Combine

protocol Router: ObservableObject {
    var nav: UINavigationController? { get set }
    func pushTo(view: UIViewController)
    func pop()
    func popToRoot()
}

extension Router {
    func pop() {
        nav?.popViewController(animated: true)
    }
    
    func popToRoot() {
        nav?.popToRootViewController(animated: true)
    }
}
