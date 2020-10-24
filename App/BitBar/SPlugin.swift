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
  var lastUpdated: Date = Date()
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
    
    
    if NSFont.responds(to: Selector(("monospacedDigitSystemFont:ofSize:weight:"))) {
      
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
    
    let args: NSArray = params["args"] 

    
    terminal = (terminal != nil) ? terminal : "true"
 
    
//      NSString *bash = [params[@"bash"] stringByStandardizingPath].stringByResolvingSymlinksInPath,
//             *param1 = params[@"param1"] ?: @"",
//             *param2 = params[@"param2"] ?: @"",
//             *param3 = params[@"param3"] ?: @"",
//             *param4 = params[@"param4"] ?: @"",
//             *param5 = params[@"param5"] ?: @"",
//           *terminal = params[@"terminal"] ?: [NSString stringWithFormat:@"%s", "true"];
//      NSArray *args = params[@"args"] ?: ({
//
//        NSMutableArray *argArray = @[].mutableCopy;
//        for (int i = 1; i < 6; i ++) {
//          id x = params[[NSString stringWithFormat:@"param%i", i]];
//          if (x) [argArray addObject:x];
//        }
//        argArray.copy;
//
//      });
//
//      if([terminal isEqual: @"false"]){
//        NSLog(@"Args: %@", args);
//        [params setObject:bash forKey:@"bash"];
//        [params setObject:args forKey:@"args"];
//        [self performSelectorInBackground:@selector(startTask:) withObject:params];
//      } else {
//
//        NSString *full_link = [NSString stringWithFormat:@"'%@' %@ %@ %@ %@ %@", bash, param1, param2, param3, param4, param5];
//        NSString *s = [NSString stringWithFormat:@"tell application \"Terminal\" \n\
//                   do script \"%@\" \n\
//                   activate \n\
//                   end tell", full_link];
//        NSAppleScript *as = [NSAppleScript.alloc initWithSource: s];
//        [as executeAndReturnError:nil];
//      }
  }

  @objc func performMenuItemOpenTerminalAction(menuItem: NSMenuItem) {
    
    self.performOpenTerminalAction(params: menuItem.representedObject as! NSMutableDictionary)
  }


  func buildMenuItemForLine(line: String) -> NSMenuItem? {

    return self.buildMenuItemWithParams(params: self.dictionaryForLine(line: line))
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

  func dictionaryForLine(line: String) -> Dictionary<String, Any> {
    
//    // Find the title
//    NSRange found = [line rangeOfString:@"|"];
//    if (found.location == NSNotFound) return @{ @"title": line };
//    NSString * title = [line substringToIndex:found.location];
//    NSMutableDictionary * params = @{@"title":title}.mutableCopy;
//
//    // Find the parameters
//    NSString * paramStr = [line substringFromIndex:found.location + found.length];
//
//    NSScanner* scanner = [NSScanner scannerWithString:paramStr];
//    NSMutableCharacterSet* keyValueSeparator = [NSMutableCharacterSet characterSetWithCharactersInString:@"=:"];
//    NSMutableCharacterSet* quoteSeparator = [NSMutableCharacterSet characterSetWithCharactersInString:@"\"'"];
//
//    while (![scanner isAtEnd]) {
//      NSString *key = @""; NSString* value = @"";
//      [scanner scanUpToCharactersFromSet:keyValueSeparator intoString:&key];
//      [scanner scanCharactersFromSet:keyValueSeparator intoString:NULL];
//
//      if ([scanner scanCharactersFromSet:quoteSeparator intoString:NULL]) {
//        [scanner scanUpToCharactersFromSet:quoteSeparator intoString:&value];
//        [scanner scanCharactersFromSet:quoteSeparator intoString:NULL];
//      } else {
//        [scanner scanUpToString:@" " intoString:&value];
//      }
//
//      // Remove extraneous spaces from key and value
//      key = [key stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//      value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//      params[key] = value;
//
//      if([key isEqualToString:@"args"]){
//        params[key] = [value componentsSeparatedByString:@"__"];
//      }
//    }
//
//    return params
    let params: Dictionary<String, Any> = [:]
    return params
  }

 
  
  func rebuildMenuForStatusItem(statusItem: NSStatusItem) {
    
  
  }
  
  func addAdditionalMenuItems(menu: NSMenu) {
    
  }
  
  func addDefaultMenuItems(menu: NSMenu) {
    
    self.manager.addHelperItems(to: menu, asSubMenu: menu.items.count>0)
  }
  
  @objc func performRefreshNow() {
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
}
