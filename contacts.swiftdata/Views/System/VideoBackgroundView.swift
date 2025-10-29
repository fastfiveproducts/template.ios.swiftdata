//
//  VideoBackgroundView.swift
//
//  Template file created by Pete Maiser, Fast Five Products LLC, in October 2025.
//      Template v0.2.3 Fast Five Products LLC's public AGPL template.
//
//  Copyright © 2025 Fast Five Products LLC. All rights reserved.
//
//  This file is part of a project licensed under the GNU Affero General Public License v3.0.
//  See the LICENSE file at the root of this repository for full terms.
//
//  An exception applies: Fast Five Products LLC retains the right to use this code and
//  derivative works in proprietary software without being subject to the AGPL terms.
//  See LICENSE-EXCEPTIONS.md for details.
//
//  For licensing inquiries, contact: licenses@fastfiveproducts.llc
//


import SwiftUI
import AVKit

extension EnvironmentValues {
    var tabSafeAreaBackground: Bool {
        get { self[tabSafeAreaBackgroundKey.self] }
        set { self[tabSafeAreaBackgroundKey.self] = newValue }
    }
}

private struct tabSafeAreaBackgroundKey: EnvironmentKey {
    static let defaultValue = false
}

struct VideoBackgroundView: UIViewRepresentable {
    @ObservedObject var shared = VideoBackgroundPlayer.shared
    @Environment(\.tabSafeAreaBackground) private var useTabSafeAreaBackground
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor(ViewConfig.bgColor)

        // add the video layer
        let layer = AVPlayerLayer(player: shared.queuePlayer)
        layer.videoGravity = .resizeAspectFill
        layer.frame = UIScreen.main.bounds
        view.layer.addSublayer(layer)

        // overlay a static bar for the Tab Bar to appear over, if requested via \.tabSafeAreaBackground
        if useTabSafeAreaBackground {
            let overlay = UIHostingController(
                rootView:
                    Color(.systemGroupedBackground)
                        .frame(height: 100)
                        .offset(y: 100)
                        .ignoresSafeArea(edges: .bottom)
            )
            overlay.view.backgroundColor = .clear
            overlay.view.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(overlay.view)

            NSLayoutConstraint.activate([
                overlay.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                overlay.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                overlay.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        }

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) { }
}

final class VideoBackgroundPlayer: ObservableObject, DebugPrintable {
    
    // initiate this View as a Swift Singleton
    // this is also how to 'get' the singleton store
    static let shared = VideoBackgroundPlayer()

    // MARK: - Configuration
    private let videoName = "StreemsBackground"
    private let videoExtension = "mp4"

    // MARK: - Player components
    let queuePlayer: AVQueuePlayer
    private var playerLooper: AVPlayerLooper?

    private init() {
        // Configure audio session so background music keeps playing
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            debugPrint("⚠️ SharedVideoPlayer: Audio session config failed: \(error.localizedDescription)")
        }

        // Try to load the video
        if let url = Bundle.main.url(forResource: videoName, withExtension: videoExtension) {
            let item = AVPlayerItem(url: url)
            let queue = AVQueuePlayer(items: [item])
            let looper = AVPlayerLooper(player: queue, templateItem: item)
            queue.isMuted = true
            queue.play()

            self.queuePlayer = queue
            self.playerLooper = looper
        } else {
            // Fallback if video file missing
            debugPrint("⚠️ Missing \(videoName).\(videoExtension); using fallback empty composition.")

            let queue = AVQueuePlayer()
            queue.isMuted = true

            // make a 1-frame empty video so layer still works
            let oneFrame = CMTime(seconds: 1/30, preferredTimescale: 30)
            let emptyComposition = AVMutableComposition()
            emptyComposition.insertEmptyTimeRange(CMTimeRange(start: .zero, duration: oneFrame))
            let emptyItem = AVPlayerItem(asset: emptyComposition)
            let looper = AVPlayerLooper(player: queue, templateItem: emptyItem)

            self.queuePlayer = queue
            self.playerLooper = looper
        }
    }
}


#if DEBUG
#Preview("Plain") {
    ZStack {
        VideoBackgroundView()
        // HeroView()
    }
    .dynamicTypeSize(...ViewConfig.dynamicSizeMax)
    .environment(\.font, Font.body)
}
#Preview("Tab Safe Area") {
    ZStack {
        VideoBackgroundView()
        // HeroView()
    }
    .environment(\.tabSafeAreaBackground, true)
    .dynamicTypeSize(...ViewConfig.dynamicSizeMax)
    .environment(\.font, Font.body)
}
#endif

