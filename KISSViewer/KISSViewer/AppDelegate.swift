//
//  AppDelegate.swift
//  Borderless Image Viewer
//
//  Created by Seth Buxton on 2015-08-13.
//  Copyright (c) 2015 ZAE Games. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    // The window that is shown when the user wants to open a file
    @IBOutlet weak var openFileWindow: NSWindow!
    
    // The text field for the image path
    @IBOutlet weak var filePathField: NSTextField!
    
    // The color well for the image background color
    @IBOutlet weak var windowBackgroundColorWell: NSColorWell!
    
    // The checkbox for if the window should show the traffic lights
    @IBOutlet weak var windowControlsCheckbox: NSButton!
    
    // The checkbox for if the window should float above the others
    @IBOutlet weak var windowFloatsCheckbox: NSButton!
    
    // The checkbox for if the window should move to the active space
    @IBOutlet weak var windowJoinCheckbox: NSButton!
    
    // The checkbox for if the window should have a shadow
    @IBOutlet weak var windowShadowCheckbox: NSButton!
    
    // The checkbox for if the window should let users click through it
    @IBOutlet weak var windowClickThroughCheckbox: NSButton!
    
    // When the user clicks the open menu item or pressed CMD+O
    @IBAction func openMenuItemTriggered(sender: AnyObject) {
        // Prompt to open a file
        promptToOpen();
    }
    
    // When the user clicks the Browse button in the open file panel
    @IBAction func browseButtonPressed(sender: AnyObject) {
        // Open the modal
        openPanel.runModal();
        
        // If the URL isnt nil...
        if(openPanel.URL != nil) {
            // Set the file path field value to the url we selected. We first remove file:// , and then we replace %20 with " "
            filePathField.stringValue = openPanel.URL!.absoluteString!.substringWithRange(Range<String.Index>(start: advance(openPanel.URL!.absoluteString!.startIndex, 7), end: advance(openPanel.URL!.absoluteString!.endIndex, 0))).stringByReplacingOccurrencesOfString("%20", withString: " ", options: NSStringCompareOptions.LiteralSearch, range: nil);
        }
    }
    
    // When the open button in the openFileWinodw is pressed...
    @IBAction func openButtonPressed(sender: AnyObject) {
        // Hide the open file window
        openFileWindow.orderOut(self);
        
        // Initialize variables for all the window options
        
        // Shows traffic lights
        var windowControlsState : Bool = false;
        
        // Float
        var windowFloatsState : Bool = false;
        
        // Moveto active space
        var windowJoinState : Bool = false;
        
        // Shadow
        var windowShadowState : Bool = false;
        
        // Can click through
        var windowClickThroughState : Bool = false;
        
        // Set all the bools to there respective values, based on the checkbox state
        
        if(windowControlsCheckbox.state == 1) {
            // Its on, set it to true
            windowControlsState = true;
        }
        else {
            // Its off, set it to false
            windowControlsState = false;
        }
        
        if(windowFloatsCheckbox.state == 1) {
            // Its on, set it to true
            windowFloatsState = true;
        }
        else {
            // Its off, set it to false
            windowFloatsState = false;
        }
        
        if(windowJoinCheckbox.state == 1) {
            // Its on, set it to true
            windowJoinState = true;
        }
        else {
            // Its off, set it to false
            windowJoinState = false;
        }
        
        if(windowShadowCheckbox.state == 1) {
            // Its on, set it to true
            windowShadowState = true;
        }
        else {
            // Its off, set it to false
            windowShadowState = false;
        }
        
        if(windowClickThroughCheckbox.state == 1) {
            // Its on, set it to true
            windowClickThroughState = true;
        }
        else {
            // Its off, set it to false
            windowClickThroughState = false;
        }
        
        // Create new image viewer window with or variables
        createNewViewer(filePathField.stringValue, windowControls: windowControlsState, floats: windowFloatsState, joins: windowJoinState, shadow: windowShadowState, clickThrough: windowClickThroughState, bgColor: windowBackgroundColorWell.color);
    }
    
    // An array of all the opened windows
    var windowArray : [NSWindow] = [NSWindow](count: 0, repeatedValue: NSWindow());
    
    // An array of all the opened image views
    var imageViewArray : [NSImageView] = [NSImageView](count: 0, repeatedValue: NSImageView());
    
    // The current window we are opening
    var currentWindow : Int = 0;
    
    // A temp variable to temporaroly store our new image view
    var newImage : NSImage = NSImage();
    
    // The modal that is shown when the user is opening an image
    var openPanel : NSOpenPanel = NSOpenPanel();
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        // Hide the file open window
        openFileWindow.orderOut(self);
        
        // Set the open panels allowed file types to only images
        openPanel.allowedFileTypes = ["png", "tiff", "jpg", "gif", "jpeg"];
        
        // Allow the user to input a color with an alpha value
        NSColorPanel.sharedColorPanel().showsAlpha = true;
    }
    
    // Prompts the user to open an image
    func promptToOpen() {
        // Center the open file window
        openFileWindow.center();
        
        // Make the open file window key and in front
        openFileWindow.makeKeyAndOrderFront(self);
    }
    
    // Creates a new image viewer window
    // url (String): The path to the image to open
    // windowControls (Bool): Should the window show the traffic lights?
    // floats (Bool): Should the iwndow float above the others?
    // joins (Bool): Should the window move to the active space?
    // shadow (Bool): Shoudl the window have a shadow?
    // clickThrough (Bool): Can the user click through the window?
    // bgColor (NSColor): The color to put for parts of the image that are transparent
    func createNewViewer(url : String, windowControls : Bool, floats : Bool, joins : Bool, shadow : Bool, clickThrough : Bool, bgColor : NSColor) {
        
        // If the url is on a server (Starts with http)
        if(url.substringWithRange(Range<String.Index>(start: advance(url.startIndex, 0), end: advance(url.startIndex, 4))) == "http") {
            // Load it as an online image
            
            // Create the new NSImage to hold our image we are loading
            newImage = NSImage(contentsOfURL: NSURL(string: url)!)!;
        }
        else {
            // Load it as a regular image
            
            // Create the new NSImage to hold our image we are loading
            newImage = NSImage(contentsOfURL: NSURL(fileURLWithPath: url)!)!;
        }
        
        // Add a new NSImageView to the array, to show the NSImage
        imageViewArray.append(NSImageView(frame: NSRect(x: 0, y: 0, width: newImage.size.width, height: newImage.size.height)));
        
        // Set the new image view's image to our new image we are loading
        imageViewArray[currentWindow].image = newImage;
        
        // Set the image view resizing mask so it matches the width and height of the window
        imageViewArray[currentWindow].autoresizingMask = NSAutoresizingMaskOptions.ViewHeightSizable | NSAutoresizingMaskOptions.ViewWidthSizable;
        
        // Set the NSImageView scaling to Axes Independent
        imageViewArray[currentWindow].imageScaling = NSImageScaling.ImageScaleAxesIndependently;
        
        // If we want to show the traffic lights...
        if(windowControls) {
            // Create a new window with traffic lights
            windowArray.append(NSWindow(
                contentRect: NSScreen.mainScreen()!.frame,
                styleMask: NSTitledWindowMask | NSFullSizeContentViewWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask | NSResizableWindowMask,
                backing: NSBackingStoreType.Buffered,
                defer: false)
            );
        }
        // If we dont want to show traffic lights...
        if(!windowControls) {
            // Create a new window
            windowArray.append(NSWindow(
                contentRect: NSScreen.mainScreen()!.frame,
                styleMask: NSTitledWindowMask | NSFullSizeContentViewWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask | NSResizableWindowMask,
                backing: NSBackingStoreType.Buffered,
                defer: false)
            );
            
            // Hide the close button
            var closeButton : NSButton = windowArray[currentWindow].standardWindowButton(NSWindowButton.CloseButton)!;
            closeButton.hidden = true;
            
            // Hide the minimize button
            var minimizeButton : NSButton = windowArray[currentWindow].standardWindowButton(NSWindowButton.MiniaturizeButton)!;
            minimizeButton.hidden = true;
            
            // Hide the zoom button
            var maximizeButton : NSButton = windowArray[currentWindow].standardWindowButton(NSWindowButton.ZoomButton)!;
            maximizeButton.hidden = true;
        }
        
        // If we said to floa tthe window...
        if(floats) {
            // Set its level to 200, it floats above EVERYTHING
            windowArray[currentWindow].level = 200;
        }
        
        println(joins);
        // If we said for the window to move tp the active space...
        if(joins) {
            println("Joining");
            // Set the collection behaviour to can join all spaces
            windowArray[currentWindow].collectionBehavior = NSWindowCollectionBehavior.CanJoinAllSpaces;
        }
        
        // If we said not to have a shadow...
        if(!shadow) {
            // Disable the shadow
            windowArray[currentWindow].hasShadow = false;
        }
        
        // If we said to let us click through...
        if(clickThrough) {
            // Let us click ttough
            windowArray[currentWindow].ignoresMouseEvents = true;
        }
        
        // Set the window size to the image size in pixels
        windowArray[currentWindow].setFrame(NSRect(x: 0, y: 0, width: newImage.size.width, height: newImage.size.height), display: false);
        
        // Get the file extension
        var imageNameAndExtension : String = url.lastPathComponent;
        var imageNameAndExtensionSplit : [String] = split(imageNameAndExtension){$0 == "."}
        var imageExtension : String = imageNameAndExtensionSplit[imageNameAndExtensionSplit.count - 1];
        
        // If its not a GIF...
        if(imageExtension != "gif") {
            // Set the max size to 2x
            windowArray[currentWindow].contentMaxSize = NSSize(width: newImage.size.width * 2, height: newImage.size.height * 2);
        }
        else {
            // It is a gif, make the window unsizable
            windowArray[currentWindow].contentMinSize = NSSize(width: newImage.size.width, height: newImage.size.height);
            windowArray[currentWindow].contentMaxSize = NSSize(width: newImage.size.width, height: newImage.size.height);
        }
        
        // Make the window participate in the window cycling
        windowArray[currentWindow].collectionBehavior |= NSWindowCollectionBehavior.ParticipatesInCycle;
        
        // Set the window aspect ratio to that of the image, so we can scale the window nicely
        windowArray[currentWindow].contentAspectRatio = NSSize(width: newImage.size.width, height: newImage.size.height);
        
        // Add the image view to the window view
        windowArray[currentWindow].contentView.addSubview(imageViewArray[currentWindow]);
        
        // Hide the titlebar
        windowArray[currentWindow].titlebarAppearsTransparent = true;
        
        // Set the window to be transparent
        windowArray[currentWindow].opaque = false;
        
        // Let the window be moved by its background (BROKEN)
        windowArray[currentWindow].movableByWindowBackground = true;
        
        // Set the winddow background color
        windowArray[currentWindow].backgroundColor = bgColor;
        
        // Center the window
        windowArray[currentWindow].center();
        
        //Make the new window key
        windowArray[currentWindow].makeKeyAndOrderFront(nil);
        
        // Add 1 to currentWindow
        currentWindow += 1;
    }
    
    // Changes the image of the given imageView, and resizes the parent window to fit
    // imageView (NSImageView): the image view to change the image of
    // url (String): The URL to the new image
    // window (NSWindow): The window that the image view is in
    func changeImage(imageView : NSImageView, url : String, window : NSWindow) {
        // If the url is on a server (Starts with http)
        if(url.substringWithRange(Range<String.Index>(start: advance(url.startIndex, 0), end: advance(url.startIndex, 4))) == "http") {
            // Load it as an online image
            
            // Create the new NSImage to hold our image we are loading
            newImage = NSImage(contentsOfURL: NSURL(string: url)!)!;
        }
        else {
            // Load it as a regular image
            
            // Create the new NSImage to hold our image we are loading
            newImage = NSImage(contentsOfURL: NSURL(fileURLWithPath: url)!)!;
        }
        
        // Set the new image view's image to our new image we are loading
        imageView.image = newImage;
        
        // Set the window size to the image size in pixels
        window.setFrame(NSRect(x: 0, y: 0, width: newImage.size.width, height: newImage.size.height), display: false);
        
        // Get the file extension
        var imageNameAndExtension : String = url.lastPathComponent;
        var imageNameAndExtensionSplit : [String] = split(imageNameAndExtension){$0 == "."}
        var imageExtension : String = imageNameAndExtensionSplit[imageNameAndExtensionSplit.count - 1];
        
        // If its not a GIF...
        if(imageExtension != "gif") {
            // Set the max size to 2x
            windowArray[currentWindow].contentMaxSize = NSSize(width: newImage.size.width * 2, height: newImage.size.height * 2);
        }
        else {
            // It is a gif, make the window unsizable
            window.contentMinSize = NSSize(width: newImage.size.width, height: newImage.size.height);
            window.contentMaxSize = NSSize(width: newImage.size.width, height: newImage.size.height);
        }
        
        // Set the window aspect ratio to that of the image, so we can scale the window nicely
        window.contentAspectRatio = NSSize(width: newImage.size.width, height: newImage.size.height);
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
}

