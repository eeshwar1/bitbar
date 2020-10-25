//
//  SPlugin.swift
//  BitBar
//
//  Created by Venkateswaran Venkatakrishnan on 10/18/20.
//  Copyright © 2020 Bit Bar. All rights reserved.
//

import Foundation
import Cocoa

class SPlugin: NSObject, NSMenuDelegate {
  
  
//  @property (nonatomic)      NSInteger currentLine, cycleLinesIntervalSeconds;
//  @property (nonatomic)           BOOL lastCommandWasError, pluginIsVisible, menuIsOpen;
//  @property (readonly)            BOOL isMultiline;
//  @property (readonly)        NSString *lastUpdatedString;
//  @property (nonatomic, copy) NSString *path, *name, *content, *allContent, *errorContent;
//  @property (nonatomic)        NSArray *allContentLines;
//  @property (nonatomic)        NSArray *titleLines;
//  @property (nonatomic)       NSNumber *refreshIntervalSeconds;
//  @property (nonatomic)     NSMenuItem *lastUpdatedMenuItem;
//  @property (nonatomic)         NSDate *lastUpdated;
//  @property (weak, readonly)   PluginManager *manager;
//
//  // UI
//  @property (nonatomic) NSStatusItem *statusItem;
  var currentLine: Int = -1
  var cycleLinesIntervalSeconds: Int = 5
  var lastCommandWasError: Bool = false
  var pluginIsVisible: Bool = false
  var menuIsOpen: Bool = false
  var isMultiline: Bool = false
  var lastUpdatedString: String = ""
  var path: String = ""
  var name: String = ""
  var content: String = ""
  var allContent: String = ""
  var errorContent: String = ""
  var allContentLines: [Any] = []
  var titleLines: [Any] = []
  var refreshIntervalSeconds: NSNumber = 0
  var lastUpdatedMenuItem: NSMenuItem?
  var lastUpdated: Date?
  var manager: PluginManager = PluginManager()
  
  // UI
  var statusItem: NSStatusItem {
    
    get {
      let _statusItem =  self.manager.statusBar.statusItem(withLength: NSStatusItem.variableLength)
      self.rebuildMenuForStatusItem(statusItem: _statusItem)
      return _statusItem
    }
  }
  
  
//  - initWithManager:(PluginManager*)manager;
//  - (void) close;
//
//  - (NSMenuItem*) buildMenuItemForLine:(NSString *)line;
//  - (NSMenuItem*) buildMenuItemWithParams:(NSDictionary *)params;
//  - (NSDictionary *)dictionaryForLine:(NSString *)line;
//  - (void) rebuildMenuForStatusItem:(NSStatusItem*)statusItem;
//  - (void) addAdditionalMenuItems:(NSMenu *)menu;
//  - (void) addDefaultMenuItems:(NSMenu *)menu;
//
//  - (void) performRefreshNow;
//  - (BOOL) refresh;
//  - (void) cycleLines;
//  - (void) contentHasChanged;
//  - (BOOL) isFontValid:(NSString *)fontName;
// actions
//  - (void)changePluginsDirectorySelected:(id)sender;
  
  override init() {
    
    super.init()
    self.currentLine = -1
    self.cycleLinesIntervalSeconds = 5
    self.lastCommandWasError = false
    
  }

  init(withManager manager: PluginManager) {
   
    super.init()
    self.currentLine = -1
    self.cycleLinesIntervalSeconds = 5
    self.lastCommandWasError = false
    self.manager = manager
    
  }
  
  func close() {
    
  }

