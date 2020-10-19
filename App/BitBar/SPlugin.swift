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

//  func buildMenuItemForLine(line: String) -> NSMenuItem {
//
//
//  }
//
//  func buildMenuItemWithParams(params: Dictionary<String, Any>) -> NSMenuItem {
//
//  }
//
//  func dictionaryForLine(line: String) -> Dictionary<String, Any> {
//
//  }
//
  func rebuildMenuForStatusItem(statusItem: NSStatusItem) {
    
  
  }
  
  func addAdditionalMenuItems(menu: NSMenu) {
    
  }
  
  func addDefaultMenuItems(menu: NSMenu) {
    
    self.manager.addHelperItems(to: menu, asSubMenu: menu.items.count>0)
  }
  
  func performRefreshNow() {
    
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
  
  
}
