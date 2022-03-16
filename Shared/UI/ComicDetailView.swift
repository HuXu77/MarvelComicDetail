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
                await loadComicDetails()
            }.alert("Error", isPresented: $viewModel.showErrorMessage) {
                Button("Ok") {}
            } message: {
                Text(viewModel.errorMessage ?? "Unknown Error")
            }.background(Color.black)
        }.redacted(reason: viewModel.loading ? .placeholder : [])
            .navigationTitle(viewModel.title)
            .toolbar {
                ToolbarItem {
                    if viewModel.error {
                        ReloadView(action: loadComicDetails)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        #if DEBUG || TEST
            .sheet(isPresented: $showSettingModal, onDismiss: {
                Task {
                    await loadComicDetails()
                }
            }) {
                SettingsView(comicId: $id, isPresented: $showSettingModal)
            }
            .onShake {
                self.showSettingModal = true
            }
        #endif
    }
    
    private func loadComicDetails() async {
        await viewModel.loadComicDetails(comicId: id)
    }
    
    private var titleView: some View {
        Text(viewModel.title)
            .font(.largeTitle)
            .multilineTextAlignment(.center)
            .padding()
    }
    
    private var descriptionView: some View {
        Text(viewModel.description)
            .font(.body)
            .padding()
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
        ComicDetailView(id: 92260)
            .preferredColorScheme(.dark)
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

