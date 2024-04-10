//
//  ContentView.swift
//  ColorCC
//
//  Created by eric.yang on 2024.04.08.
//

import AppKit
import Cocoa
import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
  @State private var selectedImage: NSImage?
  @State private var selectedImageName: String = ""
  @State private var images: [URL] = []
  @State private var currentIndex: Int = 0
  @State private var showAlert = false
  @State private var allImagesInFolder: [NSImage] = []

  var body: some View {
    HStack {
      if selectedImage != nil {
        Button("上一张") {
          loadPreviousImage()
        }
      }

      Spacer()

      VStack {
        if let selectedImage = selectedImage {
          Image(nsImage: selectedImage)
            .resizable()
            .scaledToFit()

          Text(selectedImageName)
            .font(.caption)
            .padding(.top, 12)
        } else {
          Button("选择图片文件夹") {
            selectImage()
          }
        }

        // 浏览同一文件夹下的所有图片
        // 仅当 allImagesInFolder 不为空时显示 List
        if !allImagesInFolder.isEmpty {
          List(allImagesInFolder, id: \.self) { image in
            Image(nsImage: image)
              .resizable()
              .scaledToFit()
          }
        }

      }

      Spacer()

      if selectedImage != nil {
        Button("下一张") {
          loadNextImage()
        }
      }
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .alert(
      isPresented: $showAlert,
      content: {
        Alert(
          title: Text("提示"), message: Text(currentIndex == 0 ? "当前是第一张图片" : "当前是最后一张图片"),
          dismissButton: .default(Text("好")))
      })
  }

  // 1. 选择单张图片时既能预览该图片，同时也能浏览同一文件夹下的其他所有图片
  // 2. 选择文件夹时需要能浏览文件夹下的所有图片
  func selectImage() {
    let panel = NSOpenPanel()
    panel.prompt = "请选择单个文件夹或图片"
    panel.canChooseFiles = true
    panel.canChooseDirectories = true
    panel.allowsMultipleSelection = false
    panel.allowedFileTypes = ["png", "jpg", "jpeg", "tiff", "gif", "bmp"]

    panel.begin { (result) in
      if result == .OK, let url = panel.urls.first {

        if url.hasDirectoryPath {
          let folderURL = url.hasDirectoryPath ? url : url.deletingLastPathComponent()
          // 用户选择了文件夹
          // 在这里处理文件夹逻辑，比如列出所有图片文件等
          // 请求访问权限
          let accessGranted = folderURL.startAccessingSecurityScopedResource()
          // 记得在适当的时机调用 stopAccessingSecurityScopedResource() 来释放权限
          if accessGranted {
            defer {
              DispatchQueue.main.async {
                folderURL.stopAccessingSecurityScopedResource()
              }
            }
            self.loadImagesFromFolder(folderURL)
          } else {
            print("没有获得访问权限")
          }

        } else {
          // 用户选择了单个文件
          if let image = NSImage(contentsOf: url) {
            DispatchQueue.main.async {
              self.selectedImage = image
              self.selectedImageName = url.lastPathComponent  // 获取文件名
            }
          }
          // 加载同一文件夹下的其他图片
          let folderURL = url.deletingLastPathComponent()
          loadImagesFromFolderForFile(folderURL)
        }
      }
    }
  }

  func loadImagesFromFolderForFile(_ folderURL: URL) {
    let fileManager = FileManager.default
    do {
      // 访问文件夹中的所有项目
      let items = try fileManager.contentsOfDirectory(
        at: folderURL, includingPropertiesForKeys: nil)

      // 过滤出图片文件并加载它们
      let imageFiles = items.filter {
        $0.pathExtension.lowercased().matches("png|jpg|jpeg|tiff|gif|bmp")
      }
      var images: [NSImage] = []
      for file in imageFiles {
        if let image = NSImage(contentsOf: file) {
          images.append(image)
        }
      }
      DispatchQueue.main.async {
        self.allImagesInFolder = images
      }
    } catch {
      print("Error loading images from folder: \(error)")
    }
  }

  // 加载图片所在文件夹的所有图片
  private func loadImagesFromFolder(_ folderURL: URL) {
    do {
      let fileURLs = try FileManager.default.contentsOfDirectory(
        at: folderURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
      images = fileURLs.filter { $0.isImage }
      if !images.isEmpty {
        currentIndex = 0
        tryLoadImage(at: images[currentIndex])
      }
    } catch {
      print("Error loading images from folder: \(error)")
    }
  }

  private func tryLoadImage(at url: URL) {
    do {
      let imageData = try Data(contentsOf: url)
      if let image = NSImage(data: imageData) {
        selectedImage = image
        selectedImageName = url.lastPathComponent
      } else {
        print("无法从数据加载图像")
      }
    } catch {
      print("加载图像失败: \(error.localizedDescription)")
    }
  }

  private func loadPreviousImage() {
    if currentIndex > 0 {
      currentIndex -= 1
      tryLoadImage(at: images[currentIndex])
    } else {
      showAlert = true
    }
  }

  private func loadNextImage() {
    if currentIndex < images.count - 1 {
      currentIndex += 1
      tryLoadImage(at: images[currentIndex])
    } else {
      showAlert = true
    }
  }
}

extension URL {
  var isImage: Bool {
    let imageExtensions = ["jpg", "jpeg", "png", "gif", "bmp"]
    return imageExtensions.contains(self.pathExtension.lowercased())
  }
}

extension String {
  func matches(_ regex: String) -> Bool {
    return self.range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}

#Preview {
  ContentView()
}
