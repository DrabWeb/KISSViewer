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
    
    // Used for storing the opened images when the user does multiples of them
    var openImages : [NSImage] = [NSImage()];
    
    // Used for scrolling through images while knowing where we are
    var currentImageIndex = 0;
    
    // Menu items
    
    // Float
    @IBOutlet weak var floatMenuItem: NSMenuItem!
    @IBAction func floatMenuItemTriggered(sender: AnyObject) {
        if(window.level == 250) {
            window.level = 0;
            floatMenuItem.state = 1;
        }
        else {
            window.level = 250;
            floatMenuItem.state = 0;
        }
    }
    
    // Click through
    @IBOutlet weak var clickThroughMenuItem: NSMenuItem!
    @IBAction func clickThroughMenuItemTriggered(sender: AnyObject) {
        if(window.ignoresMouseEvents) {
            window.ignoresMouseEvents = false;
            clickThroughMenuItem.state = 0;
        }
        else {
            window.ignoresMouseEvents = true;
            clickThroughMenuItem.state = 1;
        }
    }
    
    // Connect spaces
    @IBOutlet weak var connectSpacesMenuItem: NSMenuItem!
    @IBAction func connectSpacesMenuItemTriggered(sender: AnyObject) {
        if(window.collectionBehavior == NSWindowCollectionBehavior.CanJoinAllSpaces) {
            window.collectionBehavior = NSWindowCollectionBehavior.Default;
            connectSpacesMenuItem.state = 0;
        }
        else {
            window.collectionBehavior = NSWindowCollectionBehavior.CanJoinAllSpaces;
            connectSpacesMenuItem.state = 1;
        }
    }
    
    // Shadow
    @IBOutlet weak var shadowMenuItem: NSMenuItem!
    @IBAction func shadowMenuItemTriggered(sender: AnyObject) {
        if(window.hasShadow) {
            window.hasShadow = false;
            shadowMenuItem.state = 0;
        }
        else {
            window.hasShadow = true;
            shadowMenuItem.state = 1;
        }
    }
    
    // Clear background
    @IBOutlet weak var backgroundMenuItem: NSMenuItem!
    @IBAction func backgroundMenuItemTriggered(sender: AnyObject) {
        if(window.backgroundColor == NSColor.clearColor()) {
            window.backgroundColor = NSColor.whiteColor();
            visualEffectView.hidden = false;
            window.opaque = true;
            backgroundMenuItem.state = 0;
        }
        else {
            window.backgroundColor = NSColor.clearColor();
            visualEffectView.hidden = true;
            window.opaque = false;
            backgroundMenuItem.state = 1;
        }
    }
    
    // Next image
    @IBOutlet weak var nextImageMenuItem: NSMenuItem!
    @IBAction func nextImageMenuItemTriggered(sender: AnyObject) {
        print("Next image");
        
        // If we add 1 from currentImageIndex and its less than the amount of images we opened...
        if(currentImageIndex + 1 < openImages.count) {
            // Add 1 to currentImageIndex
            currentImageIndex++;
        }
        else {
            // Set currentImageIndex
            currentImageIndex = 0;
        }
        
        // Open the image we just changed to
        openImage(openImages[currentImageIndex], clearBackground: false, resize: false);
    }
    
    // Previous image
    @IBOutlet weak var previousImageMenuItem: NSMenuItem!
    @IBAction func previousImageMenuItemTriggered(sender: AnyObject) {
        print("Previous image");
        
        // If we remove 1 from currentImageIndex and its greater than or equal to 0...
        if(currentImageIndex - 1 >= 0) {
            // Subtract 1 from currentImageIndex
            currentImageIndex--;
        }
        else {
            // Set currentImageIndex to the length of the openImages array
            currentImageIndex = openImages.count - 1;
        }
        
        // Open the image we just changed to
        openImage(openImages[currentImageIndex], clearBackground: false, resize: false);
    }
    

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
            // Allow the open panel to allow multiple image selections
            openPanel.allowsMultipleSelection = true;
            
            // Set the open panels allowed file types to only images
            openPanel.allowedFileTypes = ["png", "tiff", "jpg", "gif", "jpeg"];
            
            // Show the open panel modal
            openPanel.runModal();
            
            // Print the URLs of the selected files, for debugging
            print(openPanel.URLs);
            
            print(openPanel.URLs.count);
            
            // If we selected multiple images...
            if(openPanel.URLs.count > 1) {
                // Create a variable to store the image array to load
                var images : [NSImage]! = [NSImage()];
                
                // Go through the URL of every selected file from the open panel
                for(var iterateUrls = 0; iterateUrls < openPanel.URLs.count; iterateUrls++) {
                    // Create the NSImage that we are going to show in the image view
                    var image : NSImage = NSImage(contentsOfURL: openPanel.URLs[iterateUrls])!;
                    
                    // Load the image at this URL and add it to the images array
                    images.append(image);
                }
                
                // For some reason the first image is null, lets remove it
                images.removeAtIndex(0);
                
                // Open the images
                openImages(images, clearBackground: false);
            }
            // If we only selected one image...
            else {
                // Disable the next and previous image menu items
                nextImageMenuItem.hidden = true;
                previousImageMenuItem.hidden = true;
                
                // Create the NSImage that we are going to show in the image view
                var image : NSImage = NSImage(contentsOfURL: openPanel.URLs[0])!;
                
                // Open the image
                openImage(image, clearBackground: false, resize: true);
            }
        }
    }
    
    // Opens the specified image, and it also makes the window background transparent if clearBackground is set to true. Also, if you set resize to false, it wont resize it
    func openImage(image : NSImage, clearBackground : Bool, resize : Bool) {
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
        
        // Store the current window height and origin for when we are doing multiple images
        var oldHeight = window.frame.height;
        var oldOrigin = window.frame.origin;
        
        // Set the window frame to match the image size
        window.setFrame(NSRect(x: 0, y: 0, width: image.size.width, height: image.size.height), display: false);
        
        // Set the window aspect ratio to the image size
        window.aspectRatio = NSSize(width: window.frame.width, height: window.frame.height);
        
        // If we dont want to resize...
        if(!resize) {
            // Get the aspect ratio of the image
            var aspectRatio = image.size.width / image.size.height;
            
            // Figure out what the width would be if we kept the aspect ratio and set the height to the windows old height
            var width = aspectRatio * oldHeight;
            
            // Set the windows frame tobe similar to the last one
            window.setFrame(NSRect(x: oldOrigin.x, y: oldOrigin.y, width: width, height: oldHeight), display: false);
            
        }
        
        // If we want to resize...
        if(resize) {
            // Center the window
            window.center();
        }
        
        // Order the window to the front
        window.makeKeyAndOrderFront(self);
    }
    
    // Opens the specified images, allows the user to scroll through them with the arrow keys, and it also makes the window background transparent if clearBackground is set to true
    func openImages(images : [NSImage], clearBackground : Bool) {
        print("Opening images...");
        // If we said to have a clear background...
        if(clearBackground == true) {
            // Set the window so it can be rendered transparent
            window.opaque = false;
            
            // Set the window background color to clear
            window.backgroundColor = NSColor.clearColor();
            
            // Hide the effect view
            visualEffectView.hidden = true;
        }
        
        // Set the openImages to the images we are opening
        openImages = images;
        
        openImage(openImages[0], clearBackground: clearBackground, resize: true);
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
        openImage(NSImage(contentsOfURL: imageURL)!, clearBackground: imageTransparent, resize: true);
        
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

