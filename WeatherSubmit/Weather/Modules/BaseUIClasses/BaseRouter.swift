//
//  BaseRouter.swift
//  Weather
//
//  Created by Utreja, Sumit on 22/12/20.
//  Copyright © 2020 Utreja, Sumit. All rights reserved.
//

import Foundation
import UIKit

class BaseRouter {
    
    fileprivate unowned var _viewController: UIViewController
    
    //to retain view controller reference upon first access
    fileprivate var _temporaryStoredViewController: UIViewController?
    
    init(viewController: UIViewController) {
        _temporaryStoredViewController = viewController
        _viewController = viewController
    }

    func dismissModal(animated: Bool, completion: (() -> Void)? = nil ) {
        self._viewController.dismiss(animated: animated, completion: nil)
    }
}

extension BaseRouter {
    func popFromNavigationController(animated: Bool) {
        let _ = navigationController?.popViewController(animated: animated)
    }
}


extension UIViewController {
    func presentRouter(_ router: BaseRouter, animated: Bool = true, completion: (() -> Void)? = nil) {
        router.viewController.modalPresentationStyle = .fullScreen
        present(router.viewController, animated: animated, completion: completion)
    }
}

extension BaseRouter {

    var viewController: UIViewController {
        return _viewController
    }

    var navigationController: UINavigationController? {
        return viewController.navigationController
    }
}

extension UINavigationController {
    func pushRouter(_ router: BaseRouter, animated: Bool = true) {
        self.pushViewController(router.viewController, animated: animated)
    }
}
