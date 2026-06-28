import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

        if let bestAttemptContent = bestAttemptContent {
            // Modify the notification content here...
            
            // Check for image URL in payload (fcm_options.image or your custom key)
            // FCM sends image in 'fcm_options' -> 'image', but sometimes in data
            let userInfo = request.content.userInfo
            
            var imageUrlString: String?
            
            // Try to find image in standard FCM location
            if let fcmOptions = userInfo["fcm_options"] as? [String: Any],
               let image = fcmOptions["image"] as? String {
                imageUrlString = image
            } 
            // Fallback to 'image' or 'image_url' in data
            else if let image = userInfo["image"] as? String {
                imageUrlString = image
            } else if let image = userInfo["image_url"] as? String {
                imageUrlString = image
            }

            if let imageUrlString = imageUrlString, let url = URL(string: imageUrlString) {
                downloadImage(from: url) { attachment in
                    if let attachment = attachment {
                        bestAttemptContent.attachments = [attachment]
                    }
                    contentHandler(bestAttemptContent)
                }
            } else {
                contentHandler(bestAttemptContent)
            }
        }
    }
    
    private func downloadImage(from url: URL, completion: @escaping (UNNotificationAttachment?) -> Void) {
        let task = URLSession.shared.downloadTask(with: url) { (downloadedUrl, response, error) in
            guard let downloadedUrl = downloadedUrl else {
                completion(nil)
                return
            }
            
            // Move file to a location with correct extension
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let urlPath = URL(fileURLWithPath: path)
            let uniqueName = ProcessInfo.processInfo.globallyUniqueString
            let fileExtension = url.pathExtension.isEmpty ? "jpg" : url.pathExtension
            let destinationUrl = urlPath.appendingPathComponent("\(uniqueName).\(fileExtension)")
            
            try? FileManager.default.moveItem(at: downloadedUrl, to: destinationUrl)
            
            do {
                let attachment = try UNNotificationAttachment(identifier: uniqueName, url: destinationUrl, options: nil)
                completion(attachment)
            } catch {
                completion(nil)
            }
        }
        task.resume()
    }

    override func serviceExtensionTimeWillExpire() {
        if let contentHandler = contentHandler, let bestAttemptContent = bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
}
