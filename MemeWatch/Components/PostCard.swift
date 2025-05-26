import SwiftUI

struct PostCard: View {
    let post: Post
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                AsyncImage(url: URL(string: post.owner.avatar.url)) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                    } else if phase.error != nil {
                        Circle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 40, height: 40)
                    } else {
                        ProgressView()
                            .frame(width: 40, height: 40)
                    }
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(post.owner.nickname)
                        .font(.custom(TextFonts.instrumentSansSemiBold.rawValue, size: 16))
                        .foregroundColor(.black)
                    
                    Text(post.postTime)
                        .font(.custom(TextFonts.interRegular.rawValue, size: 12))
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.top, 12)
            
            Text(post.textContent)
                .font(.custom(TextFonts.interRegular.rawValue, size: 15))
                .foregroundColor(.black)
                .lineLimit(3)
                .padding(.horizontal, 12)
            
            HStack(spacing: 20) {
                HStack(spacing: 4) {
                    Image(systemName: "eye.fill")
                        .font(.system(size: 14))
                    Text(post.impressionCount)
                        .font(.custom(TextFonts.interMedium.rawValue, size: 14))
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 14))
                    Text(post.likeCount)
                        .font(.custom(TextFonts.interMedium.rawValue, size: 14))
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "arrowshape.turn.up.right.fill")
                        .font(.system(size: 14))
                    Text(post.repostCount)
                        .font(.custom(TextFonts.interMedium.rawValue, size: 14))
                }
            }
            .foregroundColor(.gray)
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
        .frame(width: 320)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }
}
