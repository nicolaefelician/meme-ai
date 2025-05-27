import SwiftUI
import Combine

final class AiChatViewModel: ObservableObject {
    @Published var inputText: String = ""
    @Published var isInteracting: Bool = false
    @Published var messages: [ChatMessage] = []
    
    @Published var uploadedImages: [UIImage] = []
    @Published var selectedImage: UIImage?
    @Published var analysisImage: UIImage?
    
    @Published var showActionSheet: Bool = false
    @Published var showAnalysisSheet: Bool = false
    
    @ObservedObject var appManager = AppManager.shared
    
    private var cancellables = Set<AnyCancellable>()
    
    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    
    @MainActor
    func sendTapped() async {
        let text = inputText
        inputText = ""
        await send(text)
    }
    
    init() {
        self.impactFeedback.prepare()
        
        $selectedImage.sink { newImage in
            guard let image = newImage else { return }
            self.uploadedImages.append(image)
        }
        .store(in: &cancellables)
        
        $analysisImage.sink { newImage in
            guard let image = newImage else { return }
            
            Task { @MainActor in
                self.appManager.isLoading = true
                let analysis = await CoinAnalysisApi.shared.getChartAnalysis(image: image)
                
                if let analysis = analysis {
                    self.appManager.path.append(.coinAnalysisView(analysis: analysis))
                } else {
                    self.appManager.showError = true
                }
                
                self.appManager.isLoading = false
            }
        }
        .store(in: &cancellables)
    }
    
    func scrollToBottom(proxy: ScrollViewProxy) {
        guard let id = self.messages.last?.id else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeOut(duration: 0.3)) {
                proxy.scrollTo(id, anchor: .bottom)
            }
        }
    }
    
    @MainActor
    func retry(chatMessage: ChatMessage) async {
        let index = messages.firstIndex { message in
            return chatMessage.id == message.id
        }
        
        guard let index = index else { return }
        
        messages.remove(at: index)
        await send(chatMessage.sendText)
    }
    
    @MainActor
    private func send(_ text: String) async {
        isInteracting = true
        var streamText = ""
        
        let imagesList = uploadedImages.map { image in
            return Utilities.shared.convertImageToBase64(image: image) ?? ""
        }
        
        let history = self.messages
        let messageRow = ChatMessage(isInteracting: true, sendText: text, responseImage: "small-icon", responseText: streamText, uploadedImages: self.uploadedImages)
        self.messages.append(messageRow)
        self.uploadedImages.removeAll()
        
        do {
            let stream = try await CoinAnalysisApi.shared.fetchChatResponse(text, history: history, images: imagesList)
            for try await text in stream {
                streamText += text
                messageRow.responseText = streamText.trimmingCharacters(in: .whitespacesAndNewlines)
                self.messages[self.messages.count - 1] = messageRow
            }
        } catch {
            messageRow.responseError = error.localizedDescription
        }
        
        messageRow.isInteracting = false
        self.messages[self.messages.count - 1] = messageRow
        isInteracting = false
    }
}

struct AiChatView: View {
    @StateObject var viewModel = AiChatViewModel()
    @FocusState var isTextFieldFocused: Bool
    
    @State private var isImagePickerPresented: Bool = false
    @State private var isAnalysisImagePickerPresented: Bool = false
    
    @State private var sourceType: UIImagePickerController.SourceType = .camera
    
