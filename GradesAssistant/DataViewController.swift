//
//  DataViewController.swift
//  GradesAssistant
//
//  Created by Ahmed Khattab on 8/27/19.
//  Copyright © 2019 AhmedKhattab. All rights reserved.
//

import UIKit

class DataViewController: NSObject {
    func getStudent(name :String ){
        var result = "error fetching data ..."
        let host = "https://codeails.com/ahmed_khatab/name%\(name)"
        let url = URL(string:host)
        if let url = url{
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url, completionHandler: {(data,respons,error) in
                if error == nil {
                    
                    do
                    {
                        if let jsonData = try JSONSerialization.jsonObject(with: data!, options: []) as? [String:Any]
                        {
                          result = "\(name) Grade is \( jsonData["Grade"]!) with age of \( jsonData["Age"]!).."
                        }
                        else
                        {
                            result = "There is no user with this name"

                        }
                        NotificationCenter.default.post(name: Notification.Name("getStudent"), object: nil, userInfo:["result":result])
                    }catch
                    {
                    }
                } else
                {
                   result = "error connecting to database.."
                    
                }
            })
          task.resume()
        }
    }
    
}
