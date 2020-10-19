//
//  SExecutablePlugin.swift
//  BitBar
//
//  Created by Venkateswaran Venkatakrishnan on 10/17/20.
//  Copyright © 2020 Bit Bar. All rights reserved.
//

import Foundation
import Cocoa

class SExecutablePlugin: Plugin {
  
  var lineCycleTimer: Timer?
  var refreshTimer: Timer?
  
  func refreshContentByExecutingCommand() -> Bool {
    
    guard FileManager.default.fileExists(atPath: self.path) else
    {
      return false
      
    }
    
    let task = Process()
    task.environment = self.manager.environment
    task.launchPath = self.path
    task.useSystemProxies()
    
    
    let stdoutPipe = Pipe()
    task.standardOutput = stdoutPipe
    
    let stderrPipe = Pipe()
    task.standardError = stderrPipe
    
    do {
      try task.run()
    }
    catch {
      
     print("Error when running \(String(describing: self.name)):  \(error)")
      self.lastCommandWasError = true
      self.content = ""
      self.errorContent = error.localizedDescription
    
    }
    
    let stdoutData = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
    let stderrData = stderrPipe.fileHandleForReading.readDataToEndOfFile()
    
    task.waitUntilExit()
    
    self.content = String.init(data: stdoutData, encoding: String.Encoding.utf8)!
    self.errorContent = String.init(data: stderrData, encoding: String.Encoding.utf8)!
    
    // failure
    if task.terminationStatus != 0 {
      self.lastCommandWasError = true
      return false
    }
    
    // success
    self.lastCommandWasError = false
    return true
    
  }
  
  override func performRefreshNow() {

    self.content = "Updating ..."
    self.errorContent = ""
    self.rebuildMenu(for: self.statusItem)
    self.currentLine = -1
    self.cycleLines()
    self.manager.pluginDidUdpdateItself(self)
    let _ = self.refresh()
    
  }
    
  override func refresh() -> Bool {
    
    weak var weakSelf: SExecutablePlugin? = self
    self.lineCycleTimer?.invalidate()
    self.lineCycleTimer = nil
    self.refreshTimer?.invalidate()
    self.refreshTimer = nil

    // execute command
    
    DispatchQueue.global(qos: .default).async {
    
      let _ = weakSelf?.refreshContentByExecutingCommand()
      
      DispatchQueue.main.sync {
        
        if let strongSelf = weakSelf {
          strongSelf.lastUpdated = Date()
          
          strongSelf.rebuildMenu(for: strongSelf.statusItem)
          
          // reset the current line
          strongSelf.currentLine = -1
          
          // update the status item
          
          strongSelf.cycleLines()
          
          // sort out multi-line cycler
          if strongSelf.isMultiline {
            
         
            
            strongSelf.lineCycleTimer = Timer.scheduledTimer(timeInterval: Double(strongSelf.cycleLinesIntervalSeconds), target: strongSelf, selector: #selector(self.cycleLines), userInfo: nil, repeats: true)
            
            
            // tell the manager this plugin has updated
            strongSelf.manager.pluginDidUdpdateItself(strongSelf)
            
            // strongSelf next refresh
            strongSelf.refreshTimer = Timer.scheduledTimer(timeInterval: Double(truncating: strongSelf.refreshIntervalSeconds), target: strongSelf, selector: #selector(self.refresh), userInfo: nil, repeats: false)
        
         
          }
          
        }
      }
      
    }

    return true;
  }
  
  override func close() {
    
    self.lineCycleTimer?.invalidate()
    self.lineCycleTimer = nil
    self.refreshTimer?.invalidate()
    self.refreshTimer = nil
    
  }
  
  func copyOutput() {
    
    let valueToCopy: String = self.allContentLines[self.currentLine] as! String
    let pasteboard: NSPasteboard = NSPasteboard.general
    pasteboard.clearContents()
    pasteboard.writeObjects(NSArray.init(object: valueToCopy) as! [NSPasteboardWriting])

  }
  
  func copyAllOutput() {
    
    let pasteboard = NSPasteboard.general
    pasteboard.clearContents()
    pasteboard.writeObjects(NSArray.init(object: self.allContent as Any) as! [NSPasteboardWriting])
  }
  
  @objc func runPluginExternally() {
    
    let pathString: String = self.path.replacingOccurrences(of: " ", with: "\\\\ ")
    let script: String = """
        tell application \"Termainal\" \n\
      do script \"\(pathString)\" \n\
      activate \n\
      end tell
"""
    if let appleScript : NSAppleScript = NSAppleScript(source: script) {
      appleScript.executeAndReturnError(nil)
    }
  }
  
  func addAdditionalMenuItems(menu: NSMenu) {
    
      if UserDefaults.standard.userConfigDisabled == false {
        
        let runItem : NSMenuItem = NSMenuItem.init(title: "Run in Terminal...", action: #selector(self.runPluginExternally), keyEquivalent: "o")
        runItem.target = self
        menu.addItem(runItem)
      }
      
      
    }
    
}

