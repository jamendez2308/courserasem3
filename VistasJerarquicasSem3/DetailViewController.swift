//
//  DetailViewController.swift
//  VistasJerarquicasSem3
//
//  Created by Mendez, Arturo {LALA} on 08/09/16.
//  Copyright © 2016 Mendez, Arturo {LALA}. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var lblISBN: UILabel!
    @IBOutlet weak var lblDetTitulo: UILabel!
    @IBOutlet weak var imgDetPortada: UIImageView!
    @IBOutlet weak var tvAutores: UITableView!
    
    @IBOutlet var auts: NSArray!

    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let detail = self.detailItem {
            if let label = self.lblISBN {
                label.text = detail.valueForKey("isbn")!.description
            }
            if let label = self.lblDetTitulo{
                label.text = detail.valueForKey("titulo")!.description
            }
            if let img = self.imgDetPortada{
                img.image = UIImage(data: detail.valueForKey("img")! as! NSData)
            }
            self.auts = detail.valueForKey("autores")! as! NSArray
            //self.tvAutores.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.tvAutores.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.auts != nil){
            return (self.auts.count as Int)
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.tvAutores.dequeueReusableCellWithIdentifier("cell") as UITableViewCell!
        
        let aut = self.auts[indexPath.row] as! NSDictionary
        cell.textLabel?.text = aut["name"] as! NSString as String
        
        return cell
        
    }


}

