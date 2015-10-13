//
//  AppDelegate.swift
//  KISSViewer
//
//  Created by Seth Buxton on 2015-08-13.
//  Copyright (c) 2015 ZAE Games. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    // A reference to the main window, that displays the image
    @IBOutlet weak var window: NSWindow!
    
    // A reference to the image view
    @IBOutlet weak var imageView: NSImageView!
    
    // A reference to the visual effect view behind the image
    @IBOutlet weak var visualEffectView: NSVisualEffectView!
    
    // Does the window float?
    var windowFloat : Bool = false;
    
    // Does the window let us click through it?
    var windowClickThrough : Bool = false;
    
    // Does the window connect spaces?
    var windowConnectSpaces : Bool = false;
    
    // Does the window have a shadow?
    var windowShadow : Bool = true;

    // The modal that is shown when the user is opening an image
    var openPanel : NSOpenPanel = NSOpenPanel();

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        
        // Style the window
        styleWindow();
        
        // Check if the /tmp/kissviewer file exists, to see if we launched from the command line
        if(NSFileManager.defaultManager().fileExistsAtPath("/tmp/kissviewer")) {
            // Open the specified image with the options from /tmp/kissviewer
            openImageFromTmp();
        }
            // It isnt, use the usual GUI
        else {
            // Set the open panels allowed file types to only images
            openPanel.allowedFileTypes = ["png", "tiff", "jpg", "gif", "jpeg"];
            
            // Show the open panel modal
            openPanel.runModal();
            
            // Print the URl of the selected file, for debugging
            print(openPanel.URL!);
            
            // Create the NSImage that we are going to show in the image view
            var image : NSImage = NSImage(contentsOfURL: openPanel.URL!)!;
            
            // Open the image
            openImage(image, clearBackground: true);
        }
    }
    
    // Opens the specified image, and it also makes the window background transparent if clearBackground is set to true
    func openImage(image : NSImage, clearBackground : Bool) {
        // If we said to have a clear background...
        if(clearBackground == true) {
            // Set the window so it can be rendered transparent
            window.opaque = false;
            
            // Set the window background color to clear
            window.backgroundColor = NSColor.clearColor();
            
            // Hide the effect view
            visualEffectView.hidden = true;
        }
        
        // Set the image view image
        imageView.image = image;
        
        // Set the window frame to match the image size
        window.setFrame(NSRect(x: 0, y: 0, width: image.size.width, height: image.size.height), display: false);
        
        // Set the window aspect ratio to the image size
        window.aspectRatio = NSSize(width: window.frame.width, height: window.frame.height);
        
        // Center the window
        window.center();
        
        // Order the window to the front
        window.makeKeyAndOrderFront(self);
    }
    
    // Use this when we know that /tmp/kissviewer exists, meaning it was launched from the command line
    func openImageFromTmp() {
        // Load the text of the /tmp/ file that says what the image should be
        let location = "/tmp/kissviewer";
        let fileContent = try! String(contentsOfFile: location, encoding: NSUTF8StringEncoding);
            
        // Split the file contents on every new line
        // Line 1 == Image URL
        // Line 2 == Float
        // Line 3 == Click Through
        // Line 4 == Connect Spaces
        // Line 5 == Shadow
        // Line 6 == Window background transparent
        // Line 7 == Image size (1 being the original image size, so 0.5 would be half ETC)
        let imageViewSettings : [NSString] = fileContent.characters.split{$0 == "\n"}.map(String.init);
        
        // Setup the variables for displaying
        let imageURL : NSURL = NSURL(fileURLWithPath: imageViewSettings[0] as String);
        let imageFloat : Bool = boolFromString(imageViewSettings[1] as String);
        let imageClickThrough : Bool = boolFromString(imageViewSettings[2] as String);
        let imageConnectSpaces : Bool = boolFromString(imageViewSettings[3] as String);
        let imageShadow : Bool = boolFromString(imageViewSettings[4] as String);
        let imageTransparent : Bool = boolFromString(imageViewSettings[5] as String);
        let imageScale : CGFloat = CGFloat(imageViewSettings[6].floatValue);
        
        // Load the settings
        
        // Window float
        if(imageFloat) {
            window.level = 250;
        }
        
        // Window click through
        window.ignoresMouseEvents = imageClickThrough;
        
        // Window connect spaces
        if(imageConnectSpaces) {
            window.collectionBehavior = NSWindowCollectionBehavior.CanJoinAllSpaces;
        }
        
        // Window shadow
        window.hasShadow = imageShadow;
        
        // Load the image
        openImage(NSImage(contentsOfURL: imageURL)!, clearBackground: imageTransparent);
        
        // Set the scale
        window.setFrame(NSRect(x: 0, y: 0, width: window.frame.width * imageScale, height: window.frame.height * imageScale), display: false);
        
        // Recenter the window
        window.center();
    }
    
    // Styles the window to be borderless and rounded
    func styleWindow() {
        // Get the close buttons superviews superview (The titlebar) and destroy it
        window.standardWindowButton(NSWindowButton.CloseButton)?.superview?.superview?.removeFromSuperview();
        
        if #available(OSX 10.11, *) {
            visualEffectView.material = NSVisualEffectMaterial.Popover;
        } else {
            // Fallback on earlier versions
            visualEffectView.material = NSVisualEffectMaterial.Light;
        };
    }
    
    // Turns a string into true if its text is "true" and false if "false"
    func boolFromString(string : String) -> Bool {
        if(string == "true") {
            return true;
        }
        else {
            return false;
        }
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
}

