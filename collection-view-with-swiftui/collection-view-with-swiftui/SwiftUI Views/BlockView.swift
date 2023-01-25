//
//  BlockView.swift
//  collection-view-with-swiftui
//
//  Created by 김가영 on 2023/01/22.
//

import SwiftUI

struct BlockView: View {
    var title: String
    var description: String?
    
    var body: some View {
        
        HStack {
            VStack(alignment: .leading, spacing: 10) {
                
                Text(title)
                    .font(.title3)
                    .bold()
                    .foregroundColor(.white)
                if let description = description, !description.isEmpty {
                    Text(description)
                        .foregroundColor(.white)
                        .font(.callout)
                }
                
                Spacer()
            }
            Spacer()
        }
        .padding(10)
        .background(Color.black)
        .cornerRadius(5)
    }
}

struct BlockView_Previews: PreviewProvider {
    static var previews: some View {
        BlockView(title: "통합내역", description: "결제")
    }
}
