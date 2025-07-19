import SwiftUI

struct PostDetailView: View {
    let post: Post
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Header with user info
                HStack(spacing: 12) {
                    AsyncImage(url: URL(string: post.owner.avatar.url)) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                        } else if phase.error != nil {
                            Circle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 50, height: 50)
                        } else {
                            ProgressView()
                                .frame(width: 50, height: 50)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(post.owner.nickname)
                            .font(.custom(TextFonts.instrumentSansSemiBold.rawValue, size: 18))
                            .foregroundColor(.black)
                        
                        Text(post.postTime)
                            .font(.custom(TextFonts.interRegular.rawValue, size: 14))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    // Share button
                    Button(action: {
                        sharePost()
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 20)
                
                // Post content
                Text(post.textContent)
                    .font(.custom(TextFonts.interRegular.rawValue, size: 16))
                    .foregroundColor(.black)
                    .lineSpacing(4)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                
                // Post images if available
                if let images = post.images, !images.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(images.indices, id: \.self) { index in
                                AsyncImage(url: URL(string: images[index].url)) { phase in
                                    if let image = phase.image {
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 280, height: 200)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                    } else if phase.error != nil {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.gray.opacity(0.2))
                                            .frame(width: 280, height: 200)
                                            .overlay(
                                                Image(systemName: "photo")
                                                    .font(.title)
                                                    .foregroundColor(.gray)
                                            )
                                    } else {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.gray.opacity(0.1))
                                            .frame(width: 280, height: 200)
                                            .overlay(
                                                ProgressView()
                                            )
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 25)
                }
                
                // Engagement stats
                HStack(spacing: 30) {
                    StatView(
                        icon: "eye.fill",
                        count: post.impressionCount,
                        label: "Views",
                        color: .blue
                    )
                    
                    StatView(
                        icon: "heart.fill",
                        count: post.likeCount,
                        label: "Likes",
                        color: .red
                    )
                    
                    StatView(
                        icon: "arrowshape.turn.up.right.fill",
                        count: post.repostCount,
                        label: "Reposts",
                        color: .green
                    )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
        .background(Color.white)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Post")
        .preferredColorScheme(.light)
    }
    
    private func sharePost() {
        let textToShare = "\(post.owner.nickname): \(post.textContent)"
        let activityViewController = UIActivityViewController(
            activityItems: [textToShare],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityViewController, animated: true)
        }
    }
}

struct StatView: View {
    let icon: String
    let count: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(count)
                    .font(.custom(TextFonts.instrumentSansSemiBold.rawValue, size: 18))
                    .foregroundColor(.black)
            }
            
            Text(label)
                .font(.custom(TextFonts.interRegular.rawValue, size: 14))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 15)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.05))
        )
    }
}

struct ActionButton: View {
    let icon: String
    let label: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title3)
                
                Text(label)
                    .font(.custom(TextFonts.interMedium.rawValue, size: 16))
            }
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.gray.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }
}

#Preview {
    NavigationStack {
        PostDetailView(post: Post(
            textContent: "🚀 $MAI is absolutely crushing it today! The community behind this AI meme token is incredible. Just hit a new ATH and the momentum is building. Who else is riding this wave? #MAI #AI #Crypto #MemeToken",
            impressionCount: "562",
            likeCount: "5",
            repostCount: "0",
            postTime: "2h",
            owner: Post.Owner(
                nickname: "kwx7xdol5cc7",
                avatar: Post.Owner.Avatar(url: "https://example.com/avatar.jpg")
            ),
            images: nil
        ))
    }
}
