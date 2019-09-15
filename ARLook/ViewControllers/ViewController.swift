//
//  ViewController.swift
//  ARLook
//
//  Created by ChenWei on 2019/9/11.
//  Copyright © 2019 Jacob. All rights reserved.
//

import UIKit
import MetalKit
import SceneKit


class ViewController: UITableViewController {
    
    var collectionView: UICollectionView!
    // MARL: - View lifrcircle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.tableView.cellLayoutMarginsFollowReadableWidth = true
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.estimatedRowHeight = 90
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: self.view.frame.height / 5 - 40, height: self.view.frame.height / 5 - 40)
        layout.scrollDirection = .horizontal
        
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height / 5), collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register( UINib(nibName: "SceneCollectionViewCell", bundle: nil),  forCellWithReuseIdentifier: "SCNCell")
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
        self.collectionView.reloadData()
        self.collectionView.layoutSubviews()
        self.collectionView.layoutIfNeeded()
    }
    

    
    //MARK: - UITableViewDatasource methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : 5
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? self.collectionView.frame.height : 44
    }
    
    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
//        if indexPath.section == 0 {
//            return super.tableView(tableView, indentationLevelForRowAt: IndexPath(row: 0, section: 0))
//        }
//
//        if indexPath.section == 1 {
//            return super.tableView(tableView, indentationLevelForRowAt: IndexPath(row: 0, section: 1))
//        }
        return super.tableView(tableView, indentationLevelForRowAt: IndexPath(row: 0, section: indexPath.section))
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if ( indexPath.section == 0 ) {
            cell.addSubview(self.collectionView)
            cell.frame = self.collectionView.frame
        }
        return cell
    }

}


extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return SCNDataModel.shared.models.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SCNCell", for: indexPath) as! SceneCollectionViewCell
        cell.scnView.scene = SCNDataModel.shared.models[indexPath.section].scene
//        cell.imageView.image = SCNDataModel.shared.models[indexPath.section].image
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = ARViewController()
        vc.model = SCNDataModel.shared.models[indexPath.section].scene
        self.navigationController?.pushViewController(vc, animated: true)
    }


}


