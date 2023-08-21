import Foundation
import SwiftUI
import AVFoundation

class PlayerPreview : UIView {
    private weak var videoHandler: VideoHandler?
    private var isInitialized = false
    init(videoHandler: VideoHandler, size: CGSize) {
        super.init(frame: .init(origin: .center, size: size))
        self.videoHandler = videoHandler
        self.videoHandler?.setTargetLayer(layer: self.layer)
        self.backgroundColor = .stepinWhite20
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if isInitialized {
            return
        }
        isInitialized = true
        self.videoHandler?.setVideoPlayerLayer(layer: self.layer)
    }
}


struct PlayerContainerView: UIViewRepresentable {
    typealias UIViewType = PlayerPreview
    
    private weak var videoHandler: VideoHandler?
    private var size: CGSize
    
    init(videoHandler: VideoHandler, size: CGSize) {
        self.videoHandler = videoHandler
        self.size = size
    }
    
    func makeUIView(context: Context) -> PlayerPreview {
        return PlayerPreview(videoHandler: self.videoHandler!, size: self.size)
    }
    
    func updateUIView(_ uiView: PlayerPreview, context: Context) {
        
    }
}

struct NewVideoView: View {
    
    weak var videoHandler: VideoHandler?
    init(videoHandler: VideoHandler) {
        self.videoHandler = videoHandler
    }
    
    var body: some View {
        GeometryReader { geo in
            
            PlayerContainerView(videoHandler: self.videoHandler!, size: geo.size)
        }
    }
}
