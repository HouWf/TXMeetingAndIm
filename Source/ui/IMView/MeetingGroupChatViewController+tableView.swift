//
//  MeetingGroupChatViewController+tableView.swift
//  TUIMeeting
//
//  Created by 候文福 on 2022/8/16.
//

import Foundation

class ChartBaseCell: UITableViewCell {
    
    lazy var avatarView: UIImageView = {
        let imgView = UIImageView()
        imgView.backgroundColor = .red
        return imgView
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 13)
        return label
    }()
    
    
    override var isSelected: Bool {
        didSet {
           
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        selectionStyle = .none
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CustomMsgViewCell : UITableViewCell {
        
    var msg = IMMsgModel(){
        didSet{
            
        }
    }
    
    override var isSelected: Bool {
        didSet {
           
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        selectionStyle = .none
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class EmoMsgViewCell : UITableViewCell {
    var msg = IMMsgModel(){
        didSet{
            
        }
    }
    override var isSelected: Bool {
        didSet {
           
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        selectionStyle = .none
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MeetingGroupChatViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let model = msgSource[indexPath.row]
//        if !model.message.contains("emo"){
            let cell = tableView.dequeueReusableCell(withIdentifier: "CustomMsgViewCell", for: indexPath)
            if let scell = cell as? CustomMsgViewCell {
//                scell.nameLabel.text = model.name
//                scell.msg = model.message
            }
            return cell
//        } else {
////            if model.message.contains("emo")
//            let cell = tableView.dequeueReusableCell(withIdentifier: "EmoMsgViewCell", for: indexPath)
//            if let scell = cell as? EmoMsgViewCell {
////                scell.nameLabel.text = model.name
////                scell.msg = model.message
//            }
//            return cell
//        }
        
    }
}