  func attributedTitleWithParams(params: NSDictionary) -> NSAttributedString {
    
    var fullTitle: NSString = params["title"] as! NSString
    let emojizeParam = params["emojize"] as! NSString
    if emojizeParam.lowercased == "false" {
      fullTitle = fullTitle.emojized()! as NSString
    }
    
    let trimParam : String = params["trim"] as! String
    
    if trimParam.lowercased() != "false" {
      fullTitle = fullTitle.trimmingCharacters(in: .whitespaces) as NSString
    }
    let titleLength: CGFloat = CGFloat(fullTitle.length)
    
    var lengthParam: CGFloat = titleLength
    
    if let paramLength = params["length"] {
        lengthParam = paramLength as! CGFloat
    }
    
    let truncLength: CGFloat = lengthParam >= titleLength ? titleLength: lengthParam
    
    let title: NSString = (truncLength < titleLength ? fullTitle.substring(to: Int(truncLength)) + "..." as NSString: fullTitle) as NSString
    
    
    var size: CGFloat = 14
    
    if let sizeParam = params["size"] {
      size = sizeParam as! CGFloat
    }
    
    let font: NSFont
    
    
    if NSFont.responds(to: #selector(NSFont.monospacedDigitSystemFont)) {
      
      font = self.isFontValid(fontName: params["font"] as? String) ? NSFont(name: params["font"] as! String, size: size)! : NSFont.monospacedDigitSystemFont(ofSize: size, weight: NSFont.Weight.regular)
    }
    else {
      
      font = self.isFontValid(fontName: params["font"] as? String) ? NSFont(name: params["font"] as! String, size: size)!: NSFont.menuFont(ofSize: size)
    }
  
    let attributes: [ NSAttributedString.Key: Any ] = [ .font: font, .baselineOffset: 0]
    
    let paramANSI = params["ansi"] as! String
    
    let parseANSI: Bool = fullTitle.containsANSICodes() && paramANSI.lowercased() == "false"
    
    if parseANSI {
      
      let attributedTitle: NSMutableAttributedString = title.attributedStringParsingANSICodes()
      attributedTitle.addAttributes(attributes, range: NSMakeRange(0, attributedTitle.length))
      
      return attributedTitle
    }
    else {
      
      let attributedTitle: NSMutableAttributedString = NSMutableAttributedString.init(string: title as String, attributes: attributes)
      
      if let fgColor = NSColor(webColorString: params.object(forKey: "color") as? String) {
      
        attributedTitle.addAttribute(.foregroundColor, value: fgColor, range: NSMakeRange(0, attributedTitle.length))
        
        return attributedTitle
      }
      else {
        return attributedTitle
      }
    }
    
  }
  
  
  func performHREFAction(params: NSDictionary) {
    
    let hrefParam = params["href"] as! String
    
    if let url = URL(string: hrefParam) {
      
      NSWorkspace.shared.open(url)
    }
    
  
  }

  @objc func performMenuItemHREFAction(menuItem: NSMenuItem) {

    self.performHREFAction(params: menuItem.representedObject as! NSDictionary)
  }
  
