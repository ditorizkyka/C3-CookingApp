//
//  EditInstructionRow.swift
//  CookingApp
//
//  Created by Andito Rizkyka Rianto on 07/06/26.
//

import SwiftUI

struct EditInstructionRow: View {
    var body: some View {
        VStack(alignment: .leading) {
            HStack() {
                Button {
                    print("deleted group ingredients")
                } label: {
                    Image(systemName: AppIcon.minusFill)
                        .foregroundStyle(Color.actionDelete!)
                }
                
                HStack {
                    Text("1")
                        .font(.footnote)
                               .foregroundColor(.black)
                             
                               .frame(width: 20, height: 20)
                               
                               .background(Color.brandSecondary)
                               
                               .clipShape(Circle())
                    Text("Blender bawang merah, lengkuas, air dan serai sampai halus.")
                        .font(.body)
                    
                }
                
                Spacer()
                
                Image(systemName: AppIcon.line3Horizontal)
                    .font(.body)
                    .foregroundStyle(Color.labelLight!)
                   
               
            }
            
            PhotoPickerHStack()
                .padding(.leading,50)
        }
        .padding(.horizontal,10)
        
        
    }
}

struct PhotoPickerHStack: View {
  
    @State private var selectedImage: Image? = Image("image_preview")

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            
            HStack(spacing: 16) {
                ZStack(alignment: .topTrailing) {
                    
                    (selectedImage ?? Image(systemName: "person.crop.circle.fill"))
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.gray)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    if selectedImage != nil {
                        Button(action: {
                            withAnimation {
                                selectedImage = nil
                            }
                        }) {
                            Image(systemName: "minus")
                                .font(.caption2.bold())
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.red)
                                .clipShape(Circle())
                        }
                        .offset(x: 10, y: -10)
                    }
                }
                .frame(width: 100, height: 100)
                
                Button(action: {
                    print("Tombol Tambah Foto ditekan")
                }) {
                    VStack(spacing: 8) {
                        ZStack(alignment: .bottomTrailing) {
                            Image(systemName: "photo")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                            
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                                .foregroundColor(.gray)
                                .background(Color.white)
                                .clipShape(Circle())
                                .offset(x: 5, y: 5)
                        }
                        
                        Text("Tambah Foto")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(width: 100, height: 100)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray, style: StrokeStyle(lineWidth: 1, dash: [5]))
                    )
                }
                .buttonStyle(.plain)
            
                
            }
     
            .padding(.top, 12)
            .padding(.trailing, 12)
            .padding(.bottom, 8)
            .padding(.leading, 4)
        }
        
    }
}

//// MARK: - Preview
//struct PhotoPickerHStack_Previews: PreviewProvider {
//    static var previews: some View {
//        ZStack {
//            // Background abu-abu muda seperti di gambar agar kotak putih terlihat menonjol
//            Color(UIColor.secondarySystemBackground).ignoresSafeArea()
//            PhotoPickerHStack()
//        }
//    }
//}

#Preview {
    EditInstructionRow()
}
