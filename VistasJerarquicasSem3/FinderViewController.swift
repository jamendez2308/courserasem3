//
//  FinderViewController.swift
//  VistasJerarquicasSem3
//
//  Created by Mendez, Arturo {LALA} on 08/09/16.
//  Copyright © 2016 Mendez, Arturo {LALA}. All rights reserved.
//

import UIKit
import CoreData


class FinderViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate{

    @IBOutlet weak var txtISBN: UITextField!
    @IBOutlet weak var lblTitulo: UILabel!
    @IBOutlet weak var imgPortada: UIImageView!
    @IBOutlet weak var tvAutores: UITableView!
    
    @IBOutlet var auts: NSArray!
    var managedObjectContext: NSManagedObjectContext? = nil
    var _fetchedResultsController: NSFetchedResultsController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.txtISBN.delegate = self
        self.tvAutores.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
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

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true);
        
        //Metodo sincrono
        let url1 = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:"
        let url2 = self.txtISBN.text!
        let urls = url1 + url2
        
        let url = NSURL(string: urls)
        let datos:NSData? = NSData(contentsOfURL: url!)
        
        do{
            let json = try NSJSONSerialization.JSONObjectWithData(datos!, options: NSJSONReadingOptions.MutableLeaves)
            //Validar json correcto
            if NSJSONSerialization.isValidJSONObject(json){
                let resp = json as! NSDictionary
                //Validar si el diccionario contiene elementos
                if resp.allKeys.count > 0 {
                    let book = resp["ISBN:" + self.txtISBN.text!] as! NSDictionary
                    //Aqui se recupera el titulo
                    self.lblTitulo.text = book["title"] as! NSString as String
                    
                    //Aqui se recupera la portada segun especificaciones de Open Library https://openlibrary.org/dev/docs/api/covers
                    self.imgPortada.image = nil
                    if let url = NSURL(string: "http://covers.openlibrary.org/b/ISBN/" + self.txtISBN.text! + "-M.jpg") {
                        if let data = NSData(contentsOfURL: url) {
                            self.imgPortada.image = UIImage(data: data)
                        }
                    }
                    
                    //Aqui recuperamos la lista de autores
                    self.auts = book["authors"] as! NSArray
                    self.tvAutores.reloadData()
                    
                    let context = self._fetchedResultsController!.managedObjectContext
                    
                    let tblLibros = NSEntityDescription.insertNewObjectForEntityForName("Libros", inManagedObjectContext: context)
                    
                    // If appropriate, configure the new managed object.
                    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
                    tblLibros.setValue(self.txtISBN.text!, forKey: "isbn")
                    tblLibros.setValue(self.lblTitulo.text, forKey: "titulo")
                    tblLibros.setValue(UIImageJPEGRepresentation(self.imgPortada.image!, 1.0), forKey: "img")
                    tblLibros.setValue(self.auts, forKey: "autores")
                    
                    // Save the context.
                    do {
                        try context.save()
                    } catch {
                        abort()
                    }

                }
                else{
                    msgNoEncontrado()
                }
                
            }
            else{
                msgNoEncontrado()
            }
        }
        catch _ {
            let alert = UIAlertController(title: "Petición", message: "Error de comunicación!!!", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
        return false;
    }
    
    func msgNoEncontrado(){
        self.lblTitulo.text = ""
        self.imgPortada.image = nil
        self.auts = nil;
        self.tvAutores.reloadData()
        
        let alert = UIAlertController(title: "Busqueda", message: "ISBN No recuperado.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
