//
//  ContentView.swift
//  TPWallet
//
//  Created by Truc Pham on 27/07/2022.
//

import SwiftUI
import AVKit
import AVFoundation
import Combine
import MediaPlayer

class SoundManager: NSObject, ObservableObject {
   
    struct PlayItem {
        let id : String
        let title : String
        let artist : String
        let thumb : String
        let duration : Double
    }
    private var player: AVPlayer?
    private var timer: AnyCancellable?
    var playlist : [PlayItem] = []
    @Published var isPlaying = false
    @Published var isLoading = false
    @Published var elapsedTime: Double = 0
    @Published var playingIndex: Int = -1
    init(_ playlist : [PlayItem] = []) {
        self.playlist = playlist
    }
    
    
    func play(_ index: Int){
        self.isLoading = true
        self.elapsedTime = 0
        guard self.playlist.count > 0, playingIndex < self.playlist.count - 1 else {
            self.stopSound()
            return
        }
        self.playingIndex = index
        APIManager().sendPostRequest(urlString: "http://13.229.105.182:8080/api/zingmp3/song", bodyParameters: ["songId": playlist[playingIndex].id]) {[weak self] (result : Result<AudioQuality, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                print(data)
                var url = data.normal ?? ""
                if let lossless = data.lossless { url = lossless }
                if let high = data.high { url = high }
                let mp3URL = URL(string: url)!
                DispatchQueue.main.async {
                    self.playSound(mp3URL)
                }
            case .failure(let error):
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    self.play(self.playingIndex + 1)
                }
            }
        }
    }
    
    func playSound(_ url : URL) {
        removeActionsToControlCenter()
        removePlayerObserver()
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        _ = try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
        _ = try? AVAudioSession.sharedInstance().setActive(true)
        
        // Add observer for player item status changes
        
        addActionsToControlCenter()
        player?.addObserver(self, forKeyPath: "status", options: [.new], context: nil)
        player?.addObserver(self, forKeyPath: "timeControlStatus", options: [.new], context: nil)
        
        // Add observer for player item playback completion
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
        
        // Start the timer to update elapsed time
        timer = Timer.publish(every: 1, on: .main, in: .default)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateElapsedTime()
            }
        
        player?.play()
    }
    func removePlayerObserver(){
        player?.removeObserver(self, forKeyPath: "status")
        player?.removeObserver(self, forKeyPath: "timeControlStatus")
    }
    func removeActionsToControlCenter(){
        MPRemoteCommandCenter.shared().playCommand.removeTarget(self)
        MPRemoteCommandCenter.shared().pauseCommand.removeTarget(self)
        MPRemoteCommandCenter.shared().previousTrackCommand.removeTarget(self)
        MPRemoteCommandCenter.shared().nextTrackCommand.removeTarget(self)
//        MPRemoteCommandCenter.shared().changePlaybackPositionCommand.removeTarget(self)
//        MPRemoteCommandCenter.shared().seekForwardCommand.removeTarget(self)
//        MPRemoteCommandCenter.shared().seekBackwardCommand.removeTarget(self)
        
    }
    func addActionsToControlCenter(){
        addActionToPlayCommand()
        addActionToPauseCommnd()
        addActionToPreviousCommand()
        addActionToNextCommand()
//        addActionToChangePlayBackPosition()
//        addActionToseekForwardCommand()
//        addActionToseekBackwordCommand()
    }
    func addActionToPlayCommand(){
        MPRemoteCommandCenter.shared().playCommand.isEnabled = true
        MPRemoteCommandCenter.shared().playCommand.addTarget(self, action: #selector(playCommand))
    }
    @objc private func playCommand() -> MPRemoteCommandHandlerStatus {
        self.player?.play()
        return .success
    }
    func addActionToPauseCommnd(){
        MPRemoteCommandCenter.shared().pauseCommand.isEnabled = true
        MPRemoteCommandCenter.shared().pauseCommand.addTarget(self, action: #selector(pauseCommand))
    }
    @objc private func pauseCommand() -> MPRemoteCommandHandlerStatus {
        self.player?.pause()
        return .success
    }
    
    func addActionToPreviousCommand(){
        MPRemoteCommandCenter.shared().previousTrackCommand.isEnabled = true
        MPRemoteCommandCenter.shared().previousTrackCommand.addTarget(self, action: #selector(previousButtonTapped))
    }
    @objc private func previousButtonTapped() -> MPRemoteCommandHandlerStatus{
        guard playingIndex - 1 > -1 else { return .commandFailed }
        self.play(self.playingIndex - 1)
        return .success
    }
    
    func addActionToNextCommand(){
        MPRemoteCommandCenter.shared().nextTrackCommand.isEnabled = true
        MPRemoteCommandCenter.shared().nextTrackCommand.addTarget(self, action: #selector(nextButtonTapped))
    }
    @objc private func nextButtonTapped() -> MPRemoteCommandHandlerStatus{
        guard playingIndex + 1 < self.playlist.count else { return .commandFailed }
        self.play(self.playingIndex + 1)
        return .success
    }
    
    func addActionToChangePlayBackPosition(){
        MPRemoteCommandCenter.shared().changePlaybackPositionCommand.isEnabled = true
        MPRemoteCommandCenter.shared().changePlaybackPositionCommand.addTarget(self, action: #selector(changePlaybackPosition))
    }
    @objc private func changePlaybackPosition() -> MPRemoteCommandHandlerStatus {
        return .success
    }
    
    func addActionToseekForwardCommand(){
        MPRemoteCommandCenter.shared().seekForwardCommand.isEnabled = true
        MPRemoteCommandCenter.shared().seekForwardCommand.addTarget(self, action: #selector(seekForward))
    }
    @objc private func seekForward() -> MPRemoteCommandHandlerStatus {
        return .success
    }
    
    func addActionToseekBackwordCommand(){
        MPRemoteCommandCenter.shared().seekBackwardCommand.isEnabled = true
        MPRemoteCommandCenter.shared().seekBackwardCommand.addTarget(self, action: #selector(seekBackword))
    }
    @objc private func seekBackword() -> MPRemoteCommandHandlerStatus{
        return .success
    }
    
    @objc private func playerDidFinishPlaying(note: NSNotification) {
        stopSound()
        self.play(self.playingIndex + 1)
    }
    
    func stopSound() {
        self.isPlaying = false
        self.isLoading = false
        self.elapsedTime = 0
        
        player?.pause()
        player = nil
        
        // Cancel the timer
        timer?.cancel()
        timer = nil
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = 0
        UIApplication.shared.endReceivingRemoteControlEvents()

    }
    
    func pause(){
        player?.pause()
        self.paused()
    }
    
    private func updateElapsedTime() {
        guard let player = player else { return }
        elapsedTime = player.currentTime().seconds
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = NSNumber(value: elapsedTime)
    }
    
    
    private func playing(){
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = NSNumber(value: 1.0)
        self.isPlaying = true
        self.isLoading = false
    }
    private func waitingToPlayAtSpecifiedRate(){
        self.isPlaying = false
        self.isLoading = true
    }
    private func paused(){
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = NSNumber(value: 0.0)
        self.isPlaying = false
        self.isLoading = false
    }
    
    private func readyToPlay(){
        UIApplication.shared.beginReceivingRemoteControlEvents()
        let nowPlayingInfo : [String : Any] = [
            MPMediaItemPropertyPlaybackDuration : NSNumber(value: (self.player?.currentItem?.asset.duration.seconds ?? 0)),
            MPMediaItemPropertyTitle            : playlist[playingIndex].title,
            MPNowPlayingInfoPropertyElapsedPlaybackTime : NSNumber(value: self.elapsedTime),
            MPNowPlayingInfoPropertyPlaybackQueueCount  : NSNumber(value: playlist.count),
            MPNowPlayingInfoPropertyPlaybackQueueIndex  : NSNumber(value:playingIndex),
            MPMediaItemPropertyMediaType : NSNumber(value: MPNowPlayingInfoMediaType.audio.rawValue),
            MPMediaItemPropertyArtist :  playlist[playingIndex].artist,
            MPNowPlayingInfoPropertyPlaybackRate : NSNumber(value: 0.0),
        ]
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        fetchArtworkImage(from: URL(string: playlist[playingIndex].thumb)!) { artworkImage in
            if let artworkImage = artworkImage {
                let artwork = MPMediaItemArtwork(boundsSize: artworkImage.size) { _ in return artworkImage }
                MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyArtwork] = artwork
            }
        }
        self.isLoading = false
        self.isPlaying = false
    }
    // Observer for player item status changes
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let player = player else { return }
        switch keyPath {
        case "timeControlStatus":
            if  let rawStatus = change?[.newKey] as? Int, let status = AVPlayer.TimeControlStatus(rawValue: rawStatus) {
                switch status {
                case .playing: self.playing()
                case .paused: self.paused()
                case .waitingToPlayAtSpecifiedRate: self.waitingToPlayAtSpecifiedRate()
                default: break
                }
            }
        case "status":
            if player.status == .readyToPlay {
                self.readyToPlay()
            } else if player.status == .failed || player.status == .unknown {
                self.stopSound()
            }
        default:
            break
        }
        
    }
    private func fetchArtworkImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let imageData = try Data(contentsOf: url)
                let artworkImage = UIImage(data: imageData)
                completion(artworkImage)
            } catch {
                print("Failed to fetch artwork image: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }
    
    deinit {
        self.removeActionsToControlCenter()
        self.removePlayerObserver()
        NotificationCenter.default.removeObserver(self)
    }
}

class ViewModel : ObservableObject {
    @Published var playlist : ChartHome?
    func getData() {
        APIManager().sendPostRequest(urlString: "http://13.229.105.182:8080/api/zingmp3/charthome", bodyParameters: [:], completion: { (result : Result<ChartHome, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let success):
                    self.playlist = success
                case .failure(let failure):
                    print(failure)
                }
            }
        })
    }
}


struct ContentView: View {
    let maxRow = 10
    @StateObject private var viewModel : ViewModel = .init()
    @StateObject private var soundManager = SoundManager()
    @State var lastScaleValue: CGFloat = 1.0
    var body: some View {
        //        MainView()
        //            .background(Color("19173D").ignoresSafeArea())
        let rtChart = viewModel.playlist?.rtChart.items ?? []
        let newRelease = viewModel.playlist?.newRelease ?? []
        let weekVN = viewModel.playlist?.weekChart.vn.items ?? []
        let weekUS = viewModel.playlist?.weekChart.us.items ?? []
        let weekKR = viewModel.playlist?.weekChart.korea.items ?? []
        let items = rtChart + newRelease + weekVN + weekUS + weekKR
        ZStack {
            ScrollViewReader { reader in
                ScrollView([.horizontal, .vertical], showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 10) {
                        let to = Int(items.count / maxRow) + (items.count % maxRow > 0 ? 1 : 0)
                        ForEach(0..<to, id: \.self) { i in
                            HStack(spacing: 10) {
                                let from = i * maxRow
                                let to = min(items.count, (i * maxRow + maxRow))
                                ForEach(from..<to, id: \.self) { j in
                                    if #available(iOS 15.0, *) {
                                        ItemView(item: items[j], isPlaying: .constant(soundManager.isPlaying), isLoading: .constant(soundManager.isLoading), playbackTime: $soundManager.elapsedTime, isSelected: .constant(soundManager.playingIndex == j)).id(j)
                                            .onTapGesture {
                                                if soundManager.playingIndex == j {
                                                    soundManager.pause()
                                                }
                                                else {
                                                    soundManager.playlist = items.map({ ele in
                                                        SoundManager.PlayItem(id: ele.encodeID, title: ele.title, artist: ele.artistsNames, thumb: ele.thumbnailM, duration: Double(ele.duration))
                                                    })
                                                    soundManager.play(j)
                                                }
                                            }
                                    } else {
                                        // Fallback on earlier versions
                                    }
                                }
                            }
                        }
                    }
                }
                .background(Color.black.opacity(0.8))
                .onChange(of: soundManager.playingIndex, perform: { value in
                    withAnimation(.linear(duration: 0.3)) {
                        reader.scrollTo(value, anchor: .center)
                    }
                    
                })
                .onAppear{
                    viewModel.getData()
                }
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity).background(Color.white)
            .edgesIgnoringSafeArea(.all)
        
    }
    
}

@available(iOS 15.0, *)
struct ItemView : View {
    var item : NewRelease
    @Binding var isPlaying : Bool
    @Binding var isLoading : Bool
    @Binding var playbackTime: Double
    @Binding var isSelected : Bool
    var body: some View {
        ZStack(alignment: .leading) {
            CacheAsyncImage(url: URL(string: item.thumbnailM)!) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 250, height: 360)
            } placeholder: {
                ZStack {
                    ProgressView().tint(.white)
                }.frame(maxWidth: .infinity, maxHeight: .infinity).background(.clear)
            }
            .overlay(
                LinearGradient(colors: [
                    .clear,
                    .black.opacity(0.8)
                ], startPoint: .top, endPoint: .bottom)
            )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title).font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                Text(item.artistsNames)
                    .foregroundColor(.white.opacity(0.7))
                
                if isSelected {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(.ultraThinMaterial)
                                .frame(width: geo.size.width,height: 5)
                            Capsule().fill(.blue)
                                .frame(width: geo.size.width * playbackTime / Double(item.duration),height: 5)
                            
                        }.frame(maxWidth: .infinity,alignment: .leading)
                    }.frame(height: 5).padding(.top, 15)
                    
                    HStack {
                        Text("\(Int(playbackTime).secondsToHoursMinutesSeconds.1):\(String(format: "%02d", Int(playbackTime).secondsToHoursMinutesSeconds.2))")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        Spacer()
                        Text("\(item.duration.secondsToHoursMinutesSeconds.1):\(String(format: "%02d", item.duration.secondsToHoursMinutesSeconds.2))")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }.padding(.all, 5)
                    
                    HStack {
                        Spacer()
                        Button {
                            
                        } label: {
                            if isLoading { ProgressView().font(.title3).tint(.white) }
                            else { Image(systemName: self.isPlaying ? "pause.fill" : "play.fill")
                                .font(.title3) }
                        }
                        Spacer()
                    }
                    .padding(.vertical, 10)
                    .foregroundColor(.white)
                }
                
            }.frame(maxHeight: .infinity, alignment: .bottom).padding()
            
            
        }
        .frame(width: 250, height: 360)
        .clipped()
        .shadow(color: .black, radius: 10, x: 5, y: 5)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


