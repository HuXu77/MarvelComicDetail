//
//  ComicDetailView.swift
//  Shared
//
//  Created by Mitchell Clay on 3/9/22.
//

import SwiftUI

struct ComicDetailView: View {
    @State var id: Int
    @ObservedObject var viewModel: ComicDetailViewModel = .init()
    #if DEBUG || TEST
    @State var showSettingModal: Bool = false
    #endif
    
    var body: some View {
        ScrollView {
            VStack {
                imageView
                descriptionView
            }.task {
                loadComicDetails()
            }.alert("Error", isPresented: $viewModel.showErrorMessage) {
                Button("Ok") {}
            } message: {
                Text(viewModel.errorMessage ?? "Unknown Error")
            }.background(Color.black)
        }.redacted(reason: viewModel.loading ? .placeholder : [])
            .navigationTitle(viewModel.loading ? "" : viewModel.title)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    if viewModel.error {
                        HStack {
                            Text(viewModel.title).font(.headline)
                            Spacer()
                            ReloadView(action: loadComicDetails)
                        }
                    } else {
                        if viewModel.loading {
                            VStack {
                                Text(viewModel.title).font(.headline)
                                #if targetEnvironment(simulator)
                                loadingIndicatorView
                                #else
                                LoadingIndicator()
                                #endif
                            }
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        #if DEBUG || TEST
            .sheet(isPresented: $showSettingModal, onDismiss: {
                loadComicDetails()
            }) {
                SettingsView(comicId: $id, isPresented: $showSettingModal)
            }
            .onAppear {
                loadComicDetails()
            }
            .onShake {
                self.showSettingModal = true
            }
        #endif
    }
    
    // There is a bug in the simulator where it will animate incorrectly
    // unless its included this way.  This is duplicate code of `LoadingIndicator`
    #if targetEnvironment(simulator)
    @State private var loadingIndicatorState: Bool = false
    private var loadingIndicatorView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 3)
                .stroke(Color(.systemGray5), lineWidth: 3)
                .frame(width: 250, height: 3)

            RoundedRectangle(cornerRadius: 3)
                .stroke(Color.green, lineWidth: 3)
                .frame(width: 30, height: 3)
                .offset(x: loadingIndicatorState ? 110 : -110)
                .animation(Animation.easeInOut(duration: 2).repeatForever(), value: loadingIndicatorState)
        }.onAppear {
            loadingIndicatorState.toggle()
        }
    }
    #endif
    
    private func loadComicDetails() {
        viewModel.loadComicDetails(comicId: id)
    }
    
    private var descriptionView: some View {
        Text(viewModel.description)
            .font(.body)
            .padding()
            .animation(Animation.easeIn(duration: 0.2), value: viewModel.description)
    }
    
    private var imageView: some View {
        HStack {
            Spacer()
            ZStack {
                Image(uiImage: viewModel.image)
                    .resizable()
                    .scaledToFit()
                    .accessibilityLabel(Text("Comic image"))
            }
            Spacer()
        }.background {
            Image(uiImage: viewModel.image)
                .resizable()
                .blur(radius: 6)
                .scaledToFill()
        }
        .padding()
        .animation(Animation.easeIn(duration: 0.2), value: viewModel.image)
    }
}

#if DEBUG || TEST
struct SettingsView: View {
    @Binding var comicId: Int
    @Binding var isPresented: Bool
    @State private var comicIdString: String = ""
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                TextField("Comic ID", text: $comicIdString)
                    .keyboardType(.decimalPad)
                Spacer()
            }.padding()
                .navigationTitle("Settings")
                .toolbar {
                    ToolbarItem {
                        doneButton
                    }
                }
        }.onAppear {
            comicIdString = String(comicId)
        }
    }
    
    var doneButton: some View {
        Button("Done") {
            comicId = Int(comicIdString) ?? 0
            isPresented = false
        }
    }
}
#endif

struct ComicDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ComicDetailView(id: 92260)
                .preferredColorScheme(.dark)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    @State static var comicId: Int = 0
    @State static var isPresented: Bool = true
    
    static var previews: some View {
        SettingsView(comicId: $comicId, isPresented: $isPresented)
            .preferredColorScheme(.dark)
    }
}

