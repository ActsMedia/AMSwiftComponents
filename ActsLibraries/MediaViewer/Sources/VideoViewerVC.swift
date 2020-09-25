//
//  VideoViewerVC.swift
//  
//  Copyright © 2020 ActsMedia. All rights reserved.
//  Created by Paul Fechner
//

#if canImport(UIKit) && canImport(AVKit)

import UIKit
import AVKit

open class VideoViewerVC: AVPlayerViewController, AVPlayerViewControllerDelegate, URLUpdatable {

    public var loadingAction: (() -> ())?
    public var loadingFinishedAction: (() -> ())?

    public var autoPlay: Bool = true

    private var currentURL: URL?

    open override func viewDidLoad() {
        super.viewDidLoad()
////        delegate = self
////        exitsFullScreenWhenPlaybackEnds = true
////        entersFullScreenWhenPlaybackBegins = true
        allowsPictureInPicturePlayback = true
//
    }
    open func update(with url: URL) {
        guard url != currentURL else { return }
        currentURL = url
        
        player = AVPlayer(url: url)
        loadingFinishedAction?()
        if autoPlay {
            player?.play()
        }
    }
}

#endif
