//
//  ConnectionView.swift
//  Untangler
//
//  Created by Jin Lee on 2020-04-29.
//  Copyright © 2020 Jin Lee. All rights reserved.
//

import UIKit
//this is one of our views (circle)
//functionalities
//1. a closure when the thing is moved slightly
//2. a closure when the things finished dragging
//3. where they started touching the view - this is so that when a user is tapping and has skinny fingers, the dragging will start at the point of contact rather than the middle, becasue if it centralizes whenever we touch it would have a weird movage 
class ConnectionView: UIView {
    //closure declaration that is bascially self contained blocks of functionality
    var dragChanged: (() ->Void)?//accepts no parameters and returns nothings - this can be nil
    var dragFinished: (() ->Void)?
    
    var touchStartPos = CGPoint.zero //stores where the touch handle the user starts dragging from
    
    var after: ConnectionView!//this is always a view not nill - unwrapped 
    
    //figure out where touches begin before draggin happens- we override so that we can update a prebuilt function - inehritance vibes
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return } //firgure out where they touched - read the first touch
        let startPos = touch.location(in: self)//find where inside our view did they start tapping out of the 44 points
        touchStartPos = startPos //assign this to attribute
        
        
        //uikit measures from top left corner - we will be dragging around the centrer point of the circle so we want to find this centre and offset that
        touchStartPos.x -= frame.width / 2
        touchStartPos.y -= frame.height / 2
        
        transform = CGAffineTransform(scaleX: 1.15, y: 1.15) //make this view 15 percent bigger than normal - makes it obvisous what is being dragged around - when the circle is touched
        
        superview?.bringSubviewToFront(self)//bring our circle above all the other circles - self refers to the one that we are clicking on.
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return } //read the first touch
        let point = touch.location(in: superview)//figure out where we tapped - where did we drag TO
        
        center = CGPoint(x:point.x - touchStartPos.x, y:point.y - touchStartPos.y)//new center position
        dragChanged?()//kind of like a marker that indicates that there is a drag change
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        transform = .identity //every uiview has a transform property so .identity resets the uiview back to initial view 
        dragFinished?()//finished the drag functionality
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches,with: event)
    }

}
