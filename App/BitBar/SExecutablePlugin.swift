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
    
    self.content = String.init(data: stdoutData, encoding: String.Encoding.utf8)
    self.errorContent = String.init(data: stderrData, encoding: String.Encoding.utf8)
    
    if task.terminationStatus != 0 {
      self.lastCommandWasError = true
      return false
    }
    
    self.lastCommandWasError = false
    return true
    
  }
  
    
}
