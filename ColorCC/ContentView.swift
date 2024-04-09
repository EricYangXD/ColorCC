//
//  ContentView.swift
//  ColorCC
//
//  Created by eric.yang on 2024.04.08.
//

import SwiftUI
import UniformTypeIdentifiers
import Cocoa


struct ContentView: View {
  @State private var selectedImage: NSImage?
//  @State private var isShowingImagePicker = false
  
  var body: some View {
      VStack {
          if let selectedImage = selectedImage {
              Image(nsImage: selectedImage)
                  .resizable()
                  .scaledToFit()
          } else {
              Text("选择一张图片")
          }

          // 只有在没有选择图片的情况下才显示打开图片按钮
          if selectedImage == nil {
              Button("打开图片") {
                  // 直接在这里调用 NSOpenPanel，并处理用户的选择
                  let panel = NSOpenPanel()
                  panel.message = "请选择文件"
                  panel.prompt = "选择"
                  panel.canChooseFiles = true
                  panel.canChooseDirectories = false
                  panel.allowsMultipleSelection = false
                  panel.canCreateDirectories = false
                  panel.allowedContentTypes = [UTType.png, UTType.jpeg, UTType.gif, UTType.bmp, UTType.rawImage]
                  
                  if panel.runModal() == .OK, let url = panel.url {
                      if let image = NSImage(contentsOf: url) {
                          self.selectedImage = image
                      }
                  }
              }
          }
      }
//      .sheet(isPresented: $isShowingImagePicker) {
//          FilePicker(selectedImage: $selectedImage)
////          .environmentObject(FilePicker.Coordinator(parent: FilePicker(selectedImage: $selectedImage)))
//      }
  }
  
}

//struct FilePicker: NSViewControllerRepresentable {
//    @Binding var selectedImage: NSImage?
//  
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//  
//    func makeNSViewController(context: Context) -> NSViewController {
//        let viewController = NSViewController()
//        context.coordinator.openPanel() // 调用 openPanel 方法
//        return viewController
//    }
//
//    func updateNSViewController(_ nsViewController: NSViewController, context: Context) {}
//  
//    class Coordinator: NSObject {
//          var parent: FilePicker
//
//          init(_ parent: FilePicker) {
//              self.parent = parent
//          }
//
//          func openPanel() {
//              let panel = NSOpenPanel()
//              panel.message = "请选择文件"
//              panel.prompt = "选择"
//              panel.canChooseFiles = true
//              panel.canChooseDirectories = false
//              panel.allowsMultipleSelection = false
//              panel.canCreateDirectories = false
//              panel.allowedContentTypes = [UTType.png, UTType.jpeg, UTType.gif, UTType.bmp, UTType.rawImage]
//              
//              panel.begin { (result) in
//                  if result == .OK, let url = panel.urls.first {
//                      self.handleImageURL(url)
//                  } else {
//                      print("用户取消了文件选择")
//                  }
//              }
//          }
//
//          private func handleImageURL(_ url: URL) {
//              if let image = NSImage(contentsOf: url) {
//                  DispatchQueue.main.async {
//                      self.parent.selectedImage = image
//                  }
//              }
//          }
//      }
//
//}

#Preview {
    ContentView()
}
