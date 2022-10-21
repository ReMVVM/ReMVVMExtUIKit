//
//  StoreActions.swift
//  BNUICommon
//
//  Created by Grzegorz Jurzak, Daniel Plachta, Dariusz Grzeszczak.
//  Copyright © 2019. All rights reserved.
//

import Loaders
import ReMVVMCore
import RxSwift
import SwiftUI
import UIKit

public struct SynchronizeState: StoreAction {
    
    public let type: SynchronizeType
    public init(_ type: SynchronizeType) {
        self.type = type
    }
    
    public enum SynchronizeType {
        case navigation, modal
    }
}

public struct ShowOnRoot: StoreAction {
    
    public let controllerInfo: LoaderWithFactory
    public let navigationBarHidden: Bool
    
    public init(loader: Loader<UIViewController>,
                factory: ViewModelFactory? = nil,
                animated: Bool = true,
                navigationBarHidden: Bool = true) {
        
        self.controllerInfo = LoaderWithFactory(loader: loader,
                                                factory: factory,
                                                animated: animated)
        self.navigationBarHidden = navigationBarHidden
    }
    
    @available(iOS 13.0, *)
    public init<V>(view: V,
                   factory: ViewModelFactory? = nil,
                   animated: Bool = true,
                   navigationBarHidden: Bool = true) where V: View {
        
        self.controllerInfo = LoaderWithFactory(view: view,
                                                factory: factory,
                                                animated: animated)
        self.navigationBarHidden = navigationBarHidden
        
    }
}

public struct Show: StoreAction {
    public let controllerInfo: LoaderWithFactory
    public let navigationBarHidden: Bool
    public let item: AnyNavigationItem
    let navigationType: NavigationType
    
    public init<Item: CaseIterableNavigationItem>(on item: Item,
                                                  loader: Loader<UIViewController>,
                                                  factory: ViewModelFactory? = nil,
                                                  animated: Bool = true,
                                                  navigationBarHidden: Bool = true) {
        
        self.controllerInfo = LoaderWithFactory(loader: loader,
                                                factory: factory,
                                                animated: animated)
        self.navigationBarHidden = navigationBarHidden
        self.item = AnyNavigationItem(item)
        self.navigationType = Item.navigationType
    }
    
    @available(iOS 13.0, *)
    public init<V, Item: CaseIterableNavigationItem>(on item: Item,
                                                     view: V,
                                                     factory: ViewModelFactory? = nil,
                                                     animated: Bool = true,
                                                     navigationBarHidden: Bool = true) where V: View {
        
        self.controllerInfo = LoaderWithFactory(view: view,
                                                factory: factory,
                                                animated: animated)
        self.navigationBarHidden = navigationBarHidden
        self.item = AnyNavigationItem(item)
        self.navigationType = Item.navigationType
    }
}

public struct Push: StoreAction {
    
    public let controllerInfo: LoaderWithFactory
    public let pop: PopMode?
    
    public init(loader: Loader<UIViewController>,
                factory: ViewModelFactory? = nil,
                pop: PopMode? = nil,
                animated: Bool = true) {
        self.pop = pop
        self.controllerInfo = LoaderWithFactory(loader: loader,
                                                factory: factory,
                                                animated: animated)
    }
    
    @available(iOS 13.0, *)
    public init<V>(view: V,
                   factory: ViewModelFactory? = nil,
                   pop: PopMode? = nil,
                   animated: Bool = true) where V: View {
        self.pop = pop
        self.controllerInfo = LoaderWithFactory(view: view,
                                                factory: factory,
                                                animated: animated)
    }
    
}

public enum PopMode {
    case popToRoot, pop(Int)
    case resetStack
}

public struct Pop: StoreAction {
    public let animated: Bool
    public let mode: PopMode
    public init(mode: PopMode = .pop(1), animated: Bool = true) {
        self.mode = mode
        self.animated = animated
    }
}

public struct ShowModal: StoreAction {
    
    public let controllerInfo: LoaderWithFactory
    public let withNavigationController: Bool
    public let showOverSplash: Bool
    public let showOverSelfType: Bool
    public let presentationStyle: UIModalPresentationStyle
    
    public init(loader: Loader<UIViewController>,
                factory: ViewModelFactory? = nil,
                animated: Bool = true,
                withNavigationController: Bool = true,
                showOverSplash: Bool = true,
                showOverSelfType: Bool = true,
                presentationStyle: UIModalPresentationStyle = .fullScreen) {
        
        self.controllerInfo = LoaderWithFactory(loader: loader,
                                                factory: factory,
                                                animated: animated)
        self.withNavigationController = withNavigationController
        self.showOverSplash = showOverSplash
        self.showOverSelfType = showOverSelfType
        self.presentationStyle = presentationStyle
    }
    
    @available(iOS 13.0, *)
    public init<V>(view: V,
                   factory: ViewModelFactory? = nil,
                   animated: Bool = true,
                   withNavigationController: Bool = true,
                   showOverSplash: Bool = true,
                   showOverSelfType: Bool = true,
                   presentationStyle: UIModalPresentationStyle = .fullScreen,
                   clearBackground: Bool = false) where V: View {
        self.controllerInfo = LoaderWithFactory(view: view,
                                                factory: factory,
                                                animated: animated,
                                                clearBackground: clearBackground)
        self.withNavigationController = withNavigationController
        self.showOverSplash = showOverSplash
        self.showOverSelfType = showOverSelfType
        self.presentationStyle = presentationStyle
    }
}

public struct DismissModal: StoreAction {
    
    public let dismissAllViews: Bool
    public let animated: Bool
    
    public init(dismissAllViews: Bool = false, animated: Bool = true) {
        self.dismissAllViews = dismissAllViews
        self.animated = animated
    }
}

public struct LoaderWithFactory {
    
    public let loader: Loader<UIViewController>
    public let factory: ViewModelFactory?
    public let animated: Bool
    
    public init(loader: Loader<UIViewController>,
                factory: ViewModelFactory?,
                animated: Bool = true) {
        self.loader = loader
        self.factory = factory
        self.animated = animated
    }
    
    @available(iOS 13.0, *)
    public init<V>(view: V,
                   factory: ViewModelFactory?,
                   animated: Bool = true,
                   clearBackground: Bool = false) where V: View {
        
        let hostLoader: Loader<UIViewController> = Loader {
            let loader = Loader(view).load()
            if clearBackground {
                loader.view.backgroundColor = .clear
            }
            return loader

        }
        
        self.init(loader: hostLoader, factory: factory, animated: animated)
    }
}