    var body: some View {
        ScrollViewReader { proxy in
            ZStack {
                VStack {
                    ScrollView {
                        if viewModel.messages.isEmpty {
                            VStack(spacing: 0) {
                                Image("icon")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 90, height: 90)
                                    .cornerRadius(45)
                                
                                Text("Chat with your personal AI!")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 30)
                                    .multilineTextAlignment(.center)
                                
                                Text("Understand any chart with the help of the AI Chart Analysis! Take a photo of the chart and get instant information and details.")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 40)
                            }
                            .padding(.top, isTextFieldFocused ? 60 : 200)
                            .animation(.easeOut, value: isTextFieldFocused)
                        } else {
                            ForEach(viewModel.messages, id: \.id) { message in
                                ChatMessageCard(messageRow: message) { message in
                                    Task { @MainActor in
                                        await viewModel.retry(chatMessage: message)
                                    }
                                }
                            }
                        }
                    }
                    .onTapGesture {
                        isTextFieldFocused = false
                    }
                    .sheet(isPresented: $isImagePickerPresented) {
                        ImagePicker(selectedImage: $viewModel.selectedImage, isImagePickerPresented: $isImagePickerPresented, sourceType: sourceType)
                    }
                    .sheet(isPresented: $isAnalysisImagePickerPresented) {
                        ImagePicker(selectedImage: $viewModel.analysisImage, isImagePickerPresented: $isAnalysisImagePickerPresented, sourceType: sourceType)
                    }
                    .actionSheet(isPresented: $viewModel.showAnalysisSheet) {
                        ActionSheet(
                            title: Text("Choose Photo Source"),
                            buttons: [
                                .default(Text("From Photos")) {
                                    sourceType = .photoLibrary
                                    isAnalysisImagePickerPresented = true
                                },
                                .default(Text("Take Photo")) {
                                    sourceType = .camera
                                    isAnalysisImagePickerPresented = true
                                },
                                .cancel {}
                            ]
                        )
                    }
                    
                    VStack {
                        if !viewModel.uploadedImages.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHStack(spacing: 10) {
                                    ForEach(Array(viewModel.uploadedImages.enumerated()), id: \.offset) { index, image in
                                        ZStack(alignment: .topTrailing) {
                                            Image(uiImage: image)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 80, height: 80)
                                                .cornerRadius(10)
                                                .clipped()
                                            
                                            Button(action: {
                                                viewModel.uploadedImages.remove(at: index)
                                            }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.gray)
                                                    .background(Color.white.clipShape(Circle()))
                                            }
                                            .offset(x: -5, y: 7)
                                        }
                                    }
                                }
                                .padding(.bottom, 10)
                                .padding(.top, 10)
                            }
                            .frame(height: 80)
                        }
                        
                        HStack {
                            Button(action: {
                                viewModel.impactFeedback.impactOccurred()
                                viewModel.showActionSheet = true
                            }) {
                                Image("image")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 27.5, height: 27.5)
                                    .foregroundColor(.black)
                            }
                            
                            TextField("Type here...", text: $viewModel.inputText)
                                .padding(.horizontal, 5)
                                .padding(.leading, 2)
                                .background(.clear)
                                .cornerRadius(15)
                                .foregroundColor(.black)
                                .focused($isTextFieldFocused)
                            
                            if viewModel.isInteracting {
                                ProgressView()
                                    .frame(width: 29, height: 29)
                            } else {
                                Button(action: {
                                    viewModel.impactFeedback.impactOccurred()
                                    if viewModel.inputText.isEmpty { return }
                                    
                                    Task { @MainActor in
                                        isTextFieldFocused = false
                                        await viewModel.sendTapped()
                                        viewModel.scrollToBottom(proxy: proxy)
                                    }
                                }) {
                                    Image("send")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 29, height: 29)
                                }
                            }
                        }
                    }
                    .onAppear {
                        viewModel.scrollToBottom(proxy: proxy)
                    }
                    .onChange(of: viewModel.messages) { _ in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            viewModel.scrollToBottom(proxy: proxy)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(.gray.opacity(0.2))
                    .cornerRadius(20)
                    .padding(.horizontal, 13)
                    .padding(.bottom, 20)
                }
                
                VStack {
                    Spacer()
                    
                    HStack {
                        Button(action: {
                            viewModel.impactFeedback.impactOccurred()
                            viewModel.showAnalysisSheet = true
                        }) {
                            ZStack {
                                Rectangle()
                                    .frame(width: 46, height: 46)
                                    .cornerRadius(23)
                                    .foregroundStyle(Color(hex: "#FFBB00"))
                                Image("grid")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                            }
                        }
                        .actionSheet(isPresented: $viewModel.showActionSheet) {
                            ActionSheet(
                                title: Text("Choose Photo Source"),
                                buttons: [
                                    .default(Text("From Photos")) {
                                        sourceType = .photoLibrary
                                        isImagePickerPresented = true
                                    },
                                    .default(Text("Take Photo")) {
                                        sourceType = .camera
                                        isImagePickerPresented = true
                                    },
                                    .cancel {}
                                ]
                            )
                        }
                        
                        Spacer()
                    }
                    .padding(.leading, 13)
                    .padding(.bottom, viewModel.uploadedImages.isEmpty ? 80 : 165)
                }
            }
        }
        .background(Consts.shared.backgroundColor)
    }
}
