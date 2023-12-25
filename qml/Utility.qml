import QtQuick 2.0
import Flow 1.0

QtObject {
    function deepCopy(obj) {
        return JSON.parse(JSON.stringify(obj))
    }

    function getFileExtension(filePath) {
      // Get the last index of the dot character
      const dotIndex = filePath.lastIndexOf('.');

      // If the dot is not found or it's the last character, return an empty string
      if (dotIndex === -1 || dotIndex === filePath.length - 1) {
        return '';
      }

      // Extract the file extension using substring
      const extension = filePath.substring(dotIndex + 1);

      // Convert the extension to lowercase (optional)
      const lowercaseExtension = extension.toLowerCase();

      return lowercaseExtension;
    }

    // 返回指定文件的大小（字节数）
    function getFileSize(filePath) {
        return QmlUtility.getFileSize(filePath)
    }

    function isImageFile(extension) {
        if (extension === "png" || extension === "jpg" || extension === "jpeg" || extension === "bmp") {
            return true
        } else {
            return false
        }
    }

    function isVideoFile(extension) {
        if (extension === "mp4" || extension === "avi") {
            return true
        } else {
            return false
        }
    }
}