struct CacheAsyncImage<Content, PlaceHolder>: View where Content: View, PlaceHolder: View{
    
    let url: URL
    let content: (Image) -> Content
    let placeholder: () -> PlaceHolder
    @State var isLoading : Bool = false
    @State var imageData : Data = Data()
    
    typealias DownloadCompletionHandler = (Result<Data,Error>) -> ()
    private var cache: URLCache = URLCache(memoryCapacity: 0, diskCapacity: 100 * 1024 * 1024, diskPath: "gifCache")
    
    init(
        url: URL,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> PlaceHolder
    ){
        self.url = url
        self.content = content
        self.placeholder = placeholder
    }
    
    var body: some View{
        ZStack {
            if isLoading { placeholder() }
            else {
                content(.init(uiImage: UIImage(data: imageData) ?? UIImage()))
            }
        }.onAppear {
            self.isLoading = true
            downloadContent(url: url) { result in
                self.isLoading = false
                switch result {
                case.success(let data):
                    self.imageData = data
                case .failure(let err):
                    print(err.localizedDescription)
                }
            }
        }
        
    }

    

    private func createAndRetrieveURLSession() -> URLSession {
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.requestCachePolicy = .returnCacheDataElseLoad
        sessionConfiguration.urlCache = cache
        return URLSession(configuration: sessionConfiguration)
    }
    private func downloadContent(url: URL?, completionHandler: @escaping DownloadCompletionHandler) {
        guard let downloadUrl = url else { return }
        let urlRequest = URLRequest(url: downloadUrl)
        // First try to fetching cached data if exist
        if let cachedData = self.cache.cachedResponse(for: urlRequest) {
            print("Cached data in bytes:", cachedData.data)
            completionHandler(.success(cachedData.data))

        } else {
            // No cached data, download content than cache the data
            createAndRetrieveURLSession().dataTask(with: urlRequest) { (data, response, error) in
                self.isLoading = false
                if let error = error {
                    completionHandler(.failure(error))
                } else {
                    let cachedData = CachedURLResponse(response: response!, data: data!)
                    self.cache.storeCachedResponse(cachedData, for: urlRequest)
                    completionHandler(.success(data!))
                }
            }.resume()
        }
    }
}




extension Int {
    var secondsToHoursMinutesSeconds : (Int, Int, Int) {
        let seconds = self
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
}
