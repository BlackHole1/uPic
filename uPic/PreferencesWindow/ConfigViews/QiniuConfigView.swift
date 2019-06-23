//
//  QiniuConfigView.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/23.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa

class QiniuConfigView: NSView {

    var data: QiniuHostConfig = QiniuHostConfig()

    var domainField: NSTextField!

    var configSheetController: ConfigSheetController!
    
    override func viewWillDraw() {
        super.viewWillDraw()
        // Do view setup here.
        
        configSheetController = (self.window?.contentViewController?.storyboard!.instantiateController(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ConfigSheetController").rawValue)
            as! ConfigSheetController)
        
        self.createView()
    }

    init(frame frameRect: NSRect, data: HostConfig?) {
        super.init(frame: frameRect)

        if data != nil {
            self.data = data as! QiniuHostConfig
        }

    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        if configSheetController != nil {
            configSheetController.removeFromParent()
        }
    }


    func createView() {

        let paddingTop = 50, paddingLeft = 6, gapTop = 10, gapLeft = 5, labelWidth = 75, labelHeight = 20,
            viewWidth = Int(self.frame.width), viewHeight = Int(self.frame.height),
            textFieldX = labelWidth + paddingLeft + gapLeft, textFieldWidth = viewWidth - paddingLeft - textFieldX

        var y = viewHeight - paddingTop
        
        // MARK: Region
        let regionLabel = NSTextField(labelWithString: "\(self.data.displayName(key: "region")):")
        regionLabel.frame = NSRect(x: paddingLeft, y: y, width: labelWidth, height: labelHeight)
        regionLabel.alignment = .right
        regionLabel.lineBreakMode = .byClipping
        
        let regionButtonPopUp = NSPopUpButton(frame: NSRect(x: textFieldX, y: y, width: textFieldWidth, height: labelHeight))
        regionButtonPopUp.target = self
        regionButtonPopUp.action = #selector(regionChange(_:))
        regionButtonPopUp.identifier = NSUserInterfaceItemIdentifier(rawValue: "region")
        
        var selectRegion: NSMenuItem?
        for region in QiniuRegion.allCases {
            let menuItem = NSMenuItem(title: region.name, action: nil, keyEquivalent: "")
            menuItem.identifier = NSUserInterfaceItemIdentifier(rawValue: region.rawValue)
            regionButtonPopUp.menu?.addItem(menuItem)
            
            if data.region == region.rawValue {
                selectRegion = menuItem
            }
        }
        if selectRegion != nil {
            regionButtonPopUp.select(selectRegion)
        }
        
        self.addSubview(regionLabel)
        self.addSubview(regionButtonPopUp)
        

        // MARK: Bucket
        y = y - gapTop - labelHeight
        let bucketLabel = NSTextField(labelWithString: "\(self.data.displayName(key: "bucket")):")
        bucketLabel.frame = NSRect(x: paddingLeft, y: y, width: labelWidth, height: labelHeight)
        bucketLabel.alignment = .right
        bucketLabel.lineBreakMode = .byClipping

        let bucketField = NSTextField(frame: NSRect(x: textFieldX, y: y, width: textFieldWidth, height: labelHeight))
        bucketField.identifier = NSUserInterfaceItemIdentifier(rawValue: "bucket")
        bucketField.delegate = self.data
        bucketField.stringValue = self.data.bucket ?? ""
        self.addSubview(bucketLabel)
        self.addSubview(bucketField)

        // MARK: AccessKey
        y = y - gapTop - labelHeight

        let accessKeyLabel = NSTextField(labelWithString: "\(self.data.displayName(key: "accessKey")):")
        accessKeyLabel.frame = NSRect(x: paddingLeft, y: y, width: labelWidth, height: labelHeight)
        accessKeyLabel.alignment = .right
        accessKeyLabel.lineBreakMode = .byClipping

        let accessKeyField = NSTextField(frame: NSRect(x: textFieldX, y: y, width: textFieldWidth, height: labelHeight))
        accessKeyField.identifier = NSUserInterfaceItemIdentifier(rawValue: "accessKey")
        accessKeyField.delegate = self.data
        accessKeyField.stringValue = self.data.accessKey ?? ""
        self.addSubview(accessKeyLabel)
        self.addSubview(accessKeyField)


        // MARK: Password
        y = y - gapTop - labelHeight

        let secretKeyLabel = NSTextField(labelWithString: "\(self.data.displayName(key: "secretKey")):")
        secretKeyLabel.frame = NSRect(x: paddingLeft, y: y, width: labelWidth, height: labelHeight)
        secretKeyLabel.alignment = .right
        secretKeyLabel.lineBreakMode = .byClipping

        let secretKeyField = NSTextField(frame: NSRect(x: textFieldX, y: y, width: textFieldWidth, height: labelHeight))
        secretKeyField.identifier = NSUserInterfaceItemIdentifier(rawValue: "secretKey")
        secretKeyField.delegate = self.data
        secretKeyField.stringValue = self.data.secretKey ?? ""
        self.addSubview(secretKeyLabel)
        self.addSubview(secretKeyField)


        // MARK: domain
        y = y - gapTop - labelHeight
        let settingsBtnWith = 40

        let domainLabel = NSTextField(labelWithString: "\(self.data.displayName(key: "domain")):")
        domainLabel.frame = NSRect(x: paddingLeft, y: y, width: labelWidth, height: labelHeight)
        domainLabel.alignment = .right
        domainLabel.lineBreakMode = .byClipping

        let domainField = NSTextField(frame: NSRect(x: textFieldX, y: y, width: textFieldWidth - settingsBtnWith, height: labelHeight))
        domainField.identifier = NSUserInterfaceItemIdentifier(rawValue: "domain")
        domainField.delegate = self.data
        domainField.stringValue = self.data.domain ?? ""
        self.domainField = domainField

        let settingsBtn = NSButton(title: "", image: NSImage(named: NSImage.advancedName)!, target: self, action: #selector(openConfigSheet(_:)))
        settingsBtn.frame = NSRect(x: textFieldX + Int(domainField.frame.width) + gapLeft, y: y, width: settingsBtnWith, height: labelHeight)
        settingsBtn.imagePosition = .imageOnly

        self.addSubview(domainLabel)
        self.addSubview(domainField)
        self.addSubview(settingsBtn)
    }

    func addObserver() {
        PreferencesNotifier.addObserver(observer: self, selector: #selector(saveHostSettings), notification: PreferencesNotifier.Notification.saveHostSettings)
    }


    func removeObserver() {
        PreferencesNotifier.removeObserver(observer: self, notification: .saveHostSettings)
        PreferencesNotifier.addObserver(observer: self, selector: #selector(saveHostSettings), notification: .saveHostSettings)
    }

    @objc func openConfigSheet(_ sender: NSButton) {
        let userInfo: [String: Any] = ["domain": self.data.domain ?? "", "folder": self.data.folder ?? "", "saveKey": self.data.saveKey ?? HostSaveKey.dateFilename.rawValue]
        self.window?.contentViewController?.presentAsSheet(configSheetController)
        configSheetController.setData(userInfo: userInfo as [String: AnyObject])
        self.addObserver()

    }

    @objc func saveHostSettings(notification: Notification) {
        guard let userInfo = notification.userInfo else {
            print("No userInfo found in notification")
            return
        }

        self.data.domain = userInfo["domain"] as? String ?? ""
        self.data.folder = userInfo["folder"] as? String ?? ""
        self.data.saveKey = userInfo["saveKey"] as? String ?? HostSaveKey.dateFilename.rawValue

        domainField.stringValue = self.data.domain!
    }
    
    @objc func regionChange(_ sender: NSPopUpButton) {
        if let menuItem = sender.selectedItem, let identifier = menuItem.identifier?.rawValue {
            self.data.region = identifier
        }
    }
}
