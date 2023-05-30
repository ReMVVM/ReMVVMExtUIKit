//
//  ShowTabReducer.swift
//  ReMVVMExt
//
//  Created by DGrzegorz Jurzak, Daniel Plachta, Dariusz Grzeszczak.
//  Copyright © 2019. All rights reserved.
//

import Loaders
import ReMVVMCore
import UIKit

public typealias NavigationType = [AnyNavigationItem]

extension NavigationRoot {
    var navigationType: NavigationType { stacks.map { $0.0 } }
}

extension NavigationItem where Self: CaseIterable {
    static var navigationType: NavigationType { allCases.map { AnyNavigationItem($0) }}
}

struct ShowReducer: Reducer {
    public static func reduce(state: Navigation, with action: Show) -> Navigation {
        let current = action.item
        var stacks: [(AnyNavigationItem, [ViewModelFactory])]
        let factory = action.controllerInfo.factory ?? state.factory
        if action.navigationType == state.root.navigationType { //check the type is the same
            stacks = state.root.stacks.map {
                guard $0.0 == current, $0.1.isEmpty else {
                    if action.resetStack { return ($0.0, [factory]) }
                    return $0
                }
                return ($0.0, [factory])

            }
        } else {
            stacks = action.navigationType.map {
                guard $0 == current else { return ($0, []) }
                return ($0, [factory])
            }
        }
        let root = NavigationRoot(current: current, stacks: stacks)
        return Navigation(root: root, modals: [])
    }
}

public struct ShowMiddleware<State: NavigationState>: Middleware {
    public let uiState: UIState

    public init(uiState: UIState) {
        self.uiState = uiState
    }

    public func onNext(for state: State, action: Show, interceptor: Interceptor<Show, State>, dispatcher: Dispatcher) {
        print(action)
        guard state.navigation.root.currentItem != action.item || action.resetStack else {
            dispatcher.dispatch(action: Pop(mode: .popToRoot, animated: true))
            return
        }

        interceptor.next(action: action) { [uiState] _ in
            let wasTabOnTop = state.navigation.root.navigationType == action.navigationType
            && uiState.rootViewController is NavigationContainerController

            let containerController: NavigationContainerController
            if wasTabOnTop {
                containerController = uiState.rootViewController as! NavigationContainerController
            } else {
                let config = uiState.config.navigationConfigs.first { $0.navigationType == action.navigationType }
                if case let .custom(configurator) = config?.config {
                    containerController = configurator(action.navigationType)
                } else {
                    let tabController = TabBarViewController(config: config, navigationControllerFactory: uiState.config.navigationController)
                    tabController.loadViewIfNeeded()

                    containerController = tabController
                }
            }


            //set up current if empty (or reset)
            let topNavigationController = containerController
                .containers?
                .first { action.item == ($0.tabBarItem as? TabItem)?.navigationTab }?
                .currentNavigationController

            if let topNavigationController,
               topNavigationController.viewControllers.isEmpty || action.resetStack {
                NavigationDispatcher.main.async { completion in
                    topNavigationController.setViewControllers([action.controllerInfo.loader.load()],
                                                               animated: false,
                                                               completion: completion)
                }
            }

            if !wasTabOnTop {
                NavigationDispatcher.main.async { completion in
                    uiState.setRoot(controller: containerController,
                                    animated: action.controllerInfo.animated,
                                    navigationBarHidden: action.navigationBarHidden,
                                    completion: completion)
                }
            }

            NavigationDispatcher.main.async { completion in
                // dismiss modals
                uiState.rootViewController.dismiss(animated: true, completion: completion)
            }
        }
    }
}
