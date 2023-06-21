//
//  ContentView.swift
//  HP Trivia
//
//  Created by Yery Castro on 17/6/23.
//

import SwiftUI
import AVKit

struct ContentView: View {
    @EnvironmentObject private var store: Store
    @EnvironmentObject private var game: Game
    @State private var audioPlayer: AVAudioPlayer!
    @State private var scalePlayButton = false
    @State private var movebackgroundImage = false
    @State private var animateViewIn = false
    @State private var showInstructions = false
    @State private var showSettings = false
    @State private var playGame = false
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Image("hogwarts")
                    .resizable()
                    .frame(width: geo.size.width * 3, height: geo.size.height)
                    .padding(.top, 3)
                    .offset(x: movebackgroundImage ? geo.size.width/1.1 : -geo.size.width/1.1)
                    .onAppear {
                        withAnimation(.linear(duration: 60).repeatForever()) {
                            movebackgroundImage.toggle()
                        }
                    }
                
                VStack {
                    VStack {
                        if animateViewIn {
                            VStack {
                                Image(systemName: "bolt.fill")
                                    .font(.largeTitle)
                                    .imageScale(.large)
                                
                                Text("HP")
                                    .font(.custom(Constans.hpFont, size: 70))
                                    .padding(.bottom, -50)
                                
                                Text("Trivia")
                                    .font(.custom(Constans.hpFont, size: 60))
                            }
                            .padding(.top, 70)
                            .transition(.move(edge: .top))
                        }
                    }
                    .animation(.easeOut(duration: 0.7).delay(2), value: animateViewIn)
                    
                    Spacer()
                    
                    
                    VStack {
                        if animateViewIn {
                            VStack {
                                Text("Recent Scores")
                                    .font(.title2)
                                
                                Text("\(game.recentScores[0])")
                                Text("\(game.recentScores[1])")
                                Text("\(game.recentScores[2])")
                            }
                            .font(.title3)
                            .padding(.horizontal)
                            .foregroundColor(.white)
                            .background(.black.opacity(0.7))
                            .cornerRadius(15)
                            .transition(.opacity)
                        }
                    }
                    .animation(.linear(duration: 1).delay(4), value: animateViewIn)
                    
                    Spacer()
                    
                    HStack {
                        
                        Spacer()
                        
                        VStack {
                            if animateViewIn {
                                Button {
                                    showInstructions.toggle()
                                } label: {
                                    Image(systemName: "info.circle.fill")
                                        .font(.largeTitle)
                                        .foregroundColor(.white)
                                        .shadow(radius: 5)
                                }
                                .transition(.offset(x: -geo.size.width/4))
                                .sheet(isPresented: $showInstructions) {
                                    Instructions()
                                }
                            }
                        }
                        .animation(.easeOut(duration: 0.7).delay(2.7), value: animateViewIn)
                        
                        Spacer()
                        
                        
                        
                        VStack {
                            if animateViewIn {
                                Button {
                                    filterQuestions()
                                    game.startGame()
                                    playGame.toggle()
                                } label: {
                                    Text("Play")
                                        .font(.largeTitle)
                                        .foregroundColor(.white)
                                        .padding(.vertical, 7)
                                        .padding(.horizontal, 50)
                                        .background(store.books.contains(.active) ?.brown : .gray)
                                        .cornerRadius(7)
                                        .shadow(radius: 5)
                                }
                                .scaleEffect(scalePlayButton ? 1.2 : 1)
                                .onAppear {
                                    withAnimation(.easeInOut(duration: 1.3).repeatForever()) {
                                        scalePlayButton.toggle()
                                    }
                                }
                                .transition(.offset(y: geo.size.height/3))
                                .fullScreenCover(isPresented: $playGame) {
                                    Gameplay()
                                        .environmentObject(game)
                                        .onAppear {
                                            audioPlayer.setVolume(0, fadeDuration: 2)
                                        }
                                        .onDisappear {
                                            audioPlayer.setVolume(1, fadeDuration: 3)
                                        }
                                }
                                .disabled(store.books.contains(.active) ? false : true)
                            }
                        }
                        .animation(.easeOut(duration: 0.7).delay(2), value: animateViewIn)
                                
                        Spacer()
                        
                        VStack {
                            if animateViewIn {
                                Button {
                                    showSettings.toggle()
                                } label: {
                                    Image(systemName: "gearshape.fill")
                                        .font(.largeTitle)
                                        .foregroundColor(.white)
                                        .shadow(radius: 5)
                                }
                                .transition(.offset(x: geo.size.width/4))
                                .sheet(isPresented: $showSettings) {
                                    Settings()
                                        .environmentObject(store)
                                }
                            }
                        }
                        .animation(.easeOut(duration: 0.7).delay(2.7), value: animateViewIn)
                        
                        Spacer()
                    }
                    .frame(width: geo.size.width)
                    
                    VStack {
                        if animateViewIn {
                            if store.books.contains(.active) == false {
                                Text("no questions available. Go to settings.⬆️")
                                    .multilineTextAlignment(.center)
                                    .transition(.opacity)
                            }
                        }
                    }
                    .animation(.easeOut.delay(3), value: animateViewIn)
                    
                    Spacer()
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .ignoresSafeArea()
        .onAppear {
            animateViewIn = true
            playAudio()
        }
    }
    
    private func playAudio() {
        let sound = Bundle.main.path(forResource: "magic-in-the-air", ofType: "mp3")
        audioPlayer = try! AVAudioPlayer(contentsOf: URL(filePath: sound!))
        audioPlayer.numberOfLoops = -1
        audioPlayer.play()
    }
    
    private func filterQuestions() {
        var books: [Int] = []
        
        for (index, status) in store.books.enumerated() {
            if status == .active {
                books.append(index+1)
            }
        }
        
        game.filterQuestions(to: books)
        game.newQuestion()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ContentView()
                .environmentObject(Store())
                .environmentObject(Game())
        }
    }
}
