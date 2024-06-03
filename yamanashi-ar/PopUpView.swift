//
//  SwiftUIView.swift
//  asdasdfsdf
//
//  Created by Kyoya Yamaguchi on 2023/12/03.
//

import SwiftUI
import SceneKit

struct PopUpView: View {
    
    var siteInfo: SiteInfo
    
    private func starType(index: Int, rating: Double) -> String {
        let starNumber = Double(index) + 1
        if starNumber - 0.7 <= rating && rating < starNumber {
            return "star.leadinghalf.filled"
        } else if starNumber <= rating {
            return "star.fill"
        } else {
            return "star"
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                ZStack {
                    Image(siteInfo.iconType.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 80)
                        .foregroundColor(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                
                VStack(alignment: .leading) {
                    Text(siteInfo.name)
                        .foregroundStyle(.white)
                        .font(.system(size: 30))
                        .frame(maxWidth: .infinity)
                    Spacer()
                    HStack(spacing: 2) {
                        ForEach(0..<5, id: \.self) { index in
                            Image(systemName: starType(index: index, rating: siteInfo.rating))
                                .foregroundColor(.yellow)
                        }
                    }
                }
                .padding([.leading, .trailing, .top, .bottom], 10)
            }
            .frame(height: 80)
            .padding(16)
            .background(.black.opacity(0.95))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
    }
}

struct PopUpView_Preview: PreviewProvider {
    static var previews: some View {
        PopUpView(siteInfo: SiteInfo(iconType: .japanesefood, name: "Tokuei-ken Japanese-style Ramen", rating: 3.8, object: nil))
    }
}

enum IconType {
    case japanesefood
    case clothes
    case cafe
    case restaurant
    case museum
    case gift
    case eyes
    case hotel
    
    
    var imageName: String {
        switch self {
        case .japanesefood:
            return "japanese-food"
        case .clothes:
            return "clothes"
        case .cafe:
            return "cafe"
        case .restaurant:
            return "restaurant"
        case .museum:
            return "museum"
        case .gift:
            return "gift"
        case .eyes:
            return "eyes"
        case .hotel:
            return "hotel"
        }
    }
}

struct SiteInfo {
    var iconType: IconType
    var name: String
    var rating: Double
    var object: SiteObject?
}
