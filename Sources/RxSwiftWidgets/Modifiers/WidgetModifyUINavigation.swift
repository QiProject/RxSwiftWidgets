//
//  WidgetModifying.swift
//  RxSwiftWidgets
//
//  Created by Michael Long on 7/11/19.
//  Copyright © 2019 Michael Long. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension WidgetModifying {

    public func navigationBar(title: String, preferLargeTitles: Bool? = nil, hidden: Bool? = nil) -> Self {
        return modified(WidgetModifierBlock<UIView> { _, context in
            if let vc = context.viewController {
                vc.rx.methodInvoked(#selector(UIViewController.viewWillAppear(_:)))
                    .subscribe(onNext: { _ in
                        context.viewController?.title = title
                        guard let nav = context.navigator?.navigationController else { return }
                        if let largeTitles = preferLargeTitles {
                            nav.navigationBar.prefersLargeTitles = largeTitles
                        }
                        if let hidden = hidden {
                            nav.isNavigationBarHidden = hidden
                        }
                    })
                    .disposed(by: context.disposeBag)
            }
        })
    }

}
