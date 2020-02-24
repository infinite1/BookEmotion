//
//  NotificationService.swift
//  NotificationServiceExtension
//
//  Created by Xinyu Sun on 9/2/20.
//  Copyright © 2020 Xinyu Sun. All rights reserved.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension
{
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
	var documentsUrl: URL {
		return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
	}

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void)
    {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

        if let bestAttemptContent = bestAttemptContent
        {
			// download book image and add it as notification attachment
            if let urlPath = request.content.userInfo["media-url"] as? String,

                let url = URL(string: urlPath)
            {
                let destination = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(url.lastPathComponent)
				
                do
                {
                    let data = try Data(contentsOf: url)
                    try data.write(to: destination)
					
					
                    let attachment = try UNNotificationAttachment(identifier: "",
                                                                  
                                                                  url: destination)

                    bestAttemptContent.attachments = [attachment]
                }
                catch
                {
                }
            }

            contentHandler(bestAttemptContent)
        }
    }
	

    override func serviceExtensionTimeWillExpire()
    {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent = bestAttemptContent
        {
            contentHandler(bestAttemptContent)
        }
    }
}