  func performOpenTerminalAction(params: NSMutableDictionary) {

    let bashParam = params["bash"] as! NSString
    let bashParamStd = bashParam.standardizingPath as NSString
    let bashParamStdSym = bashParamStd.resolvingSymlinksInPath as NSString
    
    let bash = bashParamStdSym
    
    var param1 = params["param1"] as? NSString
    var param2 = params["param2"] as? NSString
    var param3 = params["param3"] as? NSString
    var param4 = params["param4"] as? NSString
    var param5 = params["param5"] as? NSString
    var terminal = params["terminal"] as? String
    
    param1 = param1 != nil ? param1 : ""
    param2 = param2 != nil ? param2 : ""
    param3 = param3 != nil ? param3 : ""
    param4 = param4 != nil ? param4 : ""
    param5 = param5 != nil ? param5 : ""
    
    var args: NSArray = []
    
    if let argsArray = params["args"] as? NSArray {
      args = argsArray
    }
    else {
      let argArray :NSMutableArray = []
      
      for i in 1...6 {
        if let paramArg = params["param\(i)"] {
          argArray.add(paramArg)
        }
      }
      args = argArray
    }

    
    terminal = (terminal != nil) ? terminal : "true"
 
    if (terminal == "false") {
      NSLog("Args: \(args)")
      params.setObject(bash, forKey: "bash" as NSCopying)
      params.setObject(args, forKey: "args" as NSCopying)
      self.performSelector(inBackground: #selector(startTask), with: params)
    }
    else {
      
      let fullLink: NSString = "'\(bash)' \(param1!) \(param2!) \(param3!) \(param4!) \(param5!)" as NSString
      
      let s: NSString = """
      tell application \(terminal!) \n
        do script \(fullLink) \n
        activate
      end tell
      """ as NSString
      let appleScript: NSAppleScript = NSAppleScript(source: s as String)!
      appleScript.executeAndReturnError(nil)
      
    }
  }

  @objc func performMenuItemOpenTerminalAction(menuItem: NSMenuItem) {
    
    self.performOpenTerminalAction(params: menuItem.representedObject as! NSMutableDictionary)
  }


  func buildMenuItemForLine(line: String) -> NSMenuItem? {

    return self.buildMenuItemWithParams(params: self.dictionaryForLine(line: line as NSString))
  }

  func buildMenuItemWithParams(params: Dictionary<String, Any>) -> NSMenuItem? {
    
     let dropdownParam = params["dropdown"] as! NSString
    
    if dropdownParam.lowercased == "false" {
      return nil
    }
    
    var fullTitle: NSString = params["title"] as! NSString
    
    let emojizeParam = params["emojize"] as! NSString
    if emojizeParam.lowercased == "false" {
      fullTitle = fullTitle.emojized()! as NSString
    }
    
    let trimParam : String = params["trim"] as! String
    
    if trimParam.lowercased() != "false" {
      fullTitle = fullTitle.trimmingCharacters(in: .whitespaces) as NSString
    }
    
    let titleLength: CGFloat = CGFloat(fullTitle.length)
    
    var lengthParam: CGFloat = titleLength
    
    if let paramLength = params["length"] {
        lengthParam = paramLength as! CGFloat
    }
    
    let truncLength: CGFloat = lengthParam >= titleLength ? titleLength: lengthParam
    
    let title: NSString = (truncLength < titleLength ? fullTitle.substring(to: Int(truncLength)) + "..." as NSString: fullTitle) as NSString
    
    var sel: Selector? = nil
    
    if let _ = params["href"] as? NSString {
      sel = #selector(performMenuItemHREFAction)
    }
    else if let _ = params["bash"] as? NSString {
      sel = #selector(performMenuItemOpenTerminalAction)
    }
    else if let _ = params["refresh"] as? NSString {
      sel = #selector(performRefreshNow)
    }
  
    let item: NSMenuItem = NSMenuItem(title: title as String, action: sel, keyEquivalent: "")
    
    if (truncLength > titleLength) {
      item.toolTip = fullTitle as String
    }
    
    item.representedObject = params
    
    if sel != nil {
      item.target = self
    }
    
    let paramANSI = params["href"] as! String
    
    let parseANSI = fullTitle.containsANSICodes() &&  paramANSI.lowercased() != "false"
  
    let fontParam = params["font"] as? String
    let sizeParam = params["size"] as? String
    let colorParam = params["color"] as? String
    
    if fontParam != nil ||
       sizeParam != nil ||
       colorParam != nil ||
       parseANSI {
      item.attributedTitle = self.attributedTitleWithParams(params: params as NSDictionary)
        
      }
    
    if let _ = params["alternate"] as? String {
      item.isAlternate = true
      item.keyEquivalentModifierMask = .option
    }
    
    let templateImageParam = params["templateImage"] as? NSString
    let imageParam = params["image"] as? NSString
    
    if let templateImageParam = templateImageParam {
      
      item.image = self.createImageFromBase64(string: templateImageParam, isTemplate: true)
    }
    else if let imageParam = imageParam {
      item.image = self.createImageFromBase64(string: imageParam, isTemplate: false)
    }

    return item;

  }

  func dictionaryForLine(line: NSString) -> Dictionary<String, Any> {
    
    // Find the title
    let found: NSRange = line.range(of: "|")
    
    if found.location == NSNotFound {
      return ["title": line]
    }
    
    let title: NSString = line.substring(to: found.location) as NSString
    let params: NSMutableDictionary = ["title": title]
    
    // Find the parameters
    let paramStr: NSString = line.substring(from: found.location + found.length) as NSString
    
    let scanner: Scanner = Scanner(string: paramStr as String)
    let keyValueSeparator: NSMutableCharacterSet = NSMutableCharacterSet(charactersIn: "=:")
    let quoteSeparator = NSMutableCharacterSet(charactersIn: "\"'")
    
    while (!scanner.isAtEnd) {
      
      var key: NSString? = ""
      var value: NSString? = ""
      var dummyNULL: NSString? = ""
      
      scanner.scanUpToCharacters(from: keyValueSeparator as CharacterSet, into: &key)
      scanner.scanUpToCharacters(from: quoteSeparator as CharacterSet, into: &dummyNULL)
      
      if scanner.scanCharacters(from: quoteSeparator as CharacterSet, into: &dummyNULL) {
        
        scanner.scanUpToCharacters(from: quoteSeparator as CharacterSet, into: &value)
        scanner.scanCharacters(from: quoteSeparator as CharacterSet, into: &dummyNULL)
      }
      else {
        scanner.scanUpTo(" ", into: &value)
      }
      
      // Remove extraneous spaces from key and value
      key = (key?.trimmingCharacters(in: .whitespaces))! as NSString
      value = (value?.trimmingCharacters(in: .whitespaces))! as NSString
      
      params[key! as NSString] = value
    }

    return params as! Dictionary<String, Any>
  }

  func rebuildMenuForStatusItem(statusItem: NSStatusItem) {
    
    // build the menu
    let menu: NSMenu = NSMenu()
    menu.delegate = self
    
    if (self.isMultiline) {
      
      // put all content as an item
      if (self.titleLines.count > 1) {
        for line in self.titleLines {
          let item: NSMenuItem? = self.buildMenuItemForLine(line: line as! String)
          if let item = item {
            menu.addItem(item)
            
          }
         
          // add the separator
          menu.addItem(NSMenuItem.separator())
        }
        
        // are there any allContentLines ?
        
        if self.allContentLines.count > 0 {
          // put all content as an item
          
          for line in self.allContentLines {
            
            var lineStr = line as! NSString
            if lineStr == "---" {
              menu.addItem(NSMenuItem.separator())
            }
            else {
              var submenu: NSMenu = menu
              
              while lineStr.hasPrefix("--") {
                lineStr = lineStr.substring(from: 2) as NSString
                
                let lastItem: NSMenuItem = submenu.items.last!
                
                if lastItem.submenu == nil {
                  
                  lastItem.submenu = NSMenu()
                  lastItem.submenu?.delegate = self
                }
                
                submenu = lastItem.submenu!
                
                if lineStr == "---" {
                  break
                }
                
              }
              
              if lineStr == "---" {
                submenu.addItem(NSMenuItem.separator())
              }
              else {
                let item: NSMenuItem? = self.buildMenuItemForLine(line: lineStr as String)
                if let item = item {
                  submenu.addItem(item)
                }
              }
            }
            
          }
          menu.addItem(NSMenuItem.separator())
        }
      }
      
      if self.lastUpdated != nil {
        self.lastUpdatedMenuItem = NSMenuItem(title: "Updated just now", action: nil, keyEquivalent: "")
        menu.addItem(self.lastUpdatedMenuItem!)
      }
      
    
    }
    
    self.addAdditionalMenuItems(menu: menu)
    self.addDefaultMenuItems(menu: menu)
    
    // set the menu
    statusItem.menu = menu

  }
  
  func addAdditionalMenuItems(menu: NSMenu) {
    
  }
  
  func addDefaultMenuItems(menu: NSMenu) {
    
    self.manager.addHelperItems(to: menu, asSubMenu: menu.items.count>0)
  }
  
  @objc func performRefreshNow()
  {
    NSLog("Nothing to refresh in this plugin")
    
  }
  
  func refresh() {
   
  }
  
  func cycleLines() {
    
  }
  
  func contentHasChanged() {
    
    self.allContent = ""
    self.titleLines = []
    self.allContentLines = []
    
  }
  
  func isFontValid(fontName: String?) -> Bool {
    
    if fontName == fontName {
      return false
    }
    return true
  }
  
  func changePluginsDirectorySelected(sender: Any) {
    
    self.manager.path = nil
    self.manager.reset()
    
  }
  
  func createImageFromBase64(string: NSString, isTemplate template:Bool) -> NSImage? {
    
    let imageData: NSData? = NSData(base64Encoded: string as String, options: NSData.Base64DecodingOptions(rawValue: 0))
    
    var image: NSImage = NSImage()
    
    if let imageData = imageData {
      image = NSImage(data: imageData as Data) ?? NSImage()
    }
    
    return image

  }
  
  
  @objc func startTask(params: NSMutableDictionary) {
    
    let rootParam = params["root"] as! NSString
    
    let taskItem = rootParam == "true" ? STPrivilegedTask() : Process()
    
    let task = taskItem as! Process
    
    task.launchPath = params["bash"] as? String
    task.arguments = params["args"] as? [String]
    
    task.terminationHandler = { _ in
      if params["refresh"] != nil {
        self.performSelector(onMainThread: #selector(self.performRefreshNow), with: nil, waitUntilDone: false)
      }
      
      do {
        
        try task.run()
      }
      catch {
        
        print("Error launching command for \(String(describing: self.name)): CMD: \(String(describing: params["bash"]))  ARGS:\(String(describing: params["args"]))")
        
      }
      task.waitUntilExit()
    }
  }
    
}
