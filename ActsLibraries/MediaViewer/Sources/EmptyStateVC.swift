//
//  EmptyStateVC.swift
//  
//  Copyright © 2020 ActsMedia. All rights reserved.
//  Created by Paul Fechner
//

#if canImport(UIKit)

import UIKit

class EmptyStateVC: UIViewController, RemoteResourceLoading {

    var loadingAction: (() -> ())?
    var loadingFinishedAction: (() -> ())?
}

#endif

