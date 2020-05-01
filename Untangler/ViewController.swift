//
//  ViewController.swift
//  Untangler
//
//  Created by Jin Lee on 2020-04-29.
//  Copyright © 2020 Jin Lee. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var currentLevel = 0
    var connections = [ConnectionView]() //object that manages a rectangular area on the screen - array
    let renderedLines = UIImageView()
    
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        
        renderedLines.translatesAutoresizingMaskIntoConstraints = false//remove this autoresizig mask to constraints property in imageviews so that we can manually situate the image on the screen ourselves
        view.addSubview(renderedLines)//adds rendered lines to the end of recievers list of subviews
        
        NSLayoutConstraint.activate([ //activate the contraints on the image view so that it has the ability to go anywhere in the bounds of the screen
            renderedLines.topAnchor.constraint(equalTo: view.topAnchor),//view.topanchor is the top edge of the screen
            renderedLines.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            renderedLines.leftAnchor.constraint(equalTo: view.leftAnchor),
            renderedLines.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        view.backgroundColor = .darkGray//make the view's background color dark grey
        levelUp() // this function places the dots on the screen 
    }

    func levelUp() {
        currentLevel += 1 //we start at first level
        
        connections.forEach {$0.removeFromSuperview()}//$0 is the first parameter passed into closure - foreach is a forloop alternative - THIS FUNCTION REMOVES ALL OF THE SUBVIEWS FROM THE subview - foreach is an array attribute that allows for the iteration of all items in the array
       /* same as -> for view in connections.view.subviews {
            view.removerFromSuperview()
        }*/
        
        connections.removeAll()
        //level 1 will have 5 dragable dots
        for _ in 1...(currentLevel + 4){
            let connection = ConnectionView(frame: CGRect(origin: .zero, size: CGSize(width:44, height: 44)))//CGRect is the struct that creates a location and dimensions of the rectangle - origin is 0 and size is/ CGSize is struct that contains width and height of rectangle
            connection.backgroundColor = .white //UIColor.white
            connection.layer.cornerRadius = 22 //corner radius gives rounded corners and since the view is width and height is 44, 22 corner radius will make the rectangle a circle
            connection.layer.borderWidth = 2
            connections.append(connection )//append to the connections array
            view.addSubview(connection)// adds a view to the end of the recievers list of subviews - so for each of the 5 loops it adds a view to the screen - which is essentially a dot
            
            connection.dragChanged = {[weak self] in
                self?.redrawLines() //this redraws lines for all the newly positioned connection views  - weak self avoids retain cycles
            }
            connection.dragFinished = {[weak self] in
                    self?.checkMove()
            }
            
            
        }
        for i in 0 ..< connections.count{ //less thamn connections.count
            if i == connections.count - 1 { // if last connection - create a linked list from last connection to first connection
                connections[i].after = connections[0]
            }else{
                connections[i].after = connections[i+1]
            }
        }
        
        repeat {
            connections.forEach(place)
        } while levelClear() //repeat until there is at least one cross
         //call place method once for each of our connections
        
        redrawLines()//to place the lines as soon as the program loads 
    }
    
    //places the views "dots" in random areas in the screen
    func place(_ connection: ConnectionView) {
        let randomX = CGFloat.random(in: 20...view.bounds.maxX - 20)//pick a random x coordinate in the bounds
        let randomY = CGFloat.random(in: 50...view.bounds.maxY - 50)
        //pick a random y coordinate in the bounds
        connection.center = CGPoint(x: randomX, y:randomY)//places the UIview in the correct coordinates on the screen
        
    }
    func redrawLines(){
        let renderer = UIGraphicsImageRenderer(bounds: view.bounds)//creating core graphics backed images
        
        renderedLines.image = renderer.image { ctx in
            for connection in connections { //this allows us to draw lines
                var isLineClear = true
                //using an embeded loop we can compare the one line with another line
                for other in connections{
                    if linesCross(start1: connection.center, end1: connection.after.center, start2: other.center, end2: other.after.center) != nil {
                        isLineClear = false
                        break
                    }
                }
                if isLineClear {
                    UIColor.green.set()
                }else {
                    UIColor.red.set()
                }
                
                ctx.cgContext.strokeLineSegments(between: [connection.after.center, connection.center])//cg context is a 2d drwing environment - strokelinesegment draws a line between the center of the after to the current connection
            }
        }
    }

    func linesCross(start1: CGPoint, end1: CGPoint, start2: CGPoint, end2: CGPoint) -> (x: CGFloat, y: CGFloat)? {
        // calculate the differences between the start and end X/Y positions for each of our points
        let delta1x = end1.x - start1.x
        let delta1y = end1.y - start1.y
        let delta2x = end2.x - start2.x
        let delta2y = end2.y - start2.y

        // create a 2D matrix from our vectors and calculate the determinant
        let determinant = delta1x * delta2y - delta2x * delta1y

        if abs(determinant) < 0.0001 {
            // if the determinant is effectively zero then the lines are parallel/colinear
            return nil
        }

        // if the coefficients both lie between 0 and 1 then we have an intersection
        let ab = ((start1.y - start2.y) * delta2x - (start1.x - start2.x) * delta2y) / determinant

        if ab > 0 && ab < 1 {
            let cd = ((start1.y - start2.y) * delta1x - (start1.x - start2.x) * delta1y) / determinant

            if cd > 0 && cd < 1 {
                // lines cross – figure out exactly where and return it
                let intersectX = start1.x + ab * delta1x
                let intersectY = start1.y + ab * delta1y
                return (intersectX, intersectY)
            }
        }

        // lines don't cross
        return nil
    }
    
    func levelClear() -> Bool {
        //iterate through all connections and see if there is any crossing 
        for connection in connections {
            for other in connections {
                if linesCross(start1: connection.center, end1: connection.after.center, start2: other.center, end2: other.after.center) != nil {
                    return false
                }
            }
        }
        return true
    }
    
    func checkMove() {
        if levelClear() {
            view.isUserInteractionEnabled = false
            UIView.animate(withDuration: 0.5, delay: 1, animations: {
                self.renderedLines.alpha = 0
                
                for connection in self.connections {
                    connection.alpha = 0 //transparent
                }
                
            }) {finished in
                self.view.isUserInteractionEnabled = true
                self.renderedLines.alpha = 1
                self.levelUp()
                
            } }else {
            
        }
    }
}

